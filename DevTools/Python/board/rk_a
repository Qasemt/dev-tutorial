#!/bin/bash
# download_and_install_python.sh

set -e

ARCH=$(uname -m)
PYTHON_VERSION="3.12.5"
BASE_URL="https://raw.githubusercontent.com/Qasemt/dev-tutorial/master/DevTools/Python/board_china_a"
PACKAGE="python-${PYTHON_VERSION}-${ARCH}.tar.gz"

echo "Detected architecture: ${ARCH}"
echo "Downloading Python ${PYTHON_VERSION} for ${ARCH}..."

# Create Downloads directory if not exists
mkdir -p ~/Downloads

# Download the prebuilt package
wget "${BASE_URL}/${PACKAGE}" -O ~/Downloads/${PACKAGE}

# Or use curl if wget is not available
# curl -L "${BASE_URL}/${PACKAGE}" -o ~/Downloads/${PACKAGE}

echo "Installing dependencies..."
sudo apt update
sudo apt install -y libssl-dev libsqlite3-dev libffi-dev \
    libbz2-dev liblzma-dev libreadline-dev zlib1g-dev \
    libncurses5-dev libgdbm-dev uuid-dev

echo "Extracting Python ${PYTHON_VERSION}..."
sudo tar xzf ~/Downloads/${PACKAGE} -C /usr/local/

echo "Configuring..."
sudo ldconfig
sudo ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3
sudo ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip3

echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "Verifying installation..."
python3.12 --version
pip3.12 --version

echo "Checking SSL and SQLite3..."
python3.12 -c "import ssl; print('SSL Version:', ssl.OPENSSL_VERSION)"
python3.12 -c "import sqlite3; print('SQLite3 Version:', sqlite3.sqlite_version)"

# Check for missing dependencies
echo "Checking for missing libraries..."
ldd /usr/local/bin/python3.12 | grep "not found" || echo "All dependencies satisfied"

echo "Cleaning up..."
rm ~/Downloads/${PACKAGE}

echo "Done! Python ${PYTHON_VERSION} installed successfully."
echo "You can now use 'python3.12' and 'pip3.12' commands."

# Optional: Install debugpy
# python3.12 -m pip install debugpy
