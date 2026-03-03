#!/bin/bash

# --- Color Definitions ---
BLUE='\033[0.34m'
GREEN='\033[0.32m'
RED='\033[0.31m'
YELLOW='\033[0.33m'
NC='\033[0m'

echo -e "${BLUE}Starting Minimal Hyprland Installation...${NC}"

# --- Check for AUR helper ---
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    echo -e "${YELLOW}AUR helper not found. Installing yay...${NC}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
fi

AUR_HELPER=$(command -v yay || command -v paru)

# --- Update System ---
echo -e "${GREEN}Updating system...${NC}"
sudo pacman -Syu --noconfirm

# --- Install Essential Packages ---
echo -e "${GREEN}Installing Core Components...${NC}"
sudo pacman -S --noconfirm \
    hyprland \
    waybar \
    kitty \
    rofi \
    thunar \
    mako \
    ttf-jetbrains-mono-nerd \
    polkit-gnome \
    xdg-desktop-portal-hyprland \
    qt5-wayland \
    qt6-wayland \
    brightnessctl \
    wl-clipboard

# --- Networking ---
echo -e "${GREEN}Configuring Networking...${NC}"
sudo pacman -S --noconfirm networkmanager network-manager-applet
sudo systemctl enable --now NetworkManager

# --- Audio (Pipewire) ---
echo -e "${GREEN}Configuring Audio...${NC}"
sudo pacman -S --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    wireplumber \
    pavucontrol \
    nm-connection-editor

# --- Bluetooth ---
echo -e "${GREEN}Configuring Bluetooth...${NC}"
sudo pacman -S --noconfirm bluez bluez-utils blueman
sudo systemctl enable --now bluetooth

# --- Display Drivers ---
echo -e "${GREEN}Installing Graphics Drivers...${NC}"
# Identify GPU
if lspci | grep -i nvidia &> /dev/null; then
    sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
elif lspci | grep -i intel &> /dev/null; then
    sudo pacman -S --noconfirm mesa vulkan-intel
elif lspci | grep -i amd &> /dev/null; then
    sudo pacman -S --noconfirm mesa xf86-video-amdgpu vulkan-radeon
fi

# --- Install swww from AUR ---
echo -e "${GREEN}Installing swww (Wallpaper Daemon)...${NC}"
$AUR_HELPER -S --noconfirm swww

# --- Setup Configs ---
echo -e "${GREEN}Deploying Configuration Files...${NC}"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR/hypr/scripts"
mkdir -p "$CONFIG_DIR/waybar"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/rofi"
mkdir -p "$HOME/dotfiles/wallpapers"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp -r "$SCRIPT_DIR/hypr/"* "$CONFIG_DIR/hypr/"
cp -r "$SCRIPT_DIR/waybar/"* "$CONFIG_DIR/waybar/"
cp -r "$SCRIPT_DIR/kitty/"* "$CONFIG_DIR/kitty/"
cp -r "$SCRIPT_DIR/rofi/"* "$CONFIG_DIR/rofi/"

chmod +x "$CONFIG_DIR/hypr/scripts/wallpaper_selector.sh"

echo -e "${BLUE}Installation Complete! Please reboot your system.${NC}"
