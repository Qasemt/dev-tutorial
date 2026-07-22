cat > set_network.sh << 'EOF'
#!/bin/bash
# ============================================================
# set_network.sh - Network Configuration for Buildroot
#
# Usage:
#   bash set_network.sh
#
# Features:
#   - Interactive menu (Static IP or DHCP)
#   - Works on Buildroot (BusyBox compatible)
#   - Supports multiple interfaces
#   - Backs up current config
#   - Restarts network service
# ============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
print_header() {
    clear 2>/dev/null || echo ""
    echo "========================================="
    echo "  Network Configuration - Buildroot"
    echo "========================================="
    echo ""
}

print_error()   { echo -e "${RED}✖ $1${NC}"; }
print_success() { echo -e "${GREEN}✔ $1${NC}"; }
print_info()    { echo -e "${YELLOW}ℹ️  $1${NC}"; }
print_prompt()  { echo -e "${BLUE}🔧 $1${NC}"; }

# Check root
if [ "$(id -u)" -ne 0 ]; then
    print_error "Run as root: bash $0"
    exit 1
fi

# Detect network interfaces
detect_interfaces() {
    echo "Detecting network interfaces..."
    echo ""
    
    # Try different methods to list interfaces
    if command -v ip &>/dev/null; then
        INTERFACES=$(ip link show | grep -E "^[0-9]+:" | grep -v "lo:" | awk -F': ' '{print $2}')
    elif command -v ifconfig &>/dev/null; then
        INTERFACES=$(ifconfig -a | grep -E "^[a-z]" | grep -v "lo" | awk '{print $1}')
    else
        # Fallback to /sys
        INTERFACES=$(ls /sys/class/net/ | grep -v lo)
    fi
    
    if [ -z "$INTERFACES" ]; then
        print_error "No network interfaces found!"
        exit 1
    fi
    
    echo "Available interfaces:"
    echo ""
    
    # List interfaces with current IP
    i=1
    for iface in $INTERFACES; do
        # Get current IP
        if command -v ip &>/dev/null; then
            CURRENT_IP=$(ip addr show "$iface" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
        elif command -v ifconfig &>/dev/null; then
            CURRENT_IP=$(ifconfig "$iface" 2>/dev/null | grep "inet addr:" | awk -F': ' '{print $2}' | awk '{print $1}')
            [ -z "$CURRENT_IP" ] && CURRENT_IP=$(ifconfig "$iface" 2>/dev/null | grep "inet " | awk '{print $2}')
        fi
        
        # Get MAC address
        MAC=$(cat /sys/class/net/$iface/address 2>/dev/null)
        
        [ -z "$CURRENT_IP" ] && CURRENT_IP="Not configured"
        [ -z "$MAC" ] && MAC="Unknown"
        
        echo "  $i) $iface"
        echo "     IP:  $CURRENT_IP"
        echo "     MAC: $MAC"
        echo ""
        
        eval "IFACE_$i=$iface"
        i=$((i+1))
    done
    
    INTERFACE_COUNT=$((i-1))
}

# Get current gateway and DNS for backup
get_current_network_info() {
    CURRENT_GATEWAY=""
    CURRENT_DNS=""
    
    if command -v ip &>/dev/null; then
        CURRENT_GATEWAY=$(ip route show default 2>/dev/null | awk '{print $3}' | head -1)
    elif command -v route &>/dev/null; then
        CURRENT_GATEWAY=$(route -n 2>/dev/null | grep "^0.0.0.0" | awk '{print $2}' | head -1)
    fi
    
    # Try to get DNS from resolv.conf
    if [ -f /etc/resolv.conf ]; then
        CURRENT_DNS=$(grep "nameserver" /etc/resolv.conf 2>/dev/null | awk '{print $2}' | head -1)
    fi
}

# Validate IP address
validate_ip() {
    local ip=$1
    local stat=1
    
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Validate netmask (also accepts CIDR)
validate_netmask() {
    local mask=$1
    
    # Accept CIDR notation (8-32)
    if [[ $mask =~ ^[0-9]+$ ]] && [ "$mask" -ge 8 ] && [ "$mask" -le 32 ]; then
        # Convert CIDR to netmask
        local bits=$mask
        local netmask=""
        for i in 1 2 3 4; do
            if [ "$bits" -ge 8 ]; then
                netmask="${netmask}255."
                bits=$((bits-8))
            else
                local val=$((256 - 2**(8-bits)))
                netmask="${netmask}${val}."
                bits=0
            fi
        done
        NETMASK=${netmask%?}
        return 0
    fi
    
    # Validate full netmask format
    if [[ $mask =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        NETMASK=$mask
        return 0
    fi
    
    return 1
}

# Configure Static IP
configure_static() {
    echo ""
    print_header
    echo "  Configure Static IP"
    echo "========================================="
    echo ""
    
    # Get current IP as default suggestion
    if command -v ip &>/dev/null; then
        CURRENT_IP=$(ip addr show "$INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | head -1)
    fi
    [ -z "$CURRENT_IP" ] && CURRENT_IP="192.168.1.100"
    
    # IP Address
    while true; do
        echo -n "IP Address [$CURRENT_IP]: "
        read IP_ADDR
        [ -z "$IP_ADDR" ] && IP_ADDR=$CURRENT_IP
        if validate_ip "$IP_ADDR"; then
            break
        else
            print_error "Invalid IP address format. Use: 192.168.1.100"
        fi
    done
    
    # Netmask
    echo ""
    echo "Netmask format examples:"
    echo "  - CIDR: 24 (for 255.255.255.0)"
    echo "  - Full: 255.255.255.0"
    while true; do
        echo -n "Netmask [24]: "
        read NETMASK_INPUT
        [ -z "$NETMASK_INPUT" ] && NETMASK_INPUT="24"
        if validate_netmask "$NETMASK_INPUT"; then
            break
        else
            print_error "Invalid netmask. Use CIDR (24) or full format (255.255.255.0)"
        fi
    done
    
    # Gateway
    echo ""
    # Extract network from IP for default gateway
    DEFAULT_GW=$(echo "$IP_ADDR" | cut -d'.' -f1-3).1
    [ -n "$CURRENT_GATEWAY" ] && DEFAULT_GW=$CURRENT_GATEWAY
    
    while true; do
        echo -n "Gateway [$DEFAULT_GW]: "
        read GATEWAY
        [ -z "$GATEWAY" ] && GATEWAY=$DEFAULT_GW
        if validate_ip "$GATEWAY"; then
            break
        else
            print_error "Invalid gateway format. Use: 192.168.1.1"
        fi
    done
    
    # DNS
    echo ""
    DEFAULT_DNS="8.8.8.8"
    [ -n "$CURRENT_DNS" ] && DEFAULT_DNS=$CURRENT_DNS
    
    while true; do
        echo -n "Primary DNS [$DEFAULT_DNS]: "
        read DNS1
        [ -z "$DNS1" ] && DNS1=$DEFAULT_DNS
        if validate_ip "$DNS1"; then
            break
        else
            print_error "Invalid DNS format. Use: 8.8.8.8"
        fi
    done
    
    echo -n "Secondary DNS [8.8.4.4]: "
    read DNS2
    [ -z "$DNS2" ] && DNS2="8.8.4.4"
    
    # Confirm
    echo ""
    echo "========================================="
    echo "  Configuration Summary"
    echo "========================================="
    echo "  Interface: $INTERFACE"
    echo "  IP:        $IP_ADDR"
    echo "  Netmask:   $NETMASK"
    echo "  Gateway:   $GATEWAY"
    echo "  DNS1:      $DNS1"
    echo "  DNS2:      $DNS2"
    echo "========================================="
    echo ""
    echo -n "Apply this configuration? [Y/n]: "
    read CONFIRM
    
    case "$CONFIRM" in
        [Nn]|[Nn][Oo])
            print_info "Configuration cancelled."
            return 1
            ;;
        *)
            apply_static_config
            ;;
    esac
}

# Apply static configuration
apply_static_config() {
    print_info "Applying static IP configuration..."
    
    # Backup current resolv.conf
    if [ -f /etc/resolv.conf ]; then
        cp /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null
    fi
    
    # Configure DNS
    echo "# Generated by set_network.sh" > /etc/resolv.conf
    echo "nameserver $DNS1" >> /etc/resolv.conf
    [ -n "$DNS2" ] && [ "$DNS2" != "none" ] && echo "nameserver $DNS2" >> /etc/resolv.conf
    
    # Method 1: Using ip command (preferred)
    if command -v ip &>/dev/null; then
        print_info "Using ip command..."
        ip addr flush dev "$INTERFACE" 2>/dev/null
        ip addr add "$IP_ADDR/$NETMASK" dev "$INTERFACE" 2>/dev/null
        ip link set "$INTERFACE" up 2>/dev/null
        ip route add default via "$GATEWAY" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            print_success "Network configured with ip command"
        fi
    fi
    
    # Method 2: Using ifconfig (fallback)
    if command -v ifconfig &>/dev/null; then
        print_info "Using ifconfig command..."
        ifconfig "$INTERFACE" "$IP_ADDR" netmask "$NETMASK" up 2>/dev/null
        
        # Add route
        if command -v route &>/dev/null; then
            route add default gw "$GATEWAY" 2>/dev/null
        fi
        
        print_success "Network configured with ifconfig command"
    fi
    
    # Save configuration for persistence
    save_network_config
    
    # Test connection
    print_info "Testing network connection..."
    sleep 2
    
    if ping -c 2 -W 2 "$GATEWAY" >/dev/null 2>&1; then
        print_success "Gateway reachable: $GATEWAY"
        
        if ping -c 2 -W 2 "8.8.8.8" >/dev/null 2>&1; then
            print_success "Internet access: OK"
        else
            print_error "Gateway reachable but no internet access"
        fi
    else
        print_error "Cannot reach gateway. Check settings!"
        return 1
    fi
    
    return 0
}

# Configure DHCP
configure_dhcp() {
    echo ""
    print_header
    echo "  Configure DHCP"
    echo "========================================="
    echo ""
    echo -n "Use DHCP on $INTERFACE? [Y/n]: "
    read CONFIRM
    
    case "$CONFIRM" in
        [Nn]|[Nn][Oo])
            print_info "Configuration cancelled."
            return 1
            ;;
        *)
            apply_dhcp_config
            ;;
    esac
}

# Apply DHCP configuration
apply_dhcp_config() {
    print_info "Requesting DHCP lease..."
    
    # Clear existing IP
    if command -v ip &>/dev/null; then
        ip addr flush dev "$INTERFACE" 2>/dev/null
    elif command -v ifconfig &>/dev/null; then
        ifconfig "$INTERFACE" 0.0.0.0 2>/dev/null
    fi
    
    # Try udhcpc (BusyBox)
    if command -v udhcpc &>/dev/null; then
        print_info "Using udhcpc..."
        udhcpc -i "$INTERFACE" -q 2>/dev/null &
        sleep 3
        
        # Check if we got an IP
        if command -v ip &>/dev/null; then
            NEW_IP=$(ip addr show "$INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
        elif command -v ifconfig &>/dev/null; then
            NEW_IP=$(ifconfig "$INTERFACE" 2>/dev/null | grep "inet addr:" | awk -F': ' '{print $2}' | awk '{print $1}')
            [ -z "$NEW_IP" ] && NEW_IP=$(ifconfig "$INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}')
        fi
        
        if [ -n "$NEW_IP" ]; then
            print_success "Got IP from DHCP: $NEW_IP"
        else
            print_error "DHCP failed to get IP address"
            return 1
        fi
        
    # Try dhclient
    elif command -v dhclient &>/dev/null; then
        print_info "Using dhclient..."
        dhclient "$INTERFACE" 2>/dev/null
        sleep 2
        
        if command -v ip &>/dev/null; then
            NEW_IP=$(ip addr show "$INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
        fi
        
        if [ -n "$NEW_IP" ]; then
            print_success "Got IP from DHCP: $NEW_IP"
        else
            print_error "DHCP failed to get IP address"
            return 1
        fi
    else
        print_error "No DHCP client found! (udhcpc or dhclient required)"
        print_info "Falling back to static configuration..."
        configure_static
        return $?
    fi
    
    # Save DHCP configuration
    save_dhcp_config
    
    # Test connection
    sleep 1
    if ping -c 2 -W 2 "8.8.8.8" >/dev/null 2>&1; then
        print_success "Internet access: OK"
    else
        print_error "No internet access"
    fi
    
    return 0
}

# Save network config for persistence
save_network_config() {
    # Create a startup script that survives reboot
    cat > /etc/network.sh << SCRIPT
#!/bin/sh
# Network configuration - auto-generated by set_network.sh
ifconfig $INTERFACE $IP_ADDR netmask $NETMASK up 2>/dev/null
ip addr add $IP_ADDR/$NETMASK dev $INTERFACE 2>/dev/null
ip link set $INTERFACE up 2>/dev/null
ip route add default via $GATEWAY 2>/dev/null
route add default gw $GATEWAY 2>/dev/null
echo "nameserver $DNS1" > /etc/resolv.conf
[ -n "$DNS2" ] && [ "$DNS2" != "none" ] && echo "nameserver $DNS2" >> /etc/resolv.conf
SCRIPT
    
    chmod +x /etc/network.sh
    
    # Add to init scripts if possible
    if [ -d /etc/init.d ]; then
        cat > /etc/init.d/S99network << INIT
#!/bin/sh
# Network init script
case "\$1" in
    start)
        echo "Starting network..."
        /etc/network.sh
        ;;
    stop)
        echo "Stopping network..."
        ifconfig $INTERFACE down 2>/dev/null
        ;;
    restart)
        \$0 stop
        sleep 1
        \$0 start
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart}"
        exit 1
        ;;
esac
INIT
        chmod +x /etc/init.d/S99network
    fi
    
    print_success "Configuration saved for persistence"
}

