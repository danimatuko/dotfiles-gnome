#!/bin/bash

echo "🟢 Extracting backup archive..."
tar -xzvf ~/gnome-backup.tar.gz -C ~/

BACKUP_DIR="~/gnome-backup"

echo "🟢 Restoring dconf settings..."
dconf load / < "$BACKUP_DIR/dconf-settings.ini"

echo "🟢 Restoring themes, icons, fonts..."
cp -r "$BACKUP_DIR/themes/.themes" ~/
cp -r "$BACKUP_DIR/themes/.icons" ~/
cp -r "$BACKUP_DIR/themes/.local/share/fonts" ~/.local/share/
fc-cache -fv

echo "🟢 Restoring GTK and GNOME Shell configs..."
cp -r "$BACKUP_DIR/gtk-3.0" ~/.config/
cp -r "$BACKUP_DIR/gtk-4.0" ~/.config/
cp -r "$BACKUP_DIR/gnome-shell" ~/.config/

echo "🟢 Installing GNOME extensions..."
mkdir -p ~/.local/share/gnome-shell/extensions

while read uuid; do
  echo "➡️  Installing extension: $uuid"
  EXT_URL=$(curl -s "https://extensions.gnome.org/extension-query/?search=$uuid" | jq -r '.extensions[0].link')
  EXT_ID=$(echo $EXT_URL | awk -F'/' '{print $3}')
  VERSION=$(gnome-shell --version | grep -oE '[0-9]+\.[0-9]+' | head -n1)
  DL_URL="https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${VERSION//./}"
  wget -O /tmp/$uuid.zip "$DL_URL" && unzip -q /tmp/$uuid.zip -d ~/.local/share/gnome-shell/extensions/$uuid
done < "$BACKUP_DIR/extensions-uuids.txt"

echo "🟢 Cleaning up temporary files..."
rm -f /tmp/*.zip

echo "✅ Restore complete. Log out and back in to fully apply all changes."

