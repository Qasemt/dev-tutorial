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

# Set proxy for environment (for wget, curl, etc.)
echo "export http_proxy=\"$PROXY_URL\"" | sudo tee -a /etc/environment || error_exit "Failed to set http_proxy."
echo "export https_proxy=\"$PROXY_URL\"" | sudo tee -a /etc/environment || error_exit "Failed to set https_proxy."

# Reload environment changes
source /etc/environment || error_exit "Failed to reload environment settings."

# Update package list
sudo apt update || error_exit "Failed to update package list."

# Install git
sudo apt install -y git || error_exit "Failed to install git."

# Install net-tools
sudo apt install -y net-tools || error_exit "Failed to install net-tools."

# Install locales package if not already installed
sudo apt install -y locales || error_exit "Failed to install locales package."

# Enable en_US.UTF-8 locale
sudo locale-gen en_US.UTF-8 || error_exit "Failed to generate en_US.UTF-8 locale."
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 || error_exit "Failed to update locale settings."

# Apply changes immediately
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Set locale in /etc/default/locale
echo "LANG=en_US.UTF-8" | sudo tee /etc/default/locale || error_exit "Failed to set LANG in /etc/default/locale."
echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/default/locale || error_exit "Failed to set LC_ALL in /etc/default/locale."
echo "LANGUAGE=en_US.UTF-8" | sudo tee -a /etc/default/locale || error_exit "Failed to set LANGUAGE in /etc/default/locale."

# Set locale in /etc/environment
echo "LANG=en_US.UTF-8" | sudo tee -a /etc/environment || error_exit "Failed to set LANG in /etc/environment."
echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/environment || error_exit "Failed to set LC_ALL in /etc/environment."
echo "LANGUAGE=en_US.UTF-8" | sudo tee -a /etc/environment || error_exit "Failed to set LANGUAGE in /etc/environment."

# Disable zh_CN.UTF-8 in ~/.bashrc
if [[ -f ~/.bashrc ]]; then
    sed -i 's/^export LANG=zh_CN.UTF-8/# export LANG=zh_CN.UTF-8/' ~/.bashrc || error_exit "Failed to disable zh_CN.UTF-8 in ~/.bashrc."
    sed -i 's/^export LC_ALL=zh_CN.UTF-8/# export LC_ALL=zh_CN.UTF-8/' ~/.bashrc || error_exit "Failed to disable zh_CN.UTF-8 in ~/.bashrc."
    sed -i 's/^export LANGUAGE=zh_CN.UTF-8/# export LANGUAGE=zh_CN.UTF-8/' ~/.bashrc || error_exit "Failed to disable LANGUAGE=zh_CN.UTF-8 in ~/.bashrc."
else
    echo "~/.bashrc does not exist. Creating a new file..."
    touch ~/.bashrc || error_exit "Failed to create ~/.bashrc."
fi

# Add en_US.UTF-8 to ~/.bashrc if not already present
grep -q '^export LANG=en_US.UTF-8' ~/.bashrc || echo 'export LANG=en_US.UTF-8' >> ~/.bashrc || error_exit "Failed to add LANG to ~/.bashrc."
grep -q '^export LC_ALL=en_US.UTF-8' ~/.bashrc || echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc || error_exit "Failed to add LC_ALL to ~/.bashrc."
grep -q '^export LANGUAGE=en_US.UTF-8' ~/.bashrc || echo 'export LANGUAGE=en_US.UTF-8' >> ~/.bashrc || error_exit "Failed to add LANGUAGE to ~/.bashrc."

# Reload ~/.bashrc
source ~/.bashrc || error_exit "Failed to reload ~/.bashrc."
 
# Configure static IP using /etc/network/interfaces
INTERFACES_FILE="/etc/network/interfaces"
echo "
auto eth0
iface eth0 inet static
    address 192.168.40.147
    netmask 255.255.255.0
    gateway 192.168.40.1
    dns-nameservers 172.20.10.1" | sudo tee -a $INTERFACES_FILE || error_exit "Failed to configure static IP."

# Restart networking service
sudo systemctl restart networking || error_exit "Failed to restart networking service."

# Apply netplan changes
sudo netplan apply || error_exit "Failed to apply netplan configuration."

# Display current locale settings
locale || error_exit "Failed to display locale settings."

# Configure SSH to allow root login
SSHD_CONFIG="/etc/ssh/sshd_config"
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' $SSHD_CONFIG || error_exit "Failed to update SSH configuration."

# Restart SSH service to apply changes
sudo systemctl restart ssh || error_exit "Failed to restart SSH service."

echo "SSH configuration updated: Root login is now permitted."

echo "Operation completed successfully."

```
chmod +x setup_proxy_locale.sh
