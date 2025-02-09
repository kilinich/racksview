#!/bin/bash

# Parameters
FLAGS_DIR="/opt/racksview/flags"

#remove stop flag
rm -f "${FLAGS_DIR}"/stop.flg
# set start flag
mkdir -p "${FLAGS_DIR}" 2>/dev/null
touch "${FLAGS_DIR}"/start.flg

#remove no data flag
rm -f "${FLAGS_DIR}"/no_data.flg

#beep
python3 /opt/racksview/beep.py --config /etc/racksview/beep.ini --signal "door_open"