#!/bin/bash
# Standalone test script - launches in alacritty fullscreen

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TTE_BIN="$SCRIPT_DIR/.venv/bin/tte"

# Check if tte is available in project venv
if [[ ! -x "$TTE_BIN" ]]; then
    echo "tte not found. Run 'uv sync' first:"
    echo "  cd $SCRIPT_DIR && uv sync"
    exit 1
fi

# Check if alacritty is available
if ! command -v alacritty &>/dev/null; then
    echo "alacritty not found. Install it with:"
    echo "  sudo apt install alacritty"
    exit 1
fi

# Create temporary alacritty config for fullscreen without decorations
ALACRITTY_CONFIG=$(mktemp)
cat > "$ALACRITTY_CONFIG" << 'EOF'
[window]
startup_mode = "Fullscreen"
decorations = "None"
padding = { x = 0, y = 0 }

[colors.primary]
background = "#000000"

[font]
size = 16
EOF

# Launch alacritty fullscreen with screensaver
alacritty \
    --class=slimbook.screensaver \
    --title="Slimbook Screensaver" \
    --config-file="$ALACRITTY_CONFIG" \
    -e "$SCRIPT_DIR/screensaver-run.sh"

rm -f "$ALACRITTY_CONFIG"
