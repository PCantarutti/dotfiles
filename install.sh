#!/bin/bash
echo "🚀 Instalando dotfiles de Pedro Cantarutti..."
echo ""
# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
err()  { echo -e "${RED}✗ $1${NC}"; }
# Verifica se é Arch
if ! command -v pacman &>/dev/null; then
    err "Este script é para Arch Linux apenas!"
    exit 1
fi
# Instala yay se não tiver
if ! command -v yay &>/dev/null; then
    warn "Instalando yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
    cd ~
    ok "yay instalado"
fi
# Instala Hyprland primeiro
echo ""
echo "🪟 Instalando Hyprland..."
sudo pacman -S --needed hyprland && ok "Hyprland instalado"

# Pacotes pacman
echo ""
echo "📦 Instalando pacotes pacman..."
sudo pacman -S --needed \
    waybar kitty zsh rofi-wayland \
    swww nemo brightnessctl playerctl \
    bluez bluez-utils blueman \
    networkmanager network-manager-applet \
    pipewire wireplumber pamixer \
    grim slurp wl-clipboard \
    libnotify python-pywal \
    ttf-jetbrains-mono-nerd \
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    adw-gtk-theme \
    wireless_tools \
    gnome-software \
    gtk3 python-gobject \
    hyprlock swayidle \
    flatpak && ok "Pacotes pacman instalados"
# Pacotes AUR
echo ""
echo "📦 Instalando pacotes AUR..."
yay -S --needed \
    swayosd-git \
    swaync \
    waypaper && ok "Pacotes AUR instalados"
# Copia configs
echo ""
echo "📂 Copiando configurações..."
cp -r hypr ~/.config/ && ok "Hypr copiado"
cp -r waybar ~/.config/ && ok "Waybar copiado"
cp -r rofi ~/.config/ && ok "Rofi copiado"
cp -r swayosd ~/.config/ && ok "SwayOSD copiado"
cp -r swaync ~/.config/ && ok "SwayNC copiado"
cp -r kitty ~/.config/ && ok "Kitty copiado"
# Wallpapers
echo ""
echo "🖼️  Copiando wallpapers..."
mkdir -p ~/wallpapers
cp -r wallpapers/* ~/wallpapers/ && ok "Wallpapers copiados"
# Serviço swayidle
echo ""
echo "⚙️  Configurando swayidle..."
mkdir -p ~/.config/systemd/user/
cp systemd/user/swayidle.service ~/.config/systemd/user/
systemctl --user enable --now swayidle.service && ok "Swayidle habilitado"
# Habilita serviços
echo ""
echo "⚙️  Habilitando serviços..."
sudo systemctl enable --now bluetooth && ok "Bluetooth habilitado"
sudo systemctl enable --now NetworkManager && ok "NetworkManager habilitado"
sudo systemctl enable --now swayosd-libinput-backend.service && ok "SwayOSD habilitado"
sudo systemctl enable sddm && ok "SDDM habilitado"
# Flathub
echo ""
echo "📦 Configurando Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && ok "Flathub configurado"
# WiFi power saving
echo ""
echo "🌐 Desativando WiFi power saving..."
WIFI_INTERFACE=$(iwconfig 2>/dev/null | grep -o '^\w*' | grep -v lo | head -1)
if [ -n "$WIFI_INTERFACE" ]; then
    sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf > /dev/null << EOF
[connection]
wifi.powersave = 2
EOF
    ok "WiFi power saving desativado ($WIFI_INTERFACE)"
else
    warn "Interface WiFi não encontrada"
fi
# Torna scripts executáveis
echo ""
echo "🔧 Configurando scripts..."
chmod +x ~/.config/waybar/scripts/*.sh && ok "Scripts configurados"
# Shell ZSH
echo ""
if [ "$SHELL" != "/bin/zsh" ]; then
    warn "Mudando shell para ZSH..."
    chsh -s /bin/zsh && ok "Shell mudado para ZSH"
else
    ok "ZSH já é o shell padrão"
fi
echo ""
echo -e "${GREEN}✅ Instalação concluída!${NC}"
echo ""
echo "⚠️  Lembre-se de:"
echo "   1. Editar ~/.config/hypr/hyprland.conf e configurar o layout do teclado"
echo "   2. Adicionar um wallpaper em ~/wallpapers/"
echo "   3. Reiniciar o sistema"
echo ""
read -p "Deseja reiniciar agora? (s/n): " choice
[ "$choice" = "s" ] && reboot
