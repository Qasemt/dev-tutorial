# Cross-compile Python 3.12 for 32-bit ARM (RK3506G2)

Build Python 3.12.5 on an x86_64 Linux PC with the board's `arm-none-linux-gnueabihf` GCC toolchain, then copy the result to the board.

Use this when the board has no compiler and no `apt` (Buildroot rootfs), so the native build in [Python on Boards](./readme.md) can't run on it.

**Tested with:**

| | |
| :--- | :--- |
| Build host | Debian 12 x86_64 |
| Toolchain | Arm GNU Toolchain `10.3-2021.07`, `arm-none-linux-gnueabihf` (GCC 10.3.1, glibc 2.33) |
| Target | Rockchip RK3506G2 (Cortex-A7, ARMv7-A, hard-float) |
| Python | 3.12.5 |
| Deps | zlib 1.3.1, libffi 3.4.6, OpenSSL 3.0.15, SQLite 3.46.1 |

On the host, `file` reports `ELF 32-bit LSB executable, ARM, EABI5` and `readelf -A` reports `Tag_CPU_arch: v7` / `VFP registers`. On a Luckfox RK3506G2 board, steps 6–7 were run as written: the package runs, `ssl`/`sqlite3`/`ctypes`/`zlib`/`hashlib` import, and `ensurepip` installs pip 24.2 offline.

## Prerequisites

