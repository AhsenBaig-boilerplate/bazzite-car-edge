#!/usr/bin/env bash
# Bazzite Car Edge - Apply Staged Update
# Reboots system to apply a staged system update

set -euo pipefail

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$HOME/.cache/car-edge-update-checker.log"
}

log "Apply update requested"

# Check if an update is staged
if ! rpm-ostree status 2>/dev/null | grep -q "State: pending"; then
    echo "No update is staged."
    echo ""
    echo "To check for updates, run:"
    echo "  car-edge-check-updates"
    exit 1
fi

# Get staged version info
STAGED_INFO=$(rpm-ostree status 2>/dev/null | grep -A 5 "State: pending" || true)
echo "=== Staged Update ==="
echo "$STAGED_INFO"
echo ""

# Show GUI confirmation dialog
if [ -n "${DISPLAY:-}" ] && command -v kdialog &>/dev/null; then
    if kdialog --title "Apply System Update" \
               --yesno "A system update is ready to install.

$STAGED_INFO

The system will restart to apply the update.

Save any work before continuing.

Apply update now?" 2>/dev/null; then
        
        log "User confirmed update application"
        
        # Show countdown notification
        kdialog --title "Applying Update" \
               --msgbox "System will restart in 10 seconds to apply the update.

Cancel with: systemctl cancel reboot" 2>/dev/null &
        
        # Schedule reboot
        sleep 10
        systemctl reboot
    else
        log "User cancelled update application"
        echo "Update application cancelled."
        echo ""
        echo "To apply later, run:"
        echo "  car-edge-apply-update"
        echo ""
        echo "Or manually:"
        echo "  systemctl reboot"
        exit 0
    fi
else
    # No GUI, ask via terminal
    echo "Apply update now? This will restart the system."
    read -r -p "Continue? [y/N] " response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        log "User confirmed update application (terminal)"
        echo "System will restart in 10 seconds..."
        echo "Cancel with: systemctl cancel reboot"
        sleep 10
        systemctl reboot
    else
        log "User cancelled update application (terminal)"
        echo "Update application cancelled."
        exit 0
    fi
fi
