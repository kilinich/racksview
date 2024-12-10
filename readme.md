Installing apps:

# LibCamera
sudo apt-get install libcamera-apps libcamera-dev

# GStreamer
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio gstreamer1.0-libcamera

# FFmpeg
sudo apt-get install ffmpeg

# GStreamer service
sudo chmod +x /usr/local/bin/start_gstreamer.sh
sudo systemctl daemon-reload
sudo systemctl enable gstreamer.service
sudo systemctl start gstreamer.service
sudo systemctl status gstreamer.service
sudo tail -f /var/log/gstreamer-error.log
