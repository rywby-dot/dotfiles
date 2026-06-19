#!/bin/bash
STATE_FILE="$XDG_RUNTIME_DIR/driftwm/state"
STATE_DIR=$(dirname "$STATE_FILE")

while [ ! -f "$STATE_FILE" ]; do
  sleep 1
done

MONITOR=$1
if [ -z "$MONITOR" ]; then
  echo "Error: Output name required"
  exit 1
fi

print_state() {
  awk -F'=' -v m="outputs.$MONITOR." '
        $1 == m"zoom"     { z=$2 }
        $1 == m"camera_x" { x=$2 }
        $1 == m"camera_y" { y=$2 }
        END {
            if (z != "") {
                printf "%.2f  x=%.0f y=%.0f\n", z, x, y
            }
        }
    ' "$STATE_FILE"
}

print_state

inotifywait -q -m -e close_write,moved_to,modify "$STATE_DIR" | while read -r dir action file; do
  if [ "$file" = "state" ]; then
    print_state
  fi
done
