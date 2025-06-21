#!/bin/bash
set -e

# Get script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR"

usage() {
  echo "Usage: $0 [--backup | --restore]"
  exit 1
}

backup() {
  echo "🔄 Backing up GNOME settings to $BACKUP_DIR..."

  echo "🧠 Dumping dconf settings..."
  dconf dump / > "$BACKUP_DIR/dconf-settings.ini"

  echo "📋 Saving list of enabled extensions..."
  gnome-extensions list --enabled > "$BACKUP_DIR/extension-list.txt"

  echo "📂 Backing up user extensions..."
  mkdir -p "$BACKUP_DIR/extensions"
  rsync -a --delete ~/.local/share/gnome-shell/extensions/ "$BACKUP_DIR/extensions/" \
    --exclude="*/schemas" --exclude="*/po"

  echo "🎨 Backing up themes and icons..."
  mkdir -p "$BACKUP_DIR/themes" "$BACKUP_DIR/icons"
  rsync -a --delete ~/.themes/ "$BACKUP_DIR/themes/" 2>/dev/null || true
  rsync -a --delete ~/.icons/ "$BACKUP_DIR/icons/" 2>/dev/null || true

  echo "🖼 Backing up wallpapers (~/Pictures/Wallpapers)..."
  [[ -d ~/Pictures/Wallpapers ]] && rsync -a ~/Pictures/Wallpapers "$BACKUP_DIR/wallpapers/" || true

  echo "✅ GNOME backup complete in: $BACKUP_DIR"
}

restore() {
  echo "🔁 Restoring GNOME settings from $BACKUP_DIR..."

  [[ ! -f "$BACKUP_DIR/dconf-settings.ini" ]] && echo "❌ dconf-settings.ini not found." && exit 1

  echo "🧠 Loading dconf settings..."
  dconf load / < "$BACKUP_DIR/dconf-settings.ini"

  echo "📂 Restoring extensions..."
  mkdir -p ~/.local/share/gnome-shell/extensions
  rsync -a "$BACKUP_DIR/extensions/" ~/.local/share/gnome-shell/extensions/

  echo "🎨 Restoring themes and icons..."
  mkdir -p ~/.themes ~/.icons
  rsync -a "$BACKUP_DIR/themes/" ~/.themes/
  rsync -a "$BACKUP_DIR/icons/" ~/.icons/

  echo "🖼 Restoring wallpapers..."
  [[ -d "$BACKUP_DIR/wallpapers" ]] && rsync -a "$BACKUP_DIR/wallpapers/" ~/Pictures/Wallpapers/ || true

  echo "⚙️ Re-enabling extensions..."
  while read ext; do
    gnome-extensions enable "$ext" 2>/dev/null || echo "⚠️ '$ext' not found (you may need to install it)"
  done < "$BACKUP_DIR/extension-list.txt"

  echo "✅ Restore complete. Log out or press Alt+F2 and type 'r' to reload GNOME Shell."
}

case "$1" in
  --backup) backup ;;
  --restore) restore ;;
  *) usage ;;
esac

