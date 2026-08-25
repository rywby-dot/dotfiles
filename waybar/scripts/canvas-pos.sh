#!/bin/bash

MONITOR=$1
if [ -z "$MONITOR" ]; then
  echo "Error: Output name required"
  exit 1
fi

print_state() {
  driftwm msg state 2>/dev/null | awk -v monitor="$MONITOR" '
        {
            offset = ($1 == "*" ? 1 : 0)
        }
        $(1 + offset) == monitor && $(2 + offset) == "camera" {
            x=$(3 + offset)
            y=$(4 + offset)
            z=$(6 + offset)
        }
        END {
            if (z != "") {
                printf "%.2f  x=%.0f y=%.0f\n", z, x, y
            }
        }
    '
}

last_state=
while true; do
  state=$(print_state)

  if [ -n "$state" ] && [ "$state" != "$last_state" ]; then
    printf '%s\n' "$state"
    last_state=$state
  fi

  sleep 0.2
done
