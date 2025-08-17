#!/bin/bash
# This script starts the ultrasonic sensor reading process and sets up named pipes for communication.

# Create /run/racksview directory if it doesn't exist
DIR="/run/racksview"
[[ -d "$DIR" ]] || mkdir -p "$DIR"

# Create named pipes if they don't exist
PIPE1="$DIR/racksview_door1"
PIPE2="$DIR/racksview_sensor1"

[[ -p "$PIPE1" ]] || mkfifo "$PIPE1"
[[ -p "$PIPE2" ]] || mkfifo "$PIPE2"

# Run the Python script and tee output to both pipes, ignore broken pipe errors
python3 read_ultrasonic.py -d /dev/serial0 | tee  --output-error=exit-nopipe -p "$PIPE1" "$PIPE2"