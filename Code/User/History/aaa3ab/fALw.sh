#!/bin/bash
devices=$(bluetoothctl devices | awk '{print $3}')
chosen=$(echo -e "$devices" | rofi -dmenu -p "Bluetooth")
[ -z "$chosen" ] && exit
bluetoothctl connect $(bluetoothctl devices | grep "$chosen" | awk '{print $2}')