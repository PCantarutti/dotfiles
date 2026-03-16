#!/bin/bash

CONFIG="$HOME/.config/waybar/config.jsonc"

# Lista todos os apps
apps=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read f; do
    name=$(grep -m1 "^Name=" "$f" | cut -d= -f2)
    exec=$(grep -m1 "^Exec=" "$f" | cut -d= -f2 | sed 's/ %.*//g' | sed 's/ $//g')
    [ -n "$name" ] && [ -n "$exec" ] && echo "$name|$exec"
done | sort -u)

chosen=$(echo "$apps" | awk -F'|' '{print $1}' | rofi -dmenu -p "󰐕 Fixar no Dock" -i -normalize-match \
    -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" \
    -theme ~/.config/rofi/wifi-bluetooth.rasi)

[ -z "$chosen" ] && exit

exec_cmd=$(echo "$apps" | awk -F'|' -v name="$chosen" '$1==name {print $2; exit}')
safe_name=$(echo "$chosen" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

# Mostra o módulo gerado e abre nano na linha do group/dock
module="
    \"custom/$safe_name\": {
        \"format\": \"$chosen\",
        \"on-click\": \"$exec_cmd\",
        \"tooltip\": false
    },"

echo "$module"

# Copia para clipboard
echo "$module" | wl-copy

notify-send "Dock" "Módulo copiado! Cole no config.jsonc e adicione 'custom/$safe_name' no group/dock"

# Abre o nano na linha do group/dock
line=$(grep -n "group/dock" "$CONFIG" | head -1 | cut -d: -f1)
kitty -e nano +"$line" "$CONFIG"