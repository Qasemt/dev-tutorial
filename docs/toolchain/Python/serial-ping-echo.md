# Creating `serial_ping.py` Without an Editor

Goal: get [`serial_ping.py`](./serial_ping.py) — the serial ping/pong TX/RX pin finder — onto a board where pasting a whole file into `vi` mangles it. Both blocks below are **pasted straight into a shell**; the shell writes the file. Nothing here needs an editor.

## Why pasting into `vi` breaks

- Vim's **autoindent** re-indents every pasted line: each new line inherits the indentation of the line above it, so the Python block structure is destroyed and the script no longer compiles. This is normal Vim behaviour, not a problem with the file.
- The real fix, if you want to stay in `vi`: enter paste mode first, paste, then leave it.

    ```vim
    :set paste
    " paste here
    :set nopaste
    ```

- On a serial console (`picocom`, `screen`, `minicom`) at a low baud rate a long paste can also drop characters mid-line or fold at the terminal width, which is why the `echo` block in Option B is line-based — a line that arrives garbled shows up in the error output and can be retyped on its own.
- On a board that is reachable over SSH you do not have to paste at all — see Option C.

## Prerequisites

- A shell on the board. Option A (heredoc) works in `bash`, `dash` and busybox `ash`; Option B needs `bash`.
- `python3` and `pyserial`:

    ```bash
    pip3 install pyserial
    ```

> **Warning** — Both blocks start by truncating `serial_ping.py` (`: > "$OUT"` / `>` redirect), so re-running either one **overwrites** the copy already on that board. Save any local edits before pasting again.

## Option A — one `cat` heredoc (recommended)

The delimiter is quoted (`<< 'PYEOF'`), so `$`, backticks and `\n` inside the script are written literally instead of being expanded by the shell. Paste the whole block in one go — it writes the file, sets the executable bit and syntax-checks the result:

