# IP & Network

## Change IP Address

##### Note : For Jessie package update

edit /etc/apt/sources.list

```bashe
deb http://legacy.raspbian.org/raspbian/ jessie main contrib
```

and run sudo apt-get update

### Solution 3: fixed IP on the NAT network (in VirtualBox)

Then figure out which IP/Subnet you get assigned then change the config in your /etc/network/interfaces to reflect the changes:

```
auto eth0
iface eth0 inet static
        address 10.0.2.84
        netmask 255.255.255.0
        network 10.0.2.0
        broadcast 10.0.2.255
        gateway 10.0.2.2
        dns-nameservers 8.8.8.8
```

##### Step1 :

```bash
sudo nano /etc/network/interfaces
auto eth0
iface eth0 inet static
address 192.168.1.56
netmask 255.255.255.0
# optional
dns-nameservers 8.8.8.8 8.8.4.4
cb2 =>> gateway 192.168.1.210
```

---

##### Note : For Jessie

```bash
sudo nano  /etc/dhcpcd.conf
#and add at the end of the file
interface eth0
static ip_address=192.168.1.56
static routers=192.168.1.210
static domain_name_servers=8.8.8.8

interface wlan0
static ip_address=192.168.1.111/24
static routers=192.168.1.210
static domain_name_servers=8.8.8.8

```

WIFI static Config <br>

**nano /etc/network/interface**

```bash
allow-hotplug wlan0
iface wlan0 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

**nano /etc/wpa_supplicant/wpa_supplicant.conf**

```bash
country=GB
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="Raspberry"
    psk="4321wifi!@#$"
    }
```

##### Step2 :

```bash
sudo echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

### os lite jessi

- https://randomnerdtutorials.com/installing-raspbian-lite-enabling-and-connecting-with-ssh/

## for new os raspberry 
```
 sudo nmtui
```
