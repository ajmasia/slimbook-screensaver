#!/bin/bash
# Slimbook EVO screensaver uninstaller
set -e

INSTALL_DIR="$HOME/.local/share/slimbook-screensaver"
CONFIG_DIR="$HOME/.config/slimbook-screensaver"
STATE_DIR="$HOME/.local/state/slimbook-screensaver"

show_help() {
    echo "Slimbook EVO Screensaver Uninstaller"
    echo ""
    echo "Usage: slimbook-screensaver-uninstall [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -a, --all      Remove everything including config and logs"
    echo ""
    echo "Without options, config is preserved for reinstallation."
}

REMOVE_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--all)
            REMOVE_ALL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

echo "=== Uninstalling Slimbook EVO Screensaver ==="

# Stop idle monitor if running
echo "[1/5] Stopping running processes..."
pkill -f "idle-monitor.sh" 2>/dev/null || true
pkill -f "slimbook.screensaver" 2>/dev/null || true

# Remove autostart
echo "[2/5] Removing autostart entry..."
rm -f ~/.config/autostart/slimbook-screensaver-monitor.desktop

# Remove symlinks
echo "[3/5] Removing symlinks..."
rm -f ~/.local/bin/slimbook-screensaver
rm -f ~/.local/bin/slimbook-screensaver-toggle
rm -f ~/.local/bin/slimbook-screensaver-uninstall
rm -f ~/.local/bin/tte

# Remove application files
echo "[4/5] Removing application files..."
rm -rf "$INSTALL_DIR"

# Remove config and state if requested
echo "[5/5] Cleaning up..."
if [[ "$REMOVE_ALL" == "true" ]]; then
    rm -rf "$CONFIG_DIR"
    rm -rf "$STATE_DIR"
    echo "  Removed config and logs"
else
    echo "  Config preserved at: $CONFIG_DIR"
    echo "  Logs preserved at: $STATE_DIR"
fi

echo ""
echo "=== Uninstallation complete ==="

if [[ "$REMOVE_ALL" != "true" ]]; then
    echo ""
    echo "To remove config and logs too, run:"
    echo "  rm -rf $CONFIG_DIR $STATE_DIR"
fi

echo ""
echo "System packages (python3, jq, curl, alacritty) were not removed."
