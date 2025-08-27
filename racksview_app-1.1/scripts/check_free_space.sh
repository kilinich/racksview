#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <target_directory>"
    exit 1
fi
TARGET_DIR="$1"
MIN_FREE_MB=100

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Get free space in MB
FREE_MB=$(df -m "$TARGET_DIR" | awk 'NR==2 {print $4}')

# Check if FREE_MB is a valid number
if ! [[ "$FREE_MB" =~ ^[0-9]+$ ]]; then
    echo "Error: Unable to determine free space for $TARGET_DIR."
    exit 1
fi

# If free space is less than MIN_FREE_MB
while [ "$FREE_MB" -lt "$MIN_FREE_MB" ]; do
    echo "Free space ($FREE_MB MB) is less than minimum required ($MIN_FREE_MB MB). Deleting oldest files..."
    # Find and delete oldest file
    OLDEST_FILE=$(find -L "$TARGET_DIR" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
    if [ -z "$OLDEST_FILE" ]; then
        # No files left to delete
        echo "Error: No files left to delete in $TARGET_DIR."
        break
    fi
    echo "Deleting oldest file: $OLDEST_FILE"
    rm -f "$OLDEST_FILE"

    # Delete empty directories
    echo "Deleting empty directories..."
    find -L "$TARGET_DIR" -mindepth 1 -type d -empty -delete

    # Update free space
    FREE_MB=$(df -m "$TARGET_DIR" | awk 'NR==2 {print $4}')
done

