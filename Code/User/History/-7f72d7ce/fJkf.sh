#!/bin/bash

player=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)
title=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null)

case "$player" in
    firefox)   icon=" 󰈹" ;;
    spotify)   icon=" 󰓇" ;;
    chrome)    icon=" " ;;
    chromium)  icon=" 󰊯" ;;
    vlc)       icon=" 󰕼" ;;
    mpv)       icon=" " ;;
    *)         icon=" 󰎆" ;;
esac

if [ -z "$title" ]; then
    echo "󰎆 Nada tocando"
else
    echo "$icon $title"
fi
