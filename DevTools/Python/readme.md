## Use a Prebuilt Package
```
sudo apt update

sudo apt install python3-pip
sudo apt install build-essential python3-dev gcc-aarch64-linux-gnu
```
## build via source python 
```bash
wget https://www.python.org/ftp/python/3.12.5/Python-3.12.5.tar.xz
tar -xf Python-3.12.5.tar.xz
cd Python-3.12.5
sudo apt-get install libssl-dev libsqlite3-dev

sudo apt install -y build-essential pkg-config libssl-dev zlib1g-dev \
libncurses5-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev \
liblzma-dev libgdbm-dev libnss3-dev libedit-dev uuid-dev

./configure --enable-optimizations --with-ssl --with-sqlite3  --with-ensurepip=install
make -j$(nproc)
sudo make altinstall
```

## pp vi proxy 
```
pip3 install lgpio --proxy http://172.20.10.1:3128
```

## install debugpy in linux board 
```
python3 -m pip install debugpy
```
