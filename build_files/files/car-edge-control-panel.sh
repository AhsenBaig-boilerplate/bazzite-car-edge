#!/usr/bin/env bash
# Bazzite Car Edge - Control Panel
# User-friendly GUI application for all system management

set -euo pipefail

# Ensure we have GUI
if [ -z "${DISPLAY:-}" ]; then
    echo "Error: This application requires a graphical environment."
    echo "Please run from Desktop Mode (Ctrl+Alt+F3)"
    exit 1
fi

# Check if kdialog is available
if ! command -v kdialog &>/dev/null; then
    zenity --error --text="kdialog is not installed.\n\nThis application requires KDE Plasma." 2>/dev/null || \
    echo "Error: kdialog not found" >&2
    exit 1
fi

# Configuration
LOG_FILE="$HOME/.cache/car-edge-control-panel.log"
mkdir -p "$HOME/.cache"

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "Control Panel launched"

# Get current system info
get_system_info() {
    local current_version=$(rpm-ostree status --json 2>/dev/null | jq -r '.deployments[0].version // "Unknown"')
    local current_tag=$(rpm-ostree status --json 2>/dev/null | jq -r '.deployments[0]["container-image-reference"]' | grep -oP ':[^:]+$' | tr -d ':' || echo "unknown")
    local pending_update="No"
    
    if rpm-ostree status 2>/dev/null | grep -q "State: pending"; then
        pending_update="Yes - Ready to install!"
    fi
    
    local storage_status="Not configured"
    if mountpoint -q /mnt/storage 2>/dev/null; then
        local storage_size=$(df -h /mnt/storage | tail -1 | awk '{print $2}')
        local storage_used=$(df -h /mnt/storage | tail -1 | awk '{print $3}')
        local storage_label=$(lsblk -no LABEL $(findmnt -n -o SOURCE /mnt/storage) 2>/dev/null || echo "Unknown")
        storage_status="Mounted - ${storage_label} (${storage_used}/${storage_size} used)"
    fi
    
    echo "current_version=$current_version"
    echo "current_tag=$current_tag"
    echo "pending_update=$pending_update"
    echo "storage_status=$storage_status"
}

# Main menu
show_main_menu() {
    # Get system info
    eval "$(get_system_info)"
    
    # Build info display
    INFO_TEXT="🚗 Bazzite Car Edge Control Panel

📊 System Status:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Version: $current_version
• Image Tag: $current_tag
• Pending Update: $pending_update
• Storage: $storage_status

Select an option below:"
    
    # Show menu
    local choice=$(kdialog --title "🚗 Bazzite Car Edge Control Panel" \
                          --menu "$INFO_TEXT" \
                          "updates" "🔄 System Updates - Check for new versions" \
                          "storage" "💾 Storage Management - Configure drives" \
                          "apps" "📦 Applications - Install or manage apps" \
                          "network" "🌐 Network Storage - Connect to home server" \
                          "backup" "💼 Backup & Restore - Save your settings" \
                          "settings" "⚙️  Advanced Settings - Power users" \
                          "about" "ℹ️  About & Help - Version info" \
                          "exit" "❌ Exit" 2>/dev/null || echo "exit")
    
    log "User selected: $choice"
    
    case "$choice" in
        "updates")
            show_updates_menu
            ;;
        "storage")
            show_storage_menu
            ;;
        "apps")
            show_apps_menu
            ;;
        "network")
            show_network_menu
            ;;
        "backup")
            show_backup_menu
            ;;
        "settings")
            show_settings_menu
            ;;
        "about")
            show_about
            ;;
        "exit")
            log "User exited"
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
}

