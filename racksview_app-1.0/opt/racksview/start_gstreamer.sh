#!/bin/bash

export HOSTNAME=$(hostname)
TARGET_BASE="/media/usb/video"

# Start the gstreamer pipeline

# This pipeline captures video from the camera, adds a text overlay with the hostname and current time, 
# scales the video to two different resolutions, encodes the video as jpeg, and sends the video over TCP to two different ports.

# The pipeline uses the libcamerasrc element to capture video from the camera. 

# The tee element is used to split the video stream into two branches. 

# The first branch scales the video to a resolution of 1296x972, adds a text overlay with the hostname and current time, 
# encodes the video as jpeg with a quality of 60, and sends the video over TCP to port 8013. 

# The second branch scales the video to a resolution of 320x240, adds a text overlay with the hostname and current time, 
# encodes the video as jpeg with a quality of 80, and sends the video over TCP to port 8012.


gst-launch-1.0 -e \
libcamerasrc name=src ! queue ! video/x-raw,framerate=1/1 ! tee name=t \
    t. ! queue ! videoscale ! video/x-raw,width=1296,height=972 ! videoconvert ! \
        textoverlay text="$HOSTNAME" valignment=top halignment=left font-desc="Sans, 10" xpos=10 ypos=10 ! \
        clockoverlay time-format="%d-%m-%Y %H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 10" xpos=10 ypos=-10 ! \
        videoconvert ! jpegenc quality=70 ! multipartmux ! queue ! \
        tcpserversink host=0.0.0.0 port=8013 \
    t. ! queue ! videoscale ! video/x-raw,width=320,height=240 ! videoconvert ! \
        textoverlay text="$HOSTNAME" valignment=top halignment=left font-desc="Sans, 20" xpos=5 ypos=5 ! \
        clockoverlay time-format="%H:%M.%S" valignment=bottom halignment=left font-desc="Sans, 20" xpos=5 ypos=-5 ! \
        videoconvert ! jpegenc quality=90 ! multipartmux ! queue ! \
        tcpserversink host=0.0.0.0 port=8012 \
    t. ! queue ! videoscale ! video/x-raw,width=320,height=240 ! videoconvert ! \
        jpegenc quality=30 ! multifilesink location="${TARGET_BASE}"/preview.jpg post-messages=true next-file=1 max-file-duration=60000000000
