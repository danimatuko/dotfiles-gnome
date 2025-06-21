#!/bin/bash

# Define backup directory
BACKUP_DIR="~/gnome-backup"
mkdir -p "$BACKUP_DIR"

echo "🟢 Dumping GNOME settings..."
dconf dump / > "$BACKUP_DIR/dconf-settings.ini"

echo "🟢 Saving GNOME extension list..."
gnome-extensions list > "$BACKUP_DIR/extensions-list.txt"
gnome-extensions list | xargs -n1 gnome-extensions info | grep uuid | cut -d' ' -f2 > "$BACKUP_DIR/extensions-uuids.txt"

echo "🟢 Backing up themes, icons, fonts..."
cp -r ~/.themes ~/.icons ~/.local/share/fonts "$BACKUP_DIR/themes" 2>/dev/null

echo "🟢 Backing up config folders..."
cp -r ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/gnome-shell "$BACKUP_DIR/" 2>/dev/null

echo "🟢 Archiving everything..."
tar -czvf "$HOME/gnome-backup.tar.gz" -C "$HOME" gnome-backup

echo "✅ GNOME backup complete: $HOME/gnome-backup.tar.gz"

