#!/usr/bin/env bash
# Bazzite Car Edge - Control Panel
# User-friendly GUI application for all system management

set -euo pipefail

# Check mode - diagnose installation
if [[ "${1:-}" == "--check" ]] || [[ "${1:-}" == "--diagnose" ]]; then
    echo "🔍 Bazzite Car Edge Control Panel - Diagnostic Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check script location
    echo "📄 Script Installation:"
    if [ -x "/usr/bin/car-edge-control-panel" ]; then
        echo "  ✅ /usr/bin/car-edge-control-panel (executable)"
    else
        echo "  ❌ /usr/bin/car-edge-control-panel (not found or not executable)"
    fi
    
    # Check desktop file
    echo ""
    echo "🖥️  Desktop Entry:"
    if [ -f "/usr/share/applications/car-edge-control-panel.desktop" ]; then
        echo "  ✅ /usr/share/applications/car-edge-control-panel.desktop"
    else
        echo "  ❌ /usr/share/applications/car-edge-control-panel.desktop (not found)"
    fi
    
    # Check dependencies
    echo ""
    echo "📦 Dependencies:"
    for cmd in kdialog rpm-ostree jq konsole dolphin; do
        if command -v $cmd &>/dev/null; then
            echo "  ✅ $cmd ($(command -v $cmd))"
        else
            echo "  ❌ $cmd (not found)"
        fi
    done
    
    # Check environment
    echo ""
    echo "🌍 Environment:"
    echo "  • User: $USER"
    echo "  • Display: ${DISPLAY:-❌ Not set}"
    echo "  • Desktop: ${XDG_CURRENT_DESKTOP:-Unknown}"
    echo "  • Session: ${XDG_SESSION_TYPE:-Unknown}"
    
    # Check logs
    echo ""
    echo "📋 Log Files:"
    for log in "$HOME/.cache/car-edge-control-panel.log" "$HOME/.cache/car-edge-control-panel-startup.log"; do
        if [ -f "$log" ]; then
            size=$(du -h "$log" | cut -f1)
            lines=$(wc -l < "$log")
            echo "  • $log ($size, $lines lines)"
        else
            echo "  • $log (not created yet)"
        fi
    done
    
    # Test launch
    echo ""
    echo "🧪 Quick Test:"
    if [ -n "${DISPLAY:-}" ] && command -v kdialog &>/dev/null; then
        echo "  ✅ Can launch kdialog dialogs"
        kdialog --msgbox "✅ Control Panel check successful!

kdialog is working correctly.

If you still can't launch the Control Panel from the menu:
1. Check logs: ~/.cache/car-edge-control-panel*.log
2. Try from terminal: car-edge-control-panel
3. Update desktop database: update-desktop-database ~/.local/share/applications" 2>/dev/null || echo "  ❌ kdialog test failed"
    else
        echo "  ⚠️  Cannot test kdialog (no DISPLAY or kdialog not found)"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "To launch Control Panel: car-edge-control-panel"
    echo "For test mode (no KDE): car-edge-control-panel --test"
    echo ""
    exit 0
fi

# Test mode for non-KDE systems (development)
TEST_MODE=false
if [[ "${1:-}" == "--test" ]] || [[ "${1:-}" == "--dry-run" ]]; then
    TEST_MODE=true
    echo "🧪 TEST MODE - Running without KDE (development preview)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# Mock kdialog for testing
if $TEST_MODE; then
    kdialog() {
        local cmd="$1"
        shift
        case "$cmd" in
            --title)
                echo "[DIALOG] Title: $1"
                shift
                ;;
            --menu)
                echo "[MENU] $1"
                shift
                while [[ $# -gt 0 ]]; do
                    echo "  • $1: $2"
                    shift 2 || break
                done
                echo "back"  # Return 'back' to avoid infinite loops
                return 0
                ;;
            --msgbox|--sorry|--error)
                echo "[MESSAGE] $@"
                return 0
                ;;
            --yesno|--warningyesno)
                echo "[CONFIRM] $@"
                return 1  # Return 'no' to avoid actions
                ;;
            *)
                echo "[KDIALOG $cmd] $@"
                return 0
                ;;
        esac
    }
    export -f kdialog
