#####I think @Jivings answer may be better, but I have it in my notes to do this:
#####Install apt-get install x11-xserver-utils

#####Edit /etc/xdg/lxsession/LXDE/autostart


#####Append these lines:
```bash
@xset s noblank
@xset s off
@xset -dpms
pkill openbox
```


######Possibly also comment out the line that says @xscreensaver -no-splash, so the complete file should look something like this:
```bash
@lxpanel --profile LXDE
@pcmanfm --desktop --profile LXDE
# @xscreensaver -no-splash

@xset s noblank
@xset s off
@xset -dpms
pkill openbox
```
######Also edit /etc/kbd/config and make sure these values are set as follows (however I believe this is only for when the lightweight desktop (LXDE) is not running (i.e. the pi is still in text / terminal mode):
```bash
BLANK_TIME=0
BLANK_DPMS=off
POWERDOWN_TIME=0
```

I believe that the /etc/xdg/lxsession/LXDE/autostart may be the sort of system-wide version of ~/.xinitrc but someone else probably knows the nuances better.
shareimprove this answer

```bash
/////------------------------------
------------------------behtarin source -----------------------------
source khob : http://alexba.in/blog/2013/01/07/use-your-raspberrypi-to-power-a-company-dashboard/
nano ~/vtlrun.bash
----
/usr/local/softwares/vtl/vtlcore -qws
----

ghable hame bayad vtlrun.bash ro 
ba dastor zire ejrayee kkoni -> chmod +x vtlrun.bash

nano  ~/.config/lxsession/LXDE/autostart 
and add this code 
~/vtlrun.bash
===================== Remove cursor mouse === behtarin method =============== حتما از این روش استفاده کن
nano /etc/lightdm/lightdm.conf
in tago pida kon 
xserver-command=X -bs -core -nocursor
and 
autologin-user= root
****** important *********
hatman [autologin-user= root] user root ro set kon ,agar in
parametr set nashavad autostart baray profile root call nemishavad 
````
### Source 
1: https://glframebuffer.wordpress.com/2014/01/28/how-to-auto-login-in-lxde-for-raspberrypi-and-bbb/
2: http://askubuntu.com/questions/157134/how-to-hide-the-mouse-cursor



