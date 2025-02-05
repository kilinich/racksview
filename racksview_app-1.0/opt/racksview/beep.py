#!/usr/bin/env python3
import sys
import argparse
import configparser
import ast
import time
import RPi.GPIO as GPIO

def play_signal(pin, freqs, beep_length, pause_length, count):
    """
    Plays a sequence of frequencies on the given GPIO pin.

    :param pin: GPIO pin number (BCM numbering).
    :param freqs: List of frequencies in Hz.
    :param beep_length: Duration of each frequency tone in seconds.
    :param pause_length: Pause between frequencies in seconds.
    :param count: Number of times to repeat the entire sequence.
    """
    # Create a single PWM object at an initial frequency (e.g. the first in freqs).
    pwm = GPIO.PWM(pin, freqs[0] if freqs else 440)
    try:
        for _ in range(count):
            for freq in freqs:
                # Change the frequency instead of creating new PWM objects
                pwm.ChangeFrequency(freq)

                # Start the PWM (50% duty cycle)
                pwm.start(50)
                time.sleep(beep_length)

                # Stop between frequencies
                pwm.stop()
                time.sleep(pause_length)
    finally:
        pwm.stop()  # In case it's still running

def main():
    parser = argparse.ArgumentParser(description="Play a named signal (beep) from config.")
    parser.add_argument(
        "--config", 
        default="beep.ini",
        help="Path to the configuration file (default: beep.ini)."
    )
    parser.add_argument(
        "--signal", 
        required=True,
        help="Name of the signal section in the config file (e.g., signal_name1)."
    )
    args = parser.parse_args()

    # Parse the INI config
    config = configparser.ConfigParser()
    config.read(args.config)

    # Get speaker pin from [speaker] section
    if "speaker" not in config:
        print("Error: No [speaker] section found in the config file.")
        sys.exit(1)

    pin_str = config["speaker"].get("pin")
    if not pin_str:
        print("Error: 'pin' is not specified under [speaker].")
        sys.exit(1)
    try:
        pin = int(pin_str)
    except ValueError:
        print(f"Error: Invalid GPIO pin '{pin_str}' in [speaker] section.")
        sys.exit(1)

    # Check if the requested signal exists
    signal_name = args.signal
    if signal_name not in config:
        print(f"Error: No section named [{signal_name}] in config.")
        sys.exit(1)

    # Retrieve signal parameters
    signal_section = config[signal_name]

    # freq list
    freqs_str = signal_section.get("freqs", "[440]")
    try:
        # Use ast.literal_eval to parse the string "[440, 220, 880]" into a Python list
        freqs = ast.literal_eval(freqs_str)
    except Exception as e:
        print(f"Error parsing freqs: {e}")
        sys.exit(1)

    # beep_length
    beep_length = float(signal_section.get("beep_length", "0.5"))
    # pause_length
    pause_length = float(signal_section.get("pause_length", "0.5"))
    # count
    count = int(signal_section.get("count", "1"))

    # Initialize GPIO
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)

    try:
        play_signal(pin, freqs, beep_length, pause_length, count)
    except KeyboardInterrupt:
        pass
    finally:
        GPIO.cleanup()

if __name__ == "__main__":
    main()
