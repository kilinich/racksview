gst-launch-1.0 libcamerasrc ! \
    video/x-raw,framerate=30/1 ! tee name=t \
    t. ! queue ! videoscale ! video/x-raw,width=640,height=480 ! \
        videorate ! video/x-raw,framerate=10/1 ! \
        videoconvert ! jpegenc quality=50 ! multipartmux ! tcpserversink host=0.0.0.0 port=8080 \
    t. ! queue ! videoscale ! video/x-raw,width=1920,height=1080 ! \
        videorate ! video/x-raw,framerate=5/1 ! \
        videoconvert ! jpegenc quality=90 ! multipartmux ! tcpserversink host=0.0.0.0 port=9090
