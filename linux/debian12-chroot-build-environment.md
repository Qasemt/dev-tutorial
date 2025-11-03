
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

```bash
# Update package lists
apt update

# Install minimal build toolchain
apt install -y --no-install-recommends \
    build-essential \
    gcc-12 g++-12 \
    python3.11 python3.11-dev python3-pip \
    wget ca-certificates

# Set GCC 12 as default compiler
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 120
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 120

# Clean APT cache to save space
apt clean
rm -rf /var/lib/apt/lists/*
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
 