fi

# Ensure we have GUI (skip in test mode)
if [ -z "${DISPLAY:-}" ] && ! $TEST_MODE; then
    echo "Error: This application requires a graphical environment."
    echo "Please run from Desktop Mode (Ctrl+Alt+F3)"
    exit 1
fi

# Check if kdialog is available (skip in test mode)
if ! command -v kdialog &>/dev/null && ! $TEST_MODE; then
    if command -v zenity &>/dev/null; then
        zenity --error --text="kdialog is not installed.

This application requires KDE Plasma (Bazzite Car Edge).

🧪 For testing on non-KDE systems, run:
   bash $0 --test" 2>/dev/null
    else
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║  ERROR: Control Panel requires KDE Plasma                   ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "This Control Panel is designed for Bazzite Car Edge which"
        echo "uses KDE Plasma desktop with kdialog."
        echo ""
        echo "You're currently on: $(uname -s) ($(lsb_release -ds 2>/dev/null || echo 'Unknown'))"
        echo ""
        echo "🧪 To preview menus without KDE (development mode):"
        echo "   bash $0 --test"
        echo ""
        echo "🚗 To run the actual Control Panel:"
        echo "   Install Bazzite Car Edge on your target hardware"
    fi
    exit 1
fi

# Configuration
LOG_FILE="$HOME/.cache/car-edge-control-panel.log"
STARTUP_LOG="$HOME/.cache/car-edge-control-panel-startup.log"
mkdir -p "$HOME/.cache"

# Error handler - show errors to user
error_handler() {
    local line=$1
    local command=$2
    local error_msg="Control Panel Error at line $line: $command"
    
    echo "$error_msg" >> "$LOG_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $error_msg" >> "$STARTUP_LOG"
    
    if ! $TEST_MODE && command -v kdialog &>/dev/null; then
        kdialog --title "Control Panel Error" \
                --detailederror "An error occurred while running the Control Panel.

This has been logged for troubleshooting.

Click 'Details' to see the error message." \
                "Line $line: $command

Log file: $LOG_FILE
Startup log: $STARTUP_LOG

To report this issue, please include the logs above."
    fi
    exit 1
}

# Set error trap (skip in test mode to avoid breaking test run)
if ! $TEST_MODE; then
    trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR
fi

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "═══════════════════════════════════════════════"
log "Control Panel launched"
log "User: $USER"
log "Display: ${DISPLAY:-not set}"
log "Test mode: $TEST_MODE"
log "═══════════════════════════════════════════════"

# Check dependencies and log them
if ! $TEST_MODE; then
    log "Checking dependencies..."
    for cmd in kdialog rpm-ostree jq; do
        if command -v $cmd &>/dev/null; then
            log "  ✓ $cmd: $(command -v $cmd)"
        else
            log "  ✗ $cmd: NOT FOUND"
            if [ "$cmd" = "kdialog" ]; then
                echo "ERROR: kdialog not found!" >&2
                exit 1
            fi
        fi
    done
fi

