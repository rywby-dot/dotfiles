#!/usr/bin/env bash

if [ -f "/tmp/cliphist-paused" ]; then
    exit 0
fi

exec cliphist store
