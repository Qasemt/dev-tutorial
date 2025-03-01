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

# Install locales package if not already installed
sudo apt install -y locales || error_exit "Failed to install locales package."

# Enable en_US.UTF-8 locale
sudo locale-gen en_US.UTF-8 || error_exit "Failed to generate en_US.UTF-8 locale."
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 || error_exit "Failed to update locale settings."

# Apply changes immediately
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Disable zh_CN.UTF-8 in ~/.bashrc
if [[ -f ~/.bashrc ]]; then
    sed -i 's/^export LANG=zh_CN.UTF-8/# export LANG=zh_CN.UTF-8/' ~/.bashrc || error_exit "Failed to disable zh_CN.UTF-8 in ~/.bashrc."
    sed -i 's/^export LC_ALL=zh_CN.UTF-8/# export LC_ALL=zh_CN.UTF-8/' ~/.bashrc || error_exit "Failed to disable zh_CN.UTF-8 in ~/.bashrc."
else
    echo "~/.bashrc does not exist. Creating a new file..."
    touch ~/.bashrc || error_exit "Failed to create ~/.bashrc."
fi

# Add en_US.UTF-8 to ~/.bashrc if not already present
grep -q '^export LANG=en_US.UTF-8' ~/.bashrc || echo 'export LANG=en_US.UTF-8' >> ~/.bashrc || error_exit "Failed to add LANG to ~/.bashrc."
grep -q '^export LC_ALL=en_US.UTF-8' ~/.bashrc || echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc || error_exit "Failed to add LC_ALL to ~/.bashrc."

# Reload ~/.bashrc
source ~/.bashrc || error_exit "Failed to reload ~/.bashrc."

# Display current locale settings
locale || error_exit "Failed to display locale settings."

echo "Operation completed successfully."

```
chmod +x setup_proxy_locale.sh
