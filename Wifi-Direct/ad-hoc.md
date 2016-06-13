source : [link](http://slicepi.com/creating-an-ad-hoc-network-for-your-raspberry-pi/)
### step 1:
```bash
sudo nano /etc/network/interfaces
auto lo
iface lo inet loopback
iface eth0 inet dhcp

auto wlan0
iface wlan0 inet static
address 192.168.1.1
netmask 255.255.255.0
wireless-channel 1
wireless-essid RPiwireless
wireless-mode ad-hoc
```

### step 2: 
install a package to allow your Pi to assign a device connecting to it an IP address
```bash
sudo apt-get install isc-dhcp-server
```

### step 3:
```bash
sudo nano /etc/dhcp/dhcpd.conf
```
add below code : 
```bash
ddns-update-style interim;
default-lease-time 600;
max-lease-time 7200;
authoritative;
log-facility local7;
subnet 192.168.1.0 netmask 255.255.255.0 {
 range 192.168.1.5 192.168.1.150;
 }
```
