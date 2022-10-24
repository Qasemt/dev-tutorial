#### best source :
1. http://www.raspberrypi-spy.co.uk/2015/05/adding-a-ds3231-real-time-clock-to-the-raspberry-pi/

#### Step 1
enable i2c to pi 

```bash
sudo raspi-config
>> advanced config >> I2c >> yes >> yes 
```
#### Step 2
```bash
nano  /etc/modules
=====================
#snd-bcm2835
i2c-bcm2708
i2c-dev
rtc_ds1307
```
#### Step 3
```bash
nano  /etc/modprobe.d/raspi-blacklist.conf
=====================
blacklist spi-bcm2708
#blacklist i2c-bcm2708
```
#### Step 4
```bash
apt-get install i2c-tools
```
###Note
pin hay i2c moudle ro be board raspberry pi vasl kon (pin vcc ro  pin (3 volte) board pi vasl kon )


#### Step 5
```bash
sudo nano /etc/rc.local
echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
hwclock -s
```

#### Step 6
reboot kon 

#### Step 7
bad az reboot dobare porte eshghal mishe 
va address morede nazar besorate [[[[  UU  ]]] dide mishe 
```bash
0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- UU -- -- -- -- 
```
#### Note 2:
agar **[i2cdetect -y 0] [i2cdetect -y 1]** ro ejra kardi var in error dad ->
Error: Could not open file `/dev/i2c-0' or `/dev/i2c/0': No such file or directory
az in method estefade bekon ta dorost she **(i2c enable nist)** 

##### In case someone else is experiencing the same issue.
1. http://www.raspberrypi.org/forums/viewtopic.php?f=28&t=97257

##### Model A & B users should add this to /boot/config.txt
```bash
device_tree=bcm2708-rpi-b.dtb
device_tree_param=i2c1=on
device_tree_param=spi=on
```
reboot
```bash
Model A+ & B+ users should add this to /boot/config.txt
device_tree=bcm2708-rpi-b-plus.dtb
device_tree_param=i2c1=on
device_tree_param=spi=on
```
reboot

#### Note 3

agar **[i2cdetect -y 1]**  run kardi va in payam ro dad 
```bash
    0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- UU -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --   
```
be khatere ine ke voltage 5 volt be rtc dadi va bayad pin vcc rtc ro be pin 3.5 volte board vasl konie.

