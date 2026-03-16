#!/bin/bash

while true; do
    bt_status=$(bluetoothctl show | grep "Powered: yes")

    toggle_option="󰂯 Ligar Bluetooth"
    [ -n "$bt_status" ] && toggle_option="󰂯 Desligar Bluetooth"

    options="$toggle_option\n󰑐  Buscar Dispositivos\n"

    if [ -n "$bt_status" ]; then
        devices=$(bluetoothctl devices | awk '{$1=$2=""; print $0}' | sed 's/^  //')
        while IFS= read -r device; do
            [ -z "$device" ] && continue
            options="$options󰂯 $device\n"
        done <<< "$devices"
    fi

    chosen=$(echo -e "$options" | rofi -dmenu -p " 󰂯 Bluetooth" -theme ~/.config/rofi/wifi-bluetooth.rasi)
    [ -z "$chosen" ] && exit

    if [[ "$chosen" == *"Desligar Bluetooth"* ]]; then
        bluetoothctl power off
    elif [[ "$chosen" == *"Ligar Bluetooth"* ]]; then
        bluetoothctl power on
    elif [[ "$chosen" == *"Buscar"* ]]; then
        bluetoothctl --timeout 5 scan on

    else
        device_name=$(echo "$chosen" | sed 's/.*  //')
        device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')
        bluetoothctl connect "$device_mac" && exit
    fi
done