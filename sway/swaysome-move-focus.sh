#!/usr/bin/env bash

CURRENT_WS=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .num')

if [[ ! "$CURRENT_WS" =~ ^[0-9]+$ ]]; then
    exit 0
fi

GROUP=$(( CURRENT_WS / 10 ))
INDEX=$(( CURRENT_WS % 10 ))

MOVE_CONTAINER=1

case "${1:-}" in
    next)
        TARGET_INDEX=$(( INDEX + 1 ))
        ;;
    prev)
        TARGET_INDEX=$(( INDEX - 1 ))
        ;;
    focnext)
        TARGET_INDEX=$(( INDEX + 1 ))
        MOVE_CONTAINER=0
        ;;
    focprev)
        TARGET_INDEX=$(( INDEX - 1 ))
        MOVE_CONTAINER=0
        ;;
    [0-9])
        TARGET_INDEX="$1"
        ;;
    *)
        exit 0
        ;;
esac

if [ "$TARGET_INDEX" -lt 0 ] || [ "$TARGET_INDEX" -gt 9 ]; then
    exit 0
fi

TARGET_WS=$(( GROUP * 10 + TARGET_INDEX ))

if [ "$MOVE_CONTAINER" -eq 1 ]; then
    swaymsg "move container to workspace number $TARGET_WS; workspace number $TARGET_WS"
else
    swaymsg "workspace number $TARGET_WS"
fi
