#!/bin/bash
set +e

echo Stopping RacksView services...
sudo systemctl stop doordetector.service webstreamerhigh.service webstreamerlow.service vrecorder.service gstreamer.service recwebserver.service gstreamer-usb.service gstreamer-csi.service

echo Disabling RacksView services...
sudo systemctl disable doordetector.service webstreamerhigh.service webstreamerlow.service vrecorder.service gstreamer.service recwebserver.service gstreamer-usb.service gstreamer-csi.service

echo Removing RacksView services...
sudo rm /lib/systemd/system/doordetector.service /lib/systemd/system/webstreamerhigh.service /lib/systemd/system/webstreamerlow.service /lib/systemd/system/vrecorder.service /lib/systemd/system/gstreamer.service /lib/systemd/system/recwebserver.service /lib/systemd/system/gstreamer-usb.service /lib/systemd/system/gstreamer-csi.service
sudo systemctl daemon-reload
