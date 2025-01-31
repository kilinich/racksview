import serial
import numpy as np
import configparser
import logging
import time
import subprocess
import argparse
from collections import deque

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_config(config_path):
    config = configparser.ConfigParser()
    config.read(config_path)
    return {
        "serial": {
            "device": config.get("serial", "device", fallback="/dev/ttyAMA0"),
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
            "run_on_open": config.get("detection", "run_on_open", fallback="recordvideo.sh"),
            "run_on_close": config.get("detection", "run_on_close", fallback="stopvideo.sh"),
        }
    }

def read_distance(serial_config):
    """Reads data from the sensor and returns the distance in mm."""
    ser = serial.Serial(
        serial_config["device"],
        baudrate=serial_config["baudrate"],
        bytesize=serial_config["bytesize"],
        parity=serial_config["parity"],
        stopbits=serial_config["stopbits"],
        timeout=serial_config["timeout"]
    )
    buffer = bytearray()
    
    try:
        while True:
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
                        return distance
    except KeyboardInterrupt:
        pass
    finally:
        ser.close()

def detect_door_state(measurements, baseline_distance, detection_config, last_stable_time):
    """Determines the door state based on measurement sequences."""
    window_size = detection_config["window_size"]
    threshold_change = detection_config["threshold_change"]
    stable_std_dev = detection_config["stable_std_dev"]
    stable_duration = detection_config["stable_duration"]

    if len(measurements) < window_size:
        return "Initializing", baseline_distance, last_stable_time

    mean_val = np.mean(measurements)
    std_dev = np.std(measurements)
    current_time = time.time()

    if baseline_distance is None and std_dev < stable_std_dev:
        baseline_distance = mean_val
        last_stable_time = current_time
        logging.info("Calibrated: Closed")
        return "Closed", baseline_distance, last_stable_time

    if baseline_distance is not None:
        if std_dev < stable_std_dev:
            if abs(mean_val - baseline_distance) < threshold_change:
                if current_time - last_stable_time >= stable_duration:
                    return "Closed", baseline_distance, current_time
                return "Stable, waiting confirmation", baseline_distance, last_stable_time
            else:
                return "Open", baseline_distance, last_stable_time
        else:
            return "Moving", baseline_distance, last_stable_time
    
    return "Unknown", baseline_distance, last_stable_time

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Door state detection system")
    parser.add_argument("-c", "--config", type=str, default="doordetector.ini", help="Path to the configuration file")
    args = parser.parse_args()
    
    config = load_config(args.config)
    measurements = deque(maxlen=config["detection"]["window_size"])
    baseline_distance = None
    last_stable_time = time.time()
    last_state = None
    
    logging.info("Starting door state detection...")
    
    while True:
        distance = read_distance(config["serial"])
        if distance is not None:
            measurements.append(distance)
            state, baseline_distance, last_stable_time = detect_door_state(
                measurements, baseline_distance, config["detection"], last_stable_time
            )
            
            if state != last_state:
                logging.info(f"Door state changed: {state}")
                last_state = state
                
                if state == "Open":
                    subprocess.Popen(config["detection"]["run_on_open"], shell=True)
                elif state == "Closed":
                    subprocess.Popen(config["detection"]["run_on_close"], shell=True)
