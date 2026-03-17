#!/bin/bash
options="󰹑  Tela Inteira\n󰩭  Área Selecionada\n  Janela Ativa"
chosen=$(echo -e "$options" | rofi -dmenu -p "󰹑  Print" -lines 3 -no-custom -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" -theme ~/.config/rofi/power-menu.rasi)
[ -z "$chosen" ] && exit
mkdir -p ~/Pictures/Screenshots
if [[ "$chosen" == *"Tela Inteira"* ]]; then
    FILE=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
    grim "$FILE"
    wl-copy < "$FILE"
    notify-send "Screenshot" "Tela inteira salva e copiada para a área de transferência!"
elif [[ "$chosen" == *"Área Selecionada"* ]]; then
    FILE=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
    grim -g "$(slurp)" "$FILE"
    wl-copy < "$FILE"
    notify-send "Screenshot" "Área salva e copiada para a área de transferência!"
elif [[ "$chosen" == *"Janela Ativa"* ]]; then
    FILE=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
    grim -g "$(hyprctl activewindow -j | python3 -c "import sys,json; d=json.load(sys.stdin); a=d['at']; s=d['size']; print(f'{a[0]},{a[1]} {s[0]}x{s[1]}')")" "$FILE"
    wl-copy < "$FILE"
    notify-send "Screenshot" "Janela salva e copiada para a área de transferência!"
fi