# Get current system info
get_system_info() {
    if $TEST_MODE; then
        # Mock data for testing
        echo "current_version='v1.0.0-build.123-abc1234'"
        echo "current_tag='v1.0.0-build.123-abc1234'"
        echo "pending_update='No'"
        echo "storage_status='Mounted - Data (45.2GB/476.9GB used)'"
        return
    fi
    
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
                          "status" "📊 View System Version Info" \
                          "rollback" "↩️  Rollback to Previous Version" \
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
        "status")
            local status_info=$(rpm-ostree status 2>/dev/null || echo "Could not get status")
            kdialog --title "System Version Info" --msgbox "$status_info"
            show_updates_menu
            ;;
        "rollback")
            if kdialog --warningyesno "⚠️  Rollback to Previous Version\n\nThis will:\n• Switch to the previous OS version\n• Require a reboot to apply\n• Can be rolled back again if needed\n\nContinue?"; then
                konsole --hold -e bash -c "echo 'Rolling back to previous version...'; rpm-ostree rollback; echo ''; echo 'Rollback prepared!'; echo 'Please reboot to apply: sudo systemctl reboot'; read -p 'Press Enter...'"
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
                          "check" "🔍 Check Storage Health" \
                          "remount" "🔄 Remount Storage Drive" \
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
        "check")
            if mountpoint -q /mnt/storage 2>/dev/null; then
                local device=$(findmnt -n -o SOURCE /mnt/storage | sed 's/\[.*\]//')
                local base_device=$(echo $device | sed 's/[0-9]*$//' | sed 's/p$//')
                konsole --hold -e bash -c "echo 'Checking storage health...'; echo ''; df -h /mnt/storage; echo ''; sudo smartctl -H $base_device 2>/dev/null || echo 'SMART not available'; read -p 'Press Enter...'"
            else
                kdialog --error "Storage not mounted."
            fi
            show_storage_menu
            ;;
        "remount")
            if kdialog --yesno "Remount storage drive?\n\nThis will unmount and remount /mnt/storage.\n\nClose all apps using the storage first!"; then
                konsole --hold -e bash -c "echo 'Remounting storage...'; sudo umount /mnt/storage 2>/dev/null; sudo mount -a; mountpoint /mnt/storage && echo 'Success!' || echo 'Failed!'; read -p 'Press Enter...'"
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
                          "update" "🔄 Update All Applications (Flatpak)" \
                          "list" "📋 View Installed Applications" \
                          "uninstall" "🗑️  Uninstall Application" \
                          "repair" "🔧 Repair Flatpak System" \
                          "permissions" "🔐 Fix App Permissions (Flatseal)" \
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
        "update")
            if kdialog --yesno "Update all Flatpak applications?\n\nThis will download and install updates for all installed apps."; then
                kdialog --msgbox "Updating applications...\n\nThis may take a few minutes." &
                MSGPID=$!
                konsole --hold -e bash -c "echo 'Updating all Flatpak applications...'; flatpak update -y; echo ''; echo 'Update complete!'; read -p 'Press Enter to continue...'" &
                kill $MSGPID 2>/dev/null || true
            fi
            show_apps_menu
            ;;
        "list")
            local apps=$(flatpak list --app 2>/dev/null | awk '{print $2" ("$1")"}' || echo "No apps found")
            kdialog --title "Installed Applications" --msgbox "Installed Flatpak Applications:\n\n$apps"
            show_apps_menu
            ;;
        "uninstall")
            local app_list=$(flatpak list --app 2>/dev/null | awk '{print $1" "$2}' || echo "")
            if [ -z "$app_list" ]; then
                kdialog --error "No applications installed."
            else
                local app_to_remove=$(kdialog --menu "Select application to uninstall:" $app_list 2>/dev/null || echo "")
                if [ -n "$app_to_remove" ]; then
                    if kdialog --warningyesno "Uninstall $app_to_remove?\n\nThis will remove the application and its data."; then
                        konsole --hold -e bash -c "flatpak uninstall -y $app_to_remove; read -p 'Press Enter...'" &
                    fi
                fi
            fi
            show_apps_menu
            ;;
        "repair")
            if kdialog --yesno "Repair Flatpak system?\n\nThis will fix common Flatpak issues.\n\nContinue?"; then
                konsole --hold -e bash -c "echo 'Repairing Flatpak...'; flatpak repair; echo ''; echo 'Repair complete!'; read -p 'Press Enter...'" &
            fi
            show_apps_menu
            ;;
        "permissions")
            if flatpak list --app 2>/dev/null | grep -q "Flatseal"; then
                flatpak run com.github.tchx84.Flatseal &
            else
                if kdialog --yesno "Flatseal is not installed.\n\nFlatseal lets you manage app permissions (access to files, network, etc.)\n\nInstall Flatseal now?"; then
                    konsole --hold -e bash -c "flatpak install -y flathub com.github.tchx84.Flatseal && flatpak run com.github.tchx84.Flatseal; read -p 'Press Enter...'" &
                fi
            fi
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
                          "maintenance" "🔧 System Maintenance" \
                          "logs" "📋 View System Logs" \
                          "services" "⚙️  Check Failed Services" \
                          "terminal" "💻 Open Terminal Here" \
                          "back" "← Back to Main Menu" 2>/dev/null || echo "back")
    
    case "$choice" in
        "power")
            konsole -e bash -c "echo 'TLP Configuration:'; cat /etc/tlp.d/90-car-edge.conf 2>/dev/null || echo 'Not configured'; echo ''; echo 'TLP Status:'; sudo tlp-stat --battery 2>/dev/null || echo 'TLP not available'; read -p 'Press Enter...'" &
            show_settings_menu
            ;;
        "maintenance")
            show_maintenance_menu
            ;;
        "services")
            local failed=$(systemctl --failed --no-pager 2>/dev/null || echo "Could not check services")
            kdialog --title "Failed Services" --msgbox "$failed"
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

