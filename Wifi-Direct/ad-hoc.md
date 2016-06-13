source : [link](http://slicepi.com/creating-an-ad-hoc-network-for-your-raspberry-pi/)
### step 1:
sudo nano /etc/network/interfaces
### step 2: 
install a package to allow your Pi to assign a device connecting to it an IP address
```bash
sudo apt-get install isc-dhcp-server
```

### step 3:
sudo nano /etc/dhcp/dhcpd.conf
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
