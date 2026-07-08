#!/usr/bin/env python3
"""
Serial Port Ping Script
Send ping messages to a serial port to help identify TX/RX pins on Linux boards
"""

import serial
import time
import argparse
import sys

def send_ping(port, baudrate=115200, interval=0.5, message="PING"):
    """
    Send ping message over serial port
    
    Args:
        port: Serial port path (e.g., /dev/ttyS4)
        baudrate: Baud rate (default: 115200)
        interval: Time between transmissions in seconds (default: 0.5)
        message: Message to send (default: "PING")
    """
    try:
        # Open serial port
        ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=1
        )
        
        print(f"Successfully opened port {port}")
        print(f"Settings: {baudrate} baud, 8N1")
        print(f"Sending '{message}' every {interval} seconds...")
        print("Press Ctrl+C to stop\n")
        
        counter = 0
        
        while True:
            try:
                # Create message with counter
                ping_message = f"{message} #{counter}\r\n"
                
                # Send data
                ser.write(ping_message.encode('utf-8'))
                print(f"Sent: {ping_message.strip()}")
                
                # Check for incoming data (optional)
                if ser.in_waiting > 0:
                    received = ser.readline().decode('utf-8').strip()
                    if received:
                        print(f"Received: {received}")
                
                counter += 1
                time.sleep(interval)
                
            except serial.SerialException as e:
                print(f"Serial error: {e}")
                break
                
    except serial.SerialException as e:
        print(f"Error opening port {port}: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nTransmission stopped")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print(f"Port {port} closed")

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

def main():
    parser = argparse.ArgumentParser(
        description='Send ping over serial port for pin identification',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s /dev/ttyS4
  %(prog)s /dev/ttyS4 -b 9600 -i 1 -m "TEST"
  %(prog)s --list
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
    
    send_ping(args.port, args.baudrate, args.interval, args.message)

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
