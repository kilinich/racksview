import datetime
import sys
import serial
import argparse
from collections import deque

def log_error(message):
    print(f"{datetime.datetime.now()} - {message}", file=sys.stderr)

def read_distance():
    parser = argparse.ArgumentParser(description="Read distance from ultrasonic sensor via serial port.")
    parser.add_argument('-d', '--device', default='/dev/serial0', help='Serial device name (default: /dev/serial0)')
    parser.add_argument('-b', '--baudrate', type=int, default=115200, help='Baud rate (default: 115200)')
    parser.add_argument('-o', '--timeout', type=float, default=10, help='Timeout in seconds (default: 10)')
    args, _ = parser.parse_known_args()

    try:
        ser = serial.Serial(
            port=args.device,
            baudrate=args.baudrate,
            timeout=args.timeout
        )
    except serial.SerialException as e:
        log_error(f"Error opening serial port {args.device}: {e}")
        sys.exit(1)
    
    try:
        buffer = deque([0, 0, 0, 0], maxlen=4)
        while True:
            byte = ser.read(1)
            if not byte:
                log_error("No data received from serial port within timeout")
                sys.exit(2)
                
            buffer.append(byte[0])
            if buffer[0] == 0xFF:
                start_byte, data_h, data_l, checksum = buffer
                # Check if the checksum matches and you have a complete packet
                if checksum == (start_byte + data_h + data_l) & 0x00FF:
                    # Check for co-frequency interference (0xFFFE)
                    if data_h == 0xFF and data_l == 0xFE:
                        log_error("Co-frequency interference detected")
                        continue
                    distance = (data_h << 8) + data_l
                    print(distance, flush=True)
    except Exception as e:
        log_error(f"Error during serial read: {e}")
    finally:
        ser.close()

if __name__ == "__main__":
    read_distance()
