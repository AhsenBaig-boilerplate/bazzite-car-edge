#!/usr/bin/env bash
# Bazzite Car Edge - Upgrade Helper
# Run this after rebasing from standard Bazzite to enable all new features

set -euo pipefail

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  🚗 Bazzite Car Edge - Upgrade Helper                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "This script helps existing users who rebased from standard Bazzite."
echo "It will enable all new Car Edge features for your user account."
echo ""

# Check if already upgraded
if [ -f "$HOME/.config/car-edge-upgraded" ]; then
    echo "✅ Already upgraded! You're all set."
    echo ""
    echo "To run the setup wizard again:"
    echo "  car-edge-setup-wizard --force"
    exit 0
fi

# Confirm with user
read -p "Continue with upgrade? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upgrade cancelled."
    exit 0
fi

echo ""
echo "📦 Enabling Car Edge features..."
echo ""

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config/autostart"
mkdir -p "$HOME/.config/systemd/user"

# Copy setup wizard autostart (disabled by default for manual users)
# Uncomment if you want auto-run on every boot:
# cp /etc/skel/.config/autostart/car-edge-setup-wizard.desktop "$HOME/.config/autostart/" 2>/dev/null || true

echo "✅ Car Edge features enabled!"
echo ""
echo "📱 Next Steps:"
echo ""
echo "1. Run the setup wizard to configure your system:"
echo "   car-edge-setup-wizard"
echo ""
echo "2. The wizard will help you:"
echo "   • Set up external storage"
echo "   • Install applications (Kodi, Firefox, etc.)"
echo "   • Configure Kodi media sources"
echo "   • Set up Syncthing (optional)"
echo "   • Create first backup"
echo ""
echo "3. Available commands:"
echo "   car-edge-setup-wizard   - Run setup wizard"
echo "   car-edge-install-apps   - Install applications only"
echo "   car-edge-backup         - Backup configurations"
echo ""
echo "📚 Documentation: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge"
echo ""

# Mark as upgraded
touch "$HOME/.config/car-edge-upgraded"

echo "✅ Upgrade complete!"
echo ""
echo "Run 'car-edge-setup-wizard' to get started!"
