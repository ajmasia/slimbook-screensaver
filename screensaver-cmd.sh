#!/bin/bash
# Main screensaver logic - adapted from Omarchy for GNOME/Debian

SCREENSAVER_DIR="$HOME/.local/share/slimbook-screensaver"
TTE_BIN="$HOME/.local/bin/tte"

# Load configuration
source "$SCREENSAVER_DIR/screensaver.conf"

screensaver_in_focus() {
    # Check if screensaver window is active in GNOME
    active_window=$(gdbus call --session \
        --dest org.gnome.Shell \
        --object-path /org/gnome/Shell \
        --method org.gnome.Shell.Eval \
        "global.display.focus_window ? global.display.focus_window.get_wm_class() : ''" 2>/dev/null | \
        grep -o 'slimbook.screensaver' || true)

    [[ -n "$active_window" ]]
}

exit_screensaver() {
    pkill -x tte 2>/dev/null
    pkill -f "slimbook.screensaver" 2>/dev/null
    exit 0
}

trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

# Set background to black
printf '\033]11;rgb:00/00/00\007'

while true; do
    "$TTE_BIN" -i "$SLIMBOOK_SCREENSAVER_ASCII_FILE" \
        --frame-rate "$SLIMBOOK_SCREENSAVER_FRAME_RATE" \
        --canvas-width 0 \
        --canvas-height 0 \
        --reuse-canvas \
        --anchor-canvas c \
        --anchor-text c \
        --random-effect \
        --exclude-effects "$SLIMBOOK_SCREENSAVER_EXCLUDE_EFFECTS" \
        --no-eol \
        --no-restore-cursor &

    TTE_PID=$!

    while kill -0 $TTE_PID 2>/dev/null; do
        # Exit on keypress or lost focus
        if read -n 1 -t 1; then
            exit_screensaver
        fi
    done
done
