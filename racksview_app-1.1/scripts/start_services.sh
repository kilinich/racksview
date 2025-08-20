echo Starting - GStreamer CSI service... (1/5)
systemctl start gstreamer-csi.service
sleep 5
echo Starting - GStreamer USB service... (2/5)
systemctl start gstreamer-usb.service
sleep 5
echo Starting - VRecorder service... (3/5)
systemctl start vrecorder.service
