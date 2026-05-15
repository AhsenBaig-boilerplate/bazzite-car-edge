#!/bin/bash
set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎬 Bazzite Car Edge - Application Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will install entertainment applications:"
echo ""
echo "  📺 Kodi Media Center - Movies, TV, music"
echo "  🦊 Firefox - Web streaming (Netflix, YouTube)"
echo "  🎮 Minecraft - PrismLauncher for modding"
echo "  🔄 Syncthing - Auto-sync with home lab"
echo "  📚 Kiwix - Offline Wikipedia"
echo ""
read -p "Continue? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "📦 Installing applications (this may take 10-15 minutes)..."
echo ""

# Install all entertainment Flatpaks
flatpak install --system --noninteractive --assumeyes flathub \
    tv.kodi.Kodi \
    org.mozilla.firefox \
    org.prismlauncher.PrismLauncher \
    com.github.zocker_160.SyncThingy \
    org.kiwix.desktop

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Applications installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "You can now access:"
echo "  • Kodi - Gaming Mode Library or Desktop Mode"
echo "  • Firefox - Desktop Mode"
echo "  • Minecraft - Gaming Mode Library"
echo "  • Syncthing - Desktop Mode (configure auto-start)"
echo "  • Kiwix - Desktop Mode"
echo ""
echo "💡 Tip: Download Wikipedia dumps for Kiwix from kiwix.org"
echo "💡 Tip: Configure Syncthing to auto-start on login"
echo ""
