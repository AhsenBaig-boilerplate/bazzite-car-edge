#!/usr/bin/env bash
# Bazzite Car Edge - Update Checker
# Checks for new image versions, downloads in background, shows persistent notification

set -euo pipefail

# Configuration
IMAGE_REGISTRY="ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest"
CHECK_MARKER="$HOME/.cache/car-edge-update-check"
STAGED_MARKER="$HOME/.cache/car-edge-update-staged"
DOWNLOAD_MARKER="$HOME/.cache/car-edge-update-downloading"
UPDATE_AVAILABLE=false
TARGET_REF=""
NEW_VERSION=""

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

# Check if update is already staged
if rpm-ostree status 2>/dev/null | grep -q "State: pending"; then
    log "Update already staged, showing notification"
    
    if [ -n "${DISPLAY:-}" ]; then
        # Show persistent system tray notification
        if command -v notify-send &>/dev/null; then
            notify-send -u critical -t 0 \
                -a "Bazzite Car Edge" \
                -i system-software-update \
                "Update Ready to Install" \
                "A system update has been downloaded and is ready.\nRestart your system when convenient to apply the update.\n\nClick to apply now or use: car-edge-apply-update"
        fi
    fi
    
    # Mark as staged
    rpm-ostree status --json | jq -r '.deployments[1].version // "staged"' > "$STAGED_MARKER"
    exit 0
fi

# Check if we're currently downloading
if [ -f "$DOWNLOAD_MARKER" ]; then
    log "Download already in progress"
    exit 0
fi

# Get current deployment
CURRENT_COMMIT=$(rpm-ostree status --json | jq -r '.deployments[0].checksum' 2>/dev/null || echo "unknown")
log "Current commit: $CURRENT_COMMIT"

# Check for updates (this will check :latest tag)
log "Checking for updates..."

# CRITICAL: Resolve :latest to actual digest to avoid "old and new refs are equal"
# This is necessary because rpm-ostree compares tag NAMES, not content
log "Resolving :latest tag to actual digest..."

# Get current deployment info
CURRENT_IMAGE=$(rpm-ostree status --json | jq -r '.deployments[0]["container-image-reference"] // empty' 2>/dev/null || echo "")
CURRENT_DIGEST=$(rpm-ostree status --json | jq -r '.deployments[0].checksum' 2>/dev/null || echo "unknown")

log "Current image: $CURRENT_IMAGE"
log "Current digest: $CURRENT_DIGEST"

