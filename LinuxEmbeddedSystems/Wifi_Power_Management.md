####Source : 
 1. http://raspberrypi.stackexchange.com/questions/1384/how-do-i-disable-suspend-mode/4518#4518
 2. http://svay.com/blog/setting-up-a-wifi-connection-on-the-raspberrypi/
 3. https://www.andreagrandi.it/2014/09/02/how-to-configure-edimax-ew-7811un-wifi-dongle-on-raspbian/
 
 
 
### Disable Wifi Managment (power saving)

####1. First Step Test Parameter 
The problem seems to be that the adapter has power management features enabled by default. This can be checked by running the command:
A value of 0 means disabled, 1 means min. power management, 2 means max. power management. 
```bash
cat /sys/module/8192cu/parameters/rtw_power_mgnt
```

####2. To disable this, you need to create a new file:
```bash
sudo nano /etc/modprobe.d/8192cu.conf

# and add the following:
# Disable power management
options 8192cu rtw_power_mgnt=0
```
Once you save the file and reboot your RPi, the WiFi should stay on indefinitely.
 
