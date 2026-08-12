#!/bin/bash

set -e

echo "[+] Starting Debian 12 bootstrap for Python 3.12.5 + .venv support..."

# بررسی سریع نسخه GCC (برای گزارش و اطمینان)
GCC_VERSION=$(gcc --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | cut -d. -f1)
if [ "$GCC_VERSION" -lt 12 ]; then
    echo "[!] Warning: GCC version < 12 detected. Compilation may fail."
    echo "    Current GCC: $(gcc --version | head -n1)"
else
    echo "[+] GCC version is acceptable (>=12): $(gcc --version | head -n1)"
fi

# 1. فعال‌سازی ورود root از طریق SSH
if ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo "[+] Enabling PermitRootLogin..."
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl reload sshd
fi

# 2. منابع APT برای Debian 12 (bookworm)
cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian bookworm main contrib non-free-firmware
deb http://deb.debian.org/debian-security bookworm-security main contrib non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free-firmware
EOF

# 3. به‌روزرسانی
apt update
apt full-upgrade -y
apt --fix-broken install -y

# 4. نصب وابستگی‌های کامپایل
apt install -y git build-essential pkg-config libssl-dev zlib1g-dev \
libncurses5-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev \
liblzma-dev libgdbm-dev libnss3-dev libedit-dev uuid-dev

# 5. کامپایل Python 3.12.5
PYTHON_VERSION="3.12.5"
if ! command -v python3.12.5 &> /dev/null; then
    echo "[+] Downloading and building Python ${PYTHON_VERSION}..."
    wget -q "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz"
    tar -xf "Python-${PYTHON_VERSION}.tar.xz"
    cd "Python-${PYTHON_VERSION}"

    # فعال‌سازی pip و venv به‌صورت پیش‌فرض
    ./configure --enable-optimizations --with-ssl --with-sqlite3 --enable-shared \
                --with-ensurepip=install

    make -j$(nproc)
    sudo make altinstall

    # ایجاد symlink برای راحتی (اختیاری)
    # ln -sf /usr/local/bin/python3.12.5 /usr/local/bin/python3.12

    cd ..
    echo "[+] Python ${PYTHON_VERSION} installed. Test .venv:"
    /usr/local/bin/python3.12.5 -m venv /tmp/test_venv && echo "[+] .venv works!" && rm -rf /tmp/test_venv
else
    echo "[+] Python 3.12.5 already installed."
fi

echo "[+] Done! You can now use: python3.12.5 -m venv .venv"
