#!/usr/bin/env bash

echo "Control Panel installed to $USER_BIN and desktop entry updated in $USER_APPS."
echo "You may need to log out and back in for the menu entry to appear."

# Enhanced user-local installer for Bazzite Car Edge Control Panel
# Copies script and desktop entry to user directories, updates Exec path, and checks Flatpak dependencies

set -e

SCRIPT_SRC="$(dirname "$0")/build_files/files/car-edge-control-panel.sh"
DESKTOP_SRC="$(dirname "$0")/build_files/files/car-edge-control-panel.desktop"
USER_BIN="$HOME/.local/bin"
USER_APPS="$HOME/.local/share/applications"

mkdir -p "$USER_BIN" "$USER_APPS"

# Copy script
cp "$SCRIPT_SRC" "$USER_BIN/car-edge-control-panel"
chmod +x "$USER_BIN/car-edge-control-panel"

# Update desktop entry Exec path and copy
if [ -f "$DESKTOP_SRC" ]; then
    sed "s|^Exec=.*|Exec=$USER_BIN/car-edge-control-panel|" "$DESKTOP_SRC" > "$USER_APPS/car-edge-control-panel.desktop"
    chmod 644 "$USER_APPS/car-edge-control-panel.desktop"
fi

echo "Control Panel installed to $USER_BIN and desktop entry updated in $USER_APPS."
echo "You may need to log out and back in for the menu entry to appear."

# --- Dependency Checks ---
echo
echo "Checking for required dependencies..."

missing=()

# Flatpak check helper
flatpak_check() {
    local appid="$1"
    if ! flatpak info "$appid" &>/dev/null; then
        missing+=("$appid")
    fi
}

# Check Flatpak dependencies
flatpak_check org.kde.kdialog
flatpak_check org.kde.konsole
flatpak_check org.kde.dolphin

# Check rpm-ostree (host binary)
if ! command -v rpm-ostree &>/dev/null; then
    echo "⚠️  rpm-ostree not found on host. Some system features may not work."
    echo "  If you need rpm-ostree, consider running in a toolbox/distrobox or consult Bazzite docs."
fi

# Print Flatpak install instructions if needed
if [ ${#missing[@]} -gt 0 ]; then
    echo "\nThe following Flatpak dependencies are missing:"
    for appid in "${missing[@]}"; do
        echo "  - $appid"
    done
    echo "\nTo install all required dependencies, run:"
    echo "  flatpak install flathub org.kde.kdialog org.kde.konsole org.kde.dolphin"
else
    echo "All Flatpak dependencies are installed."
fi
