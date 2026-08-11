<h1 align="center">Linux Embedded Systems</h1>

<p align="center">
  Field notes, commands and configs for embedded Linux boards.
</p>

<p align="center">
  <code>Alpine</code> · <code>Debian / Ubuntu</code> · <code>BeagleBone</code> · <code>Raspberry Pi</code> · <code>Rockchip</code>
</p>

<p align="center">
  <a href="#system">System</a> ·
  <a href="#network">Network</a> ·
  <a href="#remote-access">Remote Access</a> ·
  <a href="#boot--services">Boot &amp; Services</a> ·
  <a href="#storage">Storage</a> ·
  <a href="#boards--devices">Boards &amp; Devices</a> ·
  <a href="#servers--containers">Servers</a> ·
  <a href="#cheatsheet">Cheatsheet</a>
</p>

---

## System

| Page | Notes |
| :--- | :--- |
| [Linux Commands](./general_config/linux_command.md) | Everyday shell commands and package handling |
| [Cron](./general_config/Crontab.md) | Scheduled jobs with `crontab` |
| [Date & Time](./general_config/date_time.md) | Timezone and clock setup on Debian/Ubuntu |
| [Alpine Setup](./general_config/alpine_setup.md) | Installing and preparing Alpine Linux |
| [Free Desktop](./general_config/devices/free_desktop.md) | Desktop entries and autostart files |
| [LightDM](./general_config/devices/lightdm.md) | Start, stop and configure the display manager |
| [Passwordless Login](./general_config/devices/NoPass.md) | Auto-login without a password prompt |

## Network

| Page | Notes |
| :--- | :--- |
| [IP & Network](./general_config/ip_network.md) | Interfaces, static IP and routing |
| [iptables](./general_config/ip_table.md) | Chains, rules and NAT |
| [UFW](./general_config/uwf.md) | Simple firewall rules |
| [curl](./general_config/curl.md) | Requests, downloads and build tooling |
| [rsync](./general_config/rsync.md) | Copying and syncing files between machines |
| [Nekoray](./general_config/nekoray.md) | Proxy client setup on Linux |
| [Ports](./general_config/devices/ports.md) | Port and cape reference |

**Proxy**

| Script | Notes |
| :--- | :--- |
| [`setup-proxy.sh`](./general_config/setup-proxy.sh) | Applies a proxy system-wide on Debian — every layer at once |
| [`clear-proxy.sh`](./general_config/clear-proxy.sh) | Removes every proxy setting again, with backups |

<details>
<summary><b>Usage</b></summary>

`setup-proxy.sh` writes the proxy into all the places that matter, because
none of them read each other: systemd (system **and** user manager),
`/etc/environment`, `/etc/profile.d`, apt, wget, git, sudo `env_keep`,
`cron.d`, dconf for GTK apps, and fish/tcsh. It runs a preflight first —
if the proxy host does not resolve or the port is closed, it aborts and
writes nothing.

```bash
sudo ./setup-proxy.sh http://192.168.40.10:8080   # install
./setup-proxy.sh --show                           # resolved values, no changes
./setup-proxy.sh --verify                         # did it actually take effect?
./setup-proxy.sh --walk                           # find the stale process
sudo ./setup-proxy.sh --uninstall                 # undo
```

Dry run against a fake root, touching no real file:

```bash
ROOT=/tmp/proxytest ./setup-proxy.sh http://192.168.40.10:8080
```

**The step people miss.** A process copies its environment at `exec()` and it
can never be changed from outside afterwards. So your current shell keeps the
old value no matter how often you re-run the script — that is not a failure.
Test what the *next* login gets, then refresh:

```bash
bash -lc 'echo $https_proxy'    # the honest test
exec bash -l                    # refresh this shell, keeps SSH alive
pkill -f '.vscode-server'       # the usual stale ancestor (ppid=1)
```

A stale **ancestor** poisons every child it spawns, so killing a leaf process
does not help. `sudo reboot` clears every layer at once.

`clear-proxy.sh` reverses all of it and backs up each edited file to
`<file>.bak-<timestamp>`:

```bash
sudo ./clear-proxy.sh             # system level; reports per-user files
sudo ./clear-proxy.sh --all       # also clean ~/.bashrc, ~/.npmrc, etc.
sudo ./clear-proxy.sh --dry-run   # show only
```

Both scripts default to a placeholder address and an internal domain of
`.emdad.local` — override with `INTERNAL_DOMAIN` or edit the CONFIG block.
For a loopback proxy (cntlm, v2ray/Xray on `127.0.0.1`), make that client a
systemd unit with `WantedBy=multi-user.target`, or boot-time services will
run before it is up and fail.

</details>

**Wi‑Fi**

| Page | Notes |
| :--- | :--- |
| [Wi‑Fi Hotspot](./general_config/devices/wifi_hotspot.md) | Turning the board into an access point |
| [Wi‑Fi Power Management](./general_config/devices/wifi_power_management.md) | Preventing the adapter from sleeping |
| [Ad‑hoc Mode](./general_config/devices/wifi-direct/ad-hoc.md) | Direct board-to-board links |
| [wpa_supplicant](./general_config/devices/wifi-direct/wpaSupplicant.md) | Manual Wi‑Fi client configuration |

