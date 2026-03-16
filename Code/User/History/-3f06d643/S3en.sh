#!/bin/bash

PINNED_FILE="$HOME/.config/waybar/pinned-apps.txt"
CONFIG="$HOME/.config/waybar/config.jsonc"
touch "$PINNED_FILE"

# Lista todos os apps
apps=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read f; do
    name=$(grep -m1 "^Name=" "$f" | cut -d= -f2)
    exec=$(grep -m1 "^Exec=" "$f" | cut -d= -f2 | sed 's/ %.//g')
    [ -n "$name" ] && [ -n "$exec" ] && echo "$name|$exec"
done | sort -u)

chosen=$(echo "$apps" | awk -F'|' '{print $1}' | rofi -dmenu -p "󰍉  Apps" -i -normalize-match \
    -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" \
    -kb-custom-1 "Control+f" \
    -theme ~/.config/rofi/wifi-bluetooth.rasi)

ret=$?
[ -z "$chosen" ] && exit

exec_cmd=$(echo "$apps" | awk -F'|' -v name="$chosen" '$1==name {print $2; exit}')
safe_name=$(echo "$chosen" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

if [ $ret -eq 10 ]; then
    # Ctrl+F = fixar no dock
    if grep -q "^$safe_name$" "$PINNED_FILE"; then
        notify-send "Dock" "󰗙 $chosen removido do dock"
        grep -v "^$safe_name$" "$PINNED_FILE" > /tmp/pinned-tmp && mv /tmp/pinned-tmp "$PINNED_FILE"
    else
        notify-send "Dock" "󰐕 $chosen fixado no dock"
        echo "$safe_name|$exec_cmd|$chosen" >> "$PINNED_FILE"
    fi

    # Gera os módulos do dock
    dock_modules=""
    custom_modules=""

    while IFS='|' read -r sname sexec sLabel; do
        [ -z "$sname" ] && continue
        dock_modules="$dock_modules\"custom/$sname\", "
        custom_modules="$custom_modules
    \"custom/$sname\": {
        \"format\": \"$sLabel\",
        \"on-click\": \"$sexec\",
        \"tooltip\": false
    },"
    done < "$PINNED_FILE"

    # Remove vírgula final
    dock_modules=$(echo "$dock_modules" | sed 's/, $//')

    # Substitui o group/dock no config
    python3 -c "
import re, sys

with open('$CONFIG', 'r') as f:
    content = f.read()

# Remove módulos custom do dock antigos
content = re.sub(r'\n\s*\"custom/dock-.*?},', '', content, flags=re.DOTALL)

# Atualiza o group/dock
new_group = '\"group/dock\": {\n        \"orientation\": \"horizontal\",\n        \"modules\": [$dock_modules]\n    }'
content = re.sub(r'\"group/dock\":\s*\{[^}]*\}', new_group, content)

# Adiciona novos módulos custom antes do group/dock
new_modules = '''$custom_modules'''
content = re.sub(r'(\"group/dock\")', new_modules + r'\n    \1', content)

with open('$CONFIG', 'w') as f:
    f.write(content)
"
    # Reinicia waybar
    pkill waybar && waybar &

else
    # Abre o app
    $exec_cmd &
fi