# Save DHCP configuration
save_dhcp_config() {
    # Create startup script for DHCP
    cat > /etc/network.sh << SCRIPT
#!/bin/sh
# Network configuration - DHCP (auto-generated)
ifconfig $INTERFACE up 2>/dev/null
ip link set $INTERFACE up 2>/dev/null
udhcpc -i $INTERFACE 2>/dev/null &
SCRIPT
    
    chmod +x /etc/network.sh
    
    if [ -d /etc/init.d ]; then
        cat > /etc/init.d/S99network << INIT
#!/bin/sh
case "\$1" in
    start)
        echo "Starting network (DHCP)..."
        /etc/network.sh
        ;;
    stop)
        echo "Stopping network..."
        ifconfig $INTERFACE down 2>/dev/null
        ;;
    restart)
        \$0 stop
        sleep 1
        \$0 start
        ;;
esac
INIT
        chmod +x /etc/init.d/S99network
    fi
    
    print_success "DHCP configuration saved"
}

# Show current network status
show_status() {
    print_header
    echo "  Current Network Status"
    echo "========================================="
    echo ""
    
    # Show all interfaces
    for iface in $INTERFACES; do
        echo "  Interface: $iface"
        
        if command -v ip &>/dev/null; then
            IP=$(ip addr show "$iface" 2>/dev/null | grep "inet " | awk '{print $2}')
            [ -z "$IP" ] && IP="Not configured"
            echo "  IP: $IP"
        elif command -v ifconfig &>/dev/null; then
            IP=$(ifconfig "$iface" 2>/dev/null | grep "inet " | awk '{print $2}')
            [ -z "$IP" ] && IP="Not configured"
            echo "  IP: $IP"
        fi
        
        # Gateway
        if command -v ip &>/dev/null; then
            GW=$(ip route show default 2>/dev/null | awk '{print $3}')
            [ -n "$GW" ] && echo "  Gateway: $GW"
        fi
        
        echo ""
    done
    
    echo "========================================="
    echo ""
    echo -n "Press Enter to continue..."
    read
}

