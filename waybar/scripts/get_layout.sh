#!/bin/bash
LAYOUT=$(cat /tmp/kbd_layout)

if [ "$LAYOUT" = "RU" ]; then
  echo "{\"text\": \"RU\", \"class\": \"ru\"}"
else
  echo "{\"text\": \"EN\", \"class\": \"en\"}"
fi
