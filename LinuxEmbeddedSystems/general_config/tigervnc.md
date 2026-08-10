<div align="center">

# 🖥️ TigerVNC — Direct Connection Guide

**No SSH Tunnel · Auto-Start at Boot · No User Login Required**

`Ubuntu / systemd` · `GNOME Flashback + Metacity` · `Display :1`

</div>

---

> [!CAUTION]
> ### 🔓 Security Warning
> By configuring VNC to accept **direct** connections, your traffic will **not be encrypted**.
> All data — including your VNC password — is sent in **plain text** over the internet.
> Use a **very strong** VNC password, and prefer an SSH tunnel or VPN whenever possible.

---

## 📑 Contents

1. [Systemd Service File](#-1-systemd-service-file)
2. [xstartup Script](#-2-xstartup-script)
3. [Deployment Commands](#-3-deployment-commands)
4. [Verify Status](#-4-verify-status)
5. [VNC Viewer Connection](#-5-vnc-viewer-connection)

---

## ⚙️ 1. Systemd Service File

**Path:** `/etc/systemd/system/vncqasemt@.service`

> [!NOTE]
> - `-localhost no` is what allows **direct external connections**.
> - There is intentionally **no `mkdir` for `/run/user`** — it causes *Permission Denied*.

```ini
[Unit]
Description=TigerVNC Server for %i
After=network.target

[Service]
Type=forking
User=qasemt
Group=qasemt
WorkingDirectory=/home/qasemt

ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill :%i > /dev/null 2>&1 || true'
ExecStartPre=/bin/rm -rf /tmp/.X%i-lock /tmp/.X11-unix/X%i /home/qasemt/.vnc/*.pid

ExecStart=/usr/bin/vncserver :%i -geometry 1920x1080 -depth 24 -localhost no
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
```

| Directive | Value | Meaning |
| :--- | :--- | :--- |
| `Type` | `forking` | `vncserver` daemonizes itself |
| `-geometry` | `1920x1080` | Virtual screen resolution |
| `-depth` | `24` | Color depth in bits |
| `-localhost` | `no` | Accept remote connections directly |
| `WantedBy` | `multi-user.target` | Starts at boot, no login needed |

---

## 🧩 2. xstartup Script

**Path:** `~/.vnc/xstartup`

> [!IMPORTANT]
> The `XDG_RUNTIME_DIR` line is **required**. It creates a temporary runtime
> directory under `/tmp`, which gives the session boot independence and prevents
> GNOME from crashing when no user is physically logged in at the console.

```sh
#!/bin/sh
# Fix boot independence (bypasses missing /run/user directory at boot)
export XDG_RUNTIME_DIR=/tmp/runtime-qasemt
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=GNOME-Flashback:GNOME

[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
autocutsel -fork &

exec dbus-launch --exit-with-session gnome-session --session=gnome-flashback-metacity
```

---

## 🚀 3. Deployment Commands

Run these in order, in a terminal, **as the `qasemt` user**.

### 3.1 · Write the systemd service file

```bash
sudo tee /etc/systemd/system/vncqasemt@.service > /dev/null << 'EOF'
[Unit]
Description=TigerVNC Server for %i
After=network.target

[Service]
Type=forking
User=qasemt
Group=qasemt
WorkingDirectory=/home/qasemt

ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill :%i > /dev/null 2>&1 || true'
ExecStartPre=/bin/rm -rf /tmp/.X%i-lock /tmp/.X11-unix/X%i /home/qasemt/.vnc/*.pid

ExecStart=/usr/bin/vncserver :%i -geometry 1920x1080 -depth 24 -localhost no
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF
```

### 3.2 · Write the `xstartup` file

```bash
tee ~/.vnc/xstartup > /dev/null << 'EOF'
#!/bin/sh
export XDG_RUNTIME_DIR=/tmp/runtime-qasemt
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=GNOME-Flashback:GNOME

[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
autocutsel -fork &

exec dbus-launch --exit-with-session gnome-session --session=gnome-flashback-metacity
EOF
```

### 3.3 · Make `xstartup` executable

```bash
chmod +x ~/.vnc/xstartup
```

### 3.4 · Set a strong VNC password

```bash
vncpasswd
```

### 3.5 · Reload systemd

```bash
sudo systemctl daemon-reload
```

### 3.6 · Enable auto-start at boot

```bash
sudo systemctl enable vncqasemt@1.service
```

### 3.7 · Start the service now

```bash
sudo systemctl start vncqasemt@1.service
```

### 3.8 · Open the firewall port *(if `ufw` is active)*

```bash
sudo ufw allow 5901/tcp
```

---

## ✅ 4. Verify Status

```bash
sudo systemctl status vncqasemt@1.service
```

Expected result:

- `Active: active (running)`
- `gnome-session` visible in the process list

---

## 🔌 5. VNC Viewer Connection

No SSH tunnel is needed. Open your VNC Viewer and connect directly to:

```text
80.210.30.0:5901
```

| Item | Value |
| :--- | :--- |
| Host | `80.210.30.0` |
| Port | `5901` |
| Display | `:1` |
| Encryption | ❌ None (plain text) |

---

<div align="center"><sub>TigerVNC direct-connection configuration · display :1 · user <code>qasemt</code></sub></div>
