 ```bash
 ls /sys/bus/usb-serial/devices/ -ltrah
 
 dmesg | grep tty*
 
  USB List : lsusb
  
  
  ----------
sudo apt-get install tree
tree /sys/bus/usb/drivers
    ├── pl2303
│   ├── 1-2.1:1.0 -> ../../../../devices/pci0000:00/0000:00:11.0/0000:02:00.0/usb1/1-2/1-2.1/1-2.1:1.0
│   ├── bind
│   ├── module -> ../../../../module/pl2303
│   ├── remove_id
│   ├── uevent
│   └── unbind

So 1-2.1:1.0 is the identifier of my ttyUSB0(it can be discovered also via dmesg).


  disconnect the device (as root):
  echo -n "1-1:1.1" > /sys/bus/usb/drivers/pl2303/unbind
  
  reconnect it
  echo -n "1-1:1.1" > /sys/bus/usb/drivers/cp210x/bind
---------------------------------------------------------------------------------
enable uart 1 to 5 for beaglebone black 
-----------------------------------------------
root@beaglebone:~# vi /boot/uboot/uEnv.txt
Scroll down until you see this section of lines:
#cape_enable=capemgr.enable_partno=
edit to 
cape_enable=capemgr.enable_partno=BB-UART1,BB-UART2,BB-UART4, BB-UART5
exit and save 
 ls -l /dev/ttyO*
 ----------------------------------- Port test ---------------------
 *****************************************************************************
 root@beaglebone:~# minicom -D /dev/ttyO2 -b 115200
****************************************************************************** 
 ---------------------------------- cubie boards-=------------------------
 http://homeduino.blogspot.nl/2014/05/cubieboard-lubuntu-open-uart.html
 
 https://abhinavgupta2812.wordpress.com/2013/08/27/configuring-the-gpio-and-uart-on-the-cubieboard/
 -------------------------------------------------------------------------
 ```
