### AUTO START 
* [refrence][1]

$ nano /etc/init.d/servicename
```
#!/sbin/openrc-run

description="WireGuard Quick"

depend() {
    need localmount
    need net
}

start() {
  # [&] Execute a program from the bash terminal without waiting 
     
  $ (program start) &>/dev/null & 
}

stop() {
  $ (program stop) &>/dev/null &
  OR 
  $ kill $(ps aux | grep 'program name' | awk '{print $2}')
}
```
* $ chmod +x /etc/init.d/script
* $ rc-update add script default
* $ rc-update del script default

in ubuntu :
 * update-rc.d* script defaults


[1]:https://wiki.gentoo.org/wiki/OpenRC
