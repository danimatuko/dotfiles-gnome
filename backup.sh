#!/bin/bash

set -e

echo "🧩 Backing up GNOME desktop configuration..."

BACKUP_DIR="$PWD"

# --- Export GNOME settings ---
echo "📥 Saving GNOME dconf settings..."
dconf dump / > "$BACKUP_DIR/dconf-settings.ini"

# --- Save config files ---
echo "📂 Backing up ~/.config/gtk-* and gnome-shell..."
mkdir -p "$BACKUP_DIR/config"
cp -r ~/.config/gtk-3.0 "$BACKUP_DIR/config/" 2>/dev/null || true
cp -r ~/.config/gtk-4.0 "$BACKUP_DIR/config/" 2>/dev/null || true
cp -r ~/.config/gnome-shell "$BACKUP_DIR/config/" 2>/dev/null || true

# --- Save user-installed extensions (optional but useful for offline restore) ---
echo "🧩 Backing up GNOME Shell extensions..."
mkdir -p "$BACKUP_DIR/extensions"
cp -r ~/.local/share/gnome-shell/extensions/* "$BACKUP_DIR/extensions/" 2>/dev/null || true

# --- Export enabled extension UUIDs ---
echo "🧾 Exporting enabled extension UUIDs..."
dconf read /org/gnome/shell/enabled-extensions \
    | tr -d "[]'," \
    | tr ' ' '\n' \
    | grep -v '^$' \
    > "$BACKUP_DIR/enabled-extensions.list"

# --- Optional theming assets ---
echo "🎨 Backing up themes, icons, and fonts..."
cp -r ~/.themes "$BACKUP_DIR/" 2>/dev/null || true
cp -r ~/.icons "$BACKUP_DIR/" 2>/dev/null || true
cp -r ~/.fonts "$BACKUP_DIR/" 2>/dev/null || true

echo "✅ GNOME backup complete!"

