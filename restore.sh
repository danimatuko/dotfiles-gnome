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

# --- Restore optional theming assets ---
echo "🎨 Restoring themes, icons, fonts..."
cp -r .themes ~/.themes 2>/dev/null || true
cp -r .icons ~/.icons 2>/dev/null || true
cp -r .fonts ~/.fonts 2>/dev/null || true

# --- Ensure installer is available ---
if ! command -v gnome-shell-extension-installer &>/dev/null; then
    echo "📦 Installing gnome-shell-extension-installer..."
    sudo curl -sSLo /usr/local/bin/gnome-shell-extension-installer \
        https://raw.githubusercontent.com/brunelli/gnome-shell-extension-installer/master/gnome-shell-extension-installer
    sudo chmod +x /usr/local/bin/gnome-shell-extension-installer
fi

# --- Install extensions by resolving UUIDs to IDs ---
echo "🧩 Installing extensions from UUID list..."

resolve_extension_id() {
    local uuid="$1"
    curl -s "https://extensions.gnome.org/extension-query/?search=${uuid}" \
        | grep -oP '"id":\d+,"uuid":"'"$uuid"'"' \
        | grep -oP '\d+'
}

if [[ -f enabled-extensions.list ]]; then
    while read -r uuid; do
        [[ -z "$uuid" ]] && continue
        echo "🔍 Resolving extension: $uuid"
        ext_id=$(resolve_extension_id "$uuid")
        if [[ -n "$ext_id" ]]; then
            echo "⬇️ Installing ID $ext_id for $uuid"
            gnome-shell-extension-installer --yes "$ext_id"
        else
            echo "⚠️ Could not resolve: $uuid"
        fi
    done < enabled-extensions.list
else
    echo "⚠️ enabled-extensions.list not found!"
fi

# --- Enable extensions via dconf ---
if [[ -f enabled-extensions.list ]]; then
    echo "🖇 Enabling extensions..."
    enabled=$(printf "'%s', " $(< enabled-extensions.list))
    enabled="[${enabled%, }]"
    dconf write /org/gnome/shell/enabled-extensions "$enabled"
fi

# --- Done ---
echo "✅ GNOME desktop restoration complete."
echo "🎯 GTK theme: $(gsettings get org.gnome.desktop.interface gtk-theme)"
echo "🧩 Enabled extensions: $(gsettings get org.gnome.shell.enabled-extensions)"
echo "💡 Log out or restart GNOME Shell (Alt+F2 → r) to apply changes."
