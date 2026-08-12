# Remote Serial Port Bridge (Windows board ↔ Linux controller)

Bridges a physical board's real serial port, attached to the hardware team's Windows machine, to a local virtual serial port on the PadisController Linux machine — over a Tailscale connection. No public/static IP required.

## Windows side (hardware team) — hub4com

Download this specific build — it's the one confirmed to ship with a working TCP driver: [hub4com-2.1.0.0-386.zip](https://sourceforge.net/projects/com0com/files/hub4com/2.1.0.0/hub4com-2.1.0.0-386.zip/download)

```console
hub4com --baud=115200 --parity=no --data=8 --stop=1 "\\.\COM6" --use-driver=tcp --reconnect=1000 "<linux-tailscale-ip>:9000"
```

- Replace `COM6` with the board's **actual** COM port — check Device Manager and make sure it's not a `com0com - serial port emulator` virtual pair.
- Replace `<linux-tailscale-ip>` with the PadisController machine's Tailscale IP (`tailscale ip -4`).
- `hub4com` connects out as a TCP **client** — the Linux side must already be listening.
- `--use-driver=tcp` is required — without it, `hub4com` misparses a `tcp:`/bare address as a literal file path (`CreateFile` error 123). An earlier plain-`hub4com` attempt (a different/older bundled build, without this flag available) failed for that reason; this build + flag combination is the one confirmed working.

## Linux side (PadisController) — socat

```bash
sudo socat -d -d \
  PTY,link=/dev/ttyPADIS0,raw,echo=0,user=qasemt,perm=0600 \
  TCP-LISTEN:9000,reuseaddr
```

Creates a local virtual serial port at `/dev/ttyPADIS0` that mirrors the remote COM port. Must stay running (foreground or as a service) for the link to work.

Point the app config (`files/configs/config.yaml`) at it:

```yaml
serial_port:
  port: /dev/ttyPADIS0
  baudrate: 115200
```

## Testing with minicom

```bash
minicom -b 115200 -D /dev/ttyPADIS0
```

### Issue: `minicom: cannot open /dev/ttyPADIS0: Device or resource busy`

Another process already has the PTY open — typically a leftover `screen`/`minicom` session from an earlier test that wasn't closed properly (not the `socat` process itself, which is expected to hold it).

Diagnose:

```bash
sudo lsof /dev/ttyPADIS0
```

Kill the stale process shown (leave the `socat` entry alone):

```bash
kill <pid>
```

Re-run `sudo lsof /dev/ttyPADIS0` to confirm only `socat` remains, then retry `minicom`.