# Updates Menu
show_updates_menu() {
    local choice=$(kdialog --title "System Updates" \
                          --menu "🔄 System Update Options

Choose how you want to update your system:" \
                          "check" "🔍 Check for Latest Updates (Automatic)" \
                          "choose" "📋 Browse All Versions (Manual)" \
                          "apply" "✅ Apply Staged Update (Requires restart)" \
                          "auto" "⚙️  Configure Automatic Updates" \
                          "back" "← Back to Main Menu" 2>/dev/null || echo "back")
    
    case "$choice" in
        "check")
            if command -v car-edge-check-updates &>/dev/null; then
                kdialog --msgbox "Checking for updates...\n\nPlease wait..." &
                MSGPID=$!
                car-edge-check-updates 2>&1 | tee -a "$LOG_FILE"
                kill $MSGPID 2>/dev/null || true
            else
                kdialog --error "Update checker not available.\n\nPlease update to a newer build."
            fi
            show_updates_menu
            ;;
        "choose")
            if command -v car-edge-switch-version &>/dev/null; then
                car-edge-switch-version
            else
                kdialog --error "Version switcher not available.\n\nPlease update to a newer build."
            fi
            show_updates_menu
            ;;
        "apply")
            if command -v car-edge-apply-update &>/dev/null; then
                car-edge-apply-update
            else
                kdialog --error "Update applier not available.\n\nPlease update to a newer build."
            fi
            show_updates_menu
            ;;
        "auto")
            show_auto_update_settings
            ;;
        "back")
            show_main_menu
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Storage Menu
show_storage_menu() {
    local storage_info=""
    if mountpoint -q /mnt/storage 2>/dev/null; then
        local device=$(findmnt -n -o SOURCE /mnt/storage)
        local size=$(df -h /mnt/storage | tail -1 | awk '{print $2}')
        local used=$(df -h /mnt/storage | tail -1 | awk '{print $3}')
        local avail=$(df -h /mnt/storage | tail -1 | awk '{print $4}')
        local percent=$(df -h /mnt/storage | tail -1 | awk '{print $5}')
        storage_info="Current Storage:
Device: $device
Size: $size
Used: $used ($percent)
Available: $avail"
    else
        storage_info="No storage drive configured yet."
    fi
    
    local choice=$(kdialog --title "Storage Management" \
                          --menu "💾 Storage Drive Configuration

$storage_info

What would you like to do?" \
                          "setup" "🔧 Run Storage Setup Wizard" \
                          "reconfig" "🔄 Change Storage Drive (Advanced)" \
                          "browse" "📁 Open Storage Folder" \
                          "back" "← Back to Main Menu" 2>/dev/null || echo "back")
    
    case "$choice" in
        "setup")
            if command -v car-edge-setup-wizard &>/dev/null; then
                konsole -e car-edge-setup-wizard --force &
            else
                kdialog --error "Setup wizard not available."
            fi
            show_storage_menu
            ;;
        "reconfig")
            kdialog --warningyesno "⚠️  Reconfigure Storage Drive

This will:
• Keep all your existing data safe
• Let you select a different drive
• Remount media folders to new location

This does NOT delete data!

Continue?" && {
                konsole -e bash -c "echo 'Feature coming soon!'; read -p 'Press Enter to continue...'"
            }
            show_storage_menu
            ;;
        "browse")
            if [ -d /mnt/storage ]; then
                dolphin /mnt/storage &
            else
                kdialog --error "Storage not configured.\n\nPlease run setup wizard first."
            fi
            show_storage_menu
            ;;
        "back")
            show_main_menu
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Applications Menu
show_apps_menu() {
    local choice=$(kdialog --title "Application Management" \
                          --menu "📦 Install or Manage Applications

Choose an option:" \
                          "install" "⬇️  Install Applications (Kodi, Firefox, etc.)" \
                          "list" "📋 View Installed Applications" \
                          "kodi" "🎬 Configure Kodi Media Folders" \
                          "steam" "🎮 Configure Steam Library" \
                          "back" "← Back to Main Menu" 2>/dev/null || echo "back")
    
    case "$choice" in
        "install")
            if command -v car-edge-install-apps &>/dev/null; then
                konsole -e car-edge-install-apps &
            else
                kdialog --error "App installer not available."
            fi
            show_apps_menu
            ;;
        "list")
            local apps=$(flatpak list --app 2>/dev/null | awk '{print $1" "$2}' || echo "No apps found")
            kdialog --title "Installed Applications" --msgbox "Installed Flatpak Applications:\n\n$apps"
            show_apps_menu
            ;;
        "kodi")
            if [ -f ~/.var/app/tv.kodi.Kodi/data/userdata/sources.xml ]; then
                kdialog --msgbox "Kodi is already configured!\n\nMedia folders:\n• Movies: /mnt/storage/media/movies\n• TV: /mnt/storage/media/tv\n• Music: /mnt/storage/media/music"
            else
                kdialog --error "Kodi not configured yet.\n\nRun the setup wizard first."
            fi
            show_apps_menu
            ;;
        "steam")
            dolphin ~/.var/app/com.valvesoftware.Steam/.local/share/Steam/config &
            show_apps_menu
            ;;
        "back")
            show_main_menu
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Network Storage Menu
show_network_menu() {
    if command -v car-edge-network-mounts &>/dev/null; then
        car-edge-network-mounts
    else
        kdialog --error "Network storage management not available.\n\nPlease update to a newer build."
    fi
    show_main_menu
}

