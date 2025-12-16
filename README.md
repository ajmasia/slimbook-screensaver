# Slimbook EVO Screensaver

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-green)
![Python](https://img.shields.io/badge/python-3.8%2B-yellow)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey)

A terminal-based screensaver with animated text effects, adapted from [Omarchy](https://omarchy.org).

## Compatibility

- **Debian 13+** with GNOME (tested)
- **Ubuntu 22.04+** with GNOME (should work)

## Features

- ASCII art "Slimbook EVO" logo with random visual effects
- Automatic activation after 2.5 minutes of inactivity
- Manual launch and toggle commands
- Uses [Terminal Text Effects (tte)](https://github.com/ChrisBuilds/terminaltexteffects)

## Installation

### Quick Install (from release)

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/slimbook-screensaver/main/install.sh | bash
```

### Install from cloned repo

```bash
git clone https://github.com/ajmasia/slimbook-screensaver.git
cd slimbook-screensaver
./install.sh
```

### Installer options

```bash
./install.sh --help     # Show help
./install.sh --local    # Force local installation
./install.sh --remote   # Force download from release
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `slimbook-screensaver` | Launch screensaver manually |
| `slimbook-screensaver-toggle` | Enable/disable automatic screensaver |
| `slimbook-screensaver-uninstall` | Uninstall screensaver |

### Exit Screensaver

Press any key to exit the screensaver.

## Configuration

Edit `~/.config/slimbook-screensaver/screensaver.conf`:

```bash
# Terminal to use: alacritty (default), gnome-terminal, ptyxis
SLIMBOOK_SCREENSAVER_TERMINAL=alacritty

# Idle timeout in seconds (default: 120)
SLIMBOOK_SCREENSAVER_IDLE_TIMEOUT=120

# Animation frame rate (default: 60)
SLIMBOOK_SCREENSAVER_FRAME_RATE=60
```

### Customize ASCII Art

Edit `~/.local/share/slimbook-screensaver/screensaver.txt` with your own ASCII art.

## Uninstall

```bash
# Keep config for reinstallation
slimbook-screensaver-uninstall

# Remove everything including config and logs
slimbook-screensaver-uninstall --all
```

## File Structure

```
~/.local/share/slimbook-screensaver/
├── screensaver.txt       # ASCII art displayed
├── screensaver-cmd.sh    # Core screensaver logic
├── screensaver-launch.sh # Launcher script
├── screensaver-toggle.sh # Toggle on/off
├── idle-monitor.sh       # GNOME idle detection
├── uninstall.sh          # Uninstaller
└── venv/                 # Python venv with tte

~/.local/bin/
├── tte                          # Symlink to tte binary
├── slimbook-screensaver         # Symlink to launcher
├── slimbook-screensaver-toggle  # Symlink to toggle
└── slimbook-screensaver-uninstall # Symlink to uninstaller

~/.config/slimbook-screensaver/
└── screensaver.conf      # User configuration

~/.config/autostart/
└── slimbook-screensaver-monitor.desktop  # Autostart entry
```

## Dependencies

- **Python 3.8+** - For tte installation
- `python3-pip`, `python3-venv` - Python package management
- `alacritty`, `gnome-terminal`, or `ptyxis` - Terminal emulator
- `jq` - JSON parsing
- `curl` - For remote installation

## Acknowledgments

This project is inspired by the screensaver from [Omarchy](https://github.com/basecamp/omarchy), created by David Heinemeier Hansson (DHH) and Basecamp, released under the MIT License.

The original implementation was designed for Arch Linux with Hyprland. This version has been adapted and rewritten for Debian/Ubuntu + GNOME, with modifications including:

- GNOME Mutter D-Bus integration for idle detection (replacing hypridle)
- Multiple terminal emulator support (alacritty, gnome-terminal, ptyxis)
- Standalone installation without Omarchy dependencies
