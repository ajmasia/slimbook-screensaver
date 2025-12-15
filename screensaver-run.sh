#!/bin/bash
# Core screensaver loop - runs inside alacritty

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TTE_BIN="$SCRIPT_DIR/.venv/bin/tte"

exit_screensaver() {
    pkill -x tte 2>/dev/null
    exit 0
}

trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

# Set terminal background to black
printf '\033]11;rgb:00/00/00\007'
clear

while true; do
    "$TTE_BIN" -i "$SCRIPT_DIR/screensaver.txt" \
        --frame-rate 60 \
        --canvas-width 0 \
        --canvas-height 0 \
        --reuse-canvas \
        --anchor-canvas c \
        --anchor-text c \
        --random-effect \
        --exclude-effects dev_worm \
        --no-eol \
        --no-restore-cursor &

    TTE_PID=$!

    while kill -0 $TTE_PID 2>/dev/null; do
        if read -n 1 -t 1; then
            exit_screensaver
        fi
    done
done
