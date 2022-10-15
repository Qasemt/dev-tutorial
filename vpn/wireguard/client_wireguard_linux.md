### Set up a WireGuard client

nano /etc/wireguard/wg0.conf

```
# Config client for Linode VPN #
[Interface]
## This Desktop/client's private key ##
PrivateKey = {KEY_GOES_HERE}
 
## Client ip address ##
Address = 10.8.0.2/24
 
[Peer]
## Remote Ubuntu 20.04 wg0 server public key ##
PublicKey = {KEY_GOES_HERE}
 
## set ACL ##
#################################################
## Allow remote server as gateway 
## Edit/Update old AllowedIPs entry as follows 
## Otherwise client won't show server's IP 
#################################################
AllowedIPs = 0.0.0.0/0
 
## Your Ubuntu 20.04 LTS server's public IPv4/IPv6 address and port ##
Endpoint = {SERVER_IP_HERE}:51194
 
##  Key connection alive ##
PersistentKeepalive = 15
```

```bash
$ wg-quick up wg0
```
