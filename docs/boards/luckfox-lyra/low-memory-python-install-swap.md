# Installing Python Applications on Low-Memory Buildroot Boards

A Python application with native dependencies installs and runs on a Buildroot board with about 100 MB of RAM if four rules are followed:

1. Install offline, from wheels built on another machine. Never let pip compile on the board.
2. Keep pip's temporary files on disk, because `/tmp` is in RAM.
3. Add a swap file and turn it on at every boot with an init script.
4. Run `sync` after every change to a file on the board.

This guide is for anyone who installs Python software on such a board by hand. It uses only the shell commands that BusyBox provides. The numbers come from a Luckfox RK3506G2 board and a Flask-based service, installed on 14 October 2026.

## Example board

The procedure was worked out on the board below. Check the same properties on your board before you start; the commands are in the last column.

| Property | Example value | Why it matters | Check with |
| --- | --- | --- | --- |
| CPU architecture | 32-bit ARM, `armv7l` | Many packages have no ready-made `armv7l` wheel on PyPI | `uname -m` |
| Operating system | Buildroot with BusyBox | Minimal tools: no `htop`, `smem`, `xxd` or `unzip` | `cat /etc/os-release` |
| Init system | BusyBox init; `/etc/init.d/rcS` runs every `S??*` script with `start` | No systemd. Nothing runs `swapon -a`, so swap entries in `/etc/fstab` are ignored | `cat /etc/init.d/rcS` |
| Python | 3.12, at `/usr/local/bin/python3.12` | Must have `zlib`, `ssl`, `ctypes` for pip | `python3.12 -c "import zlib, ssl, ctypes"` |
| RAM | about 87 MB | A Flask service with gRPC and SQLAlchemy used about 53 MB | `free -m` |
| Swap | none by default | Any memory peak ends in an OOM kill | `grep Swap /proc/meminfo` |
| `/tmp` | tmpfs, 43 MB, stored in RAM | Every file in `/tmp` uses RAM | `df -h /tmp` |
| Root disk | 7.1 GB, 5.5 GB free | Room for a swap file and temporary files | `df -h /root` |
| glibc | 2.31 or newer | Decides which `manylinux` wheels the board accepts | `/lib/libc.so.6` |

## What goes wrong without these steps

On the example board, a normal `pip install` failed in four different ways. All but the last come from too little memory.

| Symptom | Cause |
| --- | --- |
| `Installing build dependencies ... error`, `exit code: -9`, or `Killed` next to the pip command | pip found no wheel for the board (for example `bcrypt`, `cffi`) and started to compile it. The kernel's OOM killer stopped it; `-9` is SIGKILL. |
| `python3.12 -m venv` prints `ensurepip ... returned non-zero exit status 1`; the venv has no `pip` | Even `ensurepip` was OOM-killed. Leftover files from the killed pip runs filled about 24 MB of the RAM-backed `/tmp`. |
| `dmesg` shows `Out of memory: Killed process ... (python3.12)` | Confirms the two rows above. |
| Offline install: `No matching distribution found for X==Y` | The application wheel and the wheelhouse came from different builds, with different version pins, under the same version number. |

One more problem appeared after the installation. A boot script written just before a reboot was empty afterwards, because its contents had not been flushed to disk. The board then started without swap.

## Step 1: Prepare the board

Free the RAM held by `/tmp`, move temporary files to disk, and add a 512 MB swap file. Run these commands as root in one shell, then install from that same shell, because `TMPDIR` lasts only for the shell session.

> **Warning:** the first command deletes `/tmp/tmp*` and `/tmp/pip-*`, which may also match temporary files of other running programs. The `dd` line overwrites `/root/swapfile` if it already exists. To undo the swap file: `swapoff /root/swapfile && rm /root/swapfile`.

