#!/bin/bash

echo Stopping RacksView services...
systemctl stop doordetector.service webstreamerhigh.service webstreamerlow.service vrecorder.service gstreamer.service recwebserver.service
