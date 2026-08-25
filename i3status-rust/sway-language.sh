#!/usr/bin/env bash

emit_layout() {
    layout=$(
        swaymsg -t get_inputs -r 2>/dev/null |
            jq -r '[.[] | select(.type == "keyboard" and (.xkb_active_layout_name // "") != "")][0].xkb_active_layout_name // ""'
    )

    case "$layout" in
        *Russian*|*Русск*) printf '%s\n' '{"text":"RU"}' ;;
        '')                printf '%s\n' '{"text":"?"}' ;;
        *)                 printf '%s\n' '{"text":"US"}' ;;
    esac
}

emit_layout

swaymsg -m -t subscribe '["input"]' 2>/dev/null |
    while IFS= read -r _event; do
        emit_layout
    done
