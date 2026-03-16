#!/bin/bash

options="⏻  Desligar\n  Reiniciar\n  Suspender\n  Cancelar"

chosen=$(echo -e "$options" | rofi -dmenu -p "⏻  Power" -i -theme ~/.config/rofi/wifi-bluetooth.rasi)
[ -z "$chosen" ] && exit

if [[ "$chosen" == *"Desligar"* ]]; then
    systemctl poweroff
elif [[ "$chosen" == *"Reiniciar"* ]]; then
    systemctl reboot
elif [[ "$chosen" == *"Suspender"* ]]; then
    systemctl suspend
fi