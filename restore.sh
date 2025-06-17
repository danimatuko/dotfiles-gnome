#!/bin/bash

set -e

echo "🔄 Restoring GNOME Desktop Environment..."

# --- Restore dconf GNOME settings ---
if [[ -f dconf-settings.ini ]]; then
    echo "📥 Loading GNOME settings from dconf..."
    dconf load / < dconf-settings.ini
else
    echo "⚠️  dconf-settings.ini not found."
fi

# --- Restore GNOME config files ---
echo "📂 Restoring config files to ~/.config/ ..."
mkdir -p ~/.config
cp -r config/* ~/.config/

# --- Restore local GNOME Shell extensions (offline backup) ---
if [[ -d extensions ]]; then
    echo "🧩 Copying local extensions to ~/.local/share/gnome-shell/extensions/ ..."
    mkdir -p ~/.local/share/gnome-shell/extensions
    cp -r extensions/* ~/.local/share/gnome-shell/extensions/
fi

# --- Install extensions from UUID list ---
echo "🧩 Installing GNOME Shell extensions from enabled-extensions.list..."

# Ensure installer is present
if ! command -v gnome-shell-extension-installer &> /dev/null; then
    echo "📦 Installing gnome-shell-extension-installer..."
    sudo curl -sSLo /usr/local/bin/gnome-shell-extension-installer \
      https://raw.githubusercontent.com/brunelli/gnome-shell-extension-installer/master/gnome-shell-extension-installer
    sudo chmod +x /usr/local/bin/gnome-shell-extension-installer
fi

# Install extensions from the UUID list
if [[ -f enabled-extensions.list ]]; then
    while read -r uuid; do
        if [[ -n "$uuid" ]]; then
            echo "🔧 Installing extension: $uuid"
            gnome-shell-extension-installer --yes "$uuid" || echo "⚠️ Failed to install: $uuid"
        fi
    done < enabled-extensions.list
else
    echo "⚠️ No enabled-extensions.list found!"
fi

# --- Fallback: Explicitly enable extensions from list (useful for offline/local copies) ---
if [[ -f enabled-extensions.list ]]; then
    echo "🖇 Enabling extensions via dconf..."
    enabled=$(printf "'%s', " $(< enabled-extensions.list))
    enabled="[${enabled%, }]"

    echo "Writing: $enabled"
    dconf write /org/gnome/shell/enabled-extensions "$enabled"
fi

# --- Restore optional theming assets ---
if [[ -d .themes ]]; then
    echo "🎨 Restoring themes to ~/.themes/ ..."
    mkdir -p ~/.themes
    cp -r .themes/* ~/.themes/
fi

if [[ -d .icons ]]; then
    echo "🎨 Restoring icons to ~/.icons/ ..."
    mkdir -p ~/.icons
    cp -r .icons/* ~/.icons/
fi

if [[ -d .fonts ]]; then
    echo "🔤 Restoring fonts to ~/.fonts/ ..."
    mkdir -p ~/.fonts
    cp -r .fonts/* ~/.fonts/
fi

# --- Debug output ---
echo "✅ GNOME desktop restoration complete."
echo "🎯 Current GTK theme: $(gsettings get org.gnome.desktop.interface gtk-theme)"
echo "🧩 Enabled extensions: $(gsettings get org.gnome.shell.enabled-extensions)"
echo "💡 Log out or restart GNOME Shell (Alt+F2 → r) to apply changes"

