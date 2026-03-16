#!/bin/bash

CONFIG="$HOME/.config/waybar/config.jsonc"

# Lista todos os apps
apps=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read f; do
    name=$(grep -m1 "^Name=" "$f" | cut -d= -f2)
    exec=$(grep -m1 "^Exec=" "$f" | cut -d= -f2 | sed 's/ %.*//g' | sed 's/ $//g')
    [ -n "$name" ] && [ -n "$exec" ] && echo "$name|$exec"
done | sort -u)

chosen=$(echo "$apps" | awk -F'|' '{print $1}' | rofi -dmenu -p " Fixar no Dock" -i -normalize-match \
    -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" \
    -theme ~/.config/rofi/wifi-bluetooth.rasi)

[ -z "$chosen" ] && exit

exec_cmd=$(echo "$apps" | awk -F'|' -v name="$chosen" '$1==name {print $2; exit}')
safe_name=$(echo "$chosen" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

# Módulo gerado
module="    \"custom/$safe_name\": {
        \"format\": \"$chosen\",
        \"on-click\": \"$exec_cmd\",
        \"tooltip-format\": \"$chosen\",
        \"tooltip\": true
    },"

# Copia para clipboard
echo "$module" | wl-copy

# Linha do group/dock modules array
line=$(grep -n '"modules"' "$CONFIG" | tail -1 | cut -d: -f1)
style="$HOME/.config/waybar/style.css"
style_line=$(grep -n "custom-add-dock" "$style" | tail -1 | cut -d: -f1)

notify-send "Dock" "Cole o módulo em config.jsonc:$line e adicione o estilo em style.css:$style_line"

# Abre ambos no VSCode nas linhas corretas
code --goto "$CONFIG:$line"
code --goto "$style:$style_line"