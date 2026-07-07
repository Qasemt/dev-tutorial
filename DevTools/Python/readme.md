## Use a Prebuilt Package
```
sudo apt update

sudo apt install python3-pip 
sudo apt install build-essential python3-dev gcc-aarch64-linux-gnu
```
## build via source python 
```bash
wget https://www.python.org/ftp/python/3.12.5/Python-3.12.5.tar.xz

if ! command -v xz &> /dev/null; then
    echo "xz-utils is not installed. Installing now..."
    apt update && apt install -y xz-utils
else
    echo "xz-utils is already installed."
fi
tar -xf Python-3.12.5.tar.xz
cd Python-3.12.5
sudo apt-get install libssl-dev libsqlite3-dev nano screen

screen -S setup_python
# reconnect to screen setup_python
#screen -r setup_python or screen -D -r setup_python

sudo apt install -y build-essential pkg-config libssl-dev zlib1g-dev \
libncurses5-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev \
liblzma-dev libgdbm-dev libnss3-dev libedit-dev uuid-dev

./configure --enable-optimizations --with-ssl --with-sqlite3  --with-ensurepip=install  
make -j$(nproc)
sudo make altinstall
```

## Step 2: Create Portable Package on Source Board
```
# Create archive from /usr/local
cd /usr/local
sudo tar czf ~/python-3.12.5-$(uname -m).tar.gz \
    bin/python3.12 \
    bin/pip3.12 \
    bin/idle3.12 \
    bin/pydoc3.12 \
    bin/python3.12-config \
    lib/python3.12/ \
    lib/libpython3.12* \
    include/python3.12/ \
    share/man/man1/python3.12*

# Check archive size
ls -lh ~/python-3.12.5-*.tar.gz
```

## Step 3: Install Dependencies on Target Board
On the target board, install required runtime libraries:

```
sudo apt update
sudo apt install -y libssl-dev libsqlite3-dev libffi-dev \
    libbz2-dev liblzma-dev libreadline-dev zlib1g-dev \
    libncurses5-dev libgdbm-dev uuid-dev
```
### Step 4: Transfer and Install on Target Board
Method A: Direct SCP Transfer
```
# From source board
scp python-3.12.5-*.tar.gz user@target-board-ip:~/Downloads/

# On target board
sudo tar xzf ~/Downloads/python-3.12.5-*.tar.gz -C /usr/local/
```
Method B: Using USB Drive
```
# Copy to USB on source board
cp ~/python-3.12.5-*.tar.gz /media/usb/

# On target board
sudo tar xzf /media/usb/python-3.12.5-*.tar.gz -C /usr/local/
```

Step 5: Configure on Target Board
```
# Update shared library cache
sudo ldconfig

# Create symlinks (optional)
sudo ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3
sudo ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip3

# Add to PATH if not already there
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
Step 6: Verify Installation
```
# Check Python version
python3.12 --version
# Expected: Python 3.12.5

# Check pip
pip3.12 --version

# Verify SSL works
python3.12 -c "import ssl; print(ssl.OPENSSL_VERSION)"

# Verify SQLite3 works
python3.12 -c "import sqlite3; print(sqlite3.sqlite_version)"

# Check for missing dependencies
ldd /usr/local/bin/python3.12 | grep "not found"
# Should return nothing
```



## pp vi proxy 
```
pip3 install lgpio --proxy http://172.20.10.1:3128
```

## install debugpy in linux board 
```
python3 -m pip install debugpy
```
