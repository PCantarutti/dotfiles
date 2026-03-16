#!/bin/bash
options="⏻  Desligar\n  Reiniciar\n  Suspender"

chosen=$(echo -e "$options" | rofi -dmenu -p "⏻  Power" -lines 3 -no-custom -theme ~/.config/rofi/power-menu.rasi)

if [[ "$chosen" == *"Desligar"* ]]; then
    systemctl poweroff
elif [[ "$chosen" == *"Reiniciar"* ]]; then
    systemctl reboot
elif [[ "$chosen" == *"Suspender"* ]]; then
    systemctl suspend
fi