#!/bin/bash
# Standalone test script - uses local project files with config system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TTE_BIN="$SCRIPT_DIR/.venv/bin/tte"

# Check if tte is available in project venv
if [[ ! -x "$TTE_BIN" ]]; then
    echo "tte not found. Run 'uv sync' first:"
    echo "  cd $SCRIPT_DIR && uv sync"
    exit 1
fi

# Setup temporary test environment
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Copy project files to test location
cp "$SCRIPT_DIR/screensaver.conf" "$TEST_DIR/"
cp "$SCRIPT_DIR/screensaver.txt" "$TEST_DIR/"

# Set defaults (can be overridden by environment variables)
SLIMBOOK_SCREENSAVER_TERMINAL="${SLIMBOOK_SCREENSAVER_TERMINAL:-alacritty}"
SLIMBOOK_SCREENSAVER_ASCII_FILE="${SLIMBOOK_SCREENSAVER_ASCII_FILE:-$SCRIPT_DIR/screensaver.txt}"
SLIMBOOK_SCREENSAVER_FRAME_RATE="${SLIMBOOK_SCREENSAVER_FRAME_RATE:-60}"
SLIMBOOK_SCREENSAVER_EXCLUDE_EFFECTS="${SLIMBOOK_SCREENSAVER_EXCLUDE_EFFECTS:-dev_worm}"
SLIMBOOK_SCREENSAVER_FONT_SIZE="${SLIMBOOK_SCREENSAVER_FONT_SIZE:-16}"

# Validate terminal choice and check availability
case "$SLIMBOOK_SCREENSAVER_TERMINAL" in
    alacritty|gnome-terminal|ptyxis)
        if ! command -v "$SLIMBOOK_SCREENSAVER_TERMINAL" &>/dev/null; then
            echo "Warning: Terminal '$SLIMBOOK_SCREENSAVER_TERMINAL' not found. Using gnome-terminal." >&2
            SLIMBOOK_SCREENSAVER_TERMINAL="gnome-terminal"
        fi
        ;;
    *)
        echo "Warning: Invalid terminal '$SLIMBOOK_SCREENSAVER_TERMINAL'. Using gnome-terminal." >&2
        SLIMBOOK_SCREENSAVER_TERMINAL="gnome-terminal"
        ;;
esac

# Create test config
mkdir -p "$TEST_DIR/config"
cat > "$TEST_DIR/config/config" << EOF
SLIMBOOK_SCREENSAVER_TERMINAL=$SLIMBOOK_SCREENSAVER_TERMINAL
SLIMBOOK_SCREENSAVER_ASCII_FILE=$SLIMBOOK_SCREENSAVER_ASCII_FILE
SLIMBOOK_SCREENSAVER_FRAME_RATE=$SLIMBOOK_SCREENSAVER_FRAME_RATE
SLIMBOOK_SCREENSAVER_EXCLUDE_EFFECTS=$SLIMBOOK_SCREENSAVER_EXCLUDE_EFFECTS
SLIMBOOK_SCREENSAVER_FONT_SIZE=$SLIMBOOK_SCREENSAVER_FONT_SIZE
EOF

# Create test screensaver-cmd that uses project tte
cat > "$TEST_DIR/screensaver-cmd.sh" << CMDEOF
#!/bin/bash
SCREENSAVER_DIR="$TEST_DIR"
TTE_BIN="$TTE_BIN"

# Load configuration (override config path for testing)
CONFIG_FILE="$TEST_DIR/config/config"
source "\$CONFIG_FILE"

exit_screensaver() {
    pkill -x tte 2>/dev/null
    exit 0
}

trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

printf '\033]11;rgb:00/00/00\007'
clear

while true; do
    "\$TTE_BIN" -i "\$SLIMBOOK_SCREENSAVER_ASCII_FILE" \\
        --frame-rate "\$SLIMBOOK_SCREENSAVER_FRAME_RATE" \\
        --canvas-width 0 \\
        --canvas-height 0 \\
        --reuse-canvas \\
        --anchor-canvas c \\
        --anchor-text c \\
        --random-effect \\
        --exclude-effects "\$SLIMBOOK_SCREENSAVER_EXCLUDE_EFFECTS" \\
        --no-eol \\
        --no-restore-cursor &

    TTE_PID=\$!

    while kill -0 \$TTE_PID 2>/dev/null; do
        if read -n 1 -t 1; then
            exit_screensaver
        fi
    done
done
CMDEOF
chmod +x "$TEST_DIR/screensaver-cmd.sh"

# Launch based on terminal
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
            -e "$TEST_DIR/screensaver-cmd.sh"
        ;;
    gnome-terminal)
        gnome-terminal \
            --class=slimbook.screensaver \
            --title="Slimbook Screensaver" \
            --full-screen \
            --hide-menubar \
            -- "$TEST_DIR/screensaver-cmd.sh"
        ;;
    ptyxis)
        ptyxis \
            --class=slimbook.screensaver \
            --title="Slimbook Screensaver" \
            -- "$TEST_DIR/screensaver-cmd.sh"
        ;;
esac
