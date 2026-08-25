#!/usr/bin/env bash

# swaybar cannot remap workspace labels. Keep swaysome's numeric workspace
# groups, but add the display label after Sway creates a workspace.

lock_file="${XDG_RUNTIME_DIR:-/tmp}/sway-workspace-icons.lock"
exec 9>"$lock_file"
flock -n 9 || exit 0

rename_workspace() {
    number=$1

    case "$number" in
        10|20) icon='`' ;;
        11|21) icon='1' ;;
        12|22) icon='2' ;;
        13|23) icon='3' ;;
        14|24) icon='4' ;;
        15|25) icon='5' ;;
        16|26) icon='6' ;;
        17|27) icon='7' ;;
        18|28) icon='8' ;;
        19|29) icon='9' ;;
        *) return ;;
    esac

    swaymsg "rename workspace $number to $number:$icon" >/dev/null
}

rename_existing_workspaces() {
    swaymsg -t get_workspaces -r 2>/dev/null |
        jq -r '.[] | select(.num >= 10 and .num <= 29 and .name == (.num | tostring)) | .num' |
        while IFS= read -r number; do
            rename_workspace "$number"
        done
}

rename_existing_workspaces

swaymsg -m -t subscribe '["workspace"]' 2>/dev/null |
    jq --unbuffered -r '
        select(
            (.change == "init" or .change == "focus") and
            .current.num >= 10 and
            .current.num <= 29 and
            .current.name == (.current.num | tostring)
        ) |
        .current.num
    ' |
    while IFS= read -r number; do
        rename_workspace "$number"
    done
