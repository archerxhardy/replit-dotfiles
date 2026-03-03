#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/dotfiles/wallpapers"

# Check if swww is running, if not start it
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# List all images in the directory
# Find all jpg, jpeg, png files
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -exec basename {} \;)

if [ -z "$wallpapers" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    # Create the directory if it doesn't exist to be helpful
    mkdir -p "$WALLPAPER_DIR"
    exit 1
fi

# Show rofi menu
selected=$(echo "$wallpapers" | rofi -dmenu -i -p "󰸉  Wallpaper" -theme-str 'listview {lines: 6;}')

if [ -n "$selected" ]; then
    # Apply wallpaper with nice transition
    swww img "$WALLPAPER_DIR/$selected" \
        --transition-type wipe \
        --transition-angle 30 \
        --transition-step 90 \
        --transition-fps 60
    
    # Optional: You can add commands here to update themes based on the wallpaper
    # For example, using pywal or material-colors to generate a palette
fi
