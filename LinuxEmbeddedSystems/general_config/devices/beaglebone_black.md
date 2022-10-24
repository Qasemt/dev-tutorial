# Beaglebone Black

(usb ip )BBB using default 192.168.7.2 IP after installing drivers for this board.

> Disable kardan lightdm (desktop defualt debian )
> Beaglebone Black (BBB) Disable Debian Desktop GUI / LXDE / lightdm cmdline=systemd.unit=multi-user.target (for Jessie)
> To disable the GUI in the Debian Desktop and just have a normal terminal login, put the following into /boot/uboot/uEnv.txt

```
nano /boot/uboot/uEnv.txt
```

in khato be file ezafe konid
optargs=text (for Whezzy)

baray run shodan desktop
sudo ligthdm (Wheezy)
sudo systemctl start graphical.target (Jessie)

---

```sh
ldconfig -p | grep libjpeg

apt-get install phonon-backend-vlc
apt-get remove phonon-backend-gstreamer

sudo ln -s /usr/lib/arm-linux-gnueabihf/qt4/plugins/phonon_backend /usr/local/Trolltech/Qt-4.8.6-raspi/plugins/phonon_backend

sudo ln -s /usr/lib/arm-linux-gnueabihf/qt4/plugins/phonon_backend /usr/bin
sudo ln -s /usr/lib/arm-linux-gnueabihf/qt4/plugins/phonon_backend /root/phonon_backend
```

---

```
scp -r /home/qasem/Development/BeagleBone/sysroot root@192.168.1.56:~/sysroot

change password : passwd
nano /etc/profile
```

---

```
if [ "`id -u`" -eq 0 ]; then
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/Trolltech/Qt-4.8.6-beaglebone/lib"
else
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/usr/local/Trolltech/Qt-4.8.6-beaglebone/lib"
fi
export PATH
```

---

```bash
ssh root@192.168.1.56

# mkdir -p /usr/local/Trolltech/Qt-4.8.6-beaglebone

# exit

scp -r /media/Q8/1.mp3 root@192.168.1.56:/home/debian/
scp -r /usr/local/Trolltech/Qt-4.8.6-beaglebone/lib/ root@192.168.1.56:/usr/local/Trolltech/Qt-4.8.6-beaglebone
scp -r /usr/local/Trolltech/Qt-4.8.6-beaglebone/plugins/ root@192.168.1.56:/usr/local/Trolltech/Qt-4.8.6-beaglebone
scp /home/qasem/Development/BeagleBone/sysroot/lib/libffi.\* root@192.168.1.56:/usr/lib/

scp -d -r /usr/local/Trolltech/geo123 root@192.168.1.56:/usr/local/Trolltech/

scp Development/BeagleBone/sysroot/lib/libffi.\* root@192.168.1.56:/usr/lib/

zip -y -r vtl.zip ./vtl
ssh -n root@192.168.1.56 'tar zcvf - /usr/local/softwares/vtl' | cat - > localZip.tar.gz
```
