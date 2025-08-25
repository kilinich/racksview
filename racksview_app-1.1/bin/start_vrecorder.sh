#!/bin/bash
set +e

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
        --unflag)
            STOP_FLAG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Ensure all required parameters are set
if [[ -z "${SOURCE_PORT}" || -z "${FILE_NAME}" || -z "${START_FLAG}" || -z "${STOP_FLAG}" ]]; then
    echo "Usage: $0 --port <source_port> --file <file_name> --flag <start_flag> --unflag <stop_flag>"
    exit 1
fi

# Configuration
RUN_ON_START_REC="/opt/racksview/bin/start_recording.sh"
RUN_ON_STOP_REC="/opt/racksview/bin/stop_recording.sh"
TARGET_BASE="/opt/racksview/var/video"
TEMP_NAME="_recording-in-progress"
SEGMENT_DURATION=300
BITRATE=60

# Initialize flags
rm -f "${START_FLAG}"
rm -f "${STOP_FLAG}"

while true
do    
    # Wait for the start flag to be created
    if [ -f "${START_FLAG}" ]; then
        # Run the start recording script
        "${RUN_ON_START_REC}"

        # Loop until the stop flag is created
        while [ ! -f "${STOP_FLAG}" ]; do
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
            FULL_PATH="${TARGET_DIR}/${OUTPUT_FILE}"

            # Run ffmpeg to record a segment, overwriting any existing file (-y)
            ffmpeg -y -loglevel warning -r 1 -i tcp://127.0.0.1:${SOURCE_PORT} \
            -t ${SEGMENT_DURATION} \
            -c:v libx264 -preset ultrafast -threads 1 -b:v ${BITRATE}k \
            "${FULL_PATH}${TEMP_NAME}.mp4"

            mv -f "${FULL_PATH}${TEMP_NAME}.mp4" "${FULL_PATH}.mp4"
        done
        # Check if the stop flag exists
        if [ -f "${STOP_FLAG}" ]; then
            rm -f "${STOP_FLAG}"
            rm -f "${START_FLAG}"            
            # Run the stop recording script
            "${RUN_ON_STOP_REC}"
        fi        
    else
        sleep 1
    fi
done
