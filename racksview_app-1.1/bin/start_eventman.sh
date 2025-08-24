#!/bin/bash

# Example named pipes (ensure these are created by other scripts)
PIPE1="/tmp/event_pipe1"
PIPE2="/tmp/event_pipe2"

# Function to read and parse status from a pipe
read_and_parse_pipe() {
    local pipe="$1"
    if [[ -p "$pipe" ]]; then
        while read -r line; do
            # Example: parse status from the line (customize as needed)
            # Assuming status is in format: STATUS: <value>
            if [[ "$line" =~ STATUS:\ (.*) ]]; then
                status="${BASH_REMATCH[1]}"
                echo "Received status from $pipe: $status"
            else
                echo "Received from $pipe: $line"
            fi
        done < "$pipe" &
    else
        echo "Pipe $pipe does not exist."
    fi
}

# Start reading from pipes
read_and_parse_pipe "$PIPE1"
read_and_parse_pipe "$PIPE2"

# Keep script running
wait