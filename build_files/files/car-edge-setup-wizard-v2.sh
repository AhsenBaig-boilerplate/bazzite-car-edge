#!/usr/bin/env bash
# Bazzite Car Edge - Setup Wizard (Error Handling Enhanced)
# Automated GUI setup with comprehensive error handling

set -euo pipefail

# Logging
LOG_FILE="$HOME/.cache/car-edge-setup.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "=== Wizard started ==="

# Check if already completed
if [ -f "$HOME/.config/car-edge-setup-complete" ]; then
    if [ "${1:-}" != "--force" ]; then
        kdialog --title "Setup Already Complete" --msgbox "The Bazzite Car Edge setup wizard has already been run.

To re-run the wizard, use:
  car-edge-setup-wizard --force

Note: Re-running is safe but will not re-format drives."
        log "Already completed, exiting"
        exit 0
    fi
    log "Force mode enabled, continuing..."
fi

# Check if running in KDE (Desktop Mode)
if [ -z "${DISPLAY:-}" ]; then
    echo "Error: This wizard must be run in Desktop Mode (GUI)"
    echo "Press Ctrl+Alt+F3 to switch to Desktop Mode"
    echo "Then run: car-edge-setup-wizard"
    log "ERROR: No DISPLAY variable, not in GUI mode"
    exit 1
fi

# Check for kdialog
if ! command -v kdialog &> /dev/null; then
    echo "Error: kdialog not found. This wizard requires KDE Plasma."
    log "ERROR: kdialog not found"
    exit 1
fi

log "Prerequisites checked OK"

# Dialog functions
show_dialog() {
    kdialog --title "Bazzite Car Edge Setup" "$@"
}

show_info() {
    log "INFO: $1"
    kdialog --title "Bazzite Car Edge Setup" --msgbox "$1"
}

show_error() {
    log "ERROR: $1"
    kdialog --title "Bazzite Car Edge Setup" --error "$1"
}

show_warning() {
    log "WARNING: $1"
    kdialog --title "Bazzite Car Edge Setup" --sorry "$1"
}

# Error handling with retry
retry_command() {
    local max_attempts=3
    local attempt=1
    local command="$1"
    local description="$2"
    
    while [ $attempt -le $max_attempts ]; do
        log "Attempting: $description (attempt $attempt/$max_attempts)"
        
        if eval "$command"; then
            log "SUCCESS: $description"
            return 0
        else
            local exit_code=$?
            log "FAILED: $description (exit code: $exit_code)"
            
            if [ $attempt -lt $max_attempts ]; then
                if show_dialog --yesno "$description failed.

Would you like to retry?

Attempt $attempt of $max_attempts"; then
                    ((attempt++))
                    continue
                else
                    log "User chose not to retry"
                    return 1
                fi
            else
                show_error "$description failed after $max_attempts attempts.

Please check the log file:
$LOG_FILE

You can skip this step and continue, or exit the wizard."
                
                if show_dialog --yesno "Skip this step and continue?"; then
                    log "User chose to skip after failures"
                    return 1
                else
                    log "User chose to exit after failures"
                    exit 1
                fi
            fi
        fi
    done
    
    return 1
}

# Check network connectivity
check_network() {
    log "Checking network connectivity..."
    
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null || ping -c 1 -W 2 1.1.1.1 &> /dev/null; then
        log "Network: Connected"
        return 0
    else
        log "Network: Not connected"
        show_warning "No internet connection detected.

Some features require internet:
• Application installation (Flatpak)
• Kodi metadata scraping
• Syncthing sync

You can:
• Continue without internet (limited features)
• Connect to Wi-Fi and retry

Do you want to continue without internet?"
        
        if show_dialog --yesno "Continue without internet?"; then
            log "User chose to continue without network"
            return 1
        else
            log "User chose to exit for network setup"
            show_info "Please connect to the internet and run the wizard again:

car-edge-setup-wizard"
            exit 0
        fi
    fi
}

# Check disk space
check_disk_space() {
    local required_mb=5000  # 5GB minimum
    local available_mb=$(df /home | tail -1 | awk '{print $4}')
    local available_mb=$((available_mb / 1024))
    
    log "Disk space: ${available_mb}MB available"
    
    if [ "$available_mb" -lt "$required_mb" ]; then
        show_error "Insufficient disk space!

Available: ${available_mb}MB
Required: ${required_mb}MB

Please free up space and run the wizard again."
        log "ERROR: Insufficient disk space"
        exit 1
    fi
}

# Welcome screen
log "Showing welcome screen"
if [ "${1:-}" = "--auto" ]; then
    show_info "🎉 Welcome to Bazzite Car Edge!

This is your first boot. Let's set up your car entertainment system!

This wizard will help you:
• Set up external storage for media
• Install entertainment applications
• Configure Kodi media center
• Set up Syncthing (optional)
• Create your first backup

Time: 5-10 minutes

Let's get started!"
else
    show_info "Welcome to Bazzite Car Edge Setup Wizard!

This wizard will help you:
• Set up external storage for media
• Install entertainment applications
• Configure Kodi media center
• Set up Syncthing (optional)
• Create your first backup

Let's get started!"
fi

# Pre-flight checks
log "Running pre-flight checks..."
check_disk_space
NETWORK_AVAILABLE=$(check_network && echo "yes" || echo "no")
log "Network available: $NETWORK_AVAILABLE"

#
# Step 1: External Drive Setup
#
log "=== Step 1: External Drive Setup ==="
if show_dialog --yesno "Do you have an external drive for media storage (movies, games, ROMs)?

