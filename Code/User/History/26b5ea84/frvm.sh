chosen=$(echo "$apps" | awk -F'|' '{print $1}' | rofi -dmenu -p " Fixar no Dock" -i -normalize-match \
    -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" \
    -kb-custom-1 "Control+MousePrimary" \
    -theme ~/.config/rofi/wifi-bluetooth.rasi)

ret=$?
[ -z "$chosen" ] && exit

exec_cmd=$(echo "$apps" | awk -F'|' -v name="$chosen" '$1==name {print $2; exit}')
safe_name=$(echo "$chosen" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

if [ $ret -eq 10 ]; then
    # Control+Enter = fixar no dock
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
    notify-send "Dock" "Cole o módulo em config.jsonc:$line"
    code --goto "$CONFIG:$line"
    code --goto "$style:$style_line"
else
    # Enter normal = abre o app
    $exec_cmd &
fi