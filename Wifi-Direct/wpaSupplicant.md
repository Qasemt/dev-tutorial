#### Source Download 
* http://w1.fi/releases/wpa_supplicant-2.5.tar.gz
* https://bitbucket.org/jackalsh/mt7601/overview 

### install Driver TP Link TL-WN727N (best Source)

* http://askubuntu.com/questions/577941/installing-the-driver-for-tp-link-tl-wn727n-on-ubuntu-14-04
```bash
sudo apt-get install linux-headers-generic build-essential git
git clone https://github.com/porjo/mt7601.git 
cd mt7601/src
make
sudo make install
sudo mkdir -p /etc/Wireless/RT2870STA/
sudo cp RT2870STA.dat /etc/Wireless/RT2870STA/
sudo modprobe mt7601Usta

```
###### hatman patch ro ejra konid
```bash
patch < DPO_MT7601U_LinuxSTA_3.0.0.4_20130913-Linux-3.17.0-v2.patch
```

##### config
```bash
sudo ./wpa_supplicant -Dnl80211 -ira0 -c/home/qasem/wpa.config -Bd

sudo ./wpa_cli -i ra0
```

#### Config File  for make
```bash
CONFIG_DRIVER_NL80211=y
# optional, depending on libnl version you want to use:
CONFIG_LIBNL32=y

CONFIG_CTRL_IFACE=y
CONFIG_WPS=y
#CONFIG_WPS2=y
CONFIG_P2P=y
CONFIG_AP=y

# and maybe DBus
CFLAGS += -I/usr/include/libnl3

```

##### WPA Config 
```bash
nano ~/wpa.config 

ctrl_interface=/var/run/wpa_supplicant
ap_scan=1

device_name=Qasem-p2p
device_type=1-0050F204-1
driver_param=use_p2p_group_interface=1
# If you need to modify the group owner intent, 0-15, the higher
# number indicates preference to become the GO
#p2p_go_intent=15

# optional, can be useful for monitoring, forces
# wpa_supplicant to use only channel 1 rather than
# 1, 6 and 11:
#p2p_listen_reg_class=81
#p2p_listen_channel=1
#p2p_oper_reg_class=81
#p2p_oper_channel=1
```
