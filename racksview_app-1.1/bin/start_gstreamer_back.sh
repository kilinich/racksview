#!/bin/bash

export OVLABEL=$(hostname)-back
export GST_DEBUG=1
# Start the gstreamer pipeline

# This pipeline captures video from the camera, adds a text overlay with the hostname and current time,
# scales the video to two different resolutions, encodes the video as jpeg, and sends the video over TCP to two different ports.

gst-launch-1.0 -q -e \
libcamerasrc name=src ! queue leaky=2 ! video/x-raw,framerate=1/1 ! tee name=t \
    t. ! queue leaky=2 ! videoscale ! video/x-raw,width=1296,height=972 !\
        textoverlay text="$OVLABEL" valignment=top halignment=left font-desc="Sans, 10" xpos=10 ypos=10 ! \
        clockoverlay time-format="%d-%m-%Y %H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 10" xpos=10 ypos=-10 ! \
        v4l2jpegenc extra-controls="controls,compression_quality=50" ! multipartmux ! \
        tcpserversink host=127.0.0.1 port=8013 recover-policy=3 sync=false \
    t. ! queue leaky=2 ! videorate ! video/x-raw,framerate=1/2 ! videoscale ! video/x-raw,width=320,height=240 ! \
        textoverlay text="$OVLABEL" valignment=top halignment=left font-desc="Sans, 20" xpos=5 ypos=5 ! \
        clockoverlay time-format="%H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 20" xpos=5 ypos=-5 ! \
        v4l2jpegenc extra-controls="controls,compression_quality=30" ! multipartmux ! \
        tcpserversink host=127.0.0.1 port=8012 recover-policy=3 sync=false