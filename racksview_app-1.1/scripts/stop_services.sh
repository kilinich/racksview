#!/bin/bash

# Stop all services
sudo systemctl stop gstreamer-back.service
sudo systemctl stop gstreamer-front.service
sudo systemctl stop mdetector-back.service
sudo systemctl stop mdetector-front.service
sudo systemctl stop vrecorder-back.service
sudo systemctl stop vrecorder-front.service
