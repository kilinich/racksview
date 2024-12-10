#!/bin/bash

export HOSTNAME=$(hostname)

gst-launch-1.0 libcamerasrc ! \
video/x-raw,width=1024,height=768,framerate=1/1 ! \
videoconvert ! \
textoverlay text="$HOSTNAME" valignment=top halignment=left font-desc="Sans, 10" xpos=10 ypos=10 ! \
clockoverlay time-format="%d-%m-%Y %H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 10" xpos=10 ypos=-10 ! \
videoconvert ! jpegenc quality=50 ! multipartmux ! queue ! \
tcpserversink host=0.0.0.0 port=8080 \
2>/var/log/gstreamer-error.log
