#!/bin/bash

PINNED_FILE="$HOME/.config/waybar/pinned-apps.txt"
touch "$PINNED_FILE"

while IFS= read -r app; do
    [ -z "$app" ] && continue
    # Pega o nome do app
    name=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | xargs grep -l "Exec=$app" 2>/dev/null | head -1 | xargs grep -m1 "^Name=" | cut -d= -f2)
    [ -z "$name" ] && name="$app"
    echo "$name: $app"
done < "$PINNED_FILE"