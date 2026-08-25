#!/usr/bin/env bash

waylock -ignore-empty-password -init-color 0x000000 -input-color 0x303030 &
sleep 3 &&
  loginctl suspend
