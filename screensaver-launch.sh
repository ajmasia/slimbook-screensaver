#!/bin/bash
# Screensaver launcher for GNOME/Debian - adapted from Omarchy

SCREENSAVER_DIR="$HOME/.local/share/slimbook-screensaver"
TTE_BIN="$HOME/.local/bin/tte"
STATE_FILE="$HOME/.local/state/slimbook-screensaver/screensaver-off"

# Load configuration
source "$SCREENSAVER_DIR/screensaver.conf"

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

# Launch screensaver based on configured terminal
case "$SLIMBOOK_SCREENSAVER_TERMINAL" in
    alacritty)
        alacritty \
            --class slimbook.screensaver \
            --title "Slimbook Screensaver" \
            -o "font.size=$SLIMBOOK_SCREENSAVER_FONT_SIZE" \
            -o "window.padding.x=0" \
            -o "window.padding.y=0" \
            -o 'window.decorations="None"' \
            -o 'colors.primary.background="#000000"' \
            -o 'window.startup_mode="Fullscreen"' \
            -e "$SCREENSAVER_DIR/screensaver-cmd.sh" &
        ;;
    gnome-terminal)
        gnome-terminal \
            --class=slimbook.screensaver \
            --title="Slimbook Screensaver" \
            --full-screen \
            --hide-menubar \
            -- "$SCREENSAVER_DIR/screensaver-cmd.sh" &
        ;;
    ptyxis)
        ptyxis \
            --class=slimbook.screensaver \
            --title="Slimbook Screensaver" \
            -- "$SCREENSAVER_DIR/screensaver-cmd.sh" &
        ;;
esac
