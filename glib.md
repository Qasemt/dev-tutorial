
```bash 
1- to in file  in khato comment kon /etc/apt/sources.list
deb [arch=armhf] http://debian.beagleboard.org/packages wheezy-bbb main


2- In lino hatman run kon (ta sid) ro shenasay konad
echo "deb http://ftp.debian.org/debian sid main" >> /etc/apt/sources.list
apt-get update
apt-get -t sid install libc6 libc6-dev libc6-dbg
echo "Please remember to hash out sid main from your sources list. /etc/apt/sources.list"

It works, application now runs.



```

###agar method bala error dad az in ravesh estefade kon az in ravesh estefade koni behtare
```bash
aptitude update
aptitude install libc6-dev
```
