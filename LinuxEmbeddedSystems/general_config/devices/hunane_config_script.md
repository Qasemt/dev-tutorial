# make script 
file script setup_proxy_locale
```
chmod +x setup_proxy_locale.sh
```
```bash
#!/bin/bash

# Function to display error messages and exit
function error_exit {
    echo "Error: $1" >&2
    exit 1
}

# --- 1. Optional Proxy Configuration ---
read -p "Do you want to configure a proxy? (y/N): " CONFIGURE_PROXY
if [[ "$CONFIGURE_PROXY" =~ ^[Yy]$ ]]; then
    # Prompt the user for proxy credentials
    read -p "Enter your proxy username: " PROXY_USER
    read -s -p "Enter your proxy password: " PROXY_PASS
    echo # Add a newline after password input

    # Proxy server details
    PROXY_SERVER="172.20.10.1"
    PROXY_PORT="3128"

    # Construct the proxy URL
    PROXY_URL="http://$PROXY_USER:$PROXY_PASS@$PROXY_SERVER:$PROXY_PORT"

    # Set proxy for APT
    echo "Acquire::http::Proxy \"$PROXY_URL\";" | sudo tee /etc/apt/apt.conf.d/95proxy || error_exit "Failed to set proxy for APT."

    # Set proxy for environment
    grep -q "http_proxy" /etc/environment || echo "export http_proxy=\"$PROXY_URL\"" | sudo tee -a /etc/environment
    grep -q "https_proxy" /etc/environment || echo "export https_proxy=\"$PROXY_URL\"" | sudo tee -a /etc/environment
    
    # Export for current script session
    export http_proxy="$PROXY_URL"
    export https_proxy="$PROXY_URL"
    
    echo "Proxy configuration applied."
else
    echo "Skipping proxy configuration."
fi

# --- 2. Fix Outdated Repositories (Before Update) ---
echo "Commenting out outdated bullseye-backports repositories to avoid 404 errors..."
sudo sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list 2>/dev/null
sudo sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list.d/*.list 2>/dev/null

# --- 3. System Update & Essential Tools ---
echo "Updating package list..."
sudo apt update || error_exit "Failed to update package list."

echo "Installing core packages (nano, git, net-tools, locales)..."
sudo apt install -y nano git net-tools locales || error_exit "Failed to install packages."

# --- 4. Bluetooth Disabling ---
echo "Disabling Bluetooth service..."
sudo systemctl stop bluetooth 2>/dev/null
sudo systemctl disable bluetooth 2>/dev/null
sudo systemctl mask bluetooth 2>/dev/null
echo "Bluetooth has been stopped, disabled, and masked."

# --- 5. Locale Configuration (FIXED) ---
echo "Configuring locale to en_US.UTF-8..."

# اصلاح فایل اصلی لوکالها (کامنت کردن چینی و باز کردن انگلیسی)
if [ -f /etc/locale.gen ]; then
    sudo sed -i 's/^zh_CN.UTF-8/# zh_CN.UTF-8/' /etc/locale.gen
    sudo sed -i 's/^#\s*en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
fi

# تولید مجدد لوکالها و پاک کردن لوکال چینی از کش
sudo locale-gen --purge en_US.UTF-8 || error_exit "Failed to generate en_US.UTF-8 locale."

# استفاده از ابزار استاندارد دبیان برای تنظیم پیشفرض سیستم (جلوگیری از ==)
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 || error_exit "Failed to update locale settings."

# اعمال به سشن فعلی اسکریپت
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# اصلاح تمیز فایل ~/.bashrc و حذف آثار زبان چینی
BASHRC_FILE="$HOME/.bashrc"
if [[ ! -f "$BASHRC_FILE" ]]; then
    touch "$BASHRC_FILE"
fi

sed -i '/zh_CN.UTF-8/d' "$BASHRC_FILE" 2>/dev/null
sed -i '/en_US.UTF-8/d' "$BASHRC_FILE" 2>/dev/null

echo 'export LANG=en_US.UTF-8' >> "$BASHRC_FILE"
echo 'export LC_ALL=en_US.UTF-8' >> "$BASHRC_FILE"
echo 'export LANGUAGE=en_US.UTF-8' >> "$BASHRC_FILE"

# --- 6. Network Configuration (Static IP) ---
read -p "Do you want to configure a static IP? (y/N): " CONFIGURE_STATIC_IP
if [[ "$CONFIGURE_STATIC_IP" =~ ^[Yy]$ ]]; then
    # Prompt for network configuration details
    read -p "Enter the network interface name (default: eth0): " NETWORK_INTERFACE
    NETWORK_INTERFACE=${NETWORK_INTERFACE:-eth0}
    
    read -p "Enter static IP address (default: 192.168.40.147): " STATIC_IP
    STATIC_IP=${STATIC_IP:-192.168.40.147}
    
    read -p "Enter netmask (default: 255.255.255.0): " NETMASK
    NETMASK=${NETMASK:-255.255.255.0}
    
    read -p "Enter gateway (default: 192.168.40.1): " GATEWAY
    GATEWAY=${GATEWAY:-192.168.40.1}
    
    read -p "Enter DNS nameserver (default: 172.20.10.1): " DNS_NAMESERVER
    DNS_NAMESERVER=${DNS_NAMESERVER:-172.20.10.1}
    
    echo "Configuring static IP with the following settings:"
    echo "  Interface: $NETWORK_INTERFACE"
    echo "  IP Address: $STATIC_IP"
    echo "  Netmask: $NETMASK"
    echo "  Gateway: $GATEWAY"
    echo "  DNS: $DNS_NAMESERVER"
    
    INTERFACES_FILE="/etc/network/interfaces"
    if [ -f "$INTERFACES_FILE" ]; then
        echo "Adding static IP configuration to $INTERFACES_FILE..."
        
        # Remove any existing configuration for this interface to avoid duplicates
        sudo sed -i "/^auto $NETWORK_INTERFACE/,/^$/d" "$INTERFACES_FILE"
        
        # Add new static IP configuration
        sudo tee -a "$INTERFACES_FILE" > /dev/null <<EOF

auto $NETWORK_INTERFACE
iface $NETWORK_INTERFACE inet static
    address $STATIC_IP
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS_NAMESERVER
EOF
        
        echo "Static IP configuration added successfully."
        
        # Prompt before restarting network
        read -p "Do you want to restart the networking service now? (y/N): " RESTART_NETWORK
        if [[ "$RESTART_NETWORK" =~ ^[Yy]$ ]]; then
            echo "Restarting networking service..."
            sudo systemctl restart networking 2>/dev/null
            echo "Network service restarted."
        else
            echo "Network restart skipped. Changes will take effect after next reboot."
        fi
    else
        echo "Warning: $INTERFACES_FILE not found. Cannot configure static IP."
    fi
else
    echo "Skipping static IP configuration."
fi

# Apply netplan changes only if netplan config actually exists
if command -v netplan &> /dev/null; then
    echo "Applying netplan configuration (if /etc/netplan/ files exist)..."
    sudo netplan apply 2>/dev/null
fi

# --- 7. SSH Configuration ---
SSHD_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSHD_CONFIG" ]; then
    echo "Configuring SSH to allow root login..."
    sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$SSHD_CONFIG" || error_exit "Failed to update SSH configuration."
    sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null
    echo "SSH configuration updated: Root login is now permitted."
fi

echo "----------------------------------------"
echo "Operation completed successfully."
echo "Please restart your terminal or run 'source ~/.bashrc' for all environment changes to take effect."
echo "----------------------------------------"
```
chmod +x setup_proxy_locale.sh
