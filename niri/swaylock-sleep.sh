#!/usr/bin/env bash

niri msg action power-off-monitors
niri msg action switch-layout 0
sleep 0.1
swaylock -f -c 000000 &
sleep 0.1
loginctl suspend