```bash
# 1) free the RAM held by tmpfs (leftovers from earlier killed pip runs)
rm -rf /tmp/tmp* /tmp/pip-*
df -h /tmp            # Used should drop close to 0

# 2) move temporary files to disk
mkdir -p /root/tmp
export TMPDIR=/root/tmp

# 3) create and enable a swap file on disk
dd if=/dev/zero of=/root/swapfile bs=1M count=512
chmod 600 /root/swapfile
mkswap /root/swapfile && swapon /root/swapfile
free -m               # the Swap row should show 512
```

If `swapon` answers `Function not implemented` or `Invalid argument`, the kernel may be built without swap support. Steps 1 and 2 alone free about 24 MB, which may be enough for an offline install.

### Keep swap on after a reboot

The swap file stays on disk, but `swapon` lasts only until the next reboot. On BusyBox init an `/etc/fstab` entry does nothing, because no boot script runs `swapon -a`. Add a numbered init script instead. Its number must be lower than the application's own init script, so swap is on before the application starts.

```bash
cat > /etc/init.d/S05swap <<'EOF'
#!/bin/sh
case "$1" in
  start) [ -f /root/swapfile ] && swapon /root/swapfile ;;
  stop)  swapoff /root/swapfile 2>/dev/null ;;
esac
exit 0
EOF
chmod +x /etc/init.d/S05swap
sync                  # without this the file can be empty after a reboot
cat /etc/init.d/S05swap
```

If the application needs swap only during installation, skip this script and run `swapoff /root/swapfile` afterwards. Measure first (see Verification): the example service needed swap at run time too.

## Step 2: Install the application offline

Collect every wheel on a machine with internet access, copy them to the board, and install with `--no-index`. pip then never downloads or compiles anything on the board.

On the build machine, with the same Python minor version as the board:

```bash
mkdir -p wheelhouse
pip download --only-binary=:all: \
  --platform manylinux2014_armv7l --platform manylinux_2_28_armv7l \
  --platform manylinux_2_31_armv7l --platform linux_armv7l \
  --python-version 3.12 --implementation cp --abi cp312 \
  -d wheelhouse <APP>-<VERSION>-cp312-cp312-linux_armv7l.whl
pip download pip --no-deps -d wheelhouse   # a spare pip, in case ensurepip fails on the board
```

List only `manylinux` tags up to the board's glibc version. If pip reports `No matching distribution` for a package, it has no wheel for the board. Build that wheel on the build machine with an ARM cross-compiler, or on an ARM machine with more memory, and add it to `wheelhouse/`.

Copy the application wheel and the whole `wheelhouse/` folder to one folder on the board, for example `/root/<APP>/`. Keep only one build of the application wheel there. Then, in the shell prepared in Step 1:

```bash
cd /root/<APP>
python3.12 -m venv .venv
.venv/bin/python -m pip --version          # must print a version
.venv/bin/pip install --no-index --find-links=wheelhouse <APP>-*.whl
sync
```

To check the version pins inside a wheel without `unzip`:

```bash
python3.12 -c "import zipfile,sys; z=zipfile.ZipFile(sys.argv[1]); print([l for l in z.read(next(n for n in z.namelist() if n.endswith('METADATA'))).decode().splitlines() if l.startswith('Requires-Dist')])" <APP>-*.whl
```

## Step 3: Start the application at boot

Add an init script with a number higher than `S05swap`. BusyBox `start-stop-daemon` runs it in the background and writes a pid file. Replace `<APP>` and `<ENTRY_POINT>` with your application's names.

```bash
cat > /etc/init.d/S99<APP> <<'EOF'
#!/bin/sh
APP_DIR=/root/<APP>
DAEMON=$APP_DIR/.venv/bin/<ENTRY_POINT>
PIDFILE=/var/run/<APP>.pid
LOGFILE=/var/log/<APP>.log
case "$1" in
  start)   start-stop-daemon -S -b -m -p $PIDFILE -x /bin/sh -- -c "cd $APP_DIR && exec $DAEMON >> $LOGFILE 2>&1" ;;
  stop)    start-stop-daemon -K -p $PIDFILE; rm -f $PIDFILE ;;
  restart) $0 stop; sleep 2; $0 start ;;
esac
exit 0
EOF
chmod +x /etc/init.d/S99<APP>
sync
/etc/init.d/S99<APP> start
```

