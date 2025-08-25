#!/bin/bash

sudo apt install pipx
sudo pipx install nuitka
sudo pipx inject nuitka pyserial
sudo nuitka --standalone --onefile motion_detector.py
sudo mv motion_detector.bin ../bin/