# RacksView is an open source hardware based on Raspberry Pi and A22 ultrasonic sensor 
Racksview app is a bunch of open-source microservices and scripts to provide video web service and recording, 
automatic door open/close detection, slack (or any way you need) notification.

#Libs

**LibCamera**  
install: libcamera-apps libcamera-dev  
test: libcamera-hello; libcamera-still -o test.jpg  

**GStreamer**  
**install:** libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio gstreamer1.0-libcamera  
**test:** gst-inspect-1.0 libcamerasrc  

**WebStreamer**  
**install:** python3-flask python3-waitress  

**DoorDetector**  
**install:** python3-serial python3-numpy  
**test:** python3 /opt/racksview/testultrasonic.py  

**USB auto-mount**  
**install** gdebi; gdeby /var/tmp/usbmount_0.0.24_all.deb  

**VRecorder**  
**install:** ffmpeg  
