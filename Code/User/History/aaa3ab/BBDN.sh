#!/bin/bash

while true; do
    bt_status=$(bluetoothctl show | grep "Powered: yes")

    if [ -n "$bt_status" ]; then
        bluetoothctl --timeout 3 scan on &
        sleep 3
    fi

    toggle_option="󰂯 Ligar Bluetooth"
    [ -n "$bt_status" ] && toggle_option="󰂯 Desligar Bluetooth"

    options="$toggle_option\n󰑐  Buscar Dispositivos\n"

    if [ -n "$bt_status" ]; then
        while IFS= read -r line; do
            mac=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | awk '{$1=$2=""; print $0}' | sed 's/^  //')
            [ -z "$name" ] && continue

            connected=$(bluetoothctl info "$mac" | grep "Connected: yes")
            if [ -n "$connected" ]; then
                options="$options󰂱 $name ✓\n"
            else
                options="$options󰂯 $name\n"
            fi
        done <<< "$(bluetoothctl devices)"
    fi

    chosen=$(echo -e "$options" | rofi -dmenu -p "󰂯 Bluetooth" -theme ~/.config/rofi/wifi-bluetooth.rasi)
    [ -z "$chosen" ] && exit

    if [[ "$chosen" == *"Desligar Bluetooth"* ]]; then
        bluetoothctl power off
    elif [[ "$chosen" == *"Ligar Bluetooth"* ]]; then
        bluetoothctl power on
    elif [[ "$chosen" == *"Buscar"* ]]; then
        bluetoothctl --timeout 5 scan on &
    else
        device_name=$(echo "$chosen" | sed 's/.*󰂯 //' | sed 's/.*󰂱 //' | sed 's/ ✓//')
        device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')
        bluetoothctl connect "$device_mac" && exit
    fi
done