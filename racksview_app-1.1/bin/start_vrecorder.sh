#!/bin/bash
set +e

# Parameters
# Check and parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)
            SOURCE_PORT="$2"
            shift 2
            ;;
        --file)
            FILE_NAME="$2"
            shift 2
            ;;
        --flag)
            START_FLAG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Ensure all required parameters are set
if [[ -z "${SOURCE_PORT}" || -z "${FILE_NAME}" || -z "${START_FLAG}" ]]; then
    echo "Usage: $0 --port <source_port> --file <file_name> --flag <start_flag>"
    exit 1
fi

# Configuration
TARGET_BASE="/opt/racksview/var/video"
TEMP_DIR="/tmp/racksview"
SEGMENT_DURATION=300
BITRATE=50

rm -f "${START_FLAG}"

while true
do    
    # Wait for the start flag to be created
    while [ ! -f "${START_FLAG}" ]; do
        sleep 1
    done

    if [ -f "${START_FLAG}" ]; then

        # Get current date/time components
        YEAR=$(date +%Y)
        MONTH=$(date +%m)
        DAY=$(date +%d)
        HOUR=$(date +%H)
        MINUTE=$(date +%M)

        # Create target directory if it doesn't exist
        TARGET_DIR="${TARGET_BASE}/${YEAR}-${MONTH}-${DAY}"
        mkdir -p "${TARGET_DIR}" 2>/dev/null

        # Build output file name with hours, minutes, and seconds
        OUTPUT_FILE="${HOUR}-${MINUTE}_${FILE_NAME}"
        TEMP_PATH="${TEMP_DIR}/${OUTPUT_FILE}"
        FULL_PATH="${TARGET_DIR}/${OUTPUT_FILE}"

        # Run ffmpeg to record a segment, overwriting any existing file (-y)
        ffmpeg -y -loglevel warning -r 1 -i tcp://127.0.0.1:${SOURCE_PORT} \
          -t ${SEGMENT_DURATION} \
          -c:v libx264 -preset veryfast -b:v ${BITRATE}k \
          "${TEMP_PATH}"

        # Move the temporary file to the final destination
        mv "${TEMP_PATH}" "${FULL_PATH}"

        # Delete the flag after recording is finished
        rm -f "${START_FLAG}"
    fi
done
