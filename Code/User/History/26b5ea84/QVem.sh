#!/bin/bash

CONFIG="$HOME/.config/waybar/config.jsonc"

# Lista todos os apps
apps=$(find /usr/share/applications ~/.local/share/applications /var/lib/flatpak/exports/share/applications ~/.local/share/flatpak/exports/share/applications -name "*.desktop" 2>/dev/null | while read f; do
    hidden=$(grep -m1 "^NoDisplay=" "$f" | cut -d= -f2)
    [ "$hidden" = "true" ] && continue

    name=$(grep -m1 "^Name=" "$f" | cut -d= -f2)
    raw_exec=$(grep -m1 "^Exec=" "$f" | cut -d= -f2)

    if echo "$raw_exec" | grep -q "flatpak run"; then
        appid=$(echo "$raw_exec" | grep -oP '[\w]+\.[\w]+\.[\w]+')
        exec_path="/usr/bin/flatpak run $appid"
    else
        exec_path=$(echo "$raw_exec" | sed 's/ %.*//g' | sed 's/ $//g')
    fi

    [ -n "$name" ] && [ -n "$exec_path" ] && echo "$name|$exec_path"
done | sort -u)

chosen=$(echo "$apps" | awk -F'|' '{print $1}' | rofi -dmenu -p " Apps" -i -normalize-match \
    -hover-select \
    -me-select-entry "" \
    -me-accept-entry "MousePrimary" \
    -kb-custom-1 "Control+o" \
    -theme ~/.config/rofi/wifi-bluetooth.rasi)

ret=$?
[ -z "$chosen" ] && exit

exec_cmd=$(echo "$apps" | awk -F'|' -v name="$chosen" '$1==name {print $2; exit}')
safe_name=$(echo "$chosen" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

if [ $ret -eq 10 ]; then
    module="    \"custom/$safe_name\": {
        \"format\": \"$chosen\",
        \"on-click\": \"$exec_cmd\",
        \"tooltip-format\": \"$chosen\",
        \"tooltip\": true
    },"

    echo "$module" | wl-copy

    line=$(grep -n '"modules"' "$CONFIG" | tail -1 | cut -d: -f1)
    style="$HOME/.config/waybar/style.css"
    style_line=$(grep -n "custom-add-dock" "$style" | tail -1 | cut -d: -f1)

    notify-send "Dock" "Módulo copiado! Cole em config.jsonc linha $line"
    code --goto "$style:$style_line"
    code --goto "$CONFIG:$line"
else
    desktop=$(find /usr/share/applications ~/.local/share/applications /var/lib/flatpak/exports/share/applications ~/.local/share/flatpak/exports/share/applications -name "*.desktop" 2>/dev/null | xargs grep -l "^Name=$chosen" 2>/dev/null | head -1)
    if [ -n "$desktop" ]; then
        gtk-launch "$(basename "$desktop" .desktop)" &
    else
        $exec_cmd &
    fi
fi