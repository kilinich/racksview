#!/bin/bash

echo Stopping RacksView services...
systemctl stop doordetector.service webstreamerhigh.service webstreamerlow.service vrecorder.service gstreamer.service recwebserver.service
sleep 5


echo Updating RacksView software...
rm -rf /opt/racksview/*
rm -rf /etc/racksview/*
rm -rf /var/log/racksview/*
rm -rf /media/usb/video/*
mkdir /media/usb/video

cp -a ./etc/* /etc/
cp -a ./opt/* /opt/
cp -a ./lib/* /lib/
cp -a ./var/* /var/

echo Updating file permissions...
chmod 755 /opt/racksview/*.sh

echo Restarting RacksView services...
systemctl daemon-reload
systemctl enable gstreamer.service webstreamerhigh.service webstreamerlow.service vrecorder.service doordetector.service recwebserver.service

echo Starting GStreamer service...
systemctl start gstreamer.service
sleep 5
echo Starting WebStreamer services...
systemctl start webstreamerhigh.service webstreamerlow.service
sleep 2
echo Starting VRecorder service...
systemctl start vrecorder.service
echo Starting DoorDetector service...
systemctl start doordetector.service
echo Starting RecWebServer service...
systemctl start recwebserver.service

echo RacksView software update complete.