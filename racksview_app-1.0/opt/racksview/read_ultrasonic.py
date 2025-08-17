import datetime
import sys
import serial
import argparse
from collections import deque
import time

def log_error(message):
    print(f"{datetime.datetime.now()} - {message}", file=sys.stderr)

def read_distance():
    parser = argparse.ArgumentParser(description="Read distance from ultrasonic sensor via serial port.")
    parser.add_argument('-d', '--device', default='/dev/serial0', help='Serial device name (default: /dev/serial0)')
    parser.add_argument('-b', '--baudrate', type=int, default=115200, help='Baud rate (default: 115200)')
    parser.add_argument('-o', '--timeout', type=float, default=10, help='Timeout in seconds (default: 10)')
    parser.add_argument('-a', '--average', type=float, default=5, help='Time in seconds (default: 5) to average the distance readings')

    args, _ = parser.parse_known_args()

    # Check for incorrect values
    if args.baudrate <= 0:
        log_error("Baud rate must be a positive integer.")
        sys.exit(1)
    if args.timeout <= 0:
        log_error("Timeout must be a positive number.")
        sys.exit(1)
    if args.average <= 0:
        log_error("Average window must be a positive number.")
        sys.exit(1)

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
        distances = deque(maxlen=1000)
        timestamps = deque(maxlen=1000)
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
                    # Check for no object detected (0xFFFD)
                    if data_h == 0xFF and data_l == 0xFD:
                        # No object detected, just skip this reading
                        continue
                    distance = (data_h << 8) + data_l
                    now = time.time()
                    distances.append(distance)
                    timestamps.append(now)
                    # Remove old values outside the averaging window, but always keep the latest value
                    while len(distances) > 1 and now - timestamps[0] > args.average:
                        timestamps.pop(0)
                        distances.pop(0)
                    avg_distance = int(round(sum(distances) / len(distances)))
                    # Calculate values_per_sec as number of values in the last 1 second interval
                    one_sec_ago = now - 1
                    values_per_sec = sum(1 for t in timestamps if t >= one_sec_ago)
                    # Calculate jitter (standard deviation of distances in the window)
                    if len(distances) > 1:
                        variance = sum((d - avg_distance) ** 2 for d in distances) / len(distances)
                        jitter = int(round(variance ** 0.5))
                    else:
                        jitter = 0
                    print(f"{distance},{avg_distance},{jitter},{values_per_sec}", flush=True)
    except Exception as e:
        log_error(f"Error during serial read: {e}")
    finally:
        ser.close()

if __name__ == "__main__":
    read_distance()
