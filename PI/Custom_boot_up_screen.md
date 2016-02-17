## Custom boot up screen

This solution works but there are a few seconds of text shown before the boot image appears.
```bash
Install fbi
```
sudo apt-get install fbi
Copy the splashscreen image to be used
Copy your custom splash image into: /etc/ and name it "splash.png".

Presumably the resolution to use is 1920x1080px.

Create A Script

```bash
sudo nano
```

Paste the following into the text editor:

```bash

#! /bin/sh
### BEGIN INIT INFO
# Provides:          asplashscreen
# Required-Start:
# Required-Stop:
# Should-Start:      
# Default-Start:     S
# Default-Stop:
# Short-Description: Show custom splashscreen
# Description:       Show custom splashscreen
### END INIT INFO


do_start () {

    /usr/bin/fbi -T 1 -noverbose -a /etc/splash.png    
    exit 0
}

case "$1" in
  start|"")
    do_start
    ;;
  restart|reload|force-reload)
    echo "Error: argument '$1' not supported" >&2
    exit 3
    ;;
  stop)
    # No-op
    ;;
  status)
    exit 0
    ;;
  *)
    echo "Usage: asplashscreen [start|stop]" >&2
    exit 3
    ;;
esac

:
```

IMPORTANT – If copying and pasting via SSH check it has pasted in correctly (pasting via FiseSSH for us caused the # lines and the esac line to be altered and need modifying back to be correct)

Exit and save the file as: /etc/init.d/asplashscreen

(using a name starting with 'a' will ensure it runs first)

Finally make the script executable and install it for init mode:

```bash
sudo chmod a+x /etc/init.d/asplashscreen
sudo insserv /etc/init.d/asplashscreen
Thats it:


sudo reboot
 ```
 

Getting Out Of Black Screen
If you get a black screen at the end of booting (if you've not setup auto running the GUI etc) use CTRL + ALT + F2 to get the command prompt


