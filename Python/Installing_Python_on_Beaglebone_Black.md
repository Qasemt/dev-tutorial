#### Installing Python on Beaglebone Black
```bash 
# First install some dependencies:
sudo apt-get install build-essential
sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
# Then download using the following commands:
mkdir Downloads
cd ~/Downloads/
wget http://python.org/ftp/python/2.7.6/Python-2.7.6.tgz
# Extract and go to the directory:
tar -xvf Python-2.7.6.tgz
cd Python-2.7.6
# Now, install using the command you just tried:
./configure
make
sudo make install
# use “sudo make altinstall” if you don’t want
# Python 2.7.6 as the default version to use
```