- **A native Python 3.12 on the build host.** A 3.12 cross-build needs a host interpreter of the *same* `major.minor`, passed as `--with-build-python`. Build it first with the [native build steps](./readme.md#build-via-source-python); it lands in `/usr/local/bin/python3.12`.
- **glibc ≥ 2.33 on the board.** The binary needs `GLIBC_2.33` symbols. A board image built with the same toolchain/SDK is fine. To check on the board, run its libc directly:

  ```bash
  /lib/libc.so.6
  ```
  <!-- UNVERIFIED: needs a check on real hardware -->

  If the board's glibc is older, the binary won't start (`version 'GLIBC_2.33' not found`). Use the toolchain that built the board's rootfs instead.
- About 1 GB of free disk space (measured: ~860 MB for sources, build trees and the install).

## The steps people miss

- **The sysroot has glibc and nothing else.** The toolchain's `arm-none-linux-gnueabihf/libc` has no zlib, libffi, OpenSSL or SQLite. Without them `configure` silently skips `zlib`, `ctypes`, `ssl`, `hashlib` and `sqlite3`, and pip doesn't work. Cross-build them first (step 2).
- **No `--enable-optimizations`.** PGO runs the freshly built binary, and an ARM binary can't run on x86. Drop the flag.
- **`config.site` is mandatory.** `configure` can't run its own tests when cross-compiling. Without the three cache values in step 3 it stops with `set ac_cv_file__dev_ptmx to yes/no in your CONFIG_SITE file`, then with `You must get working getaddrinfo() function`.
- **`--with-ensurepip=install` silently installs nothing here.** At install time it runs the *host* `python3.12`, which finds the host's own pip in `/usr/local/lib/python3.12/site-packages`, prints `Requirement already satisfied`, and leaves the package without pip. Build with `--with-ensurepip=no` and install pip on the board (step 7). The pip wheel is still shipped in `lib/python3.12/ensurepip/_bundled/`.
- **`apt install` on the target doesn't apply.** The dependency `.so` files are shipped inside the package (step 5), and an rpath points Python at `/usr/local/lib`.

## 1. Set up the environment

Point `TOOLCHAIN` at the folder that contains `bin/arm-none-linux-gnueabihf-gcc`:

```bash
export TOOLCHAIN=<PATH_TO_TOOLCHAIN>     # e.g. ~/work_space/tools_board/toolchains/rk3506g2
export HOST=arm-none-linux-gnueabihf
export W=$HOME/xpython                   # work dir
export STAGE=$W/stage                    # cross-built deps land here
export OUT=$W/out                        # Python install root

export PATH=$TOOLCHAIN/bin:$PATH
export CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib STRIP=$HOST-strip

mkdir -p $W/src $STAGE $OUT
$CC --version
```

Every later step assumes this shell, so run them all in the same terminal. A `screen` session helps, as in the native build.

## 2. Cross-build the dependencies

Download the sources:

```bash
cd $W/src
wget https://zlib.net/fossils/zlib-1.3.1.tar.gz
wget https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz
wget https://www.openssl.org/source/openssl-3.0.15.tar.gz
wget https://www.sqlite.org/2024/sqlite-autoconf-3460100.tar.gz
wget https://www.python.org/ftp/python/3.12.5/Python-3.12.5.tar.xz
for f in *.tar.*; do tar -xf $f; done
```

zlib. Its `configure` isn't autoconf, so there is no `--host`. It picks up the cross compiler from `CC`:

```bash
cd $W/src/zlib-1.3.1
./configure --prefix=/usr/local
make -j$(nproc) && make install DESTDIR=$STAGE
```

libffi (needed for `ctypes`):

```bash
cd $W/src/libffi-3.4.6
./configure --host=$HOST --prefix=/usr/local --disable-static
make -j$(nproc) && make install DESTDIR=$STAGE
```

OpenSSL (needed for `ssl`, `hashlib`, and pip over HTTPS). `linux-armv4` is OpenSSL's name for 32-bit ARM, including ARMv7. `--openssldir=/etc/ssl` makes it look for the board's CA certificates in the usual place:

```bash
cd $W/src/openssl-3.0.15
./Configure linux-armv4 shared no-tests --prefix=/usr/local --openssldir=/etc/ssl --libdir=lib
make -j$(nproc) && make install_sw DESTDIR=$STAGE
```

SQLite (needed for `sqlite3`):

```bash
cd $W/src/sqlite-autoconf-3460100
./configure --host=$HOST --prefix=/usr/local --disable-static
make -j$(nproc) && make install DESTDIR=$STAGE
```

## 3. Write `config.site`

```bash
cd $W/src/Python-3.12.5
cat > config.site <<'EOF'
ac_cv_file__dev_ptmx=yes
ac_cv_file__dev_ptc=no
ac_cv_buggy_getaddrinfo=no
EOF
```

## 4. Configure and build Python

```bash
cd $W/src/Python-3.12.5

CONFIG_SITE=$PWD/config.site \
CPPFLAGS="-I$STAGE/usr/local/include" \
LDFLAGS="-L$STAGE/usr/local/lib -Wl,-rpath-link,$STAGE/usr/local/lib -Wl,-rpath,/usr/local/lib" \
PKG_CONFIG_LIBDIR="$STAGE/usr/local/lib/pkgconfig" \
PKG_CONFIG_SYSROOT_DIR="$STAGE" \
./configure \
  --host=$HOST \
  --build=x86_64-linux-gnu \
  --prefix=/usr/local \
  --with-build-python=/usr/local/bin/python3.12 \
  --with-openssl=$STAGE/usr/local \
  --with-ensurepip=no

make -j$(nproc)
make altinstall DESTDIR=$OUT
```

What the flags do:

- `-rpath-link` lets the linker find the staged libraries at build time.
- `-rpath,/usr/local/lib` is baked into the binaries so the board's loader looks there at run time.
- `PKG_CONFIG_*` stops `configure` from picking up the *host's* x86 libraries.

At the end of `configure`, check the module summary. With the deps above, these must say `yes`:

```text
checking for stdlib extension module _ctypes... yes
checking for stdlib extension module _sqlite3... yes
checking for stdlib extension module zlib... yes
checking for stdlib extension module _ssl... yes
checking for stdlib extension module _hashlib... yes
```

`_bz2`, `_lzma`, `_uuid`, `readline`, `_curses`, `_dbm`/`_gdbm` and `_tkinter` show `missing`. Each one needs its own library cross-built into `$STAGE` the same way. Skip them unless you need them.

## 5. Check the binary and build the package

Confirm the binary is ARM, not x86:

```bash
file $OUT/usr/local/bin/python3.12
$HOST-readelf -A $OUT/usr/local/bin/python3.12 | grep -E 'Tag_CPU_arch|Tag_ABI_VFP'
```

Expected output:

```text
.../python3.12: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, ...
  Tag_CPU_arch: v7
  Tag_ABI_VFP_args: VFP registers
```

Copy the dependency libraries next to Python, then trim it. A full install is about 320 MB, mostly the test suite and the static `libpython3.12.a`. Trimmed, it's about 30 MB, and the `.tar.gz` about 11 MB:

```bash
cd $OUT/usr/local
cp -a $STAGE/usr/local/lib/libssl.so.3 $STAGE/usr/local/lib/libcrypto.so.3 \
      $STAGE/usr/local/lib/libffi.so.8* $STAGE/usr/local/lib/libsqlite3.so.0* \
      $STAGE/usr/local/lib/libz.so.1* lib/

rm -rf lib/python3.12/test lib/python3.12/idlelib/idle_test \
       lib/python3.12/tkinter lib/python3.12/turtledemo
rm -f  lib/libpython3.12.a lib/python3.12/config-3.12-arm-linux-gnueabihf/libpython3.12.a
find . -name __pycache__ -prune -exec rm -rf {} +
$STRIP bin/python3.12 lib/python3.12/lib-dynload/*.so lib/*.so*

tar czf $W/python-3.12.5-armhf.tar.gz .
ls -lh $W/python-3.12.5-armhf.tar.gz
```

Removing `libpython3.12.a` means you can't build C extensions on the board. Build wheels on the host instead, see [Wheel Management](./whl_managment.md).

## 6. Install on the board

> **Warning**
> Extracting into `/usr/local` overwrites any existing files with the same names there, including a `libssl.so.3`/`libcrypto.so.3` the board may already have in `/usr/local/lib`. Check first with `ls /usr/local/lib`. To undo, delete the files listed by `tar tzf python-3.12.5-armhf.tar.gz`.

```bash
# on the PC
scp $W/python-3.12.5-armhf.tar.gz root@<BOARD_IP>:/tmp/

# on the board
tar xzf /tmp/python-3.12.5-armhf.tar.gz -C /usr/local/
```

`/usr/local/bin` is not on root's `PATH` on the Luckfox image, so `python3.12` gives `-bash: python3.12: command not found` even though `/usr/local/bin/python3.12 --version` works. Add it:

```bash
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

If the board has no `scp` (some Buildroot images ship only Dropbear without it), use `adb push` or a USB stick.

## 7. Verify on the board

```bash
python3.12 --version
```

```text
Python 3.12.5
```

```bash
python3.12 -c "import ssl; print(ssl.OPENSSL_VERSION)"
python3.12 -c "import sqlite3, ctypes, zlib, hashlib; print('ok')"
```

```text
OpenSSL 3.0.15 3 Sep 2024
ok
```

The package has no pip yet (see "The steps people miss"), so `python3.12 -m pip` says `No module named pip` at first. Install it offline from the bundled wheel:

```bash
python3.12 -m ensurepip
python3.12 -m pip --version
```

```text
Successfully installed pip-24.2
pip 24.2 from /usr/local/lib/python3.12/site-packages/pip (python 3.12)
```

As root, `ensurepip` also prints the `Running pip as the 'root' user` warning. It's harmless here, but use a venv for project packages, see [venv Guide](./venv-guide.md).

## Troubleshooting

| Symptom | Cause / fix |
| :--- | :--- |
| `version 'GLIBC_2.33' not found` | Board glibc is older than the toolchain's. Build with the board SDK's toolchain. |
| `-bash: python3.12: command not found` | `/usr/local/bin` isn't on `PATH`. Confirm with `/usr/local/bin/python3.12 --version`, then add it to `PATH` (step 6). |
| `/usr/local/bin/python3.12: No such file or directory` although `ls` shows the file | Usually a missing loader: the board has no `/lib/ld-linux-armhf.so.3` (soft-float or musl rootfs). Check with `ls /lib/ld-*`. |
| `libssl.so.3: cannot open shared object file` | The libs weren't copied into `/usr/local/lib` (step 5), or Python was built without the `-rpath,/usr/local/lib` flag. Workaround: `export LD_LIBRARY_PATH=/usr/local/lib`. |
| `pip` fails with `CERTIFICATE_VERIFY_FAILED` | No CA bundle under `/etc/ssl` on the board. Copy one there, or point `SSL_CERT_FILE` at it. |
| `configure: error: "..." has incompatible version 3.11 (expected: 3.12)` | `--with-build-python` points at a host Python that isn't 3.12. Build the native 3.12 first (see Prerequisites). |
