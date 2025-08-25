#!/bin/bash

sudo pipx inject nuitka pyserial
sudo ~/.local/bin/nuitka-standalone --onefile motion_detector.py
sudo mv -f motion_detector.bin ../bin/