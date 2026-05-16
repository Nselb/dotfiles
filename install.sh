#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# ── Colores ───────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════╗${NC}"
echo -e "${BLUE}║      nselb dotfiles        ║${NC}"
echo -e "${BLUE}╚════════════════════════════╝${NC}"
echo ""

# ── Paquetes ──────────────────────────────────────────────
packages=(
  hyprland
  hyprpaper
  waybar
  dunst
  rofi-wayland
  kitty
  fish
  starship
  neovim
  pipewire
  pipewire-pulse
  wireplumber
  brightnessctl
  playerctl
  btop
  lazygit
  yazi
  glow
  ttf-jetbrains-mono-nerd
  noto-fonts-emoji
  git
  openssh
  sddm
)

aur_packages=(
  cider
)

echo -e "${BLUE}📦 Instalando paquetes...${NC}"
echo ""

# pacman
echo -e "${YELLOW}→ pacman${NC}"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm "${packages[@]}"

# yay
if ! command -v yay &>/dev/null; then
  echo -e "${YELLOW}Instalando yay...${NC}"
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

# AUR
echo -e "${YELLOW}→ AUR${NC}"
yay -S --needed --noconfirm "${aur_packages[@]}"

echo ""

# ── Symlinks ──────────────────────────────────────────────
configs=(
  "hypr"
  "waybar"
  "dunst"
  "kitty"
  "nvim"
  "fish"
  "rofi"
  "btop"
  "lazygit"
  "starship.toml"
)

echo -e "${BLUE}🔗 Creando symlinks...${NC}"
echo ""

mkdir -p "$CONFIG_DIR"

for config in "${configs[@]}"; do
  src="$DOTFILES_DIR/.config/$config"
  dst="$CONFIG_DIR/$config"

  if [ ! -e "$src" ]; then
    echo -e "${YELLOW}⚠️  No existe: $src, saltando...${NC}"
    continue
  fi

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo -e "${YELLOW}📦 Backup: $dst.bak${NC}"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  echo -e "${GREEN}✅ $config${NC}"
done

echo ""

# ── Fish plugins ──────────────────────────────────────────
echo -e "${BLUE}🐟 Instalando plugins de fish...${NC}"
echo ""

if ! fish -c "type -q fisher" &>/dev/null; then
  fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fi

if [ -f "$DOTFILES_DIR/.config/fish/fish_plugins" ]; then
  fish -c "fisher update"
  echo -e "${GREEN}✅ Plugins instalados${NC}"
fi

echo ""

# ── Git ───────────────────────────────────────────────────
echo -e "${BLUE}⚙️  Configurando git...${NC}"
echo ""

read -p "Nombre para git (ej: nselb): " git_name
read -p "Email para git: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global pull.rebase false

echo -e "${GREEN}✅ Git configurado${NC}"
echo ""

# ── Estructura de carpetas ────────────────────────────────
echo -e "${BLUE}📁 Creando estructura de carpetas...${NC}"
echo ""

mkdir -p ~/dev/personal
mkdir -p ~/dev/work
mkdir -p ~/Media/Music
mkdir -p ~/Media/Pictures
mkdir -p ~/Media/Wallpapers
mkdir -p ~/Documents

echo -e "${GREEN}✅ Carpetas creadas${NC}"
echo ""

# ── SSH Key ───────────────────────────────────────────────
echo -e "${BLUE}🔑 Generando SSH key...${NC}"
echo ""

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  echo -e "${YELLOW}⚠️  Ya existe una SSH key, saltando...${NC}"
else
  ssh-keygen -t ed25519 -C "$git_email" -f "$SSH_KEY" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
  echo -e "${GREEN}✅ SSH key generada${NC}"
fi

# ── Ocultar apps innecesarias ─────────────────────────────
echo -e "${BLUE}🧹 Ocultando apps innecesarias...${NC}"
echo ""

mkdir -p ~/.local/share/applications

for app in avahi-discover bssh bvnc qv4l2 qvidcap xgps xgpsspeed rofi-theme-selector; do
  printf "[Desktop Entry]\nType=Application\nName=%s\nNoDisplay=true\n" "$app" >~/.local/share/applications/$app.desktop
done

update-desktop-database ~/.local/share/applications
echo -e "${GREEN}✅ Apps ocultas${NC}"
echo ""

echo ""
echo -e "${YELLOW}📋 Agrega esta key a GitHub → Settings → SSH Keys:${NC}"
echo ""
cat "$SSH_KEY.pub"
echo ""
echo -e "${BLUE}→ https://github.com/settings/ssh/new${NC}"
echo ""

# ── Shell ─────────────────────────────────────────────────
if [ "$SHELL" != "$(which fish)" ]; then
  echo -e "${YELLOW}🐟 Cambiando shell a fish...${NC}"
  chsh -s "$(which fish)"
fi

# ── SDDM ─────────────────────────────────────────────────
echo -e "${BLUE}🎨 Configurando SDDM...${NC}"
echo ""

sudo systemctl enable sddm

# Tema catppuccin para SDDM
yay -S --needed --noconfirm sddm-catppuccin-frappe-git

sudo mkdir -p /etc/sddm.conf.d
cat <<'EOF' | sudo tee /etc/sddm.conf.d/theme.conf
[Theme]
Current=catppuccin-frappe
EOF

echo -e "${GREEN}✅ SDDM configurado${NC}"
echo ""

# ── GRUB ─────────────────────────────────────────────────
echo -e "${BLUE}🎨 Configurando GRUB...${NC}"
echo ""

yay -S --needed --noconfirm catppuccin-frappe-grub-theme-git

sudo mkdir -p /boot/grub/themes
sudo cp -r /usr/share/grub/themes/catppuccin-frappe /boot/grub/themes/

# Agrega el tema al grub
sudo sed -i 's|#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/catppuccin-frappe/theme.txt"|' /etc/default/grub
# Habilitar os-prober para detectar Windows
sudo pacman -S --needed --noconfirm os-prober
sudo sed -i 's|#GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|' /etc/default/grub
# Si no existe la línea, agregarla
grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub || echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub

sudo grub-mkconfig -o /boot/grub/grub.cfg

echo -e "${GREEN}✅ GRUB configurado${NC}"
echo ""

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🎉 Listo! Pasos finales:                  ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║  1. Agrega la SSH key a GitHub             ║${NC}"
echo -e "${GREEN}║  2. Cambia el remote a SSH:                ║${NC}"
echo -e "${GREEN}║     git remote set-url origin              ║${NC}"
echo -e "${GREEN}║     git@github.com:tuusuario/dotfiles.git  ║${NC}"
echo -e "${GREEN}║  3. Reinicia sesión                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
