#!/bin/bash
# Slimbook EVO screensaver uninstaller

echo "=== Uninstalling Slimbook EVO Screensaver ==="

# Stop idle monitor if running
echo "[1/4] Stopping idle monitor..."
pkill -f "idle-monitor.sh" 2>/dev/null || true
pkill -f "slimbook.screensaver" 2>/dev/null || true

# Remove autostart
echo "[2/4] Removing autostart..."
rm -f ~/.config/autostart/slimbook-screensaver-monitor.desktop

# Remove symlinks
echo "[3/4] Removing symlinks..."
rm -f ~/.local/bin/slimbook-screensaver
rm -f ~/.local/bin/slimbook-screensaver-toggle
rm -f ~/.local/bin/tte

# Remove application files
echo "[4/4] Removing application files..."
rm -rf ~/.local/share/slimbook-screensaver

echo ""
echo "=== Uninstallation complete ==="
echo ""
echo "Configuration preserved at: ~/.config/slimbook-screensaver/"
echo "To remove config too: rm -rf ~/.config/slimbook-screensaver"
echo ""
echo "System packages (python3-pip, jq, libnotify-bin, alacritty) were not removed."
