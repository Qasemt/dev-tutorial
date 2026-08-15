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

If [Proxifier](https://www.proxifier.com/) is forcing all traffic through a proxy, add a bypass rule for these process names so Tailscale connects directly instead of through the proxy:
```text
tailscale-setup-1.102.2.exe; tailscale; tailscale-ipn.exe; tailscaled.exe; tailscale.exe
```
<!-- UNVERIFIED: needs a check on real hardware -->

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

## Gotcha — a local circumvention proxy silently swallows Tailscale traffic (Linux)

If `tailscale ping` succeeds but a specific app (gRPC client, `curl`, browser) still can't reach a peer's `100.x.x.x` address, check for a system-wide proxy:

```bash
env | grep -i proxy
```

Dev machines that also run a proxy client for internet censorship circumvention (NekoBox/sing-box, v2ray, Clash) often export `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY` globally (via `/etc/environment` or `/etc/profile.d/`). Any proxy-*aware* client — gRPC's C-core, `curl -x`, browsers — honors these and tunnels the connection through that local proxy port via an HTTP CONNECT, instead of going direct over the tailnet. Plain `nc`/`ncat`/telnet-style tools ignore these vars entirely and connect direct, which is why they succeed while the real app hangs.

If the proxy's upstream exit node (a VPS somewhere abroad) was never joined to your tailnet, it has no route to `100.x.x.x` at all — the CONNECT just hangs until the client's own timeout fires, often with an empty/unhelpful error (`asyncio.TimeoutError` carries no message, so `f"failed: {e}"` prints nothing).

Symptom checklist:
- `nc -vz <tailnet-ip> <port>` (or a raw TCP tool like Hercules) connects fine.
- A proxy-aware client to the same host:port hangs/times out with no useful error.
- Isolate it: `curl -v -x http://127.0.0.1:<proxy-port> --connect-timeout 6 telnet://<tailnet-ip>:<port>` hangs the same way; the same command without `-x` succeeds instantly.

**Fix** — don't bypass the proxy per app (`NO_PROXY`/`no_grpc_proxy`); add a direct-route rule *inside the proxy client itself* for Tailscale's CGNAT range, so every app benefits and non-Tailscale traffic still goes through the proxy as intended:

- **NekoBox/NekoRay**: Program → **Routing** tab → open the active route (e.g. `Default`) → its editor has a **Custom Config (JSON)** field — this is the `"custom"` key stored in `~/.config/nekoray/config/routes_box/<name>`. Paste the rule there:
  ```json
  {"rules": [{"ip_cidr": ["100.64.0.0/10"], "outbound": "direct"}]}
  ```
  So the full file ends up as:
  ```json
  {
      "custom": "{\"rules\": [{\"ip_cidr\": [\"100.64.0.0/10\"], \"outbound\": \"direct\"}]}",
      "def_outbound": "proxy",
      ...
  }
  ```
  Editing this file on disk directly (instead of through the GUI) also works, but only takes effect after the reload in the next bullet — the GUI field is just a friendlier way to write the same `"custom"` value.
- **Restart the connection** afterward (disconnect/reconnect the profile, or Program → restart the core). Sing-box-based clients only generate their actual routing config at connect time, so this rule — whether saved through the GUI or edited directly in the file — has no effect on an already-running connection until it reloads.

This is the same idea as the Proxifier bypass-by-process-name trick in step 2, just keyed on the destination IP range instead of the process name — useful when the client is a library (e.g. a Python gRPC channel) rather than something you can list by process name.

## Optional — MagicDNS

Admin Console → **DNS** → enable **MagicDNS** to reach machines by hostname instead of IP.
