#!/bin/bash

export OVLABEL=$(hostname)-front
export GST_DEBUG=1
# Start the gstreamer pipeline

# This pipeline captures video from the camera, adds a text overlay with the hostname and current time,
# scales the video to two different resolutions, encodes the video as jpeg, and sends the video over TCP to two different ports.

gst-launch-1.0 -q -e \
v4l2src device=/dev/video0 ! queue leaky=2 ! image/jpeg,width=1280,height=800,framerate=10/1 ! videorate ! image/jpeg,framerate=1/1 ! v4l2jpegdec ! video/x-raw ! tee name=t \
    t. ! queue leaky=2 ! \
        textoverlay text="$OVLABEL" valignment=top halignment=left font-desc="Sans, 10" xpos=10 ypos=10 ! \
        clockoverlay time-format="%d-%m-%Y %H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 10" xpos=10 ypos=-10 ! \
        v4l2jpegenc ! multipartmux ! \
        tcpserversink host=127.0.0.1 port=9013 recover-policy=3 sync=false \
    t. ! queue leaky=2 ! videoscale ! video/x-raw,width=320,height=240 ! \
        textoverlay text="$OVLABEL" valignment=top halignment=left font-desc="Sans, 20" xpos=2 ypos=2 ! \
        clockoverlay time-format="%H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 20" xpos=2 ypos=-2 ! \
        jpegenc quality=60 ! multipartmux ! \
        tcpserversink host=127.0.0.1 port=9012 recover-policy=3 sync=false