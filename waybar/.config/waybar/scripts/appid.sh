#!/bin/bash
STATE_FILE="$XDG_RUNTIME_DIR/driftwm/state"
STATE_DIR=$(dirname "$STATE_FILE")

while [ ! -f "$STATE_FILE" ]; do
  sleep 1
done

print_state() {
  grep '^windows=' "$STATE_FILE" |
    sed 's/^windows=//' |
    jq -r '.[] | select(.is_focused == true) | "\(.app_id)  \(.size[0] | round)x\(.size[1] | round)"'
}

print_state

inotifywait -q -m -e close_write,moved_to,modify "$STATE_DIR" | while read -r dir action file; do
  if [ "$file" = "state" ]; then
    print_state
  fi
done
