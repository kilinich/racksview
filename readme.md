# RacksView

RacksView is an open-source hardware and software platform designed for intelligent rack monitoring and automation. Built on the Raspberry Pi and the A22 ultrasonic sensor, RacksView enables real-time video streaming, automatic door open/close detection, and instant notifications. The system is ideal for colocation servers racks monitoring.

## Hardware Components

- **Raspberry Pi 3B**  
    The central processing unit for running all services and interfacing with sensors and cameras.
- **Raspberry Pi CSI Camera v1.3**  
    Captures high-quality video for streaming and recording.
- **Ultrasonic Sensor A22**  
    Detects door open/close events by measuring distance changes.
- **PSU 5V 2A**  
    Provides stable power supply for all components.
- **Rackmount Adjustable Box**  
    Houses and protects the hardware, allowing flexible installation in various rack configurations.
- **Optional second unit** 
    USB-connected expansion box equipped with an additional camera and ultrasonic sensor, enabling simultaneous monitoring of both front and rear rack doors from a single host.

## Application Components

- **GStreamer**  
    Runs as a background service to capture video from the camera, resize, encode, and stream as MJPEG over local TCP ports in both high and low resolutions.
- **OpenResty**  
    Combines Nginx and Lua scripts to serve the web dashboard and transcode video streams to HTTP-MPEG format, ensuring browser compatibility.
- **MotionDetector**  
    A compiled Python script that reads raw data from the ultrasonic sensor via serial port, processes it, and generates notifications when the rack door is opened or closed.
- **VideoRecorder**  
    A Bash script service that monitors signals from MotionDetector and triggers video recording using the ffmpeg tool, saving footage for security and auditing.

## Libraries and Tools

- **LibCamera**  
    - **Install:** `libcamera-apps`, `libcamera-dev`  
    - **Test:** `libcamera-hello`, `libcamera-still -o test.jpg`
- **GStreamer**  
    - **Install:** `libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`, `libgstreamer-plugins-bad1.0-dev`, `gstreamer1.0-plugins-base`, `gstreamer1.0-plugins-good`, `gstreamer1.0-plugins-bad`, `gstreamer1.0-plugins-ugly`, `gstreamer1.0-libav`, `gstreamer1.0-tools`, `gstreamer1.0-x`, `gstreamer1.0-alsa`, `gstreamer1.0-gl`, `gstreamer1.0-gtk3`, `gstreamer1.0-qt5`, `gstreamer1.0-pulseaudio`, `gstreamer1.0-libcamera`  
    - **Test:** `gst-inspect-1.0 libcamerasrc`
- **OpenResty**
    Visit the [OpenResty official website](https://openresty.org/) and follow the installation instructions.
- **USB Auto-Mount**  
    - **Install:** `gdebi`; `gdebi /var/tmp/usbmount_0.0.24_all.deb`
- **VRecorder**  
    - **Install:** `ffmpeg`

## Features

- **Live Video Streaming:**  
    View real-time video feeds from your rack via a web dashboard.
- **Automated Door Detection:**  
    Instantly detect and log rack door open/close events.
- **Event-Based Recording:**  
    Automatically record video when motion or door activity is detected.
- **Notifications:**  
    Receive alerts for critical events to enhance security and monitoring.
- **Easy Integration:**  
    Modular design allows for customization and expansion to fit different rack environments.

## Getting Started

1. Assemble the hardware components.
2. Install the required libraries and tools on your Raspberry Pi.
3. Deploy the application components using provided scripts and configuration files.
4. Access the web dashboard to monitor your rack.