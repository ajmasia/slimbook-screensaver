#!/bin/bash
# Screensaver launcher for GNOME/Debian - adapted from Omarchy

SCREENSAVER_DIR="$HOME/.local/share/slimbook-screensaver"
TTE_BIN="$HOME/.local/bin/tte"
STATE_FILE="$HOME/.local/state/slimbook-screensaver/screensaver-off"

# Exit if tte is not installed
if [[ ! -x "$TTE_BIN" ]]; then
    notify-send "Screensaver" "tte not found. Run install.sh first."
    exit 1
fi

# Exit if screensaver is already running
if pgrep -f "slimbook.screensaver" >/dev/null; then
    exit 0
fi

# Check if screensaver is disabled (unless forced)
if [[ -f "$STATE_FILE" ]] && [[ "$1" != "force" ]]; then
    exit 1
fi

# Get list of monitors from GNOME
monitors=$(gdbus call --session \
    --dest org.gnome.Mutter.DisplayConfig \
    --object-path /org/gnome/Mutter/DisplayConfig \
    --method org.gnome.Mutter.DisplayConfig.GetCurrentState 2>/dev/null | \
    grep -oP "'\K[^']+(?=')" | head -1 || echo "primary")

# Launch screensaver in kitty fullscreen
# Using kitty as it's available in Debian repos and supports --class
kitty \
    --class=slimbook.screensaver \
    --title="Slimbook Screensaver" \
    --override font_size=16 \
    --override window_padding_width=0 \
    --override hide_window_decorations=yes \
    --override background=#000000 \
    --start-as=fullscreen \
    -e "$SCREENSAVER_DIR/screensaver-cmd.sh" &

# Alternative: use gnome-terminal if kitty is not available
# gnome-terminal --full-screen --hide-menubar -- "$SCREENSAVER_DIR/screensaver-cmd.sh"
