# Dotfiles - Pedro Cantarutti

## 📸 Preview
<!-- Adicione um screenshot aqui depois -->
![Preview1](preview/Preview1.png) ![Preview2](preview/Preview2.png) ![Preview3](preview/Preview3.png)

## 🖥️ Setup
- **OS:** Arch Linux
- **WM:** Hyprland
- **Bar:** Waybar
- **Terminal:** Kitty
- **Shell:** ZSH
- **Launcher:** Rofi
- **Notifications:** SwayNC
- **OSD:** SwayOSD
- **Wallpaper:** Waypaper + SWWW
- **File Manager:** Nemo

## 📦 Dependências

### Pacman
```bash
sudo pacman -S hyprland waybar kitty zsh rofi-wayland \
               swww nemo brightnessctl playerctl \
               bluez bluez-utils blueman \
               networkmanager network-manager-applet \
               pipewire wireplumber pamixer \
               grim slurp wl-clipboard \
               libnotify python-pywal \
               ttf-jetbrains-mono-nerd \
               xdg-desktop-portal-hyprland
```

### AUR (yay)
```bash
yay -S swayosd-git swaync waypaper
```

## ⚙️ Após instalar

### Habilite os serviços:
```bash
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now swayosd-libinput-backend.service
sudo systemctl enable sddm
```

### Configure o layout do teclado:
Edite `~/.config/hypr/hyprland.conf` e mude o bloco `input` para o layout do seu teclado.

## ⌨️ Atalhos principais

| Atalho | Ação |
|---|---|
| Super + T | Terminal (Kitty) |
| Super + B | Browser (Firefox) |
| Super + E | Gerenciador de arquivos (Nemo) |
| Super + L | Launcher (Wofi) |
| Super + V | Editor de código (VSCode) |
| Super + W | Wallpaper (Waypaper) |
| Super + P | Screenshot |
| Super + C | Fechar janela |
| Super + F | Floating |
| Super + S | Workspace especial (scratchpad) |
| Super + Shift + S | Mover para scratchpad |
| Super + R | Pseudotile |
| Super + J | Toggle split |
| Super + Escape | Sair do Hyprland |
| Super + ← → ↑ ↓ | Mover foco |
| Super + 1-9 | Trocar workspace |
| Super + Shift + 1-9 | Mover janela para workspace |
| Super + Scroll | Trocar workspace |
| Super + LMB | Mover janela |
| Super + RMB | Redimensionar janela |
| Super + Shift + LMB | Redimensionar janela |
| Print | Menu de screenshot |
| Teclas Fn | Volume e brilho |

## 📁 Estrutura
```
~/.config/
├── hypr/
│   └── hyprland.conf
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── scripts/
│       ├── wifi-menu.sh
│       ├── bluetooth-menu.sh
│       ├── power-menu.sh
│       ├── screenshot.sh
│       ├── media-info.sh
│       └── add-to-dock.sh
├── rofi/
│   ├── wifi-bluetooth.rasi
│   └── power-menu.rasi
├── swayosd/
│   └── style.css
├── swaync/
│   ├── config.json
│   └── style.css
└── kitty/
    └── kitty.conf
```