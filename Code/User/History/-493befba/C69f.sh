#!/bin/bash
wifi_list=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | sort -t: -k2 -rn)

options=""
while IFS=: read -r ssid signal security; do
    [ -z "$ssid" ] && continue
    options="$options$ssid (${signal}% $security)\n"
done <<< "$wifi_list"

chosen=$(echo -e "$options" | rofi -dmenu -p "WiFi" -i)
[ -z "$chosen" ] && exit

ssid=$(echo "$chosen" | sed 's/ (.*//')
password=$(rofi -dmenu -p "Senha para $ssid" -password)
nmcli device wifi connect "$ssid" password "$password"