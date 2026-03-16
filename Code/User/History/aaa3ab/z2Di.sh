#!/bin/bash

bt_status=$(bluetoothctl show | grep "Powered: yes")

toggle_option="\uf294  Ligar Bluetooth"
[ -n "$bt_status" ] && toggle_option="\uf294  Desligar Bluetooth"

scan_option="󰑐  Buscar Dispositivos"

if [ -n "$bt_status" ]; then
    devices=$(bluetoothctl devices | awk '{$1=$2=""; print $0}' | sed 's/^  //')
    options="$toggle_option\n$scan_option\n"
    while IFS= read -r device; do
        [ -z "$device" ] && continue
        options="$options\uf294  $device\n"
    done <<< "$devices"
else
    options="$toggle_option"
fi

chosen=$(echo -e "$options" | rofi -dmenu -p "\uf294  Bluetooth" -theme ~/.config/rofi/wifi-bluetooth.rasi)
[ -z "$chosen" ] && exit

if [[ "$chosen" == *"Desligar Bluetooth"* ]]; then
    bluetoothctl power off
elif [[ "$chosen" == *"Ligar Bluetooth"* ]]; then
    bluetoothctl power on
elif [[ "$chosen" == *"Buscar"* ]]; then
    bluetoothctl scan on &
    sleep 5
    bluetoothctl scan off
    bash ~/.config/waybar/scripts/bluetooth-menu.sh
else
    device_name=$(echo "$chosen" | sed 's/.*  //')
    device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')
    bluetoothctl connect "$device_mac"
fi