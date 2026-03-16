#!/bin/bash

PINNED_FILE="$HOME/.config/waybar/pinned-apps.txt"
CONFIG="$HOME/.config/waybar/config.jsonc"
touch "$PINNED_FILE"

# Lista todos os apps
apps=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read f; do
    name=$(grep -m1 "^Name=" "$f" | cut -d= -f2)
    exec=$(grep -m1 "^Exec=" "$f" | cut -d= -f2 | sed 's/ %.//g')
    [ -n "$name" ] && [ -n "$exec" ] && echo "$name|$exec"
done | sort -u)

chosen=$(echo "$apps" | awk -F'|' '{print $1}' | rofi -dmenu -p "󰍉  Apps" -i -normalize-match \
    -hover-select -me-select-entry "" -me-accept-entry "MousePrimary" \
    -kb-custom-1 "Control+o" \
    -theme ~/.config/rofi/wifi-bluetooth.rasi)

ret=$?
[ -z "$chosen" ] && exit

exec_cmd=$(echo "$apps" | awk -F'|' -v name="$chosen" '$1==name {print $2; exit}')
safe_name=$(echo "$chosen" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

if [ $ret -eq 10 ]; then
    if grep -q "^$safe_name|" "$PINNED_FILE"; then
        notify-send "Dock" "󰗙 $chosen removido do dock"
        grep -v "^$safe_name|" "$PINNED_FILE" > /tmp/pinned-tmp && mv /tmp/pinned-tmp "$PINNED_FILE"
    else
        notify-send "Dock" "󰐕 $chosen fixado no dock"
        echo "$safe_name|$exec_cmd|$chosen" >> "$PINNED_FILE"
    fi

    python3 << 'PYEOF'
import json, re, os

pinned_file = os.path.expanduser("~/.config/waybar/pinned-apps.txt")
config_file = os.path.expanduser("~/.config/waybar/config.jsonc")

# Lê o config removendo comentários
with open(config_file, 'r') as f:
    content = f.read()

# Remove comentários // para poder parsear
clean = re.sub(r'//[^\n]*', '', content)

config = json.loads(clean)

# Lê apps fixados
pinned = []
with open(pinned_file, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split('|', 2)
        if len(parts) == 3:
            pinned.append({'name': parts[0], 'exec': parts[1], 'label': parts[2]})

# Remove módulos custom de dock antigos
keys_to_remove = [k for k in config if k.startswith('custom/dock-')]
for k in keys_to_remove:
    del config[k]

# Adiciona novos módulos
dock_modules = []
for app in pinned:
    key = f"custom/dock-{app['name']}"
    config[key] = {
        "format": app['label'],
        "on-click": app['exec'],
        "tooltip": False
    }
    dock_modules.append(key)

# Atualiza group/dock
config['group/dock'] = {
    "orientation": "horizontal",
    "modules": dock_modules
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=4)

print("Config atualizado!")
PYEOF

    pkill waybar && waybar &

else
    $exec_cmd &
fi