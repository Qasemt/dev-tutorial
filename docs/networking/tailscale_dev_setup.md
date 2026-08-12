# Connecting Remote Teams with Tailscale

Both teams are behind NAT with no static IP. [Tailscale](https://tailscale.com) creates a mesh VPN between machines without port forwarding or a public IP.

## 1. Create account and invite the other team

1. One person signs up at [login.tailscale.com](https://login.tailscale.com).
2. Admin Console → **Users** → **Invite users** → enter the other team's email.
3. They accept the invite so both sides join the same tailnet.

## 2. Install

**Linux:**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```
On a headless machine, open the printed login link in a browser on another device.

**Windows:**
```powershell
winget install tailscale.tailscale
```

If the Windows installer fails to download (`0x80070005` / Access Denied), it's usually a corporate proxy:
```powershell
winget install --proxy http://proxyserver:port tailscale.tailscale
```
or set the system-wide proxy (also fixes other WinHTTP downloads):
```powershell
netsh winhttp set proxy proxyserver:port
```
Revert with `netsh winhttp reset proxy`. Find the proxy address under Settings → Network & Internet → Proxy, or ask IT.

> `sudo tailscale up` without extra flags (no `--exit-node`, no subnet router) does not affect existing SSH/VNC sessions.

## 3. Get IP and verify connectivity

On each machine:
```bash
tailscale ip -4       # this machine's tailnet IP
tailscale status      # list of connected devices
```

Test from either side:
```bash
ping 100.x.x.x
```

Once `ping` succeeds, the machines can reach each other directly on their `100.x.x.x` addresses, on any port/protocol, as if on the same LAN.

## Optional — MagicDNS

Admin Console → **DNS** → enable **MagicDNS** to reach machines by hostname instead of IP.
