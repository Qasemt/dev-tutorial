# Route Traffic Through a Remote VPS (SSH Tunnel)

Give a local machine or board internet access that exits through a remote VPS's IP, using only SSH — no VPN client needed.

**Prerequisites**
- SSH access to the VPS (password or key), its public IP, and a non-root SSH user — shown below as `<VPS_USER>` / `<VPS_IP>`.
- Method 1 also needs `sudo` on the VPS to install `tinyproxy` (Debian/Ubuntu `apt` shown; adjust the package manager for other distros).
- The ports used below (`8888` on the VPS, `10808` locally) are just examples — pick any free ports, they don't need to match each other.

Two ways to get there: an HTTP proxy on the VPS relayed over an SSH local port forward, or a SOCKS5 proxy from plain SSH with nothing installed on the VPS at all.

## Method 1: tinyproxy on the VPS + local port forward

1. On the VPS, install `tinyproxy`:

   ```bash
   sudo apt install tinyproxy -y
   ```

2. Edit its config to listen on localhost only:

   ```bash
   sudo nano /etc/tinyproxy/tinyproxy.conf
   ```

   ```conf
   Port 8888
   Listen 127.0.0.1
   Allow 127.0.0.1
   ```

   > **Why localhost-only.** `Listen 127.0.0.1` + `Allow 127.0.0.1` means tinyproxy only accepts connections that originate on the VPS itself — it does not open a public relay on the internet. The only way in is through the SSH tunnel in step 4, which is the point.

3. Restart and enable it:

   ```bash
   sudo systemctl restart tinyproxy
   sudo systemctl enable tinyproxy
   ```

   Confirm it's listening — run this on the VPS:

   ```bash
   ss -tlnp | grep 8888
   ```

4. From your local machine, open a local port forward to the VPS: local port `10808` maps to tinyproxy's `127.0.0.1:8888` on the VPS side. Keep this terminal running — the tunnel exists only as long as this command does:

   ```bash
   ssh -L 10808:127.0.0.1:8888 <VPS_USER>@<VPS_IP>
   ```

5. In a second, separate terminal, test through it:

   ```bash
   curl -x http://127.0.0.1:10808 ifconfig.me
   ```

   The output should be the VPS's public IP, not your local one.

**Removing it.** If you're done and want tinyproxy off the VPS again:

```bash
sudo apt remove tinyproxy -y
```

## Method 2: SSH SOCKS5 proxy, no extra software

Nothing to install on the VPS — the OpenSSH server it already runs is enough.

1. Open a dynamic (SOCKS5) tunnel:

   ```bash
   ssh -N -D 10808 <VPS_USER>@<VPS_IP>
   ```

   - `-D 10808` — opens a local SOCKS5 proxy on port 10808 that routes out through the VPS.
   - `-N` — don't run a remote shell, only forward.

   > **Note — this will look like it hung.** After you enter the password, the terminal shows no prompt and does nothing else. That's expected, not a failure: `-N` deliberately skips starting a remote shell, so there's nothing for it to print — the process is just sitting there holding the tunnel open. Leave it running and do your testing from a second terminal.

2. In a second terminal, test through it:

   ```bash
   curl --socks5 127.0.0.1:10808 http://httpbin.org/ip
   ```

   ```text
   {
     "origin": "<VPS_IP>"
   }
   ```

3. To stop the tunnel, go back to the first terminal and press Ctrl+C.

### Avoiding the "did it hang?" confusion: background it with `-f`

Add `-f` so SSH detaches to the background right after authentication — you get your prompt back immediately instead of a terminal that looks stuck:

```bash
ssh -f -N -D 10808 <VPS_USER>@<VPS_IP>
```

Find and stop it later:

```bash
ps aux | grep '[s]sh -f -N -D 10808'
kill <PID>
```

For a tunnel meant to stay up for daily use rather than a one-off test, plain `ssh -f -N -D` still won't reconnect if the network blips or the VPS reboots. `autossh` will:

```bash
autossh -M 0 -f -N -D 10808 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" <VPS_USER>@<VPS_IP>
```
<!-- UNVERIFIED: needs a check on real hardware -->

`autossh` is a separate package (`sudo apt install autossh`), not covered elsewhere in this repo.

## Which one

- **Method 2 (SOCKS5)** is the simplest — zero setup on the VPS, one command locally. Good for one-off or occasional use.
- **Method 1 (tinyproxy)** is worth the extra setup when an app only understands an HTTP/HTTPS proxy (not everything speaks SOCKS5), or when you want the proxy running on the VPS as a managed service (systemd, survives reboots) independent of any single SSH session.
