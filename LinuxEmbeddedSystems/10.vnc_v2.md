# Setup VNC Server (x11vnc) on Linux Mint 18

This tutorial was adapted from here.

1. Remove the default Vino server:
```shellscript
sudo apt-get -y remove vino
```
2. Install x11vnc:
```shellscript
sudo apt-get -y install x11vnc
```
3. Create the directory for the password file:
```shellscript
sudo mkdir /etc/x11vnc
```
4. Create the encrypted password file:
```shellscript
sudo x11vnc --storepasswd /etc/x11vnc/vncpwd
```
You will be asked to enter and verify the password.  Then press Y to save the password file.

5. Create the systemd service file for the x11vnc service:
```shellscript
sudo xed /lib/systemd/system/x11vnc.service
```
Copy/Paste this code into the empty file:
```shellscript
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -noxdamage -repeat -rfbauth /etc/x11vnc/vncpwd -rfbport 5900 -shared

[Install]
WantedBy=multi-user.target
```

6: Reload the services:
```shellscript
sudo systemctl daemon-reload
```
7. Enable the x11vnc service at boot time:
```shellscript
sudo systemctl enable x11vnc.service
```
8. Start the service:

Either reboot or
```shellscript
sudo systemctl start x11vnc.service
```

# Configure your Firewall

#### allowing single port 5901 port
```
#allow vnc
$ sudo ufw allow 5901/tcp

#allow SSH
$ sudo ufw allow OpenSSH
```
