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

  if [[ ! -f "$BACKUP_DIR/dconf-settings.ini" ]]; then
    echo "❌ dconf-settings.ini not found. Aborting."
    exit 1
  fi

  echo "🧠 Loading dconf settings..."
  dconf load / < "$BACKUP_DIR/dconf-settings.ini"

  echo "📂 Restoring extensions..."
  mkdir -p ~/.local/share/gnome-shell/extensions
  if [[ -d "$BACKUP_DIR/extensions" ]]; then
    rsync -a "$BACKUP_DIR/extensions/" ~/.local/share/gnome-shell/extensions/
  else
    echo "⚠️ No extensions found to restore."
  fi

  echo "🎨 Restoring themes..."
  mkdir -p ~/.themes
  if [[ -d "$BACKUP_DIR/themes" ]]; then
    rsync -a "$BACKUP_DIR/themes/" ~/.themes/
  else
    echo "⚠️ No themes found to restore."
  fi

  echo "🎨 Restoring icons..."
  mkdir -p ~/.icons
  if [[ -d "$BACKUP_DIR/icons" ]]; then
    rsync -a "$BACKUP_DIR/icons/" ~/.icons/
  else
    echo "⚠️ No icons found to restore."
  fi

  echo "🖼 Restoring wallpapers..."
  if [[ -d "$BACKUP_DIR/wallpapers" ]]; then
    mkdir -p ~/Pictures/Wallpapers
    rsync -a "$BACKUP_DIR/wallpapers/" ~/Pictures/Wallpapers/
  else
    echo "⚠️ No wallpapers found to restore."
  fi

  echo "⚙️ Re-enabling GNOME extensions..."
  if [[ -f "$BACKUP_DIR/extension-list.txt" ]]; then
    while read -r ext; do
      gnome-extensions enable "$ext" 2>/dev/null || echo "⚠️ Could not enable: $ext"
    done < "$BACKUP_DIR/extension-list.txt"
  else
    echo "⚠️ extension-list.txt not found — skipping enable step."
  fi

  echo "✅ Restore complete. Log out or press Alt+F2 and type 'r' to reload GNOME Shell."
}
case "$1" in
  --backup) backup ;;
  --restore) restore ;;
  *) usage ;;
esac