# Query registry for :latest digest
if command -v skopeo &>/dev/null; then
    LATEST_DIGEST=$(skopeo inspect docker://${IMAGE_REGISTRY} 2>/dev/null | jq -r '.Digest // empty' || echo "")
    log "Latest digest from registry: $LATEST_DIGEST"
    
    if [ -n "$LATEST_DIGEST" ] && [ "$LATEST_DIGEST" != "null" ]; then
        # Compare digests
        if [ "$CURRENT_DIGEST" != "$LATEST_DIGEST" ]; then
            log "Update available! Digests differ."
            
            # Resolve :latest to specific versioned tag to avoid rpm-ostree confusion
            # Get all tags for this digest
            ALL_TAGS=$(skopeo list-tags docker://ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge 2>/dev/null | jq -r '.Tags[]' || echo "")
            
            # Find the versioned tag with commit (format: v1.0.0-build.123-abc1234)
            SPECIFIC_TAG=$(echo "$ALL_TAGS" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+-build\.[0-9]+-[a-f0-9]{7}$' | sort -V -r | head -1 || echo "")
            
            # Fallback: Try version without commit (format: v1.0.0-build.123)
            if [ -z "$SPECIFIC_TAG" ]; then
                SPECIFIC_TAG=$(echo "$ALL_TAGS" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+-build\.[0-9]+$' | sort -V -r | head -1 || echo "")
            fi
            
            # Legacy fallback: Try date-commit tag (format: YYYYMMDD-commit)
            if [ -z "$SPECIFIC_TAG" ]; then
                SPECIFIC_TAG=$(echo "$ALL_TAGS" | grep -E '^[0-9]{8}-[a-f0-9]{7}$' | sort -r | head -1 || echo "")
            fi
            
            if [ -n "$SPECIFIC_TAG" ]; then
                log "Resolved :latest to specific tag: $SPECIFIC_TAG"
                TARGET_REF="ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:${SPECIFIC_TAG}"
            else
                log "Could not resolve to specific tag, using digest"
                TARGET_REF="ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge@${LATEST_DIGEST}"
            fi
            
            UPDATE_AVAILABLE=true
            NEW_VERSION="$SPECIFIC_TAG"
        else
            log "Already on latest version (digests match)"
            UPDATE_AVAILABLE=false
        fi
    else
        log "Could not query registry digest, falling back to rpm-ostree upgrade --check"
        UPDATE_CHECK=$(rpm-ostree upgrade --check 2>&1 || true)
        
        if echo "$UPDATE_CHECK" | grep -q "Available update"; then
            UPDATE_AVAILABLE=true
            NEW_VERSION=$(echo "$UPDATE_CHECK" | grep -oP 'Version: \K[^\s]+' | head -1 || echo "newer version")
            TARGET_REF="ostree-unverified-registry:${IMAGE_REGISTRY}"
        else
            UPDATE_AVAILABLE=false
        fi
    fi
else
    log "skopeo not available, using rpm-ostree upgrade --check"
    UPDATE_CHECK=$(rpm-ostree upgrade --check 2>&1 || true)
    
    if echo "$UPDATE_CHECK" | grep -q "Available update"; then
        UPDATE_AVAILABLE=true
        NEW_VERSION=$(echo "$UPDATE_CHECK" | grep -oP 'Version: \K[^\s]+' | head -1 || echo "newer version")
        TARGET_REF="ostree-unverified-registry:${IMAGE_REGISTRY}"
    else
        UPDATE_AVAILABLE=false
    fi
fi

if [ "$UPDATE_AVAILABLE" = true ]; then
    log "Update available!"
    
    # Get the new version info
    NEW_VERSION=$(echo "$UPDATE_CHECK" | grep -oP 'Version: \K[^\s]+' | head -1 || echo "newer version")
    
    # Check if we've already staged this version
    if [ -f "$STAGED_MARKER" ]; then
        STAGED_VERSION=$(cat "$STAGED_MARKER" 2>/dev/null || echo "")
        if [ "$STAGED_VERSION" = "$NEW_VERSION" ]; then
            log "Version $NEW_VERSION already staged"
            exit 0
        fi
    fi
    
    # Show GUI prompt with options if DISPLAY available
    if [ -n "${DISPLAY:-}" ] && command -v kdialog &>/dev/null; then
        log "Showing update options dialog"
        
        # Show menu with options
        UPDATE_CHOICE=$(kdialog --title "Bazzite Car Edge - Update Available" \
                              --menu "A system update is available!

Current version: $CURRENT_COMMIT
Available version: $NEW_VERSION

What would you like to do?" \
                              "download-latest" "Download Latest (Recommended)" \
                              "choose-version" "Choose Specific Version" \
                              "skip" "Skip for Now" 2>/dev/null || echo "skip")
        
        log "User choice: $UPDATE_CHOICE"
        
        case "$UPDATE_CHOICE" in
            "download-latest")
                log "User chose to download latest"
                ;;
            "choose-version")
                log "User chose version switcher"
                
                # Check if car-edge-switch-version exists
                if command -v car-edge-switch-version &>/dev/null; then
                    # Launch version switcher
                    car-edge-switch-version &
                    exit 0
                else
                    kdialog --title "Command Not Available" \
                           --error "car-edge-switch-version is not available.

This feature requires a newer build.

Falling back to automatic download..." 2>/dev/null || true
                    # Fall through to download
                fi
                ;;
            "skip")
                log "User chose to skip update"
                kdialog --title "Update Skipped" \
                       --msgbox "Update skipped.

The update will be checked again:
• Tomorrow at 11:00 AM
• 30 minutes after next boot

To check manually: car-edge-check-updates
To choose version: car-edge-switch-version" 2>/dev/null || true
                exit 0
                ;;
        esac
    fi
    
    log "Downloading update $NEW_VERSION in background..."
    
    # Mark download in progress
    echo "$NEW_VERSION" > "$DOWNLOAD_MARKER"
    
    # Show initial notification
    if [ -n "${DISPLAY:-}" ]; then
        if command -v notify-send &>/dev/null; then
            notify-send -u normal -t 10000 \
                -a "Bazzite Car Edge" \
                -i system-software-update \
                "Downloading Update" \
                "Downloading system update in the background...\nYour entertainment system will remain fully functional."
        fi
    fi
    
    # Download and stage update in background (doesn't interrupt system)
    log "Running rpm-ostree rebase to: $TARGET_REF"
    if rpm-ostree rebase "$TARGET_REF" 2>&1 | tee -a "$HOME/.cache/car-edge-update-checker.log"; then
        log "Update downloaded and staged successfully"
        
        # Mark as staged
        echo "$NEW_VERSION" > "$STAGED_MARKER"
        rm -f "$DOWNLOAD_MARKER"
        
        # Show persistent notification in system tray
        if [ -n "${DISPLAY:-}" ]; then
            if command -v notify-send &>/dev/null; then
                notify-send -u critical -t 0 \
                    -a "Bazzite Car Edge" \
                    -i system-software-update \
                    "Update Ready to Install" \
                    "System update downloaded successfully!\n\nVersion: $NEW_VERSION\n\nRestart when convenient to apply.\nUse: car-edge-apply-update"
            fi
            
            # Also show kdialog for immediate visibility
            if command -v kdialog &>/dev/null; then
                kdialog --title "Update Downloaded" \
                       --passivepopup "System update is ready to install.\nRestart when convenient to apply the update.\n\nUse: car-edge-apply-update" 15 2>/dev/null || true
            fi
        fi
    else
        log "Update download failed"
        rm -f "$DOWNLOAD_MARKER"
        
        if [ -n "${DISPLAY:-}" ] && command -v notify-send &>/dev/null; then
            notify-send -u normal -t 10000 \
                -a "Bazzite Car Edge" \
                -i dialog-error \
                "Update Download Failed" \
                "Failed to download system update.\nWill retry automatically."
        fi
    fi
    
else
    log "No updates available (already on latest)"
    # Clear markers if no updates
    rm -f "$STAGED_MARKER" "$DOWNLOAD_MARKER"
fi

# Update check timestamp
date '+%s' > "$CHECK_MARKER"

log "Update check completed"
