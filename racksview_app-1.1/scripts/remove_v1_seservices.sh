#!/bin/bash

echo Stopping RacksView services...
systemctl stop doordetector.service webstreamerhigh.service webstreamerlow.service vrecorder.service gstreamer.service recwebserver.service

echo Disabling RacksView services...
systemctl disable doordetector.service webstreamerhigh.service webstreamerlow.service vrecorder.service gstreamer.service recwebserver.service

echo Removing RacksView services...
rm /lib/systemd/system/doordetector.service /lib/systemd/system/webstreamerhigh.service /lib/systemd/system/webstreamerlow.service /lib/systemd/system/vrecorder.service /lib/systemd/system/gstreamer.service /lib/systemd/system/recwebserver.service
systemctl daemon-reload
