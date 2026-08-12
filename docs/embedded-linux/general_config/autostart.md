# Autostart / Init Scripts

Running a program automatically at boot, across the three init systems you'll actually run into on these boards: OpenRC (Alpine), systemd (Ubuntu/Debian), and legacy SysV init.

- [reference][1]
- [reference service ctl](https://timleland.com/how-to-run-a-linux-program-on-startup/)
- [reference full service ctl](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
- [service script for openrc](http://big-elephants.com/2013-01/writing-your-own-init-scripts/)

[1]: https://wiki.gentoo.org/wiki/OpenRC

---

## OpenRC (Alpine)

```bash
nano /etc/init.d/servicename
```

```bash
#!/sbin/openrc-run

description="app Quick"

depend() {
    need localmount
    need net
}
start() {
  ebegin "Starting v2ray"
    start-stop-daemon --wait 200 \
    --background --start --exec  /root/folder/app  --chdir /root/folder/ -u root   --make-pidfile --pidfile /root/folder/app.pid
    eend $?
}

stop() {
ebegin "Stopping app"
    start-stop-daemon --stop --exec /root/folder/app --chdir /root/folder/   --pidfile  /root/folder/app.pid
    eend $?
}

reload() {
 ebegin "Reloading app"
    start-stop-daemon --exec  /root/folder/app  \
    --chdir /root/folder/ \
    --pidfile /root/folder/app.pid \
    -s 1
    eend $?
}
```

```bash
chmod +x /etc/init.d/script
rc-update add script default
rc-update del script default
```

server [name service] (status / restart / start / stop)

In Ubuntu, the equivalent is:

```bash
update-rc.d script defaults
```

---

## systemd (Ubuntu / Debian)

1. Create the unit file:

    ```bash
    sudo nano /etc/systemd/system/YOUR_SERVICE_NAME.service
    ```

2. Paste in the template below. Press ctrl+x then y to save and exit:

    ```ini
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

### Sample: NGINX

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

### Sample: VPN server (SoftEther)

```yml
[Unit]
Description=SoftEther VPN Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/vpnserver/vpnserver start
ExecStop=/usr/local/vpnserver/vpnserver stop

[Install]
WantedBy=multi-user.target
```

### Sample: v2ray

```ini
Description=v2ray server

Wants=network.target
After=syslog.target network-online.target

[Service]
Type=simple
ExecStart=/root/v2ray/v2ray run -config /root/v2ray/config.json
Restart=on-failure
RestartSec=3
KillMode=process

[Install]
WantedBy=multi-user.target
```

### Managing the service

```bash
systemctl start YOUR_SERVICE_NAME
systemctl status YOUR_SERVICE_NAME
systemctl enable YOUR_SERVICE_NAME   # start at boot
systemctl daemon-reload
```

View logs:

```bash
journalctl -u YOUR_SERVICE_NAME
```

---

## SysV init (legacy)

Older boards/distros without OpenRC or systemd. Example: autostarting a custom `vtlcore` binary via a hand-written `/etc/init.d` script.

```bash
sudo nano /etc/init.d/vtlstart
```

```bash
#! /bin/sh
### BEGIN INIT INFO
# Provides:          vtlstart
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: vtlstart
### END INIT INFO
# /etc/init.d/vtlstart
#

# Carry out specific functions when asked to by the system
case "$1" in
start)
    su root  -c '/usr/local/softwares/vtl/vtlcore -qws  > /dev/null 2>&1'
    echo "Starting vtlcore "
    ;;
stop)
    pkill vtlcore
    echo "vtlcore  has been stopped (didn't double check though)"
    ;;
*)
    echo "Usage: /etc/init.d/blah {start|stop}"
    exit 1
    ;;
esac

exit 0
```

Register and start it:

```bash
sudo /etc/init.d/vtlstart start
cd /etc/init.d
sudo update-rc.d vtlstart defaults
sudo update-rc.d vtlstart defaults 98 02
```

Enable/disable later:

```bash
sudo update-rc.d vtlstart disable
sudo update-rc.d vtlstart enable
```
