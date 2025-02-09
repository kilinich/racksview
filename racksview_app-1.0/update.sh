#!/bin/bash

echo Stopping RacksView services...
sudo systemctl stop doordetector.service webstreamerhigh.service webstreamerlow.service vrecorder.service gstreamer.service
sleep 5

echo Updating RacksView software...
sudo rm -rf /opt/racksview/*
sudo rm -rf /etc/racksview/*
sudo rm -rf /var/log/racksview/*
sudo rm -rf /media/usb/video/*

sudo cp -a ./etc/* /etc/
sudo cp -a ./opt/* /opt/
sudo cp -a ./lib/* /lib/

echo Updating file permissions...
sudo chmod 755 /opt/racksview/*.sh

echo Restarting RacksView services...
sudo systemctl daemon-reload

echo Starting GStreamer service...
sudo systemctl start gstreamer.service
sleep 5
echo Starting WebStreamer services...
sudo systemctl start webstreamerhigh.service webstreamerlow.service
sleep 2
echo Starting VRecorder service...
sudo systemctl start vrecorder.service
echo Starting DoorDetector service...
sudo systemctl start doordetector.service

echo RacksView software update complete.