```bash
cat > serial_ping.py << 'PYEOF'
#!/usr/bin/env python3
"""
Serial Port Ping/Pong Script
Send ping messages and listen for pong responses to help identify TX/RX pins on Linux boards
"""

import serial
import time
import argparse
import sys
import threading
from datetime import datetime

class SerialPingPong:
    def __init__(self, port, baudrate=115200, interval=0.5, message="PING"):
        self.port = port
        self.baudrate = baudrate
        self.interval = interval
        self.message = message
        self.ser = None
        self.running = False
        self.pong_count = 0
        self.ping_count = 0
        
    def open_port(self):
        """Open serial port"""
        try:
            self.ser = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=0.1
            )
            return True
        except serial.SerialException as e:
            print(f"Error opening port {self.port}: {e}")
            return False
    
    def listen_for_pong(self):
        """Thread function to continuously listen for pong responses"""
        while self.running:
            try:
                if self.ser and self.ser.is_open and self.ser.in_waiting > 0:
                    data = self.ser.readline().decode('utf-8', errors='ignore').strip()
                    if data:
                        timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
                        if "PONG" in data.upper():
                            self.pong_count += 1
                            print(f"[{timestamp}] PONG received: '{data}' (Total: {self.pong_count})")
                        else:
                            print(f"[{timestamp}] Data received: '{data}'")
            except Exception as e:
                if self.running:
                    print(f"Read error: {e}")
            time.sleep(0.01)
    
    def send_ping(self):
        """Send ping messages"""
        counter = 0
        
        print(f"Successfully opened port {self.port}")
        print(f"Settings: {self.baudrate} baud, 8N1")
        print(f"Sending '{self.message}' every {self.interval} seconds...")
        print("Listening for PONG responses...")
        print("Press Ctrl+C to stop\n")
        print("="*60)
        
        listener_thread = threading.Thread(target=self.listen_for_pong, daemon=True)
        listener_thread.start()
        
        while self.running:
            try:
                timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
                ping_message = f"{self.message} #{counter}\r\n"
                
                bytes_sent = self.ser.write(ping_message.encode('utf-8'))
                self.ping_count += 1
                print(f"[{timestamp}] Sent: {ping_message.strip()} (Pings: {self.ping_count}, Pongs: {self.pong_count})")
                
                counter += 1
                time.sleep(self.interval)
                
            except serial.SerialException as e:
                print(f"Serial error: {e}")
                break
            except Exception as e:
                print(f"Error: {e}")
                break
    
    def start(self):
        """Main function to run ping/pong"""
        if not self.open_port():
            sys.exit(1)
        
        try:
            self.running = True
            self.send_ping()
        except KeyboardInterrupt:
            print("\n" + "="*60)
            print("Transmission stopped")
            print(f"Statistics: {self.ping_count} pings sent, {self.pong_count} pongs received")
            if self.ping_count > 0:
                success_rate = (self.pong_count / self.ping_count) * 100
                print(f"Success rate: {success_rate:.1f}%")
        finally:
            self.running = False
            if self.ser and self.ser.is_open:
                self.ser.close()
                print(f"Port {self.port} closed")

def list_serial_ports():
    """List available serial ports"""
    import serial.tools.list_ports
    ports = serial.tools.list_ports.comports()
    
    if not ports:
        print("No serial ports found!")
        return
    
    print("Available serial ports:")
    for port in ports:
        print(f"  {port.device} - {port.description}")
        if hasattr(port, 'hwid'):
            print(f"     HWID: {port.hwid}")

def main():
    parser = argparse.ArgumentParser(
        description='Send ping and listen for pong over serial port for pin identification',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s /dev/ttyS4
  %(prog)s /dev/ttyS4 -b 9600 -i 1 -m "TEST"
  %(prog)s /dev/ttyS4 -b 115200 -i 0.5 -m "HELLO"
  %(prog)s --list

Note: This script expects the other device to respond with "PONG" 
      when it receives a ping message.
        """
    )
    
    parser.add_argument('port', nargs='?', help='Serial port (e.g., /dev/ttyS4, /dev/ttyUSB0)')
    parser.add_argument('-b', '--baudrate', type=int, default=115200, 
                       help='Baud rate (default: 115200)')
    parser.add_argument('-i', '--interval', type=float, default=0.5,
                       help='Interval between pings in seconds (default: 0.5)')
    parser.add_argument('-m', '--message', default='PING',
                       help='Custom ping message (default: PING)')
    parser.add_argument('-l', '--list', action='store_true',
                       help='List available serial ports')
    
    args = parser.parse_args()
    
    if args.list:
        list_serial_ports()
        return
    
    if not args.port:
        parser.print_help()
        print("\nError: Port argument is required")
        sys.exit(1)
    
    ping_pong = SerialPingPong(args.port, args.baudrate, args.interval, args.message)
    ping_pong.start()

if __name__ == "__main__":
    main()



# Make executable
#chmod +x serial_ping.py

# Basic usage
#python3.12 serial_ping.py /dev/ttyS4

# Custom baud rate and interval
#python3.12 serial_ping.py /dev/ttyS4 -b 9600 -i 1

# Custom message
#python3.12 serial_ping.py /dev/ttyS4 -m "HELLO"

# List available ports
#python3.12 serial_ping.py --list
PYEOF
chmod +x serial_ping.py
python3 -c "import ast; ast.parse(open('serial_ping.py').read()); print('serial_ping.py: syntax OK')"
```

## Option B — the `echo` version (bash only)

One `echo ... >> serial_ping.py` per line — the variant to use when a heredoc paste is unreliable on your terminal. Every line is a self-contained command, and the leading whitespace survives because each line is single-quoted.

> **Note** — This block requires **bash**, because `echo` is not portable here. On `dash` 0.5.12 — which is `/bin/sh` on Debian 12 and Ubuntu — the builtin `echo` expands `\n` and `\r` *inside* the quotes, splitting Python string literals across two lines and corrupting the file. (Verified on `dash` 0.5.12: `echo 'a\nb'` prints two lines. BusyBox v1.35.0 `ash` does not expand it, but that behaviour is build-dependent, so `ash` is not a safe fallback either.) The block therefore refuses to run in any shell other than bash instead of writing a broken file. If it refuses: run `bash`, then paste it again — or use Option A, which is shell-agnostic.

