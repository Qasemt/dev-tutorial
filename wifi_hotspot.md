# Source 
````bash
http://willhaley.com/willhaley/blog/raspberry-pi-hotspot-ew7811un-rtl8188cus/
https://www.maketecheasier.com/set-up-raspberry-pi-as-wireless-access-point/
http://elinux.org/RPI-Wireless-Hotspot(best)
http://dev.ardupilot.com/wiki/companion-computers/raspberry-pi-via-mavlink/making-a-mavlink-wifi-bridge-using-the-raspberry-pi/

https://learn.adafruit.com/setting-up-a-raspberry-pi-as-a-wifi-access-point/install-software (best)
````

hatman be in wifi ro injor /etc/network/interfaces  tarif koni 
va nabayad be wifi digar vasl bashad ...
````bash
iface wlan0 inet static
  address 192.168.42.1
  netmask 255.255.255.0
  ---------------------------------------------------------
run sudo nano /etc/network/interfaces and add 
 up iptables-restore < /etc/iptables.ipv4.nat
to the very end

  ----------------- sample my rasp -------------------------
  auto lo

iface lo inet loopback
iface eth0 inet static
address 192.168.1.56
netmask 255.255.255.0
gateway 192.168.1.210



#auto wlan0
#allow-hotplug wlan0
#iface wlan0 inet static
#address 192.168.1.102
#netmask 255.255.255.0
#gateway 192.168.1.210
#wpa-passphrase 4321wifi!@#$
#wpa-ssid Raspberry



allow-hotplug wlan0
iface wlan0 inet static
address 192.168.1.111
netmask 255.255.255.0


up iptables-restore < /etc/iptables.ipv4.nat



//-----------------------------------
apt-get install hostapd
badd 
az in hotspot baray usb wifi UDUP (RTL8188CUS ) estefade kon 
wget http://dl.dropbox.com/u/1663660/hostapd/hostapd.zip
unzip hostapd.zip 
sudo mv /usr/sbin/hostapd /usr/sbin/hostapd.ORIG 
sudo mv hostapd /usr/sbin
sudo chmod 755 /usr/sbin/hostapd
---------------------------------
sudo apt-get install isc-dhcp-server (https://www.maketecheasier.com/set-up-raspberry-pi-as-wireless-access-point/)
or 
sudo apt-get install  udhcpd (http://elinux.org/RPI-Wireless-Hotspot)
-------------------------------------
/etc/hostapd/hostapd.conf

interface=wlan0
driver=rtl871xdrv
#driver=nl80211
ssid=QT
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=1234a1234
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
--------------------------------------------------------------------------------
sudo nano /etc/dhcp/dhcpd.conf (https://www.maketecheasier.com/set-up-raspberry-pi-as-wireless-access-point/)

subnet 192.168.1.0 netmask 255.255.255.0 {
range 192.168.1.10 192.168.1.200;
option broadcast-address 192.168.1.255;
option routers 192.168.1.1;
default-lease-time 600;
max-lease-time 7200;
option domain-name "local";
option domain-name-servers 8.8.8.8, 8.8.4.4;
}

-------------------- 
noke hamzan nemishavad ham ethernet va wifi esftedae kard 
baray test dhcp server 


Run the following commands
 sudo service hostapd start 
sudo service isc-dhcp-server start

you can always check the status of the host AP server and the DHCP server with
 sudo service hostapd status
sudo service isc-dhcp-server status

To start the daemon services. Verify that they both start successfully (no 'failure' or 'errors')
Then to make it so it runs every time on boot
 sudo update-rc.d hostapd enable 
sudo update-rc.d isc-dhcp-server enable
````
