gst-launch-1.0 libcamerasrc ! video/x-raw,width=800,height=600,framerate=2/1 ! queue ! videoconvert ! queue ! jpegenc ! queue ! multipartmux ! tcpserversink host=0.0.0.0 port=8080
