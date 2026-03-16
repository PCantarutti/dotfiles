#!/bin/bash

PINNED_FILE="$HOME/.config/waybar/pinned-apps.txt"
touch "$PINNED_FILE"

if [ ! -s "$PINNED_FILE" ]; then
    echo '{"text": "", "tooltip": ""}'
    exit
fi

text=""
tooltip=""

while IFS= read -r app; do
    [ -z "$app" ] && continue
    name=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null \
        | xargs grep -l "Exec=$app " 2>/dev/null \
        | head -1 \
        | xargs grep -m1 "^Name=" 2>/dev/null \
        | cut -d= -f2)
    [ -z "$name" ] && name="$app"
    text="$text $name |"
    tooltip="$tooltip$name\n"
done < "$PINNED_FILE"

echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"}"