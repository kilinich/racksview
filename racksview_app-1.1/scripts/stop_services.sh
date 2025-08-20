#!/bin/bash

echo Stopping RacksView services...
systemctl stop gstreamer-usb.service gstreamer-csi.service vr-recorder.service
