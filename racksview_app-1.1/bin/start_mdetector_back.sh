#!/bin/bash

TMP_DIR="/tmp/racksview"
FLAG="$TMP_DIR/motion_back.flg"

# Ensure the TMP_DIR directory exists
mkdir -p "$TMP_DIR"

python3 /opt/racksview/bin/motion_detector.py --port /dev/serial0 --flag "$FLAG"