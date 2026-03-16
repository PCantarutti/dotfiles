# #!/bin/bash

while true; do
    bt_status=$(bluetoothctl show | grep "Powered: yes")

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

    chosen=$(echo -e "$options" | rofi -dmenu -p "󰂯 Bluetooth" -i -normalize-match -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" -theme ~/.config/rofi/wifi-bluetooth.rasi)

    ret=$?
    [ $ret -ne 0 ] && exit
    [ -z "$chosen" ] && exit

    if [[ "$chosen" == *"Desligar Bluetooth"* ]]; then
        bluetoothctl power off
    elif [[ "$chosen" == *"Ligar Bluetooth"* ]]; then
        bluetoothctl power on
    elif [[ "$chosen" == *"Buscar"* ]]; then
        bluetoothctl --timeout 5 scan on &
        SCAN_PID=$!
        options="󰑐  Buscando dispositivos...\n"
        echo -e "$options" | rofi -dmenu -p "󰂯 Bluetooth" -lines 1 -no-custom -theme ~/.config/rofi/wifi-bluetooth.rasi &
        ROFI_PID=$!
        wait $SCAN_PID
        kill $ROFI_PID 2>/dev/null
    else
        device_name=$(echo "$chosen" | sed 's/.*󰂯 //' | sed 's/.*󰂱 //' | sed 's/ ✓//')
        device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')
        bluetoothctl connect "$device_mac" && exit
    fi
done