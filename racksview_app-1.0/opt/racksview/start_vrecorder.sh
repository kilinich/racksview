#!/bin/bash

# Parameters
SOURCE_PORT="8013"              # TCP port where the MJPEG stream is available
TARGET_BASE="/media/usb/video"  # Base directory for recorded files
SEGMENT_DURATION=300            # Duration (in seconds) for each segment
BITRATE=50                      # Bitrate (in kbps) for libx264 encoding

START_FLAG="/opt/racksview/flags/start.flg"
STOP_FLAG="/opt/racksview/flags/stop.flg"
NO_DATA_FLAG="/opt/racksview/flags/no_data.flg"

MIN_FREE_SPACE=1024            # Minimum free space (in MB) required on target device

export HOSTNAME=$(hostname)
echo "Starting VRecorder on ${HOSTNAME}..."

while true
do
    # Get current date/time components
    YEAR=$(date +%Y)
    MONTH=$(date +%m)
    DAY=$(date +%d)
    HOUR=$(date +%H)
    MINUTE=$(date +%M)

    # Create target directory if it doesn't exist
    TARGET_DIR="${TARGET_BASE}/${YEAR}/${MONTH}/${DAY}"
    mkdir -p "${TARGET_DIR}" 2>/dev/null

    # Build output file name with hours, minutes, and seconds
    OUTPUT_FILE="${HOUR}-${MINUTE}_${HOSTNAME}_recording-in-progress.mp4"
    FULL_PATH="${TARGET_DIR}/${OUTPUT_FILE}"

    # Run ffmpeg to record a 5-minute segment, overwriting any existing file (-y)
    ffmpeg -y -loglevel warning -r 1 -i tcp://127.0.0.1:${SOURCE_PORT} \
      -t ${SEGMENT_DURATION} \
      -c:v libx264 -preset veryfast -b:v ${BITRATE}k \
      "${FULL_PATH}"

    # If either flag exists, rename the file to include '-action'
    if [ -f "${START_FLAG}" ] || [ -f "${STOP_FLAG}" ]; then
        echo "Action detected, renaming file..."
        ACTION_PATH="${TARGET_DIR}/${HOUR}-${MINUTE}_${HOSTNAME}_recording-action.mp4"
        mv "${FULL_PATH}" "${ACTION_PATH}"
    else if [ -f "${NO_DATA_FLAG}" ]; then
            echo "No door data detected, renaming file..."
            NO_DATA_PATH="${TARGET_DIR}/${HOUR}-${MINUTE}_${HOSTNAME}_recording-unknown.mp4"
            mv "${FULL_PATH}" "${NO_DATA_PATH}"
        else
            FILE_PATH="${TARGET_DIR}/${HOUR}-${MINUTE}_${HOSTNAME}_recording-nothing.mp4"
            mv "${FULL_PATH}" "${FILE_PATH}"
        fi
    fi

    # If STOP_FLAG exists, remove it (and START_FLAG too if it exists)
    if [ -f "${STOP_FLAG}" ]; then
        rm -f "${STOP_FLAG}"
        if [ -f "${START_FLAG}" ]; then
            rm -f "${START_FLAG}"
        fi
    fi

    # Check available disk space and delete oldest files if necessary
    while true; do
        FREE_SPACE=$(df -m "${TARGET_BASE}" | awk 'NR==2 {print $4}')
        if [ ${FREE_SPACE} -ge ${MIN_FREE_SPACE} ]; then
            break
        fi

        echo "Low disk space detected, deleting oldest files..."
        # Find and delete the oldest *nothing.mp4 file in sub-directories
        OLDEST_FILE=$(find "${TARGET_BASE}" -type f -name "*nothing.mp4" -printf "%T@ %p\n" | sort -n | head -n 1 | cut -d' ' -f2)
        if [ -n "${OLDEST_FILE}" ]; then
            rm -f "${OLDEST_FILE}"
        else
            echo "No more files to delete."
            break
        fi
        
        # Remove empty directories
        find "${TARGET_BASE}" -type d -empty -delete
    done
    
done