# Main menu
main_menu() {
    while true; do
        print_header
        echo "  1) Configure Static IP"
        echo "  2) Configure DHCP"
        echo "  3) Show Current Status"
        echo "  4) Exit"
        echo ""
        echo "========================================="
        echo -n "Select option [1-4]: "
        read OPTION
        
        case "$OPTION" in
            1)
                # Select interface
                select_interface
                get_current_network_info
                configure_static
                echo ""
                echo -n "Press Enter to continue..."
                read
                ;;
            2)
                select_interface
                configure_dhcp
                echo ""
                echo -n "Press Enter to continue..."
                read
                ;;
            3)
                show_status
                ;;
            4)
                echo ""
                print_success "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Choose 1-4"
                sleep 1
                ;;
        esac
    done
}

# Select interface
select_interface() {
    echo ""
    print_prompt "Select interface (1-$INTERFACE_COUNT): "
    read INTERFACE_NUM
    
    if [ "$INTERFACE_NUM" -ge 1 ] && [ "$INTERFACE_NUM" -le "$INTERFACE_COUNT" ] 2>/dev/null; then
        eval "INTERFACE=\$IFACE_$INTERFACE_NUM"
        print_success "Selected: $INTERFACE"
    else
        print_error "Invalid selection. Using first interface."
        INTERFACE=$INTERFACES
    fi
}

# ============================================================
# Main execution
# ============================================================

# Detect interfaces first
detect_interfaces
get_current_network_info

# If only one interface, use it automatically
if [ "$INTERFACE_COUNT" -eq 1 ]; then
    INTERFACE=$INTERFACES
    print_info "Only one interface found: $INTERFACE"
    echo ""
    echo -n "Configure this interface? [Y/n]: "
    read ANSWER
    
    case "$ANSWER" in
        [Nn]|[Nn][Oo])
            print_info "Exiting."
            exit 0
            ;;
        *)
            echo ""
            echo "1) Static IP"
            echo "2) DHCP"
            echo -n "Select [1-2]: "
            read TYPE
            
            case "$TYPE" in
                2)
                    configure_dhcp
                    ;;
                *)
                    configure_static
                    ;;
            esac
            
            echo ""
            echo -n "Press Enter to continue..."
            read
            exit 0
            ;;
    esac
fi

# Multiple interfaces - show menu
main_menu

exit 0
EOF