# Backup Menu
show_backup_menu() {
    local choice=$(kdialog --title "Backup & Restore" \
                          --menu "💼 Configuration Backup

Backup your:
• Kodi settings
• Steam library paths
• Network mounts
• System preferences

Choose an option:" \
                          "backup" "💾 Create Backup Now" \
                          "restore" "📥 Restore from Backup" \
                          "auto" "⚙️  Configure Automatic Backups" \
                          "back" "← Back to Main Menu" 2>/dev/null || echo "back")
    
    case "$choice" in
        "backup")
            if command -v car-edge-backup &>/dev/null; then
                konsole -e car-edge-backup &
            else
                kdialog --error "Backup tool not available."
            fi
            show_backup_menu
            ;;
        "restore")
            kdialog --msgbox "Restore feature coming soon!\n\nFor now, backups are stored in:\n/mnt/storage/backups/configs"
            show_backup_menu
            ;;
        "auto")
            kdialog --msgbox "Automatic backup configuration coming soon!"
            show_backup_menu
            ;;
        "back")
            show_main_menu
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Settings Menu
show_settings_menu() {
    local choice=$(kdialog --title "Advanced Settings" \
                          --menu "⚙️  Advanced Configuration

For power users:" \
                          "power" "⚡ Power Management (TLP)" \
                          "logs" "📋 View System Logs" \
                          "terminal" "💻 Open Terminal Here" \
                          "back" "← Back to Main Menu" 2>/dev/null || echo "back")
    
    case "$choice" in
        "power")
            konsole -e bash -c "echo 'TLP Configuration:'; cat /etc/tlp.d/90-car-edge.conf 2>/dev/null || echo 'Not configured'; read -p 'Press Enter...'" &
            show_settings_menu
            ;;
        "logs")
            local log_choice=$(kdialog --menu "Select log to view:" \
                                      "setup" "Setup Wizard Log" \
                                      "updates" "Update Checker Log" \
                                      "control" "Control Panel Log" \
                                      "back" "← Back" 2>/dev/null || echo "back")
            case "$log_choice" in
                "setup") konsole -e less ~/.cache/car-edge-setup.log & ;;
                "updates") konsole -e less ~/.cache/car-edge-update-checker.log & ;;
                "control") konsole -e less ~/.cache/car-edge-control-panel.log & ;;
            esac
            show_settings_menu
            ;;
        "terminal")
            konsole &
            show_settings_menu
            ;;
        "back")
            show_main_menu
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Auto Update Settings
show_auto_update_settings() {
    local timer_status=$(systemctl --user is-enabled car-edge-check-updates.timer 2>/dev/null || echo "disabled")
    local status_text="Current status: "
    if [ "$timer_status" = "enabled" ]; then
        status_text+="✅ Enabled (checks daily at 11 AM)"
    else
        status_text+="❌ Disabled"
    fi
    
    local choice=$(kdialog --title "Automatic Updates" \
                          --menu "⚙️  Automatic Update Configuration

$status_text

Choose an option:" \
                          "enable" "✅ Enable Automatic Checks" \
                          "disable" "❌ Disable Automatic Checks" \
                          "back" "← Back" 2>/dev/null || echo "back")
    
    case "$choice" in
        "enable")
            systemctl --user enable --now car-edge-check-updates.timer 2>/dev/null && \
                kdialog --msgbox "✅ Automatic updates enabled!\n\nThe system will check for updates:\n• Daily at 11:00 AM\n• 30 minutes after boot" || \
                kdialog --error "Failed to enable automatic updates."
            show_auto_update_settings
            ;;
        "disable")
            systemctl --user disable --now car-edge-check-updates.timer 2>/dev/null && \
                kdialog --msgbox "Automatic updates disabled.\n\nYou can still check manually:\n• From this control panel\n• Or run: car-edge-check-updates" || \
                kdialog --error "Failed to disable automatic updates."
            show_auto_update_settings
            ;;
        "back")
            show_updates_menu
            ;;
        *)
            show_updates_menu
            ;;
    esac
}

# About
show_about() {
    local version=$(rpm-ostree status --json 2>/dev/null | jq -r '.deployments[0].version // "Unknown"')
    local image=$(rpm-ostree status --json 2>/dev/null | jq -r '.deployments[0]["container-image-reference"]' || echo "Unknown")
    
    kdialog --title "About Bazzite Car Edge" \
            --msgbox "🚗 Bazzite Car Edge Control Panel

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version: $version
Image: $image

A minimal, gaming-optimized entertainment system
for cars and edge devices.

Based on: Bazzite (Universal Blue)
Interface: Steam Deck UI (Gaming Mode)
Desktop: KDE Plasma

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 Documentation:
github.com/AhsenBaig-boilerplate/bazzite-car-edge

💬 Support:
Check the docs or open an issue on GitHub

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Made with ❤️  for car entertainment enthusiasts"
    
    show_main_menu
}

# Main loop
while true; do
    show_main_menu
done
