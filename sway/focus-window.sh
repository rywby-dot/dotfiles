#!/usr/bin/env bash

if (( $# == 0 )); then
    echo "Usage: $0 <command> [args...]" >&2
    exit 1
fi

case "$*" in
    "flatpak run com.ayugram.desktop")
        app_id="com.ayugram.desktop"
        ;;

    "flatpak run app.zen_browser.zen")
        app_id="app.zen_browser.zen"
        ;;

    "dolphin")
        app_id="org.kde.dolphin"
        ;;

    "flatpak run org.kde.kdenlive")
        app_id="org.kde.kdenlive"
        ;;

    *)
        echo "Unknown application: $*" >&2
        exit 1
        ;;
esac

if swaymsg -r -t get_tree |
    jq -e --arg id "$app_id" \
        '.. | objects | select(.app_id? == $id)' >/dev/null
then
    swaymsg -q "[app_id=\"$app_id\"] focus"
else
    "$@" >/dev/null 2>&1 &
fi
