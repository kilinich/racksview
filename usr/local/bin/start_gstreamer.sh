#!/bin/bash

export HOSTNAME=$(hostname)

gst-launch-1.0 -e \
libcamerasrc name=src ! queue ! video/x-raw,framerate=1/1 ! tee name=t \
    t. ! queue ! videoscale ! video/x-raw,width=1240,height=768 ! videoconvert ! \
        textoverlay text="$HOSTNAME" valignment=top halignment=left font-desc="Sans, 10" xpos=10 ypos=10 ! \
        clockoverlay time-format="%d-%m-%Y %H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 10" xpos=10 ypos=-10 ! \
        videoconvert ! jpegenc quality=60 ! multipartmux ! queue ! \
        tcpserversink host=0.0.0.0 port=8013 \
    t. ! queue ! videoscale ! video/x-raw,width=320,height=240 ! videoconvert ! \
        textoverlay text="$HOSTNAME" valignment=top halignment=left font-desc="Sans, 20" xpos=5 ypos=5 ! \
        clockoverlay time-format="%H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 20" xpos=5 ypos=-5 ! \
        videoconvert ! jpegenc quality=80 ! multipartmux ! queue ! \
        tcpserversink host=0.0.0.0 port=8012 \
2>/var/log/gstreamer.log

