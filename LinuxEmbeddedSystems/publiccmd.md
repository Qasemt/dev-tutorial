### Change IP Address
##### Step1 :
```bash
sudo nano /etc/network/interfaces
auto eth0
iface eth0 inet static
address 192.168.1.56
netmask 255.255.255.0
cb2 =>> gateway 192.168.1.210
```
##### Step2 :
```bash
sudo echo "nameserver 8.8.8.8" >> /etc/resolv.conf 
```
##### Description
```bash 
export QT_PLUGIN_PATH=/usr/local/Trolltech/Qt-4.8.6-raspi/plugins/
export QT_PLUGIN_PATH=/usr/lib/arm-linux-gnueabihf/qt4/plugins/phonon_backend


//----------------------------- beaglebone black -----------------
(usb ip )BBB using default 192.168.7.2 IP after installing drivers for this board. 

Disable kardan lightdm (desktop defualt debian )
Beaglebone Black (BBB) Disable Debian Desktop GUI / LXDE / lightdm cmdline=systemd.unit=multi-user.target (for Jessie)
To disable the GUI in the Debian Desktop and just have a normal terminal login, put the following into /boot/uboot/uEnv.txt 

nano /boot/uboot/uEnv.txt

in khato be file ezafe konid
optargs=text (for Whezzy) 


baray run shodan desktop
sudo ligthdm (Wheezy)
sudo systemctl start graphical.target (Jessie)

=======================================================================


ldconfig -p | grep libjpeg

apt-get install phonon-backend-vlc
apt-get remove phonon-backend-gstreamer

sudo ln -s /usr/lib/arm-linux-gnueabihf/qt4/plugins/phonon_backend /usr/local/Trolltech/Qt-4.8.6-raspi/plugins/phonon_backend


sudo ln -s /usr/lib/arm-linux-gnueabihf/qt4/plugins/phonon_backend /usr/bin
sudo ln -s /usr/lib/arm-linux-gnueabihf/qt4/plugins/phonon_backend /root/phonon_backend
----------------------------------------------







scp -r /home/qasem/Development/BeagleBone/sysroot root@192.168.1.56:~/sysroot

change password : passwd
nano /etc/profile
-----------------------------------
if [ "`id -u`" -eq 0 ]; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/Trolltech/Qt-4.8.6-beaglebone/lib"
else
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/usr/local/Trolltech/Qt-4.8.6-beaglebone/lib"
fi
export PATH
-----------------------------------
ssh root@192.168.1.56

# mkdir -p /usr/local/Trolltech/Qt-4.8.6-beaglebone
# exit
scp -r /media/Q8/1.mp3 root@192.168.1.56:/home/debian/
scp -r /usr/local/Trolltech/Qt-4.8.6-beaglebone/lib/ root@192.168.1.56:/usr/local/Trolltech/Qt-4.8.6-beaglebone
scp -r /usr/local/Trolltech/Qt-4.8.6-beaglebone/plugins/ root@192.168.1.56:/usr/local/Trolltech/Qt-4.8.6-beaglebone
scp /home/qasem/Development/BeagleBone/sysroot/lib/libffi.* root@192.168.1.56:/usr/lib/


scp -d -r  /usr/local/Trolltech/geo123 root@192.168.1.56:/usr/local/Trolltech/

scp Development/BeagleBone/sysroot/lib/libffi.* root@192.168.1.56:/usr/lib/

zip -y -r vtl.zip ./vtl
ssh -n root@192.168.1.56 'tar zcvf - /usr/local/softwares/vtl' | cat - > localZip.tar.gz
```
### extract file in linux 
```bash 
tar xpvf /path/to/my_archive.tar.xz -C /path/to/extract

```
#### enable root login from ssh
```bash
sudo nano /etc/ssh/sshd_config

# search for the line starting with

PermitRootLogin yes 

# must be "yes", "without-password", "forced-commands-only" or "no".

```
#### change root password 
```bash
$ sudo su
$ passwd
```
