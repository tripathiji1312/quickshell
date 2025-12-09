#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up QuickShell Configuration...${NC}"

# 1. Install Dependencies (Arch Linux)
if command -v pacman &> /dev/null; then
    echo -e "${BLUE}📦 Detected Arch Linux. Checking dependencies...${NC}"
    
    # Core packages
    PACKAGES=(
        "qt6-base"
        "qt6-declarative"
        "qt6-svg"
        "qt6-wayland"
        "python-pywal"
        "pipewire"
        "wireplumber"
        "networkmanager"
        "bluez"
        "bluez-utils"
        "upower"
        "power-profiles-daemon"
        "grim"
        "slurp"
        "brightnessctl"
        "pamixer" 
        "playerctl"
        "ttf-font-awesome"
        "ttf-jetbrains-mono-nerd"
    )

    # Helper to check and install
    TO_INSTALL=()
    for pkg in "${PACKAGES[@]}"; do
        if ! pacman -Qi $pkg &> /dev/null; then
            TO_INSTALL+=("$pkg")
        fi
    done

    if [ ${#TO_INSTALL[@]} -gt 0 ]; then
        echo -e "${BLUE}Installing missing packages: ${TO_INSTALL[*]}${NC}"
        if sudo pacman -S --noconfirm "${TO_INSTALL[@]}"; then
             echo -e "${GREEN}✓ Dependencies installed.${NC}"
        else
             echo -e "${RED}✗ Failed to install some dependencies.${NC}"
        fi
    else
        echo -e "${GREEN}✓ Core dependencies already installed.${NC}"
    fi

    # Check for QuickShell
    if ! command -v quickshell &> /dev/null; then
        echo -e "${BLUE}⚠️ QuickShell not found. Please install 'quickshell' (v0.2+) from AUR.${NC}"
        echo "Example: yay -S quickshell"
    else
        echo -e "${GREEN}✓ QuickShell found.${NC}"
    fi

else
    echo -e "${BLUE}⚠️ Not on Arch Linux? Please install dependencies manually (see README.md).${NC}"
fi

# 2. Setup Pywal
if command -v wal &> /dev/null; then
    echo -e "${BLUE}🎨 Checking Pywal colors...${NC}"
    # Check if a wallpaper is already set, otherwise ask or skip
    if [ -f "$HOME/.cache/wal/colors.json" ]; then
         echo -e "${GREEN}✓ Pywal colors already exist.${NC}"
    else
         echo -e "${BLUE}ℹ️ Please run 'wal -i /path/to/image' to generate colors.${NC}"
    fi
else
    echo -e "${RED}✗ 'wal' command not found. Install python-pywal.${NC}"
fi

# 3. Hyprland Config Check
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
LAYER_CONF="$HOME/.config/quickshell/hyprland-layer-config.conf"

if [ -f "$HYPR_CONF" ]; then
    if grep -q "hyprland-layer-config.conf" "$HYPR_CONF"; then
        echo -e "${GREEN}✓ Hyprland config already includes layer rules.${NC}"
    else
        echo -e "${BLUE}🔧 Adding layer rules to Hyprland config...${NC}"
        # Backup first
        cp "$HYPR_CONF" "${HYPR_CONF}.bak"
        echo "" >> "$HYPR_CONF"
        echo "# QuickShell Layer Rules" >> "$HYPR_CONF"
        echo "source = $LAYER_CONF" >> "$HYPR_CONF"
        echo -e "${GREEN}✓ Added source to $HYPR_CONF${NC}"
    fi
else
    echo -e "${BLUE}ℹ️ Hyprland config not found at $HYPR_CONF. Skipping integration.${NC}"
fi

# 4. Make scripts executable
chmod +x reload-quickshell.sh

echo -e "${GREEN}✅ Setup complete! Run ./reload-quickshell.sh to start.${NC}"