```bash
# The `echo` version: one complete command per line, nothing to escape except
# single quotes (already escaped below). bash only - see the note on the page.
if [ -z "$BASH_VERSION" ]; then
    echo 'This block needs bash. Run: bash' >&2
    echo 'Otherwise use the cat << PYEOF block above.' >&2
else
    OUT=serial_ping.py
    : > "$OUT"
    echo '#!/usr/bin/env python3' >> "$OUT"
    echo '"""' >> "$OUT"
    echo 'Serial Port Ping/Pong Script' >> "$OUT"
    echo 'Send ping messages and listen for pong responses to help identify TX/RX pins on Linux boards' >> "$OUT"
    echo '"""' >> "$OUT"
    echo '' >> "$OUT"
    echo 'import serial' >> "$OUT"
    echo 'import time' >> "$OUT"
    echo 'import argparse' >> "$OUT"
    echo 'import sys' >> "$OUT"
    echo 'import threading' >> "$OUT"
    echo 'from datetime import datetime' >> "$OUT"
    echo '' >> "$OUT"
    echo 'class SerialPingPong:' >> "$OUT"
    echo '    def __init__(self, port, baudrate=115200, interval=0.5, message="PING"):' >> "$OUT"
    echo '        self.port = port' >> "$OUT"
    echo '        self.baudrate = baudrate' >> "$OUT"
    echo '        self.interval = interval' >> "$OUT"
    echo '        self.message = message' >> "$OUT"
    echo '        self.ser = None' >> "$OUT"
    echo '        self.running = False' >> "$OUT"
    echo '        self.pong_count = 0' >> "$OUT"
    echo '        self.ping_count = 0' >> "$OUT"
    echo '        ' >> "$OUT"
    echo '    def open_port(self):' >> "$OUT"
    echo '        """Open serial port"""' >> "$OUT"
    echo '        try:' >> "$OUT"
    echo '            self.ser = serial.Serial(' >> "$OUT"
    echo '                port=self.port,' >> "$OUT"
    echo '                baudrate=self.baudrate,' >> "$OUT"
    echo '                bytesize=serial.EIGHTBITS,' >> "$OUT"
    echo '                parity=serial.PARITY_NONE,' >> "$OUT"
    echo '                stopbits=serial.STOPBITS_ONE,' >> "$OUT"
    echo '                timeout=0.1' >> "$OUT"
    echo '            )' >> "$OUT"
    echo '            return True' >> "$OUT"
    echo '        except serial.SerialException as e:' >> "$OUT"
    echo '            print(f"Error opening port {self.port}: {e}")' >> "$OUT"
    echo '            return False' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    def listen_for_pong(self):' >> "$OUT"
    echo '        """Thread function to continuously listen for pong responses"""' >> "$OUT"
    echo '        while self.running:' >> "$OUT"
    echo '            try:' >> "$OUT"
    echo '                if self.ser and self.ser.is_open and self.ser.in_waiting > 0:' >> "$OUT"
    echo '                    data = self.ser.readline().decode('\''utf-8'\'', errors='\''ignore'\'').strip()' >> "$OUT"
    echo '                    if data:' >> "$OUT"
    echo '                        timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]' >> "$OUT"
    echo '                        if "PONG" in data.upper():' >> "$OUT"
    echo '                            self.pong_count += 1' >> "$OUT"
    echo '                            print(f"[{timestamp}] PONG received: '\''{data}'\'' (Total: {self.pong_count})")' >> "$OUT"
    echo '                        else:' >> "$OUT"
    echo '                            print(f"[{timestamp}] Data received: '\''{data}'\''")' >> "$OUT"
    echo '            except Exception as e:' >> "$OUT"
    echo '                if self.running:' >> "$OUT"
    echo '                    print(f"Read error: {e}")' >> "$OUT"
    echo '            time.sleep(0.01)' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    def send_ping(self):' >> "$OUT"
    echo '        """Send ping messages"""' >> "$OUT"
    echo '        counter = 0' >> "$OUT"
    echo '        ' >> "$OUT"
    echo '        print(f"Successfully opened port {self.port}")' >> "$OUT"
    echo '        print(f"Settings: {self.baudrate} baud, 8N1")' >> "$OUT"
    echo '        print(f"Sending '\''{self.message}'\'' every {self.interval} seconds...")' >> "$OUT"
    echo '        print("Listening for PONG responses...")' >> "$OUT"
    echo '        print("Press Ctrl+C to stop\n")' >> "$OUT"
    echo '        print("="*60)' >> "$OUT"
    echo '        ' >> "$OUT"
    echo '        listener_thread = threading.Thread(target=self.listen_for_pong, daemon=True)' >> "$OUT"
    echo '        listener_thread.start()' >> "$OUT"
    echo '        ' >> "$OUT"
    echo '        while self.running:' >> "$OUT"
    echo '            try:' >> "$OUT"
    echo '                timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]' >> "$OUT"
    echo '                ping_message = f"{self.message} #{counter}\r\n"' >> "$OUT"
    echo '                ' >> "$OUT"
    echo '                bytes_sent = self.ser.write(ping_message.encode('\''utf-8'\''))' >> "$OUT"
    echo '                self.ping_count += 1' >> "$OUT"
    echo '                print(f"[{timestamp}] Sent: {ping_message.strip()} (Pings: {self.ping_count}, Pongs: {self.pong_count})")' >> "$OUT"
    echo '                ' >> "$OUT"
    echo '                counter += 1' >> "$OUT"
    echo '                time.sleep(self.interval)' >> "$OUT"
    echo '                ' >> "$OUT"
    echo '            except serial.SerialException as e:' >> "$OUT"
    echo '                print(f"Serial error: {e}")' >> "$OUT"
    echo '                break' >> "$OUT"
    echo '            except Exception as e:' >> "$OUT"
    echo '                print(f"Error: {e}")' >> "$OUT"
    echo '                break' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    def start(self):' >> "$OUT"
    echo '        """Main function to run ping/pong"""' >> "$OUT"
    echo '        if not self.open_port():' >> "$OUT"
    echo '            sys.exit(1)' >> "$OUT"
    echo '        ' >> "$OUT"
    echo '        try:' >> "$OUT"
    echo '            self.running = True' >> "$OUT"
    echo '            self.send_ping()' >> "$OUT"
    echo '        except KeyboardInterrupt:' >> "$OUT"
    echo '            print("\n" + "="*60)' >> "$OUT"
    echo '            print("Transmission stopped")' >> "$OUT"
    echo '            print(f"Statistics: {self.ping_count} pings sent, {self.pong_count} pongs received")' >> "$OUT"
    echo '            if self.ping_count > 0:' >> "$OUT"
    echo '                success_rate = (self.pong_count / self.ping_count) * 100' >> "$OUT"
    echo '                print(f"Success rate: {success_rate:.1f}%")' >> "$OUT"
    echo '        finally:' >> "$OUT"
    echo '            self.running = False' >> "$OUT"
    echo '            if self.ser and self.ser.is_open:' >> "$OUT"
    echo '                self.ser.close()' >> "$OUT"
    echo '                print(f"Port {self.port} closed")' >> "$OUT"
    echo '' >> "$OUT"
    echo 'def list_serial_ports():' >> "$OUT"
    echo '    """List available serial ports"""' >> "$OUT"
    echo '    import serial.tools.list_ports' >> "$OUT"
    echo '    ports = serial.tools.list_ports.comports()' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    if not ports:' >> "$OUT"
    echo '        print("No serial ports found!")' >> "$OUT"
    echo '        return' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    print("Available serial ports:")' >> "$OUT"
    echo '    for port in ports:' >> "$OUT"
    echo '        print(f"  {port.device} - {port.description}")' >> "$OUT"
    echo '        if hasattr(port, '\''hwid'\''):' >> "$OUT"
    echo '            print(f"     HWID: {port.hwid}")' >> "$OUT"
    echo '' >> "$OUT"
    echo 'def main():' >> "$OUT"
    echo '    parser = argparse.ArgumentParser(' >> "$OUT"
    echo '        description='\''Send ping and listen for pong over serial port for pin identification'\'',' >> "$OUT"
    echo '        formatter_class=argparse.RawDescriptionHelpFormatter,' >> "$OUT"
    echo '        epilog="""' >> "$OUT"
    echo 'Examples:' >> "$OUT"
    echo '  %(prog)s /dev/ttyS4' >> "$OUT"
    echo '  %(prog)s /dev/ttyS4 -b 9600 -i 1 -m "TEST"' >> "$OUT"
    echo '  %(prog)s /dev/ttyS4 -b 115200 -i 0.5 -m "HELLO"' >> "$OUT"
    echo '  %(prog)s --list' >> "$OUT"
    echo '' >> "$OUT"
    echo 'Note: This script expects the other device to respond with "PONG" ' >> "$OUT"
    echo '      when it receives a ping message.' >> "$OUT"
    echo '        """' >> "$OUT"
    echo '    )' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    parser.add_argument('\''port'\'', nargs='\''?'\'', help='\''Serial port (e.g., /dev/ttyS4, /dev/ttyUSB0)'\'')' >> "$OUT"
    echo '    parser.add_argument('\''-b'\'', '\''--baudrate'\'', type=int, default=115200, ' >> "$OUT"
    echo '                       help='\''Baud rate (default: 115200)'\'')' >> "$OUT"
    echo '    parser.add_argument('\''-i'\'', '\''--interval'\'', type=float, default=0.5,' >> "$OUT"
    echo '                       help='\''Interval between pings in seconds (default: 0.5)'\'')' >> "$OUT"
    echo '    parser.add_argument('\''-m'\'', '\''--message'\'', default='\''PING'\'',' >> "$OUT"
    echo '                       help='\''Custom ping message (default: PING)'\'')' >> "$OUT"
    echo '    parser.add_argument('\''-l'\'', '\''--list'\'', action='\''store_true'\'',' >> "$OUT"
    echo '                       help='\''List available serial ports'\'')' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    args = parser.parse_args()' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    if args.list:' >> "$OUT"
    echo '        list_serial_ports()' >> "$OUT"
    echo '        return' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    if not args.port:' >> "$OUT"
    echo '        parser.print_help()' >> "$OUT"
    echo '        print("\nError: Port argument is required")' >> "$OUT"
    echo '        sys.exit(1)' >> "$OUT"
    echo '    ' >> "$OUT"
    echo '    ping_pong = SerialPingPong(args.port, args.baudrate, args.interval, args.message)' >> "$OUT"
    echo '    ping_pong.start()' >> "$OUT"
    echo '' >> "$OUT"
    echo 'if __name__ == "__main__":' >> "$OUT"
    echo '    main()' >> "$OUT"
    echo '' >> "$OUT"
    echo '' >> "$OUT"
    echo '' >> "$OUT"
    echo '# Make executable' >> "$OUT"
    echo '#chmod +x serial_ping.py' >> "$OUT"
    echo '' >> "$OUT"
    echo '# Basic usage' >> "$OUT"
    echo '#python3.12 serial_ping.py /dev/ttyS4' >> "$OUT"
    echo '' >> "$OUT"
    echo '# Custom baud rate and interval' >> "$OUT"
    echo '#python3.12 serial_ping.py /dev/ttyS4 -b 9600 -i 1' >> "$OUT"
    echo '' >> "$OUT"
    echo '# Custom message' >> "$OUT"
    echo '#python3.12 serial_ping.py /dev/ttyS4 -m "HELLO"' >> "$OUT"
    echo '' >> "$OUT"
    echo '# List available ports' >> "$OUT"
    echo '#python3.12 serial_ping.py --list' >> "$OUT"
    chmod +x "$OUT"
    python3 -c "import ast; ast.parse(open('serial_ping.py').read()); print('serial_ping.py: syntax OK')"
fi
```

