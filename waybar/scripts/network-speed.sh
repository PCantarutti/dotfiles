#!/usr/bin/env bash
# network-speed.sh — retorna velocidade com largura fixa
# Salva leitura anterior no cache para calcular delta

CACHE="/tmp/waybar-net-cache-$(id -u)"

# Interface com link ativo (exclui lo e interfaces sem carrier)
IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '$2 != "lo" && /state UP/{print $2; exit}')

if [ -z "$IFACE" ] || [ ! -f "/sys/class/net/$IFACE/statistics/rx_bytes" ]; then
    echo ' 󰖪 '
    exit 0
fi

RX_FILE="/sys/class/net/$IFACE/statistics/rx_bytes"
NOW=$(cat "$RX_FILE" 2>/dev/null)
[ -z "$NOW" ] && { echo ' 󰖪 '; exit 0; }

# Lê leitura anterior
PREV_BYTES=""
PREV_TIME=""
[ -f "$CACHE" ] && IFS=' ' read -r PREV_BYTES PREV_TIME < "$CACHE"

# Salva leitura atual
echo "$NOW $(date +%s)" > "$CACHE"

# Sem dado anterior
if [ -z "$PREV_BYTES" ]; then
    echo ' 󰁅 --M/s '
    exit 0
fi

ELAPSED=$(( $(date +%s) - PREV_TIME ))
[ "$ELAPSED" -le 0 ] && ELAPSED=1

DIFF=$(( NOW - PREV_BYTES ))
[ "$DIFF" -le 0 ] && { printf ' 󰁅 0K/s \n'; exit 0; }

BPS=$(( DIFF / ELAPSED ))

if [ "$BPS" -ge 1048576 ]; then
    M=$(( BPS / 1048576 ))
    FRAC=$(( (BPS % 1048576) * 10 / 1048576 ))
    if [ "$M" -ge 100 ]; then
        printf ' 󰁅%d.%dM/s \n' "$M" "$FRAC"
    elif [ "$M" -ge 10 ]; then
        printf ' 󰁅 %d.%dM/s\n' "$M" "$FRAC"
    else
        printf ' 󰁅 %d.%dM/s \n' "$M" "$FRAC"
    fi
else
    K=$(( BPS / 1024 ))
    if [ "$K" -ge 1000 ]; then
        printf ' 󰁅 %dK/s \n' "$K"
    elif [ "$K" -ge 100 ]; then
        printf ' 󰁅 %dK/s \n' "$K"
    elif [ "$K" -ge 10 ]; then
        printf ' 󰁅  %dK/s \n' "$K"
    else
        printf ' 󰁅  %dK/s  \n' "$K"
    fi
fi
