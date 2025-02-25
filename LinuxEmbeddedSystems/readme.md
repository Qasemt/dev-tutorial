# 🗂️ Index CMDs

- [Linux Command](./general_config/linux_command.md)
- [Auto start (openRC) ](general_config/auto_start_with_open_rc.md)
- [Auto start](./general_config/auto_start_old.md)
- [IP & Network](./general_config/ip_network.md)
- [Date Time Linux](./general_config/date_time.md)
- [Curl](./general_config/curl.md)
- [SSH](./ssh_server/Readme.md)
- [Rsync](./general_config/rsync.md)
- [UWF](./general_config/uwf.md)
- [Resize Disk ](./general_config/resize_disk_linux.md)

#### Alpine

- [Setup Alpine](./general_config/alpine_setup.md)
- [Alpine Tools](./general_config/alpine.md)

#### VNC

- [VNC](./general_config/vnc.md)
- [VNC2](./general_config/vnc2.md)

#### Webserver

- [Nginx Compile](./general_config/nginx_compile.md)

### Devices

- [BBB](./general_config/devices/BBB.md)
- [BeagleBon Black](./general_config/beaglebone_black.md)
- [Serial port](./general_config/devices/qextserialport.md)
- [Audio](./general_config/devices/audio.md)
- [Raspberry remove unnecessary programs](./general_config/devices/raspberry_remove_unnecessary_programs.md)
- [Free Desktop](./general_config/devices/free_desktop.md)
- [Port](./general_config/devices/ports.md)
- [GPIO](./general_config/gpio.md)
- [Bluethooth](./general_config/devices/bluetooth.md)
- [I2C/RTC](./general_config/devices/i2c_and_rtc.md)
- [lighdm](./general_config/devices//lightdm.md)
- [Backup MMC](./general_config/devices/backup_EMMC.md)
- [No Pass](./general_config/devices/NoPass.md)
- [GIS Lib Config](./general_config/devices/gis_lib_config.md)

> Wifi

- [Wifi Hotspot](./general_config/devices/wifi_hotspot.md)
- [Wifi Power](./general_config/devices/wifi_power_management.md)
- [wifi Ad-hoc](./general_config/devices/wifi-direct/ad-hoc.md)
- [wifi Supplicant](./general_config/devices/wifi-direct/wpaSupplicant.md)

#### Sim

- [sim 5320](./general_config/devices/sim5320.md)

## 📚 extract file in linux

```bash
tar xpvf /path/to/my_archive.tar.xz -C /path/to/extract

```

## 🔑 Change root password

```bash
$ sudo su
$ passwd
```

## 💽 Space Avaiable

#### **CMD 1:**

```bash
du --max-depth=1 | sort -nr

668716  .
283508  ./lib
226560  ./share
69668   ./local
58544   ./bin
25092   ./include
5332    ./sbin
4       ./src
4       ./games

```

#### **CMD 2:**

```bash
df -h
%%%%
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       1.2G  1.1G   17M  99% /
devtmpfs        459M     0  459M   0% /dev
tmpfs           463M     0  463M   0% /dev/shm
tmpfs           463M  6.2M  457M   2% /run
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
tmpfs           463M     0  463M   0% /sys/fs/cgroup
/dev/mmcblk0p1   60M   20M   41M  34% /boot

```

## 🏟️ Change host name

```
echo "alpine_pc" > /etc/hostname
hostname -F /etc/hostname
$ hostname
```
