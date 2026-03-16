#!/bin/bash

while true; do
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    status=$(playerctl status 2>/dev/null)

    play_icon="▶"
    [ "$status" = "Playing" ] && play_icon="⏸"

    options="$play_icon  $title - $artist\n⏮  Anterior\n⏭  Próxima\n⏹  Parar"


    if [[ "$chosen" == *"Anterior"* ]]; then
        playerctl previous
    elif [[ "$chosen" == *"Próxima"* ]]; then
        playerctl next
    elif [[ "$chosen" == *"Parar"* ]]; then
        playerctl stop
    elif [[ "$chosen" == *"⏸"* ]] || [[ "$chosen" == *"▶"* ]]; then
        playerctl play-pause
    fi
done