**Cellular**

| Page | Notes |
| :--- | :--- |
| [SIM5320](./general_config/devices/sim5320.md) | AT commands and PPP dial-up |

## Remote Access

**SSH** — [overview](./ssh_server/Readme.md)

| Page | Notes |
| :--- | :--- |
| [Passwordless Login](./ssh_server/SSH-Login-No-Password.md) | Key-based access to a board |
| [Disable SSH Timeout](./ssh_server/Disabling_SSH_Timeout.md) | Keeping long sessions alive |
| [VS Code Remote SSH](./ssh_server/SSH_Config_for_VSCode.md) | `~/.ssh/config` for Remote‑SSH |
| [SSH → PPK](./ssh_server/SSH-to-PPK-Conversion.md) | Converting keys for PuTTY |
| [Deploy Key](./ssh_server/ssh_key_for_deploy.md) | Restricted key for app updates |
| [Clone a Private Repo](./ssh_server/HOW_TO_CLONE_PRIVATE_REPO_ON_LINUX.md) | Git over SSH on a board |
| [VM & Windows Host](./ssh_server/config_vm_host_windows.md) | Port forwarding to a guest VM |

**VNC**

| Page | Notes |
| :--- | :--- |
| [Install VNC](./general_config/vnc.md) | Basic server installation |
| [x11vnc](./general_config/vnc_v2.md) | Sharing an existing X session |
| [TigerVNC](./general_config/tigervnc.md) | Direct connection guide |

## Boot & Services

| Page | Notes |
| :--- | :--- |
| [Autostart with OpenRC](./general_config/auto_start_with_open_rc.md) | Init scripts on Alpine |
| [Autostart (legacy)](./general_config/auto_start_old.md) | Older `vtlstart` approach |

## Storage

| Page | Notes |
| :--- | :--- |
| [Resize Disk](./general_config/resize_disk_linux.md) | Growing the root partition |
| [Backup eMMC](./general_config/devices/backup_EMMC.md) | Full image backup and restore |

## Boards & Devices

| Page | Notes |
| :--- | :--- |
| [BeagleBone Black](./general_config/devices/beaglebone_black.md) | Board setup and quirks |
| [BBB Pinout](./general_config/devices/BBB.md) | Hardware and cape header diagrams |
| [Rockchip](./general_config/devices/rock_chip/readme.md) | Setup and Python install scripts |
| [Raspberry Pi Slimming](./general_config/devices/raspberry_remove_unnecessary_programs.md) | Removing unnecessary packages |
| [GPIO](./general_config/gpio.md) | Reading and driving pins |
| [Serial Port](./general_config/devices/qextserialport.md) | QextSerialPort usage |
| [I²C & RTC](./general_config/devices/i2c_and_rtc.md) | Bus scanning and hardware clock |
| [Bluetooth](./general_config/devices/bluetooth.md) | Pairing and services |
| [Audio](./general_config/devices/audio.md) | ALSA devices and test sounds |
| [GIS Library Config](./general_config/devices/gis_lib_config.md) | GDAL / PROJ linker flags |
| [Build Script Notes](./general_config/devices/hunane_config_script.md) | Packaging a config script |

## Servers & Containers

| Page | Notes |
| :--- | :--- |
| [Compile Nginx](./general_config/nginx_compile.md) | Building from source with modules |
| [Podman & Distrobox](./general_config/podman_docker.md) | Rootless containers on a board |

---

## Cheatsheet

<details>
<summary><b>APT behind a proxy</b> — manual, for one-off boards</summary>

For a full system-wide setup use [`setup-proxy.sh`](./general_config/setup-proxy.sh) instead; this is the minimal manual equivalent.

```bash
sudo nano /etc/apt/apt.conf.d/90proxy
```

```conf
Acquire::http::Proxy  "http://172.20.10.1:3128";
Acquire::https::Proxy "http://172.20.10.1:3128";
```

With credentials:

```conf
Acquire::http::Proxy  "http://username:password@proxy.server:port";
Acquire::https::Proxy "http://username:password@proxy.server:port";
```

One-liner:

```bash
echo 'Acquire::http::Proxy "http://USERNAME:PASS@172.20.10.1:3128/";' \
  | sudo tee /etc/apt/apt.conf.d/95proxy
```

</details>

<details>
<summary><b>Extract an archive</b></summary>

```bash
tar xpvf /path/to/my_archive.tar.xz -C /path/to/extract
```

</details>

<details>
<summary><b>Change the root password</b></summary>

```bash
sudo su
passwd
```

</details>

<details>
<summary><b>Check free space</b></summary>

Per-directory usage, largest first:

```bash
du --max-depth=1 | sort -nr
```

```text
668716  .
283508  ./lib
226560  ./share
 69668  ./local
 58544  ./bin
```

Mounted filesystems:

```bash
df -h
```

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       1.2G  1.1G   17M  99% /
tmpfs           463M  6.2M  457M   2% /run
/dev/mmcblk0p1   60M   20M   41M  34% /boot
```

</details>

<details>
<summary><b>Change the hostname</b></summary>

```bash
echo "alpine_pc" > /etc/hostname
hostname -F /etc/hostname
hostname
```

</details>
