#!/bin/bash
# ============================================================
# Dotfiles installer - Pedros Hyprland rice
# Arch Linux only (uses pacman + yay)
# ============================================================
set -e

# ---------- colors ----------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
err()  { echo -e "${RED}✗ $1${NC}"; }

# ---------- root check ----------
if [ "$EUID" -eq 0 ]; then
    err "Nao execute como root! Execute com sudo apenas quando pedido."
    exit 1
fi

# ---------- arch check ----------
if ! command -v pacman &>/dev/null; then
    err "Este script e para Arch Linux apenas!"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${GREEN}"
echo "  ██╗  ██╗██╗      ██╗ ██████╗  █████╗ ██╗"
echo "  ██║ ██╔╝██║      ██║██╔════╝ ██╔══██╗██║"
echo "  █████╔╝ ██║      ██║██║      ███████║██║"
echo "  ██╔═██╗ ██║      ██║██║      ██╔══██║██║"
echo "  ██║  ██╗███████╗██║╚██████╗ ██║  ██║███████╗"
echo "  ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝"
echo -e "${NC}"
echo "  Pedros Hyprland rice - Arch Linux"
echo "  Repositorio: https://github.com/PCantarutti/dotfiles"
echo ""

# ---------- yay ----------
if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    warn "AUR helper nao encontrado. Instalando yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    rm -rf /tmp/yay-build
    git clone https://aur.archlinux.org/yay.git /tmp/yay-build
    (cd /tmp/yay-build && makepkg -si --noconfirm)
    rm -rf /tmp/yay-build
    ok "yay instalado"
    AUR_HELPER="yay"
elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
    ok "yay ja esta instalado"
else
    AUR_HELPER="paru"
    ok "paru ja esta instalado"
fi

# ========== PACOTES ==========

# Pacotes pacman
echo ""
echo "  Instalando pacotes pacman..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    kitty \
    zsh \
    rofi-wayland \
    waybar \
    swww \
    nemo \
    brightnessctl \
    playerctl \
    bluez bluez-utils blueman \
    networkmanager network-manager-applet \
    pipewire wireplumber pamixer \
    grim slurp wl-clipboard \
    libnotify python-pywal \
    ttf-jetbrains-mono-nerd \
    xdg-desktop-portal-hyprland \
    adw-gtk-theme \
    gnome-software \
    gtk3 python-gobject \
    hyprlock \
    flatpak \
    python \
    gtkmm3 \
    gvfs \
    qt5ct qt6ct \
    wayland-idle-inhibitor \
    && ok "Pacotes pacman OK"

# Pacotes AUR
echo ""
echo "  Instalando pacotes AUR..."
$AUR_HELPER -S --needed --noconfirm \
    swayosd \
    swaync \
    waypaper \
    sddm-sugar-candy-git \
    && ok "Pacotes AUR OK"

# ========== COPIAR CONFIGS ==========
echo ""
echo "  Copiando configuracoes..."
cp -r "$SCRIPT_DIR/hypr"   ~/.config/
cp -r "$SCRIPT_DIR/waybar" ~/.config/
cp -r "$SCRIPT_DIR/rofi"   ~/.config/
cp -r "$SCRIPT_DIR/swayosd"~/.config/
cp -r "$SCRIPT_DIR/swaync" ~/.config/
cp -r "$SCRIPT_DIR/kitty"  ~/.config/
cp  "$SCRIPT_DIR/starship.toml" ~/.config/
# pavucontrol
[ -f "$SCRIPT_DIR/pavucontrol.ini" ] && cp "$SCRIPT_DIR/pavucontrol.ini" ~/.config/
# mimeapps
[ -f "$SCRIPT_DIR/mimeapps.list" ] && cp "$SCRIPT_DIR/mimeapps.list" ~/.config/
ok "configs copiadas"

