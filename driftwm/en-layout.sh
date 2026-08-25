#!/usr/bin/env bash
kill -USR1 "$(cat /tmp/kbd_layout_daemon.pid)" 2>/dev/null
[ -n "$1" ] && exec "$@"
