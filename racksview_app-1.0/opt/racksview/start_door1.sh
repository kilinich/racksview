#!/bin/bash

# Create /tmp/racksview directory if it doesn't exist
DIR="/tmp/racksview"
[[ -d "$DIR" ]] || mkdir -p "$DIR"

# Create named pipes if they don't exist
PIPE1="$DIR/door1"

[[ -p "$PIPE1" ]] || mkfifo "$PIPE1"

# Run the Python script and tee output to both pipes, ignore broken pipe errors
python3 read_ultrasonic.py -d /dev/serial0 | tee  --output-error=exit-nopipe -p "$PIPE1" /var/log/racksview/door1.log