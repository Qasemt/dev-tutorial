#!/bin/bash

set -e  # متوقف شدن در صورت خطا

echo "[+] Starting Debian 13.1 bootstrap configuration..."

# 1. پیکربندی SSH برای اجازه ورود root (فقط برای محیط‌های آزمایشی!)
if ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo "[+] Enabling PermitRootLogin..."
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl reload sshd
fi

# 2. تنظیم منابع apt برای Debian 13.1 (trixie)
echo "[+] Configuring APT sources..."
cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian trixie main contrib non-free-firmware
deb http://deb.debian.org/debian-security trixie-security main contrib non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free-firmware
EOF

# 3. به‌روزرسانی سیستم
echo "[+] Updating system..."
apt update
apt full-upgrade -y
apt --fix-broken install -y

# 4. نصب پیش‌نیازها
echo "[+] Installing build dependencies..."
apt install -y git python3.13-venv build-essential pkg-config libssl-dev zlib1g-dev \
libncurses5-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev \
liblzma-dev libgdbm-dev libnss3-dev libedit-dev uuid-dev

# 5. دانلود و کامپایل پایتون 3.12.5
PYTHON_VERSION="3.12.5"
PYTHON_TARBALL="Python-${PYTHON_VERSION}.tar.xz"
PYTHON_DIR="Python-${PYTHON_VERSION}"

if ! command -v python3.12.5 &> /dev/null; then
    echo "[+] Downloading Python ${PYTHON_VERSION}..."
    wget -q "https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_TARBALL}"
    tar -xf "${PYTHON_TARBALL}"

    echo "[+] Building Python ${PYTHON_VERSION}..."
    cd "${PYTHON_DIR}"
    ./configure --enable-optimizations --with-ssl --with-sqlite3
    make -j$(nproc)
    sudo make altinstall
    cd ..
    echo "[+] Python ${PYTHON_VERSION} installed as python3.12.5"
else
    echo "[+] Python ${PYTHON_VERSION} already installed, skipping..."
fi

echo "[+] Bootstrap completed successfully!"