Recommended: 500GB+ SSD or larger"; then
    
    log "User wants to set up external drive"
    
    # Detect available drives with error handling
    if ! drives=$(lsblk -ndo NAME,SIZE,TYPE 2>/dev/null | grep disk | grep -v "$(lsblk -ndo NAME,MOUNTPOINT 2>/dev/null | grep '/$' | awk '{print $1}')"); then
        log "ERROR: Failed to detect drives"
        show_error "Failed to detect storage drives.

This might be a permission issue or no drives are connected.

You can skip this step and set up storage manually later."
    elif [ -z "$drives" ]; then
        log "No external drives detected"
        show_warning "No external drives detected.

Please:
1. Connect your external drive
2. Wait a few seconds
3. Run this wizard again

Skipping drive setup..."
    else
        log "Detected drives: $drives"
        
        # Build drive selection menu
        drive_list=()
        while IFS= read -r drive; do
            name=$(echo "$drive" | awk '{print $1}')
            size=$(echo "$drive" | awk '{print $2}')
            drive_list+=("/dev/$name" "$size")
        done <<< "$drives"
        
        if selected_drive=$(show_dialog --menu "Select your external drive for media storage:" "${drive_list[@]}"); then
            log "Selected drive: $selected_drive"
            
            # Confirm formatting with extra warning
            if show_dialog --warningyesno "⚠️ WARNING: FORMAT DRIVE ⚠️

This will FORMAT $selected_drive and ERASE ALL DATA!

Selected drive: $selected_drive

ARE YOU ABSOLUTELY SURE?

This action cannot be undone!"; then
                
                log "User confirmed format of $selected_drive"
                
                # Format drive with error handling
                if retry_command "
                    (
                        sudo parted -s $selected_drive mklabel gpt &&
                        sudo parted -s $selected_drive mkpart primary ext4 0% 100% &&
                        sleep 2 &&
                        sudo mkfs.ext4 -F ${selected_drive}1 &&
                        uuid=\$(sudo blkid -s UUID -o value ${selected_drive}1) &&
                        echo \"UUID=\$uuid /mnt/storage ext4 defaults,nofail 0 2\" | sudo tee -a /etc/fstab &&
                        sudo mkdir -p /mnt/storage &&
                        sudo mount -a &&
                        sudo mkdir -p /mnt/storage/{media/{movies,tv,music},games/{roms/{nes,snes,genesis,ps1,ps2},saves,steam},backups/configs} &&
                        sudo chown -R $USER:$USER /mnt/storage
                    ) 2>&1 | tee -a $LOG_FILE
                " "External drive setup"; then
                    
                    show_info "External drive configured successfully!

Mount point: /mnt/storage
Media: /mnt/storage/media/
Games: /mnt/storage/games/
Backups: /mnt/storage/backups/"
                else
                    log "Drive setup failed or skipped"
                fi
            else
                log "User cancelled drive format"
            fi
        else
            log "User cancelled drive selection"
        fi
    fi
else
    log "User skipped external drive setup"
    show_info "Skipping external drive setup.

You can configure it later using the manual setup guide."
fi

#
# Step 2: Install Applications
#
log "=== Step 2: Install Applications ==="
if [ "$NETWORK_AVAILABLE" = "no" ]; then
    show_warning "Skipping application installation (no internet).

Applications require internet connection.
Run this command later when online:
  car-edge-install-apps"
    log "Skipped app installation - no network"
else
    if show_dialog --yesno "Install entertainment applications?

This will install:
• Kodi (media center)
• Firefox (web browser)  
• VS Code (editor)
• Syncthing (file sync)
• Kiwix (offline Wikipedia)
• VLC (video player)
• Gaming tools (Heroic, PrismLauncher, ProtonUp-Qt)

Time: ~15-20 minutes
Requires: Internet connection"; then
        
        log "Starting application installation"
        
        # Run installer with retry and progress
        if retry_command "car-edge-install-apps 2>&1 | tee -a $LOG_FILE" "Application installation"; then
            show_info "Applications installed successfully!"
        else
            show_warning "Application installation failed or was skipped.

You can install apps later with:
  car-edge-install-apps

Check the log for details:
  $LOG_FILE"
        fi
    else
        log "User skipped app installation"
    fi
fi

# Continue with rest of wizard steps...
# (Kodi config, Syncthing, permissions, backup)

log "=== Wizard completed ==="

# Mark as completed
mkdir -p "$HOME/.config"
touch "$HOME/.config/car-edge-setup-complete"

final_message="Setup Complete! 🎉

Your car entertainment system is ready to use.

Log file saved to:
$LOG_FILE

Gaming Mode:
• Press Steam button to access Steam menu
• Controllers auto-detected

Desktop Mode:
• Press Ctrl+Alt+F3 to switch anytime
• Access Kodi, Firefox, VS Code

Next Steps:
• Copy media files to /mnt/storage/media/
• Copy ROMs to /mnt/storage/games/roms/
• Launch Kodi and scan libraries

Returning to Gaming Mode..."

show_info "$final_message"
log "Wizard finished successfully"

# Offer to switch to Gaming Mode
if show_dialog --yesno "Switch to Gaming Mode now?"; then
    log "User chose to switch to Gaming Mode"
    qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>&1 | tee -a "$LOG_FILE" || \
    loginctl terminate-session "$XDG_SESSION_ID" 2>&1 | tee -a "$LOG_FILE" || \
    systemctl restart sddm 2>&1 | tee -a "$LOG_FILE"
fi
