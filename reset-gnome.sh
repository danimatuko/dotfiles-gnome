#!/bin/bash

echo "⚠️ WARNING: This will reset your GNOME desktop and remove all extensions and theming."
read -p "Are you sure you want to proceed? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Reset aborted."
    exit 1
fi

echo "🧼 Resetting GNOME settings via dconf..."
dconf reset -f /
dconf reset /org/gnome/shell/enabled-extensions

echo "🗑 Removing user GNOME Shell extensions..."
rm -rf ~/.local/share/gnome-shell/extensions/*

echo "🗑 Removing system-wide GNOME Shell extensions..."
sudo rm -rf /usr/share/gnome-shell/extensions/*

echo "🧹 Cleaning up GNOME config and theming files..."
rm -rf ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/gnome-shell
rm -rf ~/.themes ~/.icons ~/.fonts

echo "🔁 Reset complete. Restarting GNOME Shell..."

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
    echo "💡 Press Alt+F2, type 'r', then press Enter to reload GNOME Shell."
else
    echo "💡 You're on Wayland. Please log out and log back in to apply changes."
fi

echo "✅ GNOME desktop has been reset to default."
