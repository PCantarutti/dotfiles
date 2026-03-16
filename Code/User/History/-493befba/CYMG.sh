#!/bin/bash

while true; do
    wifi_status=$(nmcli radio wifi)

    toggle_option="󰖩  Ligar WiFi"
    [ "$wifi_status" = "enabled" ] && toggle_option="󰖪  Desligar WiFi"

    options="$toggle_option\n󰑐  Atualizar Lista\n"

    if [ "$wifi_status" = "enabled" ]; then
        wifi_list=$(nmcli -t -f SSID,SIGNAL device wifi list 2>/dev/null | sort -t: -k2 -rn | awk -F: '!seen[$1]++ && $1!=""')
        while IFS=: read -r ssid signal; do
            [ -z "$ssid" ] && continue
            options="$options󰖩  $ssid (${signal}%)\n"
        done <<< "$wifi_list"
    fi

    chosen=$(echo -e "$options" | rofi -dmenu -p "󰖩  WiFi" -theme ~/.config/rofi/wifi-bluetooth.rasi)
    [ -z "$chosen" ] && exit

    if [[ "$chosen" == *"Desligar WiFi"* ]]; then
        nmcli radio wifi off
    elif [[ "$chosen" == *"Ligar WiFi"* ]]; then
        nmcli radio wifi on
    elif [[ "$chosen" == *"Atualizar"* ]]; then
        nmcli device wifi rescan
    else
        ssid=$(echo "$chosen" | sed 's/.*  //' | sed 's/ (.*//')
        password=$(rofi -dmenu -p "🔑 Senha para $ssid" -password -theme ~/.config/rofi/wifi-bluetooth.rasi)
        [ -z "$password" ] && exit
        nmcli device wifi connect "$ssid" password "$password" && exit
    fi
done