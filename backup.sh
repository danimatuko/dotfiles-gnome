#!/bin/bash
# backup-gnome.sh

BACKUP_DIR="$HOME/gnome-backup"
mkdir -p "$BACKUP_DIR"

echo "🔄 Exporting dconf settings..."
dconf dump / > "$BACKUP_DIR/dconf-settings.ini"

echo "📦 Backing up GNOME Shell extensions..."
mkdir -p "$BACKUP_DIR/gnome-shell/extensions"
cp -r ~/.local/share/gnome-shell/extensions/* "$BACKUP_DIR/gnome-shell/extensions/"

echo "🎨 Backing up GTK themes, icons, fonts..."
cp -r ~/.themes "$BACKUP_DIR/" 2>/dev/null
cp -r ~/.icons "$BACKUP_DIR/" 2>/dev/null
cp -r ~/.fonts "$BACKUP_DIR/" 2>/dev/null

echo "⚙️ Backing up GNOME-related config files..."
cp -r ~/.config/gtk-3.0 "$BACKUP_DIR/config/" 2>/dev/null
cp -r ~/.config/gtk-4.0 "$BACKUP_DIR/config/" 2>/dev/null
cp -r ~/.config/gnome-shell "$BACKUP_DIR/config/" 2>/dev/null

echo "✅ Backup complete at $BACKUP_DIR"

