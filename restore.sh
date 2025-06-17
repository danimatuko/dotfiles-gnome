#!/bin/bash
# restore-gnome.sh

BACKUP_DIR="$HOME/gnome-backup"

echo "🔄 Restoring dconf settings..."
dconf load / < "$BACKUP_DIR/dconf-settings.ini"

echo "📦 Restoring GNOME Shell extensions..."
cp -r "$BACKUP_DIR/gnome-shell/extensions/"* ~/.local/share/gnome-shell/extensions/

echo "🎨 Restoring GTK themes, icons, fonts..."
cp -r "$BACKUP_DIR/.themes" ~/
cp -r "$BACKUP_DIR/.icons" ~/
cp -r "$BACKUP_DIR/.fonts" ~/

echo "⚙️ Restoring GNOME config files..."
rsync -a "$BACKUP_DIR/config/" ~/.config/

echo "🔁 Restarting GNOME Shell (Alt+F2, then type 'r' and hit Enter)"
