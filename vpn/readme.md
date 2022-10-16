 ### Check which ports are listening
 
 ```
 netstat -tulpn
 ```

### Generate a self signed certificate and type in anything you like

```
cd ~;openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 4095
```
---
### UUID Generator 
  - https://www.uuidgenerator.net/

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
