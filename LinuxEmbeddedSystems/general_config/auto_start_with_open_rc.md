### AUTO START 
* [refrence][1]

$ nano /etc/init.d/wireguard
```
#!/sbin/openrc-run

description="WireGuard Quick"

depend() {
    need localmount
    need net
}

start() {
  # [&] Execute a program from the bash terminal without waiting 
     
  $ program &>/dev/null & 
}

stop() {
  $ program &>/dev/null &
}
```
* $ chmod +x /etc/init.d/script
* $ rc-update add script default
* $ rc-update del script default


[1]:https://wiki.gentoo.org/wiki/OpenRC
