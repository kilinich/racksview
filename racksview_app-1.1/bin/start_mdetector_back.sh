#!/bin/bash

TMP_DIR="/tmp/racksview"
PIPE="$TMP_DIR/motion_back"

# Ensure the TMP_DIR directory exists
mkdir -p "$TMP_DIR"

# Create named pipe if it doesn't exist
if [[ ! -p "$PIPE" ]]; then
    mkfifo "$PIPE"
fi

python3 /opt/racksview/bin/motion_detector.py --device /dev/serial0 > "$PIPE"