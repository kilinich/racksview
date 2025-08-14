echo Starting GStreamer service... (1/5)
systemctl start gstreamer.service
sleep 5
echo Starting WebStreamer services... (2/5)
systemctl start webstreamerhigh.service webstreamerlow.service
sleep 2
echo Starting VRecorder service... (3/5)
systemctl start vrecorder.service
echo Starting DoorDetector service... (4/5)
systemctl start doordetector.service
echo Starting RecWebServer service... (5/5)
systemctl start recwebserver.service
