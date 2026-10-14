# USB Internet from Windows to the Luckfox Lyra (ICS)

Share a Windows PC's internet connection with a Luckfox Lyra RK3506G2 board over the USB cable using ICS. Over USB the board exposes an RNDIS network interface named `usb0`, and Windows acts as the gateway.

**Prerequisites:**

- A Luckfox Lyra (RK3506G2) board running a Buildroot image with `/etc/init.d/S??*`-style init, and root access on the board.
- Windows with ICS (Internet Connection Sharing) and Administrator rights. The Windows version these steps were tested on was not recorded.
- Blast radius: the Windows ICS registry settings; on the board, `/etc/init.d/S99net` and `/etc/resolv.conf`.

| Side | Interface | IP address |
| --- | --- | --- |
| Windows (gateway) | RNDIS adapter | 192.168.123.99 |
| Luckfox Lyra board | usb0 | 192.168.123.100 |
| DNS | — | 8.8.8.8 |

Both sides must be on the same subnet (netmask 255.255.255.0).

## Configure Windows

Change the ICS default address to 192.168.123.99, then restart ICS. Run these in PowerShell as Administrator.

> **Warning:** this changes the ICS registry settings. Every connection that uses Windows ICS (not just this board) moves to the 192.168.123.0/24 subnet. To undo, set both values back to the Windows default `192.168.137.1` and restart the `SharedAccess` service.

```powershell
$p = "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters"
Set-ItemProperty -Path $p -Name ScopeAddress -Value "192.168.123.99"
Set-ItemProperty -Path $p -Name ScopeAddressBackup -Value "192.168.123.99"
Restart-Service SharedAccess
```

1. Open `ncpa.cpl`.
2. On the adapter that has internet (e.g. Wi-Fi) → Properties → Sharing, untick sharing and click OK.
3. Tick it again and select the board's RNDIS adapter.
4. Check with `ipconfig` that the RNDIS adapter got 192.168.123.99.

After a Windows update or restart, ICS may revert to 192.168.137.1; if so, repeat the steps above.

## Manual test on the board

These commands bring the link up until the next reboot and confirm the path works. The last line overwrites the current `/etc/resolv.conf`:

```sh
ifconfig usb0 192.168.123.100 netmask 255.255.255.0 up
route del default 2>/dev/null
route add default gw 192.168.123.99 usb0
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

Test step by step:

| Command | What it tests | If it fails |
| --- | --- | --- |
| `ping -c 3 192.168.123.99` | Link to Windows | USB connection, subnet, or Windows firewall |
| `ping -c 3 8.8.8.8` | Internet access | Default route, or ICS not enabled |
| `ping -c 3 google.com` | DNS | Contents of `/etc/resolv.conf` |

## Persistent S99net script

This script checks the address, default route and DNS every 5 seconds and restores whichever has been lost. File path: `/etc/init.d/S99net`

```sh
#!/bin/sh

IP=192.168.123.100
GW=192.168.123.99

case "$1" in
  start|"")
    (
      while true; do
        if [ -d /sys/class/net/usb0 ]; then
          # if IP is missing, set it
          if ! ifconfig usb0 | grep -q "inet addr:$IP"; then
            ifconfig usb0 $IP netmask 255.255.255.0 up
            echo "$(date) IP set" >> /tmp/s99net.log
          fi
          # if default route is missing, add it
          if ! route -n | grep -q "^0.0.0.0"; then
            route add default gw $GW usb0 2>/dev/null && \
              echo "$(date) route added" >> /tmp/s99net.log
          fi
          # DNS
          grep -q "8.8.8.8" /etc/resolv.conf 2>/dev/null || \
            echo "nameserver 8.8.8.8" > /etc/resolv.conf
        fi
        sleep 5
      done
    ) &
    ;;
esac
exit 0
```

Install it (strip CRLF, make it executable, flush to storage). The last command reboots the board:

```sh
sed -i 's/\r$//' /etc/init.d/S99net
chmod +x /etc/init.d/S99net
sync
reboot
```

After boot, wait about 30 seconds; seeing `route added` twice in `/tmp/s99net.log` is normal.

To remove it: `rm /etc/init.d/S99net`, then `sync` and reboot.

## Root cause

The real problem was that `usb0` was re-created after the script ran, which wiped the default route. Order of events at boot:

1. Around second 10, `S99net` set the address and default route on `usb0`.
2. Shortly after, the board's USB startup script restarted the RNDIS gadget and a new `usb0` was created. Symptom: the MAC changed from `B6:D3:69:6D:5A:E5` to `46:C7:C7:8E:8E:B9`.
3. When the old interface disappeared, Linux removed its routes too, leaving only the local 192.168.123.0 route in `route -n`.
4. With no default route, pinging 8.8.8.8 failed with `Network is unreachable`.

The first script ran only once; the new one uses a watchdog loop, so it doesn't depend on when `usb0` gets re-created.

A side issue early on: Windows was on 192.168.123.99 while the board was on 192.168.137.2 with gateway 192.168.137.1 — two different subnets.

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `/tmp/s99net.log` doesn't exist | Script didn't run | `cat -A` to look for `^M`, then `sed -i 's/\r$//'`, `chmod +x` and `sync` |
| Changes are lost after a reset | Power was cut without `sync` | Run `sync` before resetting |
| `Network is unreachable` | No default route | Check `route -n`; install the watchdog script |
| No reply from 192.168.123.99 | ICS is off or reverted to 137.1 | `ipconfig` on Windows and repeat Configure Windows |
| Ping works by IP but not by name | DNS | Contents of `/etc/resolv.conf` |
| `usb0` MAC has changed | USB gadget was restarted | Normal; the watchdog script handles it |

Status checks on the board:

```sh
cat /tmp/s99net.log
ifconfig usb0
route -n
grep -rl usb0 /etc/init.d/ /etc/network/ 2>/dev/null
```
