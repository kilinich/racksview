#!/bin/bash

# Путь к файлу, куда будет сохраняться запись
OUTPUT_FILE="record_$(date +'%Y%m%d_%H%M%S').avi"

# Длительность записи в секундах
DURATION=10

# Адрес потока
STREAM_URL="tcp://127.0.0.1:8080"

# Команда записи
ffmpeg -y -f mjpeg -r 1 -i "$STREAM_URL" -c:v mjpeg -q:v 2 -t $DURATION "$OUTPUT_FILE"
