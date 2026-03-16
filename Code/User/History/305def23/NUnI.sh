#!/bin/bash

PINNED_FILE="$HOME/.config/waybar/pinned-apps.txt"
touch "$PINNED_FILE"

result=""
while IFS= read -r app; do
    [ -z "$app" ] && continue
    name=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null \
        | xargs grep -l "Exec=$app" 2>/dev/null \
        | head -1 \
        | xargs grep -m1 "^Name=" 2>/dev/null \
        | cut -d= -f2)
    [ -z "$name" ] && name="$app"
    result="$result $name"
done < "$PINNED_FILE"

echo "${result:-Dock vazio}"