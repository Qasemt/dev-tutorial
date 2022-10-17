### AUTO START 
* [refrence][1]
* [reference service ctl ](https://timleland.com/how-to-run-a-linux-program-on-startup/)
* [reference full service ctl](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
---
### ALPINE 
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
* $ rc-update add script default ✔️
* $ rc-update del script default ✔️

server [name service] (status / restart / start / stop)

in ubuntu :
 * update-rc.d* script defaults


[1]:https://wiki.gentoo.org/wiki/OpenRC

---

### Ubuntu And Debian
 #### How to run a Linux Program on Startup ✔️✔️✔️✔️✔️✔️
 1. Run this command
```
sudo nano /etc/systemd/system/YOUR_SERVICE_NAME.service
```
 2. Paste in the command below. Press ctrl + x then y to save and exit
 
```
Description=GIVE_YOUR_SERVICE_A_DESCRIPTION

Wants=network.target
After=syslog.target network-online.target

[Service]
Type=simple
ExecStart=YOUR_COMMAND_HERE
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
```
Sample NGINX :
```yml
Description= v2ray proxy server 
Documentation=man:nginx(8)
After=network.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
```

* systemctl start YOUR_SERVICE_NAME
* systemctl status YOUR_SERVICE_NAME
* systemctl enable YOUR_SERVICE_NAME (To start a service at boot, use the enable command)
* systemctl daemon-reload