## Option C — push it over SSH (no paste at all)

From a host that already has the repo checked out, send the file through SSH's stdin — the board never sees a paste:

```bash
ssh <BOARD_USER>@192.0.2.10 'cat > /root/serial_ping.py' < docs/toolchain/Python/serial_ping.py
```

## Verify

```bash
python3 -c "import ast; ast.parse(open('serial_ping.py').read()); print('syntax OK')"
python3 -m py_compile serial_ping.py && echo compiles
wc -l serial_ping.py
md5sum serial_ping.py
```

Expected shape of the output:

```console
syntax OK
compiles
186 serial_ping.py
f710ba04338258ab6323cdada9065a1a  serial_ping.py
```

- That hash is the copy committed in this repo at the time of writing; a mismatch is *not* automatically an error — see the next point.
- A few blank lines in the script consist only of indentation spaces. Editors that trim trailing whitespace on save (VS Code's `files.trimTrailingWhitespace`, for example) rewrite them, which changes the hash but not the behaviour. Trust the `ast.parse` / `py_compile` check, not the hash.
- Then talk to the board:

    ```bash
    python3 serial_ping.py --list
    python3 serial_ping.py /dev/ttyS4 -b 115200 -i 0.5
    ```

## Troubleshooting

| Symptom | Cause / fix |
| :--- | :--- |
| `IndentationError` / `SyntaxError` straight after pasting | The paste was re-indented (the `vi` autoindent problem) or a line was truncated by the terminal. Re-paste with Option A, or line by line with Option B. |
| `ModuleNotFoundError: No module named 'serial'` | `pip3 install pyserial` on the board. |
| `Error opening port /dev/ttyS4: [Errno 13] Permission denied` | The port belongs to a device group. Debian/Ubuntu/Fedora: `sudo usermod -aG dialout "$USER"`, then log out and back in. Some distributions use `uucp` instead; many boards simply run the script as `root`. |
| `This block needs bash` | You are in `dash`/`ash`. Type `bash` and paste Option B again — or use Option A, which is shell-agnostic. |
| Nothing received, no `PONG` | Not an installation problem: check TX/RX wiring and that the far end answers with `PONG`. Both ends need the same baud rate, 8N1. |

## See also

- [`serial_ping.py`](./serial_ping.py) — the script itself (flags, defaults, `--list`).