Then run `sync` and `reboot`, and do the checks in the next section.

## Verification and memory monitoring

After a reboot, swap must be on and the OOM log must be empty. Run:

```bash
grep -E "SwapTotal|SwapFree|MemAvailable" /proc/meminfo   # SwapTotal must be about 524284 kB, not 0
cat /etc/init.d/S05swap                                  # must show 6 lines, not be empty
dmesg | grep -i -E "out of memory|oom-kill"             # should print nothing
cat /proc/uptime                                         # seconds since boot, to date dmesg entries

for p in $(pidof python3.12); do                           # pidof can return several pids
  echo "== PID $p: $(tr '\0' ' ' < /proc/$p/cmdline | cut -c1-80)"
  grep -E "VmRSS|VmHWM|VmSwap|RssAnon" /proc/$p/status
done
```

The number in brackets in `dmesg` is seconds since boot. Compare it with `/proc/uptime` to tell an old kill from a new one.

| Field | Meaning | Example service, swap off |
| --- | --- | --- |
| `VmRSS` | RAM the process uses now | 54088 kB (about 53 MB) |
| `VmHWM` | Highest `VmRSS` since the process started | 60808 kB (about 59 MB) |
| `VmSwap` | Part of the process moved to swap | 0 kB |
| `MemAvailable` | RAM still available to the whole system | 9368 kB (about 9 MB) |

If `MemAvailable` stays below about 10 MB without swap, keep the swap file permanently. When swap was turned on, the kernel moved about 8 MB to it at once, a sign the RAM was under pressure. Check `VmHWM` and `VmSwap` again after a few days; a rising `VmHWM` points to a leak or a heavier workload.

## Known risks

- **Power loss can empty recently written files.** A boot script was found empty after a reboot without `sync`. Configuration files and SQLite databases are at the same risk. Run `sync` before any reboot or power cut.
- **Swap is slow and wears the storage.** It keeps the application alive through memory peaks, but heavy swapping slows it down and wears the SD card or eMMC.
- **Thread-heavy Python apps can use less memory with `MALLOC_ARENA_MAX=2`.** Set it in the environment before the app starts; it limits the number of glibc memory arenas. Not yet measured on the example board.
- **Two builds with one version number get mixed up.** Raise the application version whenever its dependency pins change, so the wheel and its wheelhouse always match.

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `exit code: -9`, or `Killed` next to a pip command | Out of memory | Do Step 1; install offline with `--no-index` |
| pip is `Downloading` files or building a `.tar.gz` | Online install, or a package missing from the wheelhouse | Use `--no-index --find-links=wheelhouse`; add the missing wheel on the build machine |
| `No matching distribution found for X==Y` (offline) | The application wheel and the wheelhouse come from different builds | Copy both from the same build; check the pins in the wheel (Step 2) |
| `ensurepip ... returned non-zero exit status 1` | Out of memory while creating the venv | Clean `/tmp`, set `TMPDIR`, turn on swap, delete `.venv`, try again |
| `ensurepip` still fails with swap on | Broken Python install | `python3.12 -m venv --without-pip .venv`, then `.venv/bin/python wheelhouse/pip-*.whl/pip install --no-index wheelhouse/pip-*.whl` |
| `SwapTotal: 0 kB` after a reboot | `S05swap` missing or empty | Recreate it (Step 1), run `sync`, reboot |
| `swapoff: Invalid argument` | Swap was not on | Nothing to fix |
| `grep: <pid> <pid>/status: No such file` | `pidof` returned more than one pid | Loop over the pids (Verification) |
