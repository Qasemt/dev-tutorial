
### Install VNC
```bash
root@beaglebone:~# apt-get update
root@beaglebone:~# apt-get upgrade
root@beaglebone:~# apt-get dist-upgrade
sudo apt-get install tightvncserver
```

```bash
cd /etc/init.d
sudo nano /etc/init.d/vncboot
sudo nano  vncboot
```
##### Add the following content to the file:
```bash
#!/bin/bash
### BEGIN INIT INFO
# Provides:          tightvncserver
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: vnc server
# Description:
#
### END INIT INFO
# Carry out specific functions when asked to by the system
case "$1" in
start)
    su pi -c '/usr/bin/vncserver -geometry 1440x900'
    echo "Starting VNC server "
    ;;
stop)
    pkill vncserver
    echo "VNC Server has been stopped (didn't double check though)"
    ;;
*)
    echo "Usage: /etc/init.d/blah {start|stop}"
    exit 1
    ;;
esac

exit 0
```

##### Check the VNC server is not running:
```bash
ps aux | grep vnc
```
##### baray ejraye kardan file
```bash
chmod +x /etc/init.d/vncboot
```

 ##### start up setting 
```bash
sudo /etc/init.d/vncboot start
cd /etc/init.d
sudo update-rc.d vncboot defaults
```
##### Note:
agar in cmd "sudo update-rc.d vncboot defaults" ro vared kardi va error zir ro dad 
be khater in eke script hay aval file ro to file vncboot vared nakardi (4 or 5 khate aval)

insserv: warning: script 'K01vncboot' missing LSB tags and overrides
insserv: warning: script ' vncboot ' missing LSB tags and overrides

##### How to change VNC Server password on Linux
```bash
vncpasswd
```
##### How to Reset

You will then be prompted to enter a new password twice. Choose your new vnc server password and then restart the vncserver service using the following command.
```bahs
service vncserver restart
```

#### XRDP
To install xrdp on a **Raspberry Pi** running Raspbian use:
```bahs
sudo apt-get install xrdp
```

