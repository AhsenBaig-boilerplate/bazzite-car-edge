#!/usr/bin/env bash
# Bazzite Car Edge - Control Panel
# User-friendly GUI application for all system management

set -euo pipefail

# Prevent running in sandboxed environments (Flatpak, Snap, AppImage, etc.)
if [ -n "${FLATPAK_ID:-}" ] || [ -n "${SNAP:-}" ] || [ -n "${APPIMAGE:-}" ]; then
    echo "ERROR: Car Edge Control Panel must not be run from a sandboxed environment (Flatpak, Snap, AppImage, etc.)."
    echo "Please launch from the system menu or terminal as a native app."
    if command -v kdialog &>/dev/null; then
        kdialog --error "ERROR: Car Edge Control Panel must not be run from a sandboxed environment (Flatpak, Snap, AppImage, etc.).\n\nPlease launch from the system menu or terminal as a native app."
    fi
    exit 1
fi

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
    if { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; } && command -v kdialog &>/dev/null; then
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
# Accept either X11 (DISPLAY) or Wayland (WAYLAND_DISPLAY) — Bazzite uses Wayland by default
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ] && ! $TEST_MODE; then
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

# Get current system info — prints KEY=VALUE lines, call with eval "$(get_system_info)"
get_system_info() {
    if $TEST_MODE; then
        echo "current_version='v1.0.0-build.123-abc1234'"
        echo "pending_update='No'"
        echo "storage_status='Mounted - Data (45.2GB/476.9GB used)'"
        echo "auto_updates='enabled'"
        echo "last_backup='2026-05-16 11:00'"
        echo "network_mounts='0'"
        return
    fi

    local current_version pending_update storage_status auto_updates last_backup network_mounts

    current_version=$(rpm-ostree status --json 2>/dev/null \
        | jq -r '.deployments[0].version // "Unknown"' 2>/dev/null || echo "Unknown")

    pending_update="No"
    if rpm-ostree status 2>/dev/null | grep -q "State: pending"; then
        pending_update="Yes — ready to install"
    fi

    storage_status="Not configured"
    if mountpoint -q /mnt/storage 2>/dev/null; then
        local storage_size storage_used storage_label
        storage_size=$(df -h /mnt/storage | tail -1 | awk '{print $2}')
        storage_used=$(df -h /mnt/storage | tail -1 | awk '{print $3}')
        storage_label=$(lsblk -no LABEL "$(findmnt -n -o SOURCE /mnt/storage)" 2>/dev/null || echo "")
        [ -z "$storage_label" ] && storage_label="Data"
        storage_status="Mounted — ${storage_label} (${storage_used}/${storage_size} used)"
    fi

    auto_updates=$(systemctl --user is-enabled car-edge-check-updates.timer 2>/dev/null || echo "disabled")

    last_backup="Never"
    if [ -d /mnt/storage/backups/configs ]; then
        local newest
        newest=$(ls -t /mnt/storage/backups/configs/*.tar.gz 2>/dev/null | head -1)
        if [ -n "$newest" ]; then
            last_backup=$(date -r "$newest" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "Unknown")
        fi
    fi

    network_mounts=$(find "$HOME/.config/systemd/user/" -name "*.mount" 2>/dev/null | wc -l || echo "0")

    echo "current_version=$current_version"
    echo "pending_update=$pending_update"
    echo "storage_status=$storage_status"
    echo "auto_updates=$auto_updates"
    echo "last_backup=$last_backup"
    echo "network_mounts=$network_mounts"
}

# Full system status dashboard — read-only info screen
show_system_status() {
    eval "$(get_system_info)"

    local update_icon="✅"
    [ "$pending_update" != "No" ] && update_icon="🔔"

    local storage_icon="❌"
    [[ "$storage_status" == Mounted* ]] && storage_icon="✅"

    local autoupdate_icon="❌"
    [ "$auto_updates" = "enabled" ] && autoupdate_icon="✅"

    local net_label="None configured"
    [ "$network_mounts" -gt 0 ] 2>/dev/null && net_label="$network_mounts active"

    kdialog --title "📊 System Status" --msgbox \
"🚗 Bazzite Car Edge — Current Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🖥️  OS Version
    $current_version

$update_icon Pending Update
    $pending_update

$storage_icon Data Drive
    $storage_status

$autoupdate_icon Auto-Updates
    $auto_updates

🌐 Network Mounts
    $net_label

💼 Last Backup
    $last_backup

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Use the main menu to change any of these." 2>/dev/null || true
    show_main_menu
}

# Main menu
show_main_menu() {
    # Get system info
    eval "$(get_system_info)"

    local choice
    choice=$(kdialog --title "🚗 Bazzite Car Edge" \
                     --menu "System Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version:        $current_version
Pending Update: $pending_update
Storage:        $storage_status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What would you like to do?" \
                     "updates"  "🔄 System Updates" \
                     "storage"  "💾 Storage Management" \
                     "apps"     "📦 Applications" \
                     "network"  "🌐 Network Storage" \
                     "backup"   "💼 Backup & Restore" \
                     "settings" "⚙️  Advanced Settings" \
                     "status"   "📊 View Full System Status" \
                     "about"    "ℹ️  About & Help" \
                     "exit"     "✖  Exit" 2>/dev/null || echo "exit")

    log "User selected: $choice"

    case "$choice" in
        updates)
            show_updates_menu
            ;;
        storage)
            show_storage_menu
            ;;
        apps)
            show_apps_menu
            ;;
        network)
            show_network_menu
            ;;
        backup)
            show_backup_menu
            ;;
        settings)
            show_settings_menu
            ;;
        about)
            show_about
            ;;
        status)
            show_system_status
            ;;
        exit)
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
                          "mountmgr" "🗄️  Manage Multiple Drives (No Data Loss)" \
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
        "mountmgr")
            if command -v car-edge-mount-manager &>/dev/null; then
                konsole --hold -e car-edge-mount-manager &
            elif [ -x /usr/bin/car-edge-mount-manager.sh ]; then
                konsole --hold -e /usr/bin/car-edge-mount-manager.sh &
            else
                kdialog --error "Mount Manager not available.\n\nPlease update to a newer build."
            fi
            show_storage_menu
            ;;
        "reconfig")
            if kdialog --warningyesno "🔄 Change Storage Drive

The setup wizard will let you:
• Mount an existing drive  (keeps all your data)
• Format a new/different drive

Close any apps using /mnt/storage first.

Continue?"; then
                if command -v car-edge-setup-wizard &>/dev/null; then
                    konsole -e car-edge-setup-wizard &
                else
                    kdialog --error "Setup wizard not available.\n\nPlease update to a newer build."
                fi
            fi
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
show_kodi_menu() {
    local autostart_state="Disabled"
    local autostart_action="enable"
    local autostart_label="Enable Autostart (Gaming Mode)"
    if systemctl --user is-enabled car-edge-kodi-autostart.service &>/dev/null; then
        autostart_state="Enabled"
        autostart_action="disable"
        autostart_label="Disable Autostart"
    fi

    local kodi_installed=""
    flatpak list --app 2>/dev/null | grep -q "tv.kodi.Kodi" && kodi_installed="yes"

    local choice
    choice=$(kdialog --title "Kodi Media Center" \
                     --menu "🎬 Kodi Configuration
━━━━━━━━━━━━━━━━━━━━━
Installed: ${kodi_installed:-No}
Autostart in Gaming Mode: $autostart_state

Choose an option:" \
                     "launch"     "▶  Launch Kodi Now" \
                     "autostart"  "⚙️  $autostart_label" \
                     "reconfigure" "🔄 Reconfigure Media Folders" \
                     "gaming"     "🎮 Switch to Gaming Mode" \
                     "desktop"    "🖥️  Switch to Desktop Mode" \
                     "back"       "← Back" 2>/dev/null || echo "back")

    case "$choice" in
        "launch")
            if [ -z "$kodi_installed" ]; then
                kdialog --error "Kodi is not installed.\n\nInstall it from the Application Management menu."
            else
                flatpak run tv.kodi.Kodi &>/dev/null &
            fi
            show_kodi_menu
            ;;
        "autostart")
            if systemctl --user is-enabled car-edge-kodi-autostart.service &>/dev/null; then
                systemctl --user disable --now car-edge-kodi-autostart.service 2>/dev/null || true
                kdialog --msgbox "Kodi autostart disabled.\n\nKodi will no longer launch automatically in Gaming Mode."
            else
                if ! command -v car-edge-kodi-autostart &>/dev/null; then
                    kdialog --error "Autostart script not found.\n\nPlease update to a newer build."
                else
                    systemctl --user enable --now car-edge-kodi-autostart.service 2>/dev/null || true
                    kdialog --msgbox "Kodi autostart enabled.\n\nKodi will launch automatically when you enter Gaming Mode."
                fi
            fi
            show_kodi_menu
            ;;
        "reconfigure")
            if ! mountpoint -q /mnt/storage 2>/dev/null; then
                kdialog --error "Data drive is not mounted.\n\nMount your storage drive first (Storage Management menu)."
            else
                if kdialog --warningyesno "Reconfigure Kodi media folders?\n\nThis will point Kodi to your data drive at /mnt/storage.\n\nExisting Kodi settings will be preserved."; then
                    if command -v car-edge-setup-wizard &>/dev/null; then
                        # Run just the app configuration step without full wizard
                        bash -c 'source /usr/bin/car-edge-setup-wizard 2>/dev/null; configure_apps_for_storage' 2>/dev/null || \
                            kdialog --error "Reconfiguration failed.\n\nRun the full setup wizard from the main menu."
                        kdialog --msgbox "Kodi media folders updated.\n\n• Movies: /mnt/storage/media/movies\n• TV Shows: /mnt/storage/media/tv\n• Music: /mnt/storage/media/music\n• Photos: /mnt/storage/photos"
                    else
                        kdialog --error "Setup wizard not available."
                    fi
                fi
            fi
            show_kodi_menu
            ;;
        "gaming")
            if command -v car-edge-gaming-mode &>/dev/null; then
                car-edge-gaming-mode
            else
                kdialog --error "Gaming Mode switcher not found.\n\nPlease update to a newer build."
            fi
            ;;
        "desktop")
            if command -v car-edge-desktop-mode &>/dev/null; then
                car-edge-desktop-mode
            else
                kdialog --error "Desktop Mode switcher not found.\n\nPlease update to a newer build."
            fi
            ;;
        "back"|*)
            show_apps_menu
            ;;
    esac
}

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
                car-edge-install-apps
            else
                kdialog --error "App installer not available.\n\nPlease update to a newer build."
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
            show_kodi_menu
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
            local backup_dir="/mnt/storage/backups/configs"
            if [ ! -d "$backup_dir" ]; then
                kdialog --error "No backups found.\n\nBackup directory does not exist:\n$backup_dir\n\nCreate a backup first."
            else
                local backup_files
                backup_files=$(ls -1t "$backup_dir"/*.tar.gz 2>/dev/null || echo "")
                if [ -z "$backup_files" ]; then
                    kdialog --error "No backup files found in:\n$backup_dir\n\nCreate a backup first."
                else
                    # Build kdialog menu items from backup list
                    local menu_args=()
                    local idx=0
                    while IFS= read -r f; do
                        local label
                        label=$(basename "$f")
                        menu_args+=("$f" "$label")
                        (( idx++ )) || true
                        [ "$idx" -ge 10 ] && break
                    done <<< "$backup_files"

                    local selected_backup
                    selected_backup=$(kdialog --title "Restore Backup" \
                        --menu "Select a backup to restore:\n\n(Most recent first)" \
                        "${menu_args[@]}" "cancel" "← Cancel" 2>/dev/null || echo "cancel")

                    if [ "$selected_backup" != "cancel" ] && [ -f "$selected_backup" ]; then
                        if kdialog --warningyesno "Restore from:\n$(basename "$selected_backup")\n\nThis will overwrite current settings.\n\nContinue?"; then
                            konsole --hold -e bash -c "
echo 'Restoring from backup...'
echo 'File: $selected_backup'
echo ''
tar xzf '$selected_backup' -C / 2>&1
echo ''
if [ \$? -eq 0 ]; then
    echo '✅ Restore complete!'
else
    echo '❌ Restore encountered errors. Check output above.'
fi
read -p 'Press Enter to continue...'
" &
                        fi
                    fi
                fi
            fi
            show_backup_menu
            ;;
        "auto")
            local timer_file="$HOME/.config/systemd/user/car-edge-auto-backup.timer"
            local timer_status="disabled"
            if systemctl --user is-enabled car-edge-auto-backup.timer &>/dev/null; then
                timer_status="enabled"
            fi

            local auto_choice
            auto_choice=$(kdialog --title "Auto-Backup" \
                --menu "⚙️  Automatic Backup Configuration

Current status: $timer_status

Daily backups save your settings to:
/mnt/storage/backups/configs/" \
                "enable"  "✅ Enable daily automatic backups" \
                "disable" "❌ Disable automatic backups" \
                "back"    "← Back" 2>/dev/null || echo "back")

            case "$auto_choice" in
                "enable")
                    mkdir -p "$HOME/.config/systemd/user"
                    cat > "$HOME/.config/systemd/user/car-edge-auto-backup.service" << 'SVCEOF'
[Unit]
Description=Bazzite Car Edge automatic backup

[Service]
Type=oneshot
ExecStart=/usr/bin/car-edge-backup
SVCEOF
                    cat > "$HOME/.config/systemd/user/car-edge-auto-backup.timer" << 'TIMEREOF'
[Unit]
Description=Bazzite Car Edge daily backup timer

[Timer]
OnCalendar=daily *-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
TIMEREOF
                    systemctl --user daemon-reload 2>/dev/null || true
                    if systemctl --user enable --now car-edge-auto-backup.timer 2>/dev/null; then
                        kdialog --msgbox "✅ Daily backups enabled!\n\nBackups will run at 2:00 AM every day.\nSaved to: /mnt/storage/backups/configs/"
                    else
                        kdialog --error "Failed to enable backup timer.\n\nTry manually:\nsystemctl --user enable --now car-edge-auto-backup.timer"
                    fi
                    ;;
                "disable")
                    systemctl --user disable --now car-edge-auto-backup.timer 2>/dev/null || true
                    kdialog --msgbox "Automatic backups disabled.\n\nYou can still back up manually from this menu."
                    ;;
            esac
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
show_configuration_status() {
    local setup_done="No"
    local storage_mounted="No"
    local fstab_configured="No"
    local kodi_configured="No"
    local auto_updates="Disabled"
    local vscode_installed="No"
    local vscode_host_access="No"

    [ -f "$HOME/.config/car-edge-setup-complete" ] && setup_done="Yes"
    mountpoint -q /mnt/storage 2>/dev/null && storage_mounted="Yes"
    grep -Eq '^[^#].*\s/mnt/storage\s' /etc/fstab 2>/dev/null && fstab_configured="Yes"
    [ -f "$HOME/.var/app/tv.kodi.Kodi/data/userdata/sources.xml" ] && kodi_configured="Yes"

    if systemctl --user is-enabled car-edge-check-updates.timer >/dev/null 2>&1; then
        auto_updates="Enabled"
    fi

    if command -v flatpak >/dev/null 2>&1 && flatpak info com.visualstudio.code >/dev/null 2>&1; then
        vscode_installed="Yes"
        if flatpak info --show-permissions com.visualstudio.code 2>/dev/null | grep -q "filesystems=.*host"; then
            vscode_host_access="Yes"
        fi
    fi

    kdialog --title "Current Configuration Status" --msgbox "Current system configuration:

• Setup completed: $setup_done
• /mnt/storage mounted: $storage_mounted
• /etc/fstab has /mnt/storage: $fstab_configured
• Kodi sources configured: $kodi_configured
• Auto update checks: $auto_updates
• VS Code installed: $vscode_installed
• VS Code host filesystem access: $vscode_host_access

This panel does not re-run setup. It only reports current state."
}

fix_vscode_permissions() {
    if ! command -v flatpak >/dev/null 2>&1; then
        kdialog --error "Flatpak is not available on this system."
        return
    fi

    if ! flatpak info com.visualstudio.code >/dev/null 2>&1; then
        kdialog --error "VS Code Flatpak is not installed.\n\nInstall it first from Applications menu or with:\nflatpak install -y flathub com.visualstudio.code"
        return
    fi

    flatpak override --user com.visualstudio.code --filesystem=host
    flatpak override --user com.visualstudio.code --talk-name=org.freedesktop.Flatpak
    flatpak override --user com.visualstudio.code --socket=ssh-auth

    kdialog --msgbox "VS Code permissions updated.

Applied:
• --filesystem=host
• --talk-name=org.freedesktop.Flatpak
• --socket=ssh-auth

Close and reopen VS Code to apply changes.

Note: For host-level commands from inside the Flatpak terminal, use:
flatpak-spawn --host <command>"
}

show_settings_menu() {
    local choice=$(kdialog --title "Advanced Settings" \
                          --menu "⚙️  Advanced Configuration

For power users:" \
                          "status" "📊 View Current Configuration Status" \
                          "vscode" "💻 Fix VS Code Command Permissions" \
                          "power" "⚡ Power Management (TLP)" \
                          "maintenance" "🔧 System Maintenance" \
                          "logs" "📋 View System Logs" \
                          "services" "⚙️  Check Failed Services" \
                          "terminal" "💻 Open Terminal Here" \
                          "back" "← Back to Main Menu" 2>/dev/null || echo "back")
    
    case "$choice" in
        "status")
            show_configuration_status
            show_settings_menu
            ;;
        "vscode")
            if kdialog --yesno "Apply recommended VS Code Flatpak permissions now?\n\nThis helps with workspace access and command execution in sandboxed installs."; then
                fix_vscode_permissions
            fi
            show_settings_menu
            ;;
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
