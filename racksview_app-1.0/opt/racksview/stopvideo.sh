#!/bin/bash

# Parameters
FLAGS_DIR="/opt/racksview/flags"

#set stop flag
touch "${FLAGS_DIR}"/stop.flg

#beep
python3 /opt/racksview/beep.py -config /etc/racksview/beep.ini -signal "door_close"
