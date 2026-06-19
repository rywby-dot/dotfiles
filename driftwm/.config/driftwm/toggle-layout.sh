#!/usr/bin/env bash
CURRENT=$(cat /tmp/kbd_layout 2>/dev/null || echo "EN")
if [ "$CURRENT" = "EN" ]; then
  echo "RU" >/tmp/kbd_layout
else
  echo "EN" >/tmp/kbd_layout
fi
pkill -SIGRTMIN+8 waybar
