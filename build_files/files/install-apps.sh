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
echo "  💻 VS Code - Code editor and file viewer"
echo "  🎬 VLC - Media player (backup)"
echo "  🎮 ProtonUp-Qt - Proton version manager"
echo "  🎮 Heroic - Epic/GOG games launcher"
echo "  📺 Jellyfin - Media player (if using Jellyfin server)"
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
    org.kiwix.desktop \
    com.visualstudio.code \
    org.videolan.VLC \
    net.davidotek.pupgui2 \
    com.heroicgameslauncher.hgl \
    com.github.iwalton3.jellyfin-media-player

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
echo "  • VS Code - Desktop Mode"
echo "  • VLC - Desktop Mode or Gaming Mode Library"
echo "  • ProtonUp-Qt - Desktop Mode (manage Proton versions)"
echo "  • Heroic - Gaming Mode Library (Epic/GOG games)"
echo "  • Jellyfin - Gaming Mode Library or Desktop Mode"
echo ""
echo "💡 Tip: Download Wikipedia dumps for Kiwix from kiwix.org"
echo "💡 Tip: Configure Syncthing to auto-start on login"
echo ""
