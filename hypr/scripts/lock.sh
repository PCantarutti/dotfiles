#!/bin/bash
if pgrep -x stremio > /dev/null; then
    exit 0
fi
hyprlock
