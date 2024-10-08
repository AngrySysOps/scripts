#!/bin/bash

# Piotr Tarnawski aka. Angry Admin
# Please subscribe to my YouTube channel as thank you :  https://www.youtube.com/@AngryAdmin
# Follow mw on X:  @AngrySysOps

folderPath="$HOME/test"
timeout=10
start_time=$(date +%s)

while [ $(($(date +%s) - $start_time)) -lt $timeout ]; do
    if [ -d "$folderPath" ]; then
        echo "Folder detected. No action needed."
        exit 0
    fi
    sleep 1
done

# echo "Folder not found in $timeout seconds. Rebooting..."
/sbin/reboot
