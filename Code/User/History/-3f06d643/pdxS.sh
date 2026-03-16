#!/bin/bash

PINNED_FILE="$HOME/.config/waybar/pinned-apps.txt"
touch "$PINNED_FILE"

# Lista todos os apps instalados
apps=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read f; do
    name=$(grep -m1 "^Name=" "$f" | cut -d= -f2)
    exec=$(grep -m1 "^Exec=" "$f" | cut -d= -f2 | sed 's/ %.//g')
    icon=$(grep -m1 "^Icon=" "$f" | cut -d= -f2)
    [ -n "$name" ] && echo "$name|$exec|$icon"
done | sort -u)

# Mostra no rofi
chosen=$(echo "$apps" | awk -F'|' '{print $1}' | rofi -dmenu -p "󰍉  Apps" -i -normalize-match \
    -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" \
    -kb-custom-1 "Control+o" \
    -theme ~/.config/rofi/wifi-bluetooth.rasi)

ret=$?
[ -z "$chosen" ] && exit

# Pega o exec do app escolhido
exec_cmd=$(echo "$apps" | awk -F'|' -v name="$chosen" '$1==name {print $2; exit}')

if [ $ret -eq 10 ]; then
    # Ctrl+P = fixar no dock
    if grep -q "^$exec_cmd$" "$PINNED_FILE"; then
        notify-send "Dock" "󰗙 $chosen removido do dock"
        grep -v "^$exec_cmd$" "$PINNED_FILE" > /tmp/pinned-tmp && mv /tmp/pinned-tmp "$PINNED_FILE"
    else
        notify-send "Dock" "󰐕 $chosen fixado no dock"
        echo "$exec_cmd" >> "$PINNED_FILE"
    fi
    # Atualiza o dock
    pkill waybar && waybar &
else
    # Abre o app
    $exec_cmd &
fi