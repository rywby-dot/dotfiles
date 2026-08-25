#!/usr/bin/env bash

PAUSE_FILE="/tmp/cliphist-paused"

if [ -f "$PAUSE_FILE" ]; then
    rm "$PAUSE_FILE"
    notify-send "Cliphist" "Private mode OFF" -i input-keyboard
else
    touch "$PAUSE_FILE"
    wl-copy --clear
    notify-send "Cliphist" "Private mode ON" -i security-low
fi
