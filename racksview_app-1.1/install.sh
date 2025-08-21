#!/bin/bash

set -e

services=(
    gstreamer-back
    gstreamer-front
    mdetector-back
    mdetector-front
)

APP_SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="/opt/racksview"
SYSTEMD_DIR="/usr/lib/systemd/system"
NGINX_CONF_SRC="$APP_SRC/etc/nginx/config/nginx.conf"
NGINX_CONF_DEST="/usr/local/openresty/nginx/conf/nginx.conf"

echo "Step 1: Creating $DEST_DIR and copying bin and etc directories..."
sudo mkdir -p "$DEST_DIR"
sudo cp -r "$APP_SRC/bin" "$DEST_DIR/"
sudo cp -r "$APP_SRC/etc" "$DEST_DIR/"
sudo cp -r "$APP_SRC/scripts" "$DEST_DIR/"
sudo chmod -R +x "$DEST_DIR/bin"
sudo chmod -R +x "$DEST_DIR/scripts"

echo "Step 2: Installing systemd service files..."
if [ -d "$APP_SRC/etc/systemd" ]; then
    for service in "${services[@]}"; do
        service_file="$APP_SRC/etc/systemd/${service}.service"
        if [ -f "$service_file" ]; then
            sudo cp "$service_file" "$SYSTEMD_DIR/"
            echo " - Enabling and reloading service: ${service}.service"
            sudo systemctl enable "${service}.service"
        fi
    done
    sudo systemctl daemon-reload
fi

echo "Step 3: Creating /var/log/racksview and linking to $DEST_DIR/log..."
sudo mkdir -p /var/log/racksview
sudo mkdir -p "$DEST_DIR/log"
if [ ! -L "$DEST_DIR/log" ]; then
    sudo rm -rf "$DEST_DIR/log"
    sudo ln -s /var/log/racksview "$DEST_DIR/log"
fi

echo "Creating /tmp/racksview and linking to $DEST_DIR/pipes..."
sudo mkdir -p /tmp/racksview
if [ ! -L "$DEST_DIR/pipes" ]; then
    sudo rm -rf "$DEST_DIR/pipes"
    sudo ln -s /tmp/racksview "$DEST_DIR/pipes"
fi

echo "Step 4: Copying nginx.conf to $NGINX_CONF_DEST..."
sudo mkdir -p "$(dirname "$NGINX_CONF_DEST")"
sudo cp -f "$NGINX_CONF_SRC" "$NGINX_CONF_DEST"

echo "Step 5: Reloading OpenResty (nginx)..."
sudo openresty -s reload

echo "Step 6: Starting services..."
for service in "${services[@]}"; do
    echo " - Starting service: ${service}.service"
    sudo systemctl start "${service}.service"
done

echo "Installation complete."