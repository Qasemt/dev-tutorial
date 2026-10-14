# Fix the System Clock and SSL Errors in pip Installs on the Luckfox

Set the board's clock from NTP so `pip` can verify PyPI's SSL certificate, and keep it correct across reboots.

## The problem

An online `pip install` of a Python app fails on a Luckfox board with an SSL error because the system clock is wrong. These boards usually have no RTC battery, so after every reboot the clock falls back to a date before 2022.

With the wrong clock, the PyPI server's SSL certificate looks "not yet valid" to the system, and `pip` can't download dependencies (e.g. `alembic`).

**Tested on:** Luckfox board, armv7l, Buildroot, Python 3.12 in a venv.

`<VENV>` below is the path to your app's virtualenv (e.g. `/root/<APP>/.venv`). Any Python 3 on the board works for the NTP script — it uses only the standard library.

Symptom in the install log:

```text
SystemTimeWarning: System time is way off (before 2022-01-01). This will probably lead to SSL verification errors
WARNING: Retrying (Retry(total=4, ...)) after connection broken by 'SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: certificate is not yet valid (_ssl.c:1000)'))': /simple/alembic/
```

Quick check: run `date`. If the year is before 2022, this is the problem.

## Quick fix: set the clock by hand

To get the install going, set the clock to the current date and time, then re-run the install:

```bash
date -s "2026-10-14 10:30:00"
date
```

The date and time above are only an example — use the real ones when you run it. This setting is lost on reboot; see the next sections for a persistent fix.

## Sync the clock with NTP

The current Buildroot image has no `apt`, no `ntpd`, and no matching BusyBox applet. So the clock is fetched straight from an NTP server with a small Python script.

1. Create the script:

    ```bash
    cat > /root/ntpsync.py << 'EOF'
    import socket, struct, time, subprocess
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(5)
    s.sendto(b'\x1b' + 47 * b'\0', ('pool.ntp.org', 123))
    data = s.recv(48)
    t = struct.unpack('!I', data[40:44])[0] - 2208988800
    subprocess.run(['date', '-u', '-s', time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(t))])
    EOF
    ```

2. Run it:

    ```bash
    <VENV>/bin/python3 /root/ntpsync.py
    ```

    Successful output looks like:

    ```text
    Wed Oct 14 07:07:31 UTC 2026
    ```

If `pool.ntp.org` doesn't resolve because of a DNS problem, put an NTP server's IP address (e.g. `216.239.35.0`) in the script instead. UDP port 123 must be open on the network.

## Keep the sync across reboots

To set the clock automatically on every boot, create an init script in `/etc/init.d/`. Buildroot runs the `S??*` scripts in order at boot.

```bash
cat > /etc/init.d/S99ntpsync << 'EOF'
#!/bin/sh
case "$1" in
  start)
    # wait a few seconds for the network to come up
    sleep 10
    <VENV>/bin/python3 /root/ntpsync.py
    ;;
esac
EOF
chmod +x /etc/init.d/S99ntpsync
```

Test it without rebooting:

```bash
/etc/init.d/S99ntpsync start
date
```

If the board has a hardware RTC, you can also add `hwclock -w` after the sync. Without a battery the RTC doesn't keep time through a power cut, so the NTP sync on every boot is still needed.

## Set the time zone (optional)

The system clock is set in UTC, which is correct for SSL and the install. To display Tehran time in the shell:

```bash
echo 'export TZ=Asia/Tehran' >> /root/.profile
```

If the image has no time zone files, use the POSIX form:

```bash
echo 'export TZ="<+0330>-3:30"' >> /root/.profile
```

## pip upgrade bug in install scripts

An install script's "Upgrading pip" step can fail with `no such option: -m`. It doesn't block the install; pip just doesn't get upgraded.

```text
🔧 Upgrading pip...
Usage:
  pip <command> [options]
no such option: -m
```

Cause: `-m` is an option of the Python interpreter, not of pip. The script is probably written like this:

```bash
"$VENV/bin/pip" -m pip install --upgrade pip      # wrong
```

Fix:

```bash
"$VENV/bin/python" -m pip install --upgrade pip   # right
```

To find the line in the script: `grep -n "\-m pip" <INSTALL_SCRIPT>.sh`. The exact name of the venv variable in the script still needs checking.

- [ ] Fix the pip upgrade command in your install script

## Notes and troubleshooting

| Issue | Explanation | Action |
| --- | --- | --- |
| No `apt` or `ntpd` | The Luckfox image is Buildroot-based and has no package manager | Use the Python NTP script |
| Dependencies with no armv7l wheel | pip tries to compile on the device and fails because there is no `gcc` | Download the wheels on another machine, then install offline on the device |
| DNS error during sync | `pool.ntp.org` doesn't resolve | Put the NTP server's IP address in the script |
| venv removed | The init script uses the Python inside the venv and stops working after removal | If `which python3` shows a system Python, put its path in the init script |

Suggestion for any install script: before an online install, check the system year and, if it's before 2022, warn or run the sync automatically.
