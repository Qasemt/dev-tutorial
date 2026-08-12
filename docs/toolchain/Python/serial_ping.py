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
