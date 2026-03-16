#!/bin/bash

while true; do
    wifi_status=$(nmcli radio wifi)

    toggle_option="󰖩  Ligar WiFi"
    [ "$wifi_status" = "enabled" ] && toggle_option="󰖪  Desligar WiFi"

    options="$toggle_option\n󰑐  Atualizar Lista\n"

    if [ "$wifi_status" = "enabled" ]; then
        current=$(nmcli -t -f ACTIVE,SSID device wifi list --rescan no | grep "^yes" | awk -F: '{print $2}')
        wifi_list=$(nmcli -t -f SSID,SIGNAL device wifi list --rescan no 2>/dev/null | sort -t: -k2 -rn | awk -F: '!seen[$1]++ && $1!=""')
        while IFS=: read -r ssid signal; do
            [ -z "$ssid" ] && continue
            if [ "$ssid" = "$current" ]; then
                options="$options󰖩  $ssid (${signal}%) ✓\n"
            else
                options="$options󰖩  $ssid (${signal}%)\n"
            fi
        done <<< "$wifi_list"
    fi

    chosen=$(echo -e "$options" | rofi -dmenu -p "󰖩  WiFi" -i -normalize-match -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" -theme ~/.config/rofi/wifi-bluetooth.rasi)

    ret=$?
    [ $ret -ne 0 ] && exit
    [ -z "$chosen" ] && exit

    if [[ "$chosen" == *"Desligar WiFi"* ]]; then
        nmcli radio wifi off
    elif [[ "$chosen" == *"Ligar WiFi"* ]]; then
        nmcli radio wifi on
    elif [[ "$chosen" == *"Atualizar"* ]]; then
        nmcli device wifi rescan &
    else
        ssid=$(echo "$chosen" | grep -oP '(?<=󰖩  ).*(?= \()' | sed 's/ ✓//')
        password=$(rofi -dmenu -p "󰖩 Senha:" -password -i -normalize-match -theme ~/.config/rofi/wifi-bluetooth.rasi)
        [ -z "$password" ] && exit
        nmcli device wifi connect "$ssid" password "$password" && exit
    fi
done