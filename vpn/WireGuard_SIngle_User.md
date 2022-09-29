* https://www.youtube.com/watch?v=QjbwKPBZEeU
* https://wiki.alpinelinux.org/wiki/Configure_a_Wireguard_interface_(wg) az connfig in estefade nakon
----
## How Install WireGuard Into CentOS 7

System Requirements :

OS: CentOS7

RAM: minimum 1024MB (2GB preferable)
```
#yum install kernel-devel kernel-headers # you have to install kernel headers first
#yum install epel-release https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
#yum install yum-plugin-elrepo
#yum install kmod-wireguard wireguard-tools
#yum install qrencode or apk add libqrencode
#yum install nano
```

#### Reboot and then load the module
```
$ modprobe wireguard
```

If the modprob does not work, you may have to reboot the machine.
```
#reboot
#lsmod | grep -i wireguard
```

```
#cd /etc/wireguard/
```

```
#umask 077
#umask
#wg genkey | tee server-private.key | wg pubkey > server-public.key
#ls -al
___________________________
#nano wg0.conf
```
put all of line into the file and edit some section and SAVE !
```
[Interface]
Address = 192.168.200.254/24
SaveConfig = true
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 55525
PrivateKey = _$SERVER_PRIVATE_KEY_

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 192.168.200.5/32
```

```
#cat server-private.key
```

copy key and insert
```
#nano wg0.conf
```

SAVE
```
#wg genkey | tee client-private.key | wg pubkey > client-public.key
#ls
#cat client-public.key
copy key and insert
#nano wg0.conf
SAVE

```
___________________________

```
#nano client01.conf
```
put all of line into the file and some section and SAVE !
```
[Interface]
Address = 192.168.200.5/24
PrivateKey = $_PRIVATE_KEY
DNS = 8.8.8.8

[Peer]
PublicKey = $_SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = SERVERIP:55525
PersistentKeepalive = 15
```

_____
```
#cat client-private.key
```

copy key and insert
```
#cat server-public.key
```

copy key and insert

Please put your ip address into the file and sale 

IPAdress:PORT

___________________________

Check iptables
```
#iptables -vnL
```
Check IP forward
```
#sysctl -a | grep -i forward
```
make wireguard ip forward

___________________________
Enable IP Forwarding
If you intend for peers to be able to access external resources (including the internet), you will need to enable forwarding. Edit the file /etc/sysctl.conf (or a .conf file under /etc/sysctl.d/) and add the following line.

#nano /etc/sysctl.d/wireguard.conf

```

put all of line into the file and some section and SAVE !

net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding=1
___________________________

#sysctl -p /etc/sysctl.d/wireguard.conf
#sysctl -a | grep -i ip_forward
```
check file for make QR Code !
```
#ls
#qrencode -t ansiutf8 < client01.conf
```
you will see qrcode for scan for your mobile phone | Android & IOS

for make conf file in your windows please print code and copy to .conf file
```
#cat client01.conf
```
copy code same like video to one file and save with .conf

START SERVICE :
```
#systemctl start wg-quick@wg0
#systemctl status wg-quick@wg0
```
