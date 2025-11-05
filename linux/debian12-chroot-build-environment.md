
# Debian 12 (Bookworm) Minimal chroot Build Environment

This guide creates a lightweight, container-free build environment using **debootstrap** and **chroot** to produce binaries or Python wheels that are fully compatible with Debian 12 (Bookworm).  
It avoids Docker, minimizes disk usage (~400–500 MB), and gives you full control over the toolchain.

> **Ideal for:** compiling `.whl` packages with **GCC 12** and **Python 3.11** (Debian 12’s default).  
> **Disk usage after setup:** ~400–500 MB  
> **No GUI, no services, no bloat** — only essential build tools.

---

## 🧰 Step-by-Step Setup


### 1. Install required tools (on host system)

```bash
sudo apt update
sudo apt install -y debootstrap
````

---

### 2. Bootstrap minimal Debian 12 filesystem

```bash
sudo debootstrap \
  --arch=amd64 \
  --variant=minbase \
  bookworm \
  /srv/debian12-chroot \
  http://deb.debian.org/debian/
```

> `--variant=minbase` ensures only the absolute minimal base system is installed.

---

### 3. Enter chroot and install build essentials

```bash
sudo chroot /srv/debian12-chroot
```

Inside the chroot:
### 🔧 Step 1: Ensure /etc/apt/sources.list is configured
```
cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF
```
### Fix DNS (if needed)
```
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```
### Install build dependencies
```bash
# Update package lists
apt update
 
# Install minimal build toolchain
 apt install -y --no-install-recommends build-essential zlib1g-dev libncurses-dev libgdbm-dev \
    libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev \
    libbz2-dev libexpat1-dev liblzma-dev tk-dev libdb-dev uuid-dev wget ca-certificates \
    iputils-ping dnsutils netcat-openbsd wget curl unzip git nano gcc-12 g++-12 openssh-client

# Set GCC 12 as default compiler
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 120
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 120

# Clean APT cache to save space
apt clean
rm -rf /var/lib/apt/lists/*
```
## install Python 3.12.5 with sqlit3 pip ssl

```bash
wget https://www.python.org/ftp/python/3.12.5/Python-3.12.5.tar.xz
tar -xf Python-3.12.5.tar.xz
cd Python-3.12.5
./configure --enable-optimizations --with-ssl --with-sqlite3  --with-ensurepip=install
make -j$(nproc)
sudo make altinstall
```

> **Note:** Debian 12 officially provides Python 3.11, not 3.12.
> If you require Python 3.12, it must be compiled from source inside the chroot.

---

### 4. Bind your project directory

On the host system:

```bash
sudo mkdir -p /srv/debian12-chroot/src
sudo mount --bind "$(pwd)" /srv/debian12-chroot/src
```

Your current working directory is now accessible as `/src` inside the chroot.

---

### 5. Build your package (example: Python wheel)

Inside the chroot:

```bash
cd /src
CC=gcc-12 CXX=g++-12 python3.11 -m pip wheel --no-cache-dir .
```

The resulting `.whl` file will be **compatible with Debian 12 systems**.

---

### 6. Exit and clean up (optional)

```bash
exit  # Exit chroot
sudo umount /srv/debian12-chroot/src  # Unmount project dir if done
```

Keep `/srv/debian12-chroot` for future builds — no need to recreate it!

---

## 💾 Expected Disk Usage

| Stage                  | Approx. Disk Usage |
| :--------------------- | :----------------: |
| After debootstrap      |     120–150 MB     |
| After installing tools |     400–500 MB     |
| After apt clean        |  Minimal overhead  |

---




## 🔑 Optional: Enable SSH Access (for private Git repos)

If your build depends on **private repositories** (e.g., `git@github.com:user/repo.git`), you must make your SSH key available inside the chroot environment.

> **Important:** Never commit private keys to version control. This setup is for local/secure build environments only.

### On the host system:

```bash
# Create .ssh directory inside chroot (for root user)
sudo mkdir -p /srv/debian12-chroot/root/.ssh

# Copy your SSH private and public keys
sudo cp ~/.ssh/id_rsa      /srv/debian12-chroot/root/.ssh/
sudo cp ~/.ssh/id_rsa.pub  /srv/debian12-chroot/root/.ssh/

# Set strict permissions (required by SSH)
sudo chmod 700 /srv/debian12-chroot/root/.ssh
sudo chmod 600 /srv/debian12-chroot/root/.ssh/id_rsa
sudo chmod 644 /srv/debian12-chroot/root/.ssh/id_rsa.pub

# Optional: copy or generate known_hosts to avoid host verification prompts
sudo cp ~/.ssh/known_hosts /srv/debian12-chroot/root/.ssh/ 2>/dev/null || \
  sudo ssh-keyscan github.com | sudo tee /srv/debian12-chroot/root/.ssh/known_hosts
```

### Inside the chroot (test connectivity):

```bash
sudo chroot /srv/debian12-chroot

# Install SSH client if not already present
apt update && apt install -y openssh-client

# Test GitHub access
ssh -T git@github.com
```

If you see:
```
Hi <your-username>! You've successfully authenticated...
```
→ Git over SSH will now work in your build scripts.

> 💡 Tip: For CI or ephemeral builds, consider using **deploy keys** or temporary key injection instead of copying permanent keys. 
