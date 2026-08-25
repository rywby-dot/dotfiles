#!/usr/bin/env bash

niri msg action power-off-monitors
swaylock -f -c 14161b
niri msg action power-off-monitors
sleep 0.1
niri msg action power-off-monitors
loginctl suspend #&&
#  sleep 1
#/home/rywby/./mouse-actions/target/release/mouse-actions
