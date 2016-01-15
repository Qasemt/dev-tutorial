nano /etc/udev/rules.d/01-usbwatcher.rules
```bash
ACTION=="add", KERNELS=="sda1", RUN+="/lib/udev/myusblinker.sh sda1 d1 add"
ACTION=="add", KERNELS=="sda2", RUN+="/lib/udev/myusblinker.sh sda2 d2 add"

ACTION=="remove", KERNELS=="sda1", RUN+="/lib/udev/myusblinker.sh KERNELS d1 remove"
ACTION=="remove", KERNELS=="sda2", RUN+="/lib/udev/myusblinker.sh KERNELS d2 remove"

```

nano /lib/udev/myusblinker.sh

```bash
#!/bin/bash
function add_mountusb()
{
val1=$1
val2=$2
echo "add $val2"
sudo umount -l /media/$val2
sudo mkdir -p /media/$val2
sudo mount /dev/$val1 /media/$val2
}

function remove_mountusb()
{
val1=$1

echo "remove $val1"
sudo umount -l /media/$val1
#sudo rm -d /media/$val1
}


logfile="/root/usb.txt"

echo "---------------------" >> $logfile
src_mnt=$1 #sdc1 or sdb1 or sdb2 ....
src_mountpoint=$2 #/media/d1 ....
action=$3 #add or remove usb

if [[ $action == "add" ]];then
rm $logfile
add_mountusb $src_mnt $src_mountpoint
echo "add flash drive >>> /media/$src_mountpoint/" >> $logfile

echo "Find pack ...."

pathpack="/media/$src_mountpoint/restoreip.sh"
if [ -f $pathpack ];
then

echo "File $pathpack exists" >> $logfile
echo "Run $pathpack " >> $logfile
cp /etc/network/interfaces.bak /etc/network/interfaces

else
echo "file $pathpack does not exists" >> $logfile
exit
fi

```
#### step final 
```bash
/etc/init.d/udev restart
```
