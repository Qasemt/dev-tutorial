
####source : 
1. https://github.com/slayersoft/MineNinja/wiki/Flashing-the-BeagleBone-eMMc
2. https://www.mail-archive.com/beagleboard@googlegroups.com/msg24103.html
3. http://www.circuidipity.com/getting-started-with-beaglebone-black.html
4. http://compositecode.com/2013/11/10/using-ssh-locally-to-work-with-ubuntu-vm-vmware-tools-installation-via-shell/


#### host Requierment
```bash
sudo apt-get install openssh-client openssh-server
check servic ssh : # service ssh status 
$config ip in vm-ware

get ip : ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://'

```
###BBB back up EMMC
```bash
sudo dd if=/dev/mmcblk0 bs=1M | ssh   hamed@192.168.1.1 "dd of=/home/hamed/a12/qasem_emmc_BBB_Backup_940518.img bs=1M"
```
### Restore Image to EMMC (BBB)
#### step 1: 
image backup gerfte shode ro ba in command zir ya softeware ***win32diskImager.exe*** copy kon to ye ssd 4G Or 8G 
#### Note :
Mitavnid az har noe linux estefade koni mohem ine ke ye ***linux ba ssh va ip*** biad balla.
```bash
Copy image to card using dd ...
$ sudo dd if=qasem_emmc_BBB_Backup_940518.img of=/dev/sdb bs=1M
ya 
Win32DiskImager.exe estefade kon 
```
#### step 2: 
bad flash ro be beagle bone black insert(ssd card ) kon va mogheye bala omadan button **s2** kenar ***SSD Card*** ro feshar bede ke board az SSD Bala biad ,bad az negah dashtan button **s2** hmazaman power board ro Connect kon bad motmaen bash ke board IP Gerfte 
#### step 3: 
file image ro toy ***flash usb*** copy kon va az toy ***Host (Ubuntu)*** in Command ro ejra kon 

```bash
cd Flash Dirver ( any Path )
sudo dd if=ff.img bs=1M | ssh   root@192.168.1.56 "dd of=/dev/mmcblk1  bs=1M"
``` 
#### Note : (1394-07-11)
Vaghti SSD be board Vasle Address ***SSD = /dev/mmcblk0*** va Address  ***EMMC = /dev/mmcblk1*** mibashad 
va Vaghti SSD Connect nist Address ***EMMC = /dev/mmcblk0*** mibashad  

### Description 

Step 1:  Use exiting Beaglebone Black to create a flasher image on your 
microSD card.
There is a file on most newer Beaglebone Blacks that can make a flasher 
image on a microSD card.
from ssh terminal window, change your directory and run the script if it is 
on your OS distribution.
THIS WILL OVER WRITE YOUR microSD card and take some time till completed.
$ cd /opt/scripts/tools/eMMC
$ ./beaglebone-black-make-microSD-flasher-from-eMMC.sh
when process is done, you need to power down Beaglebone Black and remove 
your microSD card.

Step 2:  Use created microSD flasher card to clone your Beaglebone Black on 
other BBB's or Restore yours.
You can use this microSD card to put in another Beaglebone Black with Power 
off, press S2 and hold 
while powering up.  It will put this image in your Beaglebone Black eMMC 
and over-write what was there.

Step 3:  Storing your microSD image on your Ubuntu Linux computer.
Caution:  when you put a bootable microSD card in your computer, you may 
need to "Cancel" pop up window from trying to run this.
change directory on your Ubuntu Linux PC to where you want this backup 
image to go
the name for you file can be anything but should be descriptive,  
eMMC_Backup_name-sdcardsize.img.gz
This next command will take the microSD card and create an image file that 
will be stored on your linux pc computer.
make sure your microSD device is correct, ie - /dev/mmcblk0   
( you can find this with the Ubuntu Linux "Disks" package under the SD card 
ICON in the upper right.)

This takes the SD card and creates a compressed image in the current linux 
pc directory. Note -4gb is a 4gb microSD card size.
$ sudo dd if=/dev/mmcblk0 | gzip > 
BBB-eMMC-flasher-debian-date-xxxx-4gb.img.gz 

it never hurts to run $ md5sum file.img.gz to get a check sum type value 
and record it in an accompaning text file for 
verifying the file does not become corrupted.

Step 4: Using a compressed image to create a bootable master microSD 
flasher card.
This process will uncompress your .gz file,  you may what to create a 
backup .gz file and copy it somewhere else first.

Unzip compressed file:
$ sudo gunzip BBB-eMMC-flasher-debian-date-xxxx-4gb.img.gz 

this converted the file to an .img file 
BBB-eMMC-flasher-debian-date-xxxx-4gb.img

Now use the .img file to create a flasher microSD card
Note: make sure your SD card on your linux pc is /dev/mmcblk0   ( some pc 
use sda, etc.)
$ sudo dd if=BBB-eMMC-flasher-debian-date-xxxx-4gb.img of=/dev/mmcblk0 bs=8M

takes about 10 minutes to finish.

You can remove this card and put it in a Beaglebone Black, hold S2 down, 
power up, then 
release S2 after about 5 to 10 seconds, then wait about 10 minutes for 
image to be written to eMMC.

You may want to delete the .img file on your Linux PC and just keep the 
.img.gz compressed file to conserve disk space.

DONE.
