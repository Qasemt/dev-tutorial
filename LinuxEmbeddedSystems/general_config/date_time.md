## Time and Timezone

- Alpine 👌 ⏰ ✔️

```bash
# apk add --no-cache tzdata
# ls /usr/share/zoneinfo
# p /usr/share/zoneinfo/Asia/Tehran /etc/localtime
# echo "Asia/Tehran" >  /etc/timezone

### You can now remove the other timezones
# apk del tzdata
```

- ubuntu 👌 ⏰✔️

```bash
# cat /etc/timezone
# timedatectl list-timezones
# timedatectl set-timezone your_time_zone -> for exam Asia/Tehran
# timedatectl
```

---

## ⏰ Date Time CMD

#####

```bash
date +%Y%m%d -s "20150422"
```

##### Set time from the command line

```bash
date +%T -s "11:14:00"
```

##### Set time and date from the command line

```bash
date -s "19 APR 2012 11:14:00"

or

date -s "2013-11-19 15:11:40"
```

##### Linux check date from command line

```bash
date
```

##### time zone query

```bash
date +%Z
```

##### UTM Time

```bash
date --utc
 Sat Sep  5 07:57:50 UTC 2015
```

---

I always keep my hardware clocks set to UTC/GMT. This maintains my clocks uniformly without any worries about "Daylight Savings Time". This is important, because when you set the hardware clock from the system clock (kept by the Linux kernel), you need to know if this is the case. To set the hardware clock from the system clock, leaving the hardware clock in UTC, enter the following:

```bash
 hwclock --systohc --utc
```

---

#### Change Time Zone

###### Source :

- http://derekmolloy.ie/automatically-setting-the-beaglebone-black-time-using-ntp/

```bash
rm /etc/localtime
ln -s /usr/share/zoneinfo/Iran /etc/localtime
```

for check

```bash
ls -al|grep localtime
 lrwxrwxrwx  1 root root      24 Apr 22 10:02 localtime -> /usr/share/zoneinfo/iran
```

Setting the system time using the date command does not automatically synchronize the RTCs. Use the hwclock command after entering the date command to synchronize an RTC with the updated system time:

```bash
hwclock -w
```

Update from the command line against a time server
You can update the clock manually, without the need of the daemon with ntpdate

```bash
ntpdate 129.6.15.28
```

Using the date and hwclock Command
Use these two commands to manipulate the system clock and hardware clock directly.
From http://busybox.net/downloads/BusyBox.html#hwclock .

```bash
hwclock -r
(Show hardware clock time)
hwclock -w
(Set hardware clock to system time)
hwclock -s
(Set system time from hardware clock)
-f FILE can be used to specify a particular RTC device (e.g. /dev/rtc2).
```
