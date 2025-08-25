#!/bin/bash

sudo pipx inject nuitka pyserial
sudo nuitka --standalone --onefile motion_detector.py
sudo mv -f motion_detector.bin ../bin/