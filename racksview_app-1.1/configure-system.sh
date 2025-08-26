#!/bin/bash
# Script to configure config.txt and timesyncd.conf

# Files to modify
CONFIG_FILE="/boot/firmware/config.txt"
TIMESYNCD_CONF="/etc/systemd/timesyncd.conf"

echo "Checking $CONFIG_FILE for required dtoverlay lines..."

# Check for dtoverlay=disable-wifi
if ! grep -q "^dtoverlay=disable-wifi" "$CONFIG_FILE"; then
    echo "dtoverlay=disable-wifi" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo "Added line: dtoverlay=disable-wifi"
else
    echo "Line dtoverlay=disable-wifi already exists"
fi

# Check for dtoverlay=disable-bt
if ! grep -q "^dtoverlay=disable-bt" "$CONFIG_FILE"; then
    echo "dtoverlay=disable-bt" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo "Added line: dtoverlay=disable-bt"
else
    echo "Line dtoverlay=disable-bt already exists"
fi

echo "Checking $TIMESYNCD_CONF for NTP parameter..."
sudo timedatectl set-timezone UTC
# Check if there is an active (non-commented) line starting with NTP=
if ! grep -q "^[[:space:]]*NTP=" "$TIMESYNCD_CONF"; then
    # Retrieve the default gateway IP address
    default_gw=$(ip route | awk '/^default/ {print $3; exit}')
    if [ -z "$default_gw" ]; then
        echo "Failed to determine the default gateway. Please check your network settings." >&2
        exit 1
    fi

    # Append the NTP parameter at the end of the file
    echo "NTP=$default_gw" | sudo tee -a "$TIMESYNCD_CONF" > /dev/null
    echo "Added line: NTP=$default_gw"
else
    echo "NTP parameter is already set in $TIMESYNCD_CONF"
fi

# Add user 'nobody' to the 'video' group for querying video devices
sudo usermod -aG video nobody

echo "Configuration complete."
