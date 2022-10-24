##### stop / start manual 
```bash
sudo service lightdm start
sudo service lightdm stop
```
  
##### Genral for all boards 
```bash
sudo update-rc.d lightdm disable
sudo update-rc.d lightdm enable
```
___
##### or BBB
(usb ip )BBB using default **192.168.7.2** IP after installing drivers for this board. 

Disable kardan lightdm (desktop defualt debian )
**Beaglebone Black (BBB)** Disable Debian Desktop GUI / LXDE / lightdm cmdline=systemd.unit=multi-user.target (for Jessie)
To disable the GUI in the Debian Desktop and just have a normal terminal login, put the following into /boot/uboot/uEnv.txt 
```bash
nano /boot/uboot/uEnv.txt
```
+ in khato be file ezafe konid
```bash
optargs=text (for Whezzy) 
```

+ baray run shodan desktop
```bash
sudo ligthdm (Wheezy)
sudo systemctl start graphical.target (Jessie)
```
