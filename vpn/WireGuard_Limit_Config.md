* https://www.cyberciti.biz/faq/how-to-set-up-wireguard-firewall-rules-in-linux
* https://dev.to/tangramvision/what-they-don-t-tell-you-about-setting-up-a-wireguard-vpn-1h2g
* https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/


## install wireguard in alpine
```
apk add wireguard-tools

modprobe wireguard

```

#### KEY GEN SERVER AND CLIENT
```
wg genkey | tee server-private.key | wg pubkey > server-public.key
wg genkey | tee client-private.key | wg pubkey > client-public.key
```
#### SERVER WIREGUARD ON VIRTUALBOX [NAT] 
```
[Interface]
Address = 10.0.0.1/24
ListenPort = 55525
PrivateKey = SERVER_PRIVATE_KEY_

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
 

[Peer]
PublicKey = CLIENT_PUBLIC_KEY 
#AllowedIPs = 10.0.0.2/32,192.168.1.0/24
AllowedIps = 10.0.0.2/32


```
##### Note :

* On your  server, set AllowedIPs =  10.0.0.2/32 (the WireGuard address of your iPhone).
* On your client, keep AllowedIPs = 0.0.0.0/0 (all IPv4 addresses). 

---
##### WIREGUARD  CLIENT  LINUX ON VIRTUALBOX [NAT]
```
[Interface]
Address = 10.0.0.2/32
PrivateKey = $Client_PRIVATE_KEY
DNS = 8.8.8.8


[Peer]
PublicKey =  $_SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0, ::/0
#Endpoint = 10.0.2.15:55525
Endpoint =192.168.1.37:55525
PersistentKeepalive = 15
```
#### TEST SERVER
```
wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip
```
---
### AUTO START 
$ nano /etc/init.d/wireguard
```
#!/sbin/openrc-run

description="WireGuard Quick"

depend() {
    need localmount
    need net
}

start() {
    wg-quick up wg0
}

stop() {
    wg-quick down wg0
}
```
* $ chmod +x /etc/init.d/wireguard
* $ rc-update add wireguard default
---

#### Update wireguard config files for firewall and routing support ↑

```
[Interface]
...
...
PostUp = /etc/wireguard/postup.sh
PostDown = /etc/wireguard/postdown.sh
```
edit postup.sh
```shellscript
#!/bin/sh
iptables -A FORWARD -i wg0 -j ACCEPT;
...
...
...
```

* chmod a+rx  /etc/wireguard/postup.sh
* chmod a+rx  /etc/wireguard/postdown.sh
