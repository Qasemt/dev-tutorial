#### source

- simple tutorial [link](https://gist.github.com/0/c73e2557d875446b9603)<br>
- best source - stackoverflow [link](http://unix.stackexchange.com/questions/92255/how-do-i-connect-and-send-data-to-a-bluetooth-serial-port-on-linux) <br>
- best source 2 [link](https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=125922) <br>
- source [link](https://en.wikibooks.org/wiki/Linux_Guide/Linux_and_Bluetooth)<br>
- config serial [link](http://raspberrypi.stackexchange.com/questions/23415/how-can-a-usb-bluetooth-dongle-be-used-as-login-tty)<br>
- config client/server [link](http://www.scriptscoop2.com/t/eff75faf36f2/android-why-cant-i-connect-to-my-linux-bluetooth-serial-port.html)<br>
- install bluez 5.3x [link](https://www.hackster.io/idreams/control-a-bluetooth-le-light-bulb-with-raspberry-pi-6d04cc) <br>
- install bluez 5.32 [link](http://www.elinux.org/RPi_Bluetooth_LE) <br>
- SPP Control [link](http://raspberrypi.stackexchange.com/questions/23415/how-can-a-usb-bluetooth-dongle-be-used-as-login-tty/24021#24021) <br>

---

```bash
pair 40:40:A7:7F:xx:xx
bluetoothctl 40:40:A7:7F:xx:xx
connect 40:40:A7:7F:xx:xx
remove 40:40:A7:7F:xx:xx
trust 40:40:A7:7F:xx:xx
```

#### Tools

for test use this tools [ bluetoothctl -a]<br>
Android app for test [link] (https://play.google.com/store/apps/details?id=nextprototypes.BTSerialController&hl=en)<br>

---

#### Config

##### Option

```bash
mknod -m 666 /dev/rfcomm0 c 216 0
```

##### Step 1

```bash
nano /etc/systemd/system/bluetooth.target.wants/bluetooth.service

to adjust the relevant line to read
ExecStart=/usr/lib/bluetooth/bluetoothd --noplugin=sap --compat

#update qasem : 94.04.29
ExecStartPost=/usr/bin/sdptool add --channel=22 SP
```

**Discoverable Time out** :

```bash
nano /etc/bluetooth/main.conf
#un commnet this field
DiscoverableTimeout = 0
```

##### Note: Refresh service

```bash
systemctl daemon-reload
systemctl restart bluetooth.service
```

##### Step 2

do this command

```bash
sudo systemctl daemon-reload
sudo service bluetooth restart

sudo service bluetooth status

● bluetooth.service - Bluetooth service
   Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled)
   Active: active (running) since Wed 2016-01-27 08:39:11 PST; 4min 11s ago
     Docs: man:bluetoothd(8)
 Main PID: 359 (bluetoothd)
   Status: "Running"
   CGroup: /system.slice/bluetooth.service
           └─359 /usr/lib/bluetooth/bluetoothd --noplugin=sap --compat

Jan 27 08:39:09 raspberrypi systemd[1]: Starting Bluetooth service...
Jan 27 08:39:10 raspberrypi bluetoothd[359]: Bluetooth daemon 5.23
Jan 27 08:39:11 raspberrypi bluetoothd[359]: Starting SDP server
Jan 27 08:39:11 raspberrypi bluetoothd[359]: Excluding (cli) sap
Jan 27 08:39:12 raspberrypi bluetoothd[359]: Bluetooth management interface 1.9 initialized
Jan 27 08:39:11 raspberrypi systemd[1]: Started Bluetooth service.
```

##### Step 3

Choosing an arbitrary channel 22

```bash
sudo sdptool add --channel=22 SP
reply msg : Serial Port service registered
```

for check

```bash
sdptool browse local
```

replay message

```bash
Browsing FF:FF:FF:00:00:00
Service RecHandle: 0x10000
Service Class ID List:
  "PnP Information" (0x1200)
Profile Descriptor List:
  "PnP Information" (0x1200)
    Version: 0x0103

[...]

Service Name: Serial Port
Service Description: COM Port
Service Provider: BlueZ
Service RecHandle: 0x10005
Service Class ID List:
  "Serial Port" (0x1101)
Protocol Descriptor List:
  "L2CAP" (0x0100)
  "RFCOMM" (0x0003)
    Channel: 22
Language Base Attr List:
  code_ISO639: 0x656e
  encoding:    0x6a
  base_offset: 0x100
Profile Descriptor List:
  "Serial Port" (0x1101)
Version: 0x0100
```

---

##### Step 4

###### Then I call 'listen' with rfcomm:

```bash
rfcomm listen /dev/rfcomm0 22

reply msg:
Waiting for connection on channel 22

Connection from 40:40:A7:7F:xx:xx to /dev/rfcomm0


# after connect any device you can see this port
root@raspberrypi: ls -l /dev/rfcomm0
root@raspberrypi: crw-rw---- 1 root dialout 216, 0 Feb  3 21:38 /dev/rfcomm0
```

---

##### Notes :

###### best Command for auto listing and read data

```bash
rfcomm watch 0 22 cat {}
```

###### free port

```bash
## 0 = /dev/rfcomm0
rfcomm release 0
```

---

##### Command's :

###### For Ping deive's

```bash
 l2ping XX:XX:XX:X:XX

```

###### bluetoothctl cmd's

```bash
power on
agent on
scan on
... wait ...
scan off
pair <dev>
```

###### Display the current bluetooth configuration :

```bash
hciconfig -a
```

##### Current MAc Address

```bash
hcitool dev

reply msg :
Devices:
        hci0    XX:XX:XX:XX:XX:XX

```

---

#### service run at boot

nano /etc/init.d/bluetoothhelper <br>
chmod +x /etc/init.d/bluetoothhelper <br>

```bash
# power on
hciconfig hci0 up
# discoverable

hciconfig hci0 piscan
# add channel
sdptool add --channel=22 SP
rfcomm -r watch 0 22 /sbin/agetty -L rfcomm0 115200

```

---

#### Automatically bind the device at startup

nano /etc/bluetooth/rfcomm.conf

```bash
#
  # RFCOMM configuration file.
  #
  rfcomm0 {
  #       # Automatically bind the device at startup
          bind yes;
  #
  #       # Bluetooth address of the device
          device 00:18:C5:xx:xx:xx;
  #
  #       # RFCOMM channel for the connection
          channel 1;
  #
  #       # Description of the connection
         comment "Example Bluetooth device";
  }
```

Now with:

```bash
modprobe rfcomm
rfcomm bind all
```