# ========== SCRIPTS EXECUTAVEIS ==========
chmod +x ~/.config/waybar/scripts/*.sh 2>/dev/null
chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null
ok "scripts permissao OK"

# ========== SWAYIDLE SERVICE ==========
echo ""
echo "  Configurando swayidle..."
SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"
# Gera o arquivo com $HOME expandido (nao hardcoded)
cat > "$SYSTEMD_DIR/swayidle.service" << 'SVCEOF'
[Unit]
Description=Idle manager for Wayland
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/swayidle -w \
  timeout 300 '%E/config/hypr/scripts/lock.sh' \
  timeout 600 'hyprctl dispatch dpms off' \
  resume 'hyprctl dispatch dpms on' \
  before-sleep '%E/config/hypr/scripts/lock.sh'
Restart=on-failure

[Install]
WantedBy=graphical-session.target
SVCEOF
systemctl --user daemon-reload
systemctl --user enable swayidle.service
ok "swayidle.service configurado e habilitado"

# ========== WALLPAPERS ==========
echo ""
echo "  Configurando wallpapers..."
mkdir -p ~/wallpapers

# Copiar wallpapers do repo se existirem
if [ -d "$SCRIPT_DIR/wallpapers" ] && [ "$(ls "$SCRIPT_DIR/wallpapers/" 2>/dev/null)" ]; then
    cp "$SCRIPT_DIR/wallpapers/"* ~/wallpapers/
    ok "wallpapers copiados do repo"
fi

# Se nao tem nenhum wallpaper, gerar um padrao via Python + Pillow ou imagem minima
if [ -z "$(ls ~/wallpapers/ 2>/dev/null)" ]; then
    warn "Nenhum wallpaper encontrado em ~/wallpapers/"
    # Tenta gerar imagem solida com Python
    if python3 -c "from PIL import Image" &>/dev/null; then
        python3 -c "
from PIL import Image
img = Image.new('RGB', (1920, 1080), (32, 25, 30))
img.save('$HOME/wallpapers/default.png')
"
        ok "Wallpaper padrao gerado via Python"
    elif convert --help &>/dev/null; then
        convert -size 1920x1080 xc:rgb(32,25,30) ~/wallpapers/default.png
        ok "Wallpaper padrao gerado via ImageMagick"
    elif magick convert --help &>/dev/null; then
        magick convert -size 1920x1080 xc:rgb(32,25,30) ~/wallpapers/default.png
        ok "Wallpaper padrao gerado via ImageMagick v7"
    else
        warn "Instale python-pillow ou imagemagick para gerar um wallpaper padrao"
        warn "Ou copie manualmente um wallpaper para ~/wallpapers/"
    fi
fi

# Atualizar configs com wallpaper atual
FIRST_WALLPAPER=$(ls ~/wallpapers/ 2>/dev/null | head -1)
if [ -n "$FIRST_WALLPAPER" ]; then
    WALLPAPER_PATH="$HOME/wallpapers/$FIRST_WALLPAPER"

    # hyprpaper.conf
    cat > ~/.config/hypr/hyprpaper.conf << WPEOF
preload = $WALLPAPER_PATH
wallpaper = ,$WALLPAPER_PATH
WPEOF

    # hyprlock.conf - atualizar background path
    if [ -f ~/.config/hypr/hyprlock.conf ]; then
        sed -i "s|path = .*|path = $WALLPAPER_PATH|g" ~/.config/hypr/hyprlock.conf
    fi

    # waypaper config.ini - atualizar wallpaper
    if [ -f ~/.config/waypaper/config.ini ]; then
        sed -i "s|wallpaper = .*|wallpaper = $WALLPAPER_PATH|g" ~/.config/waypaper/config.ini
        sed -i "s|folder = .*|folder = ~/wallpapers|g" ~/.config/waypaper/config.ini
    fi

    ok "Wallpaper configurado: $FIRST_WALLPAPER"
else
    # Usar cor solida - remover refs a arquivos
    cat > ~/.config/hypr/hyprpaper.conf << 'WPEOF'
# Adicione sua imagem em ~/wallpapers/ e rode hyprpaper reload
WPEOF
    warn "Sem wallpaper, configure manualmente em"
    warn "  ~/.config/hypr/hyprpaper.conf"
    warn "  ~/.config/hypr/hyprlock.conf"
fi

# ========== SDDM ==========
echo ""
echo "  Configurando SDDM..."
sudo pacman -S --needed --noconfirm sddm

SUGAR_DIR="/usr/share/sddm/themes/sugar-candy"
if [ -d "$SUGAR_DIR" ]; then
    sudo mkdir -p "$SUGAR_DIR/Backgrounds/"

    # theme.conf padrao
    if [ -f "$SCRIPT_DIR/sddm/theme.conf" ]; then
        sudo cp "$SCRIPT_DIR/sddm/theme.conf" "$SUGAR_DIR/theme.conf"
    else
        sudo tee "$SUGAR_DIR/theme.conf" > /dev/null << 'SDDEOF'
[General]

Background=Backgrounds/default.png
BackgroundMode=fill

ScreenWidth=1920
ScreenHeight=1080

Font=JetBrains Mono
FontSize=12
DDelay=150

AccentColor=#4a9ef5
TextColor=#ffffff

Blur=true
BlurRadius=10

LoginBackground=true
FormPosition=center
LoginBoxWidth=400
SDDEOF
    fi

    SDDM_WALLPAPER=$(ls ~/wallpapers/ 2>/dev/null | head -1)
    if [ -n "$SDDM_WALLPAPER" ]; then
        sudo cp "$HOME/wallpapers/$SDDM_WALLPAPER" "$SUGAR_DIR/Backgrounds/default.png"
        ok "Wallpaper SDDM configurado"
    fi

    # sddm.conf
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/sddm.conf > /dev/null << 'SDDMEOF'
[Theme]
Current=sugar-candy

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell
SDDMEOF
    ok "SDDM configurado"
else
    warn "Tema sugar-candy nao encontrado, verifique se instalou corretamente"
fi

# ========== HABILITAR SERVICOS ==========
echo ""
echo "  Habilitando servicos..."
sudo systemctl enable --now bluetooth      2>/dev/null && ok "Bluetooth"      || warn "Bluetooth (pode nao estar disponivel)"
sudo systemctl enable --now NetworkManager  2>/dev/null && ok "NetworkManager" || warn "NetworkManager (pode nao estar disponivel)"
sudo systemctl enable --now pipewire        2>/dev/null || true
sudo systemctl enable --now pipewire-pulse  2>/dev/null || true
sudo systemctl --user enable swayosd-server.service 2>/dev/null || true
sudo systemctl enable sddm                  2>/dev/null && ok "SDDM"          || warn "SDDM (pode nao estar disponivel)"

# ========== FLATHUB ==========
echo ""
echo "  Configurando Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null && ok "Flathub OK"

# ========== WIFI POWER SAVE ==========
if command -v iwconfig &>/dev/null; then
    WIFI_IFACE=$(iwconfig 2>/dev/null | grep -oP '^[a-zA-Z0-9]+(?=\s)' | grep -vE '^lo|^$' | head -1)
    if [ -n "$WIFI_IFACE" ]; then
        sudo mkdir -p /etc/NetworkManager/conf.d
        sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf > /dev/null << EOF
[connection]
wifi.powersave = 2
EOF
        ok "WiFi power saving desativado"
    fi
fi

# ========== TECLADO ==========
echo ""
echo "  Configurando layout do teclado..."
KB_LAYOUT=$(localectl status 2>/dev/null | grep "X11 Layout" | awk '{print $3}')
KB_VARIANT=$(localectl status 2>/dev/null | grep "X11 Variant" | awk '{print $3}')
[ -z "$KB_LAYOUT" ] && KB_LAYOUT="br"
[ -z "$KB_VARIANT" ] && KB_VARIANT="abnt2"

if [ -f ~/.config/hypr/hyprland.conf ]; then
    sed -i "s/kb_layout = .*/kb_layout = $KB_LAYOUT/g" ~/.config/hypr/hyprland.conf
    sed -i "s/kb_variant = .*/kb_variant = $KB_VARIANT/g" ~/.config/hypr/hyprland.conf
    ok "Layout teclado: $KB_LAYOUT / $KB_VARIANT"