# System Maintenance Menu
show_maintenance_menu() {
    local choice=$(kdialog --title "System Maintenance" \
                          --menu "🔧 System Maintenance & Cleanup

Free up disk space and fix common issues:" \
                          "cleanup-os" "🗑️  Clean Up Old OS Versions" \
                          "cleanup-cache" "🗑️  Clear System Caches" \
                          "cleanup-journal" "📋 Clean Journal Logs" \
                          "disk-usage" "💾 Check Disk Usage" \
                          "back" "← Back" 2>/dev/null || echo "back")
    
    case "$choice" in
        "cleanup-os")
            if kdialog --yesno "Clean up old OS deployments?\n\nThis will:\n• Remove old/unused OS versions\n• Free up disk space\n• Keep current and previous versions\n\nContinue?"; then
                konsole --hold -e bash -c "echo 'Cleaning up old OS versions...'; sudo rpm-ostree cleanup -bp; echo ''; echo 'Cleanup complete!'; df -h / | grep -E 'Filesystem|/dev'; read -p 'Press Enter...'" &
            fi
            show_maintenance_menu
            ;;
        "cleanup-cache")
            if kdialog --yesno "Clear system caches?\n\nThis will:\n• Clear /var/cache\n• Free up disk space\n• Safe operation\n\nContinue?"; then
                konsole --hold -e bash -c "echo 'Clearing system caches...'; sudo rm -rf /var/cache/* 2>/dev/null; echo 'Cache cleared!'; df -h / | grep -E 'Filesystem|/dev'; read -p 'Press Enter...'" &
            fi
            show_maintenance_menu
            ;;
        "cleanup-journal")
            if kdialog --yesno "Clean journal logs?\n\nThis will:\n• Reduce journal size to 100MB\n• Free up disk space\n• Keep recent logs\n\nContinue?"; then
                konsole --hold -e bash -c "echo 'Current journal size:'; journalctl --disk-usage; echo ''; echo 'Cleaning journal logs...'; sudo journalctl --vacuum-size=100M; echo ''; echo 'New size:'; journalctl --disk-usage; read -p 'Press Enter...'" &
            fi
            show_maintenance_menu
            ;;
        "disk-usage")
            konsole --hold -e bash -c "echo 'Disk Usage Report:'; echo ''; df -h; echo ''; echo 'Largest directories in home:'; du -h ~ --max-depth=1 2>/dev/null | sort -hr | head -10; read -p 'Press Enter...'" &
            show_maintenance_menu
            ;;
        "back")
            show_settings_menu
            ;;
        *)
            show_settings_menu
            ;;
    esac
}

# Main loop
while true; do
    show_main_menu
done
