import serial
import numpy as np
import configparser
import logging
import time
import subprocess
import argparse
import signal
from collections import deque

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Global variable to track running state
running = True

def handle_exit_signal(signum, frame):
    global running
    logging.info("Received termination signal. Stopping...")
    running = False

def load_config(config_path):
    config = configparser.ConfigParser()
    config.read(config_path)
    return {
        "serial": {
            "device": config.get("serial", "device", fallback="/dev/serial0"),
            "baudrate": config.getint("serial", "baudrate", fallback=115200),
            "bytesize": config.getint("serial", "bytesize", fallback=8),
            "parity": config.get("serial", "parity", fallback="N"),
            "stopbits": config.getint("serial", "stopbits", fallback=1),
            "timeout": config.getint("serial", "timeout", fallback=1),
        },
        "detection": {
            "window_size": config.getint("detection", "window_size", fallback=20),
            "threshold_change": config.getint("detection", "threshold_change", fallback=50),
            "stable_std_dev": config.getint("detection", "stable_std_dev", fallback=5),
            "stable_duration": config.getint("detection", "stable_duration", fallback=300),  # 5 minutes
            "run_on_open": config.get("detection", "run_on_open", fallback="door_open.sh"),
            "run_on_close": config.get("detection", "run_on_close", fallback="door_close.sh"),
            "run_on_no_data": config.get("detection", "run_on_no_data", fallback="door_no_data.sh"),
        }
    }

def open_serial_port(serial_config):
    """Opens the serial port once and returns the serial object."""
    return serial.Serial(
        serial_config["device"],
        baudrate=serial_config["baudrate"],
        bytesize=serial_config["bytesize"],
        parity=serial_config["parity"],
        stopbits=serial_config["stopbits"],
        timeout=serial_config["timeout"]
    )

def read_distance(ser):
    """Reads data from the sensor and returns the distance in mm."""
    buffer = bytearray()
    
    start_time = time.time()
    while running:
        byte = ser.read(1)
        if byte:
            buffer.append(byte[0])
            
            if len(buffer) > 4:
                buffer.pop(0)
            
            if len(buffer) == 4 and buffer[0] == 0xFF:
                start_byte, data_h, data_l, checksum = buffer
                calculated_checksum = (start_byte + data_h + data_l) & 0x00FF
                
                if calculated_checksum == checksum:
                    distance = (data_h << 8) + data_l
                    buffer.clear()
                    
                    # Check for co-frequency interference (FFFE -> 65534 in decimal)
                    if distance == 65534:
                        logging.warning("Co-frequency interference detected!")
                        continue
                    
                    return distance
        
        # Check for timeout
        if time.time() - start_time > 60:
            logging.warning("No data received for 1 minute. Returning 65535.")
            return 65535

def detect_door_state(measurements, baseline_distance, detection_config, last_stable_time, current_state):
    """Determines the door state based on measurement sequences."""
    window_size = detection_config["window_size"]
    threshold_change = detection_config["threshold_change"]
    stable_std_dev = detection_config["stable_std_dev"]
    stable_duration = detection_config["stable_duration"]
    current_time = time.time()

    if len(measurements) < window_size:
        return "Initializing", baseline_distance, last_stable_time

    median_val = np.median(measurements)
    std_dev = np.std(measurements)

    if current_state == "Initializing" and std_dev < stable_std_dev:
        baseline_distance = median_val
        last_stable_time = current_time
        logging.info("Baseline set: Closed")
        return "Closed", baseline_distance, last_stable_time

    if std_dev < stable_std_dev:
        if abs(median_val - baseline_distance) < threshold_change:
            if current_time - last_stable_time >= stable_duration:
                baseline_distance = median_val
                return "Closed", baseline_distance, current_time
            return "Closed", baseline_distance, last_stable_time
        
    return "Opened", baseline_distance, current_time

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Door state detection system")
    parser.add_argument("-c", "--config", type=str, default="doordetector.ini", help="Path to the configuration file")
    args = parser.parse_args()
    
    config = load_config(args.config)
    measurements = deque(maxlen=config["detection"]["window_size"])
    baseline_distance = None
    last_stable_time = time.time()
    current_state = "Initializing"
    
    logging.info("Starting door state detection...")
    
    ser = open_serial_port(config["serial"])  # Open serial port once
    
    signal.signal(signal.SIGINT, handle_exit_signal)  # Handle Ctrl+C
    signal.signal(signal.SIGTERM, handle_exit_signal) # Handle systemctl stop
    
    try:
        while running:
            distance = read_distance(ser)
            if distance == 65535:
                subprocess.Popen(config["detection"]["run_on_no_data"], shell=True)
            elif distance is not None:
                measurements.append(distance)
                new_state, baseline_distance, last_stable_time = detect_door_state(
                    measurements, baseline_distance, config["detection"], last_stable_time, current_state
                )
                
                if new_state != current_state:
                    logging.info(f"Door state changed: {new_state}")
                    if new_state == "Opened":
                        subprocess.Popen(config["detection"]["run_on_open"], shell=True)
                    elif new_state == "Closed" and current_state != "Initializing":
                        subprocess.Popen(config["detection"]["run_on_close"], shell=True)
                    current_state = new_state
            
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
    finally:
        ser.close()
        logging.info("Serial port closed. Exiting.")
        subprocess.Popen(config["detection"]["run_on_no_data"], shell=True)
