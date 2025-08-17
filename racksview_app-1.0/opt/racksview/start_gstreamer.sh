#!/bin/bash

export HOSTNAME=$(hostname)

# Start the gstreamer pipeline

gst-launch-1.0 -e \
libcamerasrc name=src ! queue ! video/x-raw,framerate=1/1 ! tee name=t \
    t. ! queue ! videoscale ! video/x-raw,width=1296,height=972 ! videoconvert ! \
        textoverlay text="$HOSTNAME" valignment=top halignment=left font-desc="Sans, 10" xpos=10 ypos=10 ! \
        clockoverlay time-format="%d-%m-%Y %H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 10" xpos=10 ypos=-10 ! \
        videoconvert ! x264enc tune=zerolatency bitrate=2000 speed-preset=ultrafast ! \
        h264parse ! mpegtsmux ! hlssink max-files=5 playlist-length=5 target-duration=5 \
        location="/var/www/html/stream1/segment_%05d.ts" playlist-location="/var/www/html/stream1/playlist.m3u8" \
    t. ! queue ! videoscale ! video/x-raw,width=320,height=240 ! videoconvert ! \
        textoverlay text="$HOSTNAME" valignment=top halignment=left font-desc="Sans, 20" xpos=5 ypos=5 ! \
        clockoverlay time-format="%H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 20" xpos=5 ypos=-5 ! \
        videoconvert ! x264enc tune=zerolatency bitrate=500 speed-preset=ultrafast ! \
        h264parse ! mpegtsmux ! hlssink max-files=5 playlist-length=5 target-duration=5 \
        location="/var/www/html/stream2/segment_%05d.ts" playlist-location="/var/www/html/stream2/playlist.m3u8"