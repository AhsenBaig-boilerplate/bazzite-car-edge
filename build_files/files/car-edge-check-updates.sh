#!/usr/bin/env bash
# Bazzite Car Edge - Update Checker
# Checks for new image versions and notifies user

set -euo pipefail

# Configuration
IMAGE_REGISTRY="ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest"
CHECK_MARKER="$HOME/.cache/car-edge-update-check"
NOTIFIED_MARKER="$HOME/.cache/car-edge-update-notified"

# Ensure cache directory exists
mkdir -p "$HOME/.cache"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$HOME/.cache/car-edge-update-checker.log"
}

log "Update check started"

# Check if we're running Car Edge
if ! rpm-ostree status 2>/dev/null | grep -q "bazzite-car-edge"; then
    log "Not running Car Edge, exiting"
    exit 0
fi

# Get current deployment
CURRENT_COMMIT=$(rpm-ostree status --json | jq -r '.deployments[0].checksum' 2>/dev/null || echo "unknown")
log "Current commit: $CURRENT_COMMIT"

# Check for updates (this will check :latest tag)
log "Checking for updates..."
UPDATE_CHECK=$(rpm-ostree upgrade --check 2>&1 || true)

if echo "$UPDATE_CHECK" | grep -q "Available update"; then
    log "Update available!"
    
    # Get the new version info
    NEW_VERSION=$(echo "$UPDATE_CHECK" | grep -oP 'Version: \K[^\s]+' | head -1 || echo "newer version")
    
    # Check if we've already notified about this version
    if [ -f "$NOTIFIED_MARKER" ]; then
        LAST_NOTIFIED=$(cat "$NOTIFIED_MARKER" 2>/dev/null || echo "")
        if [ "$LAST_NOTIFIED" = "$NEW_VERSION" ]; then
            log "Already notified about version $NEW_VERSION"
            exit 0
        fi
    fi
    
    # Show notification to user
    if [ -n "${DISPLAY:-}" ] && command -v kdialog &>/dev/null; then
        log "Showing GUI notification"
        
        # Try to show GUI notification
        if kdialog --title "Bazzite Car Edge Update Available" \
                   --yesno "A new version of Bazzite Car Edge is available!

Current: $CURRENT_COMMIT
Available: $NEW_VERSION

Would you like to update now?

Note: System will download the update and reboot.
You can postpone and update later with:
  rpm-ostree upgrade" 2>/dev/null; then
            
            log "User accepted update"
            
            # Show progress notification
            (
                echo "# Downloading update..."
                rpm-ostree upgrade 2>&1 | while read -r line; do
                    echo "$line" | grep -oP '\d+%' || echo "#"
                done
                
                echo "100"
                echo "# Update downloaded! Rebooting in 30 seconds..."
                sleep 5
            ) | kdialog --title "Updating Bazzite Car Edge" \
                       --progressbar "Preparing update..." 100 &
            
            # Apply update
            rpm-ostree upgrade
            
            # Schedule reboot
            log "Update downloaded, scheduling reboot"
            kdialog --title "Update Complete" \
                   --msgbox "Update downloaded successfully!

System will reboot in 30 seconds to apply the update.

Cancel the reboot with: systemctl cancel reboot
Or reboot now with: systemctl reboot" &
            
            sleep 30
            systemctl reboot
        else
            log "User postponed update"
            kdialog --title "Update Postponed" \
                   --msgbox "Update postponed.

To update later, run:
  rpm-ostree upgrade
  systemctl reboot

Or use: car-edge-check-updates" 2>/dev/null || true
        fi
    else
        # No GUI available, log only
        log "No GUI available, logging update notification"
        echo "Update available: $NEW_VERSION" > "$HOME/.cache/car-edge-update-available"
    fi
    
    # Mark this version as notified
    echo "$NEW_VERSION" > "$NOTIFIED_MARKER"
    
elif echo "$UPDATE_CHECK" | grep -q "No updates available"; then
    log "No updates available"
    # Clear notification marker if no updates
    rm -f "$NOTIFIED_MARKER"
else
    log "Update check result: $UPDATE_CHECK"
fi

# Update check timestamp
date '+%s' > "$CHECK_MARKER"

log "Update check completed"
