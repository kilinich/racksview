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
    parser.add_argument('--port', type=str, default='/dev/serial0', help='Serial device name (default: /dev/serial0)')
    parser.add_argument('--baudrate', type=int, default=115200, help='Baud rate (default: 115200)')
    parser.add_argument('--average', type=int, default=5, help='Time in seconds (default: 5) to average the distance readings')
    parser.add_argument('--jitter', type=int, default=50, help='Jitter value (default: 50) indicated motion detected')
    parser.add_argument('--distance', type=int, default=300, help='Minimum distance (default: 300) to consider motion undetected')
    parser.add_argument('--flag', type=str, default='/tmp/motion.flg', help='Named pipe for motion flags (default: /tmp/motion.flg)')

    args, _ = parser.parse_known_args()

    # Check for incorrect values
    if args.baudrate < 110:
        log_error("Baud rate must be 110 or greater.")
        sys.exit(1)
    if args.average < 1:
        log_error("Average window must be a positive number.")
        sys.exit(1)
    if args.jitter < 1:
        log_error("Jitter value must be a positive integer.")
        sys.exit(1)
    if args.distance < 20:
        log_error("Distance value must be at least 20.")
        sys.exit(1)

    try:
        ser = serial.Serial(
            port=args.port,
            baudrate=args.baudrate,
            timeout=10
        )
    except serial.SerialException as e:
        log_error(f"Error opening serial port {args.port}: {e}")
        sys.exit(1)
    
    try:
        buffer = deque([0, 0, 0, 0], maxlen=4)
        distances = deque(maxlen=1000)
        timestamps = deque(maxlen=1000)
        init_time = time.time()
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
                        distances.append(0)
                    else:
                        distances.append((data_h << 8) + data_l)
                    timestamps.append(time.time())
                    # Remove old values outside the averaging window, but always keep the latest value
                    while len(distances) > 1 and time.time() - timestamps[0] > args.average:
                        timestamps.popleft()
                        distances.popleft()
                    # Exclude zero values from averaging
                    nonzero_distances = [d for d in distances if d != 0]
                    if nonzero_distances:
                        avg_distance = int(round(sum(nonzero_distances) / len(nonzero_distances)))
                        values_in_window = len(nonzero_distances)
                    else:
                        avg_distance = 0
                        values_in_window = 0
                    # Calculate jitter (standard deviation of distances in the window)
                    if len(nonzero_distances) > 1:
                        variance = sum((d - avg_distance) ** 2 for d in nonzero_distances) / len(nonzero_distances)
                        jitter = int(round(variance ** 0.5))
                    else:
                        jitter = 0
                    # Determine if the reading is stable or unstable
                    nonzero_ratio = len(nonzero_distances) / len(distances) if distances else 0
                    if time.time() - init_time < args.average:
                        motion_status = "initializing"
                    elif (jitter < args.jitter and avg_distance < args.distance and values_in_window > args.average and nonzero_ratio >= 1/3):
                        motion_status = "undetected"
                    else:
                        motion_status = "detected"
                        with open(args.flag, "w") as flag_file:
                            flag_file.write(
                                f"detected {datetime.datetime.now().strftime('%H:%M.%S')} "
                                f"dist={distances[-1]} "
                                f"avg={avg_distance} "
                                f"jitter={jitter} "
                                f"values={values_in_window} "
                                f"measured={round(nonzero_ratio*100)}%"
                            )
                            flag_file.flush()
                    print(f"([distance]={distances[-1]} [avg]={avg_distance} [jitter]={jitter} [values]={values_in_window} [measured]={nonzero_ratio:.2f} [motion]={motion_status})")
    except KeyboardInterrupt:
        log_error("Keyboard interrupt received, exiting gracefully.")
    except Exception as e:
        log_error(f"Error during serial read: {e}")
    finally:
        ser.close()

if __name__ == "__main__":
    read_distance()
