#!/usr/bin/env bash
# Bazzite Car Edge - Version Switcher
# Interactive GUI to switch between available image versions

set -euo pipefail

# Configuration
IMAGE_BASE="ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge"
LOG_FILE="$HOME/.cache/car-edge-version-switcher.log"

# Ensure cache directory exists
mkdir -p "$HOME/.cache"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "=== Version Switcher started ==="

# Check if running in GUI
if [ -z "${DISPLAY:-}" ]; then
    echo "Error: This tool must be run in Desktop Mode (GUI)"
    echo "Press Ctrl+Alt+F3 to switch to Desktop Mode"
    log "ERROR: No DISPLAY variable"
    exit 1
fi

# Check for kdialog
if ! command -v kdialog &> /dev/null; then
    echo "Error: kdialog not found. This tool requires KDE Plasma."
    log "ERROR: kdialog not found"
    exit 1
fi

# Check for skopeo (for querying registry)
if ! command -v skopeo &> /dev/null; then
    kdialog --title "Missing Dependency" \
           --error "skopeo is not installed.

This tool requires skopeo to query available versions.

Install with: rpm-ostree install skopeo
Then reboot and try again."
    log "ERROR: skopeo not found"
    exit 1
fi

log "Prerequisites OK"

# Get current deployment info
CURRENT_IMAGE=$(rpm-ostree status --json | jq -r '.deployments[0]["container-image-reference"]' 2>/dev/null || echo "unknown")
CURRENT_VERSION=$(rpm-ostree status --json | jq -r '.deployments[0].version' 2>/dev/null || echo "unknown")
CURRENT_COMMIT=$(rpm-ostree status --json | jq -r '.deployments[0].checksum' 2>/dev/null | cut -c1-7 || echo "unknown")

log "Current image: $CURRENT_IMAGE"
log "Current version: $CURRENT_VERSION"
log "Current commit: $CURRENT_COMMIT"

# Show current version
kdialog --title "Bazzite Car Edge - Version Switcher" \
       --msgbox "Current Version Information:

Version: $CURRENT_VERSION
Commit: $CURRENT_COMMIT

This tool will show you available versions to switch to.

Fetching available versions from registry..."

log "Querying registry for available tags..."

# Query registry for available tags
if ! AVAILABLE_TAGS=$(skopeo list-tags "docker://$IMAGE_BASE" 2>&1); then
    kdialog --title "Registry Query Failed" \
           --error "Failed to fetch available versions from registry.

Error: $AVAILABLE_TAGS

Possible causes:
• Network connection issue
• Registry authentication required
• Registry temporarily unavailable

Check logs: $LOG_FILE"
    log "ERROR: Failed to query registry: $AVAILABLE_TAGS"
    exit 1
fi

log "Registry query successful"

# Parse tags from JSON
TAGS=$(echo "$AVAILABLE_TAGS" | jq -r '.Tags[]' 2>/dev/null | sort -r || echo "")

if [ -z "$TAGS" ]; then
    kdialog --title "No Tags Found" \
           --error "No version tags found in registry.

This is unexpected. Check logs: $LOG_FILE"
    log "ERROR: No tags found"
    exit 1
fi

log "Found tags: $TAGS"

# Build version selection menu
version_list=()

# Add :latest option
version_list+=("latest" "Latest stable release (recommended)")

# Add date-based tags (filter for YYYYMMDD pattern)
while IFS= read -r tag; do
    # Skip empty lines
    [ -z "$tag" ] && continue
    
    # Skip 'latest' (already added)
    [ "$tag" = "latest" ] && continue
    
    # Add date tags (YYYYMMDD format)
    if [[ "$tag" =~ ^[0-9]{8}$ ]]; then
        date_formatted=$(echo "$tag" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/')
        version_list+=("$tag" "Build from $date_formatted")
    fi
    
    # Add date+commit tags (YYYYMMDD-abcdef format)
    if [[ "$tag" =~ ^[0-9]{8}-[a-f0-9]{7}$ ]]; then
        date_part=$(echo "$tag" | cut -d'-' -f1)
        commit_part=$(echo "$tag" | cut -d'-' -f2)
        date_formatted=$(echo "$date_part" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/')
        version_list+=("$tag" "Build from $date_formatted (commit $commit_part)")
    fi
    
    # Add latest.YYYYMMDD tags
    if [[ "$tag" =~ ^latest\.[0-9]{8}$ ]]; then
        date_part=$(echo "$tag" | cut -d'.' -f2)
        date_formatted=$(echo "$date_part" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/')
        version_list+=("$tag" "Latest from $date_formatted")
    fi
done <<< "$TAGS"

# Check if we have versions to show
if [ ${#version_list[@]} -eq 0 ]; then
    kdialog --title "No Versions Available" \
           --error "No suitable version tags found.

Check logs: $LOG_FILE"
    log "ERROR: No suitable version tags"
    exit 1
fi

log "Built version menu with ${#version_list[@]} items"

# Show version selection dialog
if selected_version=$(kdialog --title "Select Version" \
                             --menu "Select a version to switch to:

Current: $CURRENT_VERSION ($CURRENT_COMMIT)

Available versions:" \
                             "${version_list[@]}"); then
    
    log "User selected: $selected_version"
    
    # Confirm switch
    if kdialog --title "Confirm Version Switch" \
              --yesno "Switch to version: $selected_version?

Current: $CURRENT_VERSION
New: $selected_version

This will:
1. Download the selected version
2. Stage it for next boot
3. Require a reboot to apply

Your current version will be kept as rollback option.

Continue?"; then
        
        log "User confirmed switch to $selected_version"
        
        # Build full image reference
        FULL_IMAGE="ostree-unverified-registry:$IMAGE_BASE:$selected_version"
        log "Full image: $FULL_IMAGE"
        
        # Show progress dialog
        kdialog --title "Downloading Version" \
               --passivepopup "Downloading $selected_version...\n\nThis may take several minutes.\nCheck progress with: rpm-ostree status" 10 &
        
        # Perform rebase
        log "Starting rebase to $FULL_IMAGE"
        if OUTPUT=$(rpm-ostree rebase "$FULL_IMAGE" 2>&1); then
            log "Rebase successful"
            log "Output: $OUTPUT"
            
            # Show success
            kdialog --title "Version Downloaded" \
                   --msgbox "Version $selected_version downloaded successfully!

The new version is staged and ready to apply.

To apply the update:
1. Save any work
2. Reboot your system

Or use: car-edge-apply-update

The previous version will be available for rollback if needed."
            
            log "Success dialog shown"
        else
            log "ERROR: Rebase failed"
            log "Error output: $OUTPUT"
            
            kdialog --title "Download Failed" \
                   --error "Failed to download version $selected_version

Error:
$OUTPUT

Possible causes:
• Network issue
• Invalid version tag
• Disk space issue

Check logs: $LOG_FILE"
        fi
    else
        log "User cancelled version switch"
        kdialog --title "Cancelled" \
               --msgbox "Version switch cancelled.

No changes were made."
    fi
else
    log "User cancelled version selection"
fi

log "=== Version Switcher completed ==="
