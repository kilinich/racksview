#!/bin/bash

services=(
    gstreamer-back
    gstreamer-front
    mdetector-back
    mdetector-front
)

for svc in "${services[@]}"; do
    sudo systemctl stop "$svc.service"
    sudo systemctl disable "$svc.service"
    sudo rm "/usr/lib/systemd/system/$svc.service"
done

sudo systemctl daemon-reload
sudo cp -f /usr/lib/local/openresty/nginx/conf/nginx.conf.default /usr/local/openresty/nginx/conf/nginx.conf
sudo openresty -s reload

sudo rm -rf /opt/racksview
sudo rm -rf /etc/racksview
sudo rm -rf /var/log/racksview
sudo rm -rf /tmp/racksview
