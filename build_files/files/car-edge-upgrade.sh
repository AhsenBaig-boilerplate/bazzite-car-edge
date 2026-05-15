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
    echo "📱 Available Commands:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  car-edge-setup-wizard      - Run setup wizard"
    echo "  car-edge-check-updates     - Check for system updates"
    echo "  car-edge-switch-version    - Browse and switch versions"
    echo "  car-edge-apply-update      - Apply staged update"
    echo "  car-edge-backup            - Backup configurations"
    echo "  car-edge-network-mounts    - Configure network storage"
    echo ""
    
    # Check if updates available
    if command -v rpm-ostree &>/dev/null; then
        echo "🔍 Checking current version..."
        CURRENT_VERSION=$(rpm-ostree status --json | jq -r '.deployments[0].version' 2>/dev/null || echo "unknown")
        echo "   Current: $CURRENT_VERSION"
        echo ""
        
        # Check if update is staged
        if rpm-ostree status 2>/dev/null | grep -q "State: pending"; then
            echo "✨ An update is already downloaded and ready!"
            echo "   Run: car-edge-apply-update"
            echo ""
        else
            # Quick check for updates
            echo "💡 To check for updates or switch versions:"
            echo "   • car-edge-check-updates (automatic, recommended)"
            echo "   • car-edge-switch-version (manual, browse all versions)"
            echo ""
        fi
    fi
    
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

# Enable update checker timer
echo "🔄 Enabling automatic update checker..."
if systemctl --user list-unit-files | grep -q "car-edge-update-checker.timer"; then
    systemctl --user enable car-edge-update-checker.timer 2>/dev/null || true
    systemctl --user start car-edge-update-checker.timer 2>/dev/null || true
    echo "   ✓ Update checker enabled (checks daily at 11 AM)"
else
    echo "   ⚠️  Update checker not found (requires reboot)"
fi

echo ""
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
echo "3. Check for updates or switch versions:"
echo "   car-edge-check-updates      - Check for latest updates"
echo "   car-edge-switch-version     - Browse all available versions"
echo ""
echo "4. Other available commands:"
echo "   car-edge-setup-wizard       - Run setup wizard"
echo "   car-edge-install-apps       - Install applications only"
echo "   car-edge-backup             - Backup configurations"
echo "   car-edge-network-mounts     - Configure network storage"
echo "   car-edge-apply-update       - Apply staged update"
echo ""
echo "📚 Documentation: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge"
echo ""

# Mark as upgraded
touch "$HOME/.config/car-edge-upgraded"

echo "✅ Upgrade complete!"
echo ""

# Offer to check for updates now
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Would you like to check for updates now?"
echo ""
echo "Options:"
echo "  1) Check for updates (automatic)"
echo "  2) Browse all versions (manual)"
echo "  3) Skip for now"
echo ""
read -p "Choose (1/2/3): " -n 1 -r choice
echo ""
echo ""

case "$choice" in
    1)
        echo "Running car-edge-check-updates..."
        echo ""
        if command -v car-edge-check-updates &>/dev/null; then
            car-edge-check-updates
        else
            echo "⚠️  car-edge-check-updates not found"
            echo "   This requires a reboot to activate"
        fi
        ;;
    2)
        echo "Launching car-edge-switch-version..."
        echo ""
        if command -v car-edge-switch-version &>/dev/null; then
            car-edge-switch-version
        else
            echo "⚠️  car-edge-switch-version not found"
            echo "   This requires a reboot to activate"
        fi
        ;;
    3|*)
        echo "Skipped. You can check for updates anytime with:"
        echo "  car-edge-check-updates"
        echo "  car-edge-switch-version"
        ;;
esac

echo ""
echo "🎉 All set! Run 'car-edge-setup-wizard' when ready!"
