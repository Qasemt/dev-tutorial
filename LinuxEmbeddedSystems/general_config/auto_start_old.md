##### Edit or Add vtlstart

```bash
sudo nano /etc/init.d/vtlstart
```

##### Copy this Codes

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

##### Step 2

Run this Commands

```bash
sudo /etc/init.d/vtlstart start
cd /etc/init.d
sudo update-rc.d vtlstart defaults
sudo update-rc.d vtlstart defaults 98 02
```

##### For handling

```bash
sudo update-rc.d vtlstart disable
sudo update-rc.d vtlstart enable
```
