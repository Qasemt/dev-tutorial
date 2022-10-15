#### References 
  1. [Set up a wireGuard client (**linux**)](client_wireguard_linux.md)
---
#### How To Set Up WireGuard
   * Installing WireGuard 
```
sudo apt update
sudo apt install wireguard qrencode resolvconf 
```
   * Service Handle
```
#systemctl start wg-quick@wg0
#systemctl status wg-quick@wg0
OR 

wg-quick up wg0
wg-quick down wg0

```
  * Create QR CODE 
```
#qrencode -t ansiutf8 < client01.conf
```
