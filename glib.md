
1. #####to in file  in khato comment kon /etc/apt/sources.list
```bash 
deb [arch=armhf] http://debian.beagleboard.org/packages wheezy-bbb main

```
2. #####In lino hatman run kon (ta sid) ro shenasay konad
```bash
echo "deb http://ftp.debian.org/debian sid main" >> /etc/apt/sources.list
```
3. #####Run Command
```bash
apt-get update
apt-get -t sid install libc6 libc6-dev libc6-dbg
```
4. ####Please remember to hash out sid main from your sources list. **/etc/apt/sources.list* [It works, application now runs.]


###agar method bala error dad az in ravesh estefade kon 1394-07-12 (این روش ساده و بهتره)  
```bash
aptitude update
aptitude install libc6-dev
```
