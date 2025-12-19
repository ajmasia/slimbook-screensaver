#!/usr/bin/env python3
"""
Multimonitor screensaver launcher using GTK4 + VTE.
Creates a fullscreen terminal on each monitor running random tte effects.
Exits on any key press, mouse movement, or click.
"""

import gi
import os
import sys
import signal
import random

gi.require_version('Gtk', '4.0')
gi.require_version('Vte', '3.91')
gi.require_version('Gdk', '4.0')

from gi.repository import Gtk, Vte, Gdk, GLib, Gio
import subprocess

SCREENSAVER_DIR = os.path.expanduser("~/.local/share/terminal-screensaver")
CONFIG_DIR = os.path.expanduser("~/.config/terminal-screensaver")
TTE_BIN = os.path.expanduser("~/.local/bin/tte")
BANNER_FILE = os.path.join(CONFIG_DIR, "banner.txt")
FRAME_RATE = "60"

# Available tte effects
EFFECTS = [
    "beams", "binarypath", "blackhole", "bouncyballs", "bubbles", "burn",
    "colorshift", "crumble", "decrypt", "errorcorrect", "expand", "fireworks",
    "highlight", "laseretch", "matrix", "middleout", "orbittingvolley",
    "overflow", "pour", "print", "rain", "randomsequence", "rings", "scattered",
    "slice", "slide", "smoke", "spotlights", "spray", "swarm", "sweep",
    "synthgrid", "thunderstorm", "unstable", "vhstape", "waves", "wipe"
]


class ScreensaverWindow(Gtk.Window):
    """A fullscreen window with an embedded VTE terminal."""

    def __init__(self, app, monitor):
        super().__init__(application=app)
        self.monitor = monitor
        self.app = app

        # Window setup
        self.set_title("Terminal Screensaver")
        self.set_decorated(False)

        # Black background CSS
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(b"window { background-color: #000000; }")
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Create terminal
        self.terminal = Vte.Terminal()
        self.terminal.set_cursor_blink_mode(Vte.CursorBlinkMode.OFF)
        self.terminal.set_scroll_on_output(False)
        self.terminal.set_scrollback_lines(0)

        # Set terminal colors (black background, white foreground)
        bg = Gdk.RGBA()
        bg.parse("#000000")
        fg = Gdk.RGBA()
        fg.parse("#FFFFFF")
        self.terminal.set_color_background(bg)
        self.terminal.set_color_foreground(fg)
        self.terminal.set_color_cursor(bg)  # Cursor same as background (invisible)
        self.terminal.set_color_cursor_foreground(bg)

        self.set_child(self.terminal)

        # Handle key press to exit (on both window and terminal)
        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.add_controller(key_controller)

        term_key_controller = Gtk.EventControllerKey()
        term_key_controller.connect("key-pressed", self.on_key_pressed)
        self.terminal.add_controller(term_key_controller)

        # Also catch any terminal input via commit signal
        self.terminal.connect("commit", self.on_terminal_input)

        # Handle mouse movement to exit
        motion_controller = Gtk.EventControllerMotion()
        motion_controller.connect("motion", self.on_mouse_motion)
        self.add_controller(motion_controller)

        # Handle mouse click to exit
        click_controller = Gtk.GestureClick()
        click_controller.connect("pressed", self.on_mouse_click)
        self.add_controller(click_controller)

        # Handle terminal child exit
        self.terminal.connect("child-exited", self.on_child_exited)

        # Track if we should ignore initial mouse position
        self.motion_started = False

    def on_key_pressed(self, controller, keyval, keycode, state):
        """Exit on any key press."""
        self.get_application().quit()
        return True

    def on_terminal_input(self, terminal, text, size):
        """Exit on any terminal input."""
        self.get_application().quit()

    def on_mouse_motion(self, controller, x, y):
        """Exit on mouse movement (after initial position)."""
        if self.motion_started:
            self.get_application().quit()
        else:
            # Ignore first motion event (initial cursor position)
            self.motion_started = True

    def on_mouse_click(self, controller, n_press, x, y):
        """Exit on mouse click."""
        self.get_application().quit()

    def on_child_exited(self, terminal, status):
        """Restart with a new random effect."""
        self.spawn_command()

    def spawn_command(self):
        """Spawn tte with a random effect."""
        # Clear screen completely including scrollback, move to top, hide cursor
        self.terminal.reset(True, True)
        self.terminal.feed(b"\033[3J\033[2J\033[H\033[?25l")

        # Choose random effect
        effect = random.choice(EFFECTS)

        # Build tte command
        cmd = [
            TTE_BIN,
            "-i", BANNER_FILE,
            "--frame-rate", FRAME_RATE,
            "--canvas-width", "0",
            "--canvas-height", "0",
            "--anchor-canvas", "c",
            "--anchor-text", "c",
            "--no-eol",
            effect
        ]

        self.terminal.spawn_async(
            Vte.PtyFlags.DEFAULT,
            os.environ.get("HOME"),
            cmd,
            None,  # envv
            GLib.SpawnFlags.DEFAULT,
            None,  # child_setup
            None,  # child_setup_data
            -1,    # timeout
            None,  # cancellable
            None,  # callback
            None   # user_data
        )

    def present_fullscreen(self):
        """Present the window fullscreen on its monitor."""
        self.present()
        self.fullscreen_on_monitor(self.monitor)


class ScreensaverApp(Gtk.Application):
    """Main application that creates a window per monitor."""

    def __init__(self):
        super().__init__(
            application_id="org.terminal.screensaver",
            flags=Gio.ApplicationFlags.FLAGS_NONE
        )
        self.windows = []

    def is_session_locked(self):
        """Check if GNOME session is locked."""
        try:
            result = subprocess.run(
                ["gdbus", "call", "--session",
                 "--dest", "org.gnome.ScreenSaver",
                 "--object-path", "/org/gnome/ScreenSaver",
                 "--method", "org.gnome.ScreenSaver.GetActive"],
                capture_output=True, text=True, timeout=2
            )
            return "true" in result.stdout.lower()
        except Exception:
            return False

    def check_session_lock(self):
        """Periodically check if session is locked and exit if so."""
        if self.is_session_locked():
            self.quit()
            return False  # Stop the timer
        return True  # Continue checking

    def do_activate(self):
        """Create a fullscreen window on each monitor."""
        display = Gdk.Display.get_default()
        monitors = display.get_monitors()

        for i in range(monitors.get_n_items()):
            monitor = monitors.get_item(i)
            window = ScreensaverWindow(self, monitor)
            window.present_fullscreen()
            window.spawn_command()
            self.windows.append(window)

        # Check for session lock every 2 seconds
        GLib.timeout_add_seconds(2, self.check_session_lock)

    def do_shutdown(self):
        """Clean up on shutdown."""
        for window in self.windows:
            window.close()
        Gtk.Application.do_shutdown(self)


def main():
    # Handle SIGINT gracefully
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    app = ScreensaverApp()
    return app.run(sys.argv)


if __name__ == "__main__":
    sys.exit(main())