fi

# Remover configuracao de monitor hardcoded e de device hardcoded
# O Hyprland detecta monitores automaticamente. O usuario pode ajustar depois
# em ~/.config/hypr/hyprland.conf no bloco "monitor=..." ou via
# Hyprland monitor rules (wlr-randr, etc).
if [ -f ~/.config/hypr/hyprland.conf ]; then
    # Remover linhas de monitor= hardcoded e device{} com nome fixo
    # mas manter o comentario e a secao
    sed -i '/^monitor=.*HDMI\|^monitor=.*eDP\|^monitor=.*DP-\|^monitor=.*HDMI-A/d' ~/.config/hypr/hyprland.conf
    # Remover bloco device com nome hardcoded
    sed -i '/^device {/,/^}/d' ~/.config/hypr/hyprland.conf
    # Remover wlr-randr exec-once
    sed -i '/exec-once.*wlr-randr/d' ~/.config/hypr/hyprland.conf 2>/dev/null || true
    ok "Configuracao de monitores generica (auto-detect)"
fi

# ========== ZSH ==========
echo ""
if [ "$SHELL" != "/bin/zsh" ]; then
    warn "Mudando shell para ZSH..."
    chsh -s /bin/zsh && ok "Shell mudado para ZSH"
else
    ok "ZSH ja e o shell padrao"
fi

# ========== DONE ==========
echo ""
echo -e "${GREEN}================================================"
echo "  Instalacao concluida!"
echo "================================================${NC}"
echo ""
echo "  Para iniciar o rice execute:"
echo "    Hyprland"
echo "  ou reinicie o sistema."
echo ""
echo "  Se precisar ajustar algo:"
echo "    Layout teclado: ~/.config/hypr/hyprland.conf (bloco input)"
echo "    Monitores:      ~/.config/hypr/hyprland.conf (monitor=...)"
echo "    Wallpaper:      coloque imagens em ~/wallpapers/"
echo ""
read -p "Deseja reiniciar agora? (s/N): " choice
if [[ "$choice" =~ ^[sSyY]$ ]]; then
    systemctl reboot
fi
