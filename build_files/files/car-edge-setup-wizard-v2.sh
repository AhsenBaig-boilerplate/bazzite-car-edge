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
    local description="${2:-Command}"  # Default to "Command" if not provided
    
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
# Step 1: Storage Drive Setup (External or Internal Secondary)
#
log "=== Step 1: Storage Drive Setup ==="
if show_dialog --yesno "Do you have a drive for media storage (movies, games, ROMs)?

This can be:
• External USB drive (SSD/HDD)
• Internal secondary SSD
• Any drive NOT used for the OS

Recommended: 500GB+ or larger"; then
    
    log "User wants to set up storage drive"
    
    # Get root partition and its parent disk - MULTIPLE METHODS
    # Handle both traditional mounts and composefs (rpm-ostree)
    root_partition=$(df / | tail -1 | awk '{print $1}')
    root_partition_name=$(basename "$root_partition")
    
    log "Step 1: Root partition from df: $root_partition"
    log "Step 2: Root partition name: $root_partition_name"
    
    # Check if using composefs (rpm-ostree systems)
    if [ "$root_partition_name" = "composefs" ] || [ "$root_partition_name" = "overlay" ]; then
        log "Step 3a: Detected composefs/overlay, using /sysroot method"
        # On rpm-ostree systems, /sysroot is the real root
        sysroot_device=$(findmnt -n -o SOURCE /sysroot 2>/dev/null | cut -d'[' -f1)
        if [ -n "$sysroot_device" ]; then
            root_partition="$sysroot_device"
            root_partition_name=$(basename "$root_partition")
            log "Step 3b: Found real device via /sysroot: $root_partition"
        else
            # Fallback: use /boot
            log "Step 3c: /sysroot not found, trying /boot"
            boot_device=$(df /boot 2>/dev/null | tail -1 | awk '{print $1}')
            if [ -n "$boot_device" ] && [ "$boot_device" != "none" ]; then
                root_partition="$boot_device"
                root_partition_name=$(basename "$root_partition")
                log "Step 3d: Found device via /boot: $root_partition"
            fi
        fi
    fi
    
    # Get the parent disk of the root partition - Method 1: PKNAME
    root_device=$(lsblk -no PKNAME "$root_partition" 2>/dev/null | head -1 || echo "")
    log "Step 4a: PKNAME result: '$root_device'"
    
    # Fallback Method 2: Strip partition number/letter
    if [ -z "$root_device" ]; then
        # Handle nvme (nvme0n1p3 -> nvme0n1), sd (sda1 -> sda), mmcblk (mmcblk0p1 -> mmcblk0)
        root_device=$(echo "$root_partition_name" | sed -E 's/(nvme[0-9]+n[0-9]+)p[0-9]+/\1/' | sed -E 's/(mmcblk[0-9]+)p[0-9]+/\1/' | sed 's/[0-9]*$//')
        log "Step 4b: Fallback stripping result: '$root_device'"
    fi
    
    # Fallback Method 3: Use findmnt
    if [ -z "$root_device" ]; then
        root_device=$(findmnt -no SOURCE / | xargs lsblk -no PKNAME 2>/dev/null | head -1 || echo "")
        log "Step 4c: findmnt fallback result: '$root_device'"
    fi
    
    # Normalize root_device (remove any whitespace)
    root_device=$(echo "$root_device" | tr -d '[:space:]')
    
    log "═══════════════════════════════════════════"
    log "FINAL OS DRIVE DETECTION:"
    log "  Root partition: $root_partition"
    log "  Root partition name: $root_partition_name"
    log "  Root device (OS disk): '$root_device'"
    log "═══════════════════════════════════════════"
    
    # CRITICAL CHECK: Ensure root_device is not empty
    if [ -z "$root_device" ]; then
        log "CRITICAL ERROR: Could not determine root device!"
        show_error "Cannot determine OS drive!

Unable to identify which drive contains the operating system.
This is required for safety.

Cannot continue with drive setup.

Check logs: $LOG_FILE"
        # Skip to next section
        log "Aborting drive setup due to safety concerns"
    else
        log "OS drive successfully identified: /dev/$root_device"
    
    # Get OS drive details for display
    os_drive_size=""
    os_drive_model=""
    os_drive_info=""
    if [ -n "$root_device" ]; then
        os_drive_size=$(lsblk -ndo SIZE "/dev/$root_device" 2>/dev/null || echo "unknown")
        os_drive_model=$(lsblk -ndo MODEL "/dev/$root_device" 2>/dev/null | sed 's/^[ \t]*//;s/[ \t]*$//' || echo "")
        
        # Get partition info for OS drive
        os_partitions=$(lsblk -no NAME,SIZE,FSTYPE,LABEL "/dev/$root_device" 2>/dev/null | grep -v "^$root_device " || echo "")
        os_partition_count=$(echo "$os_partitions" | grep -c . || echo "0")
        
        os_drive_info="🔒 YOUR OS DRIVE (Protected - Not Selectable):
   Device: /dev/$root_device
   Size: $os_drive_size"
        
        if [ -n "$os_drive_model" ]; then
            os_drive_info="$os_drive_info
   Model: $os_drive_model"
        fi
        
        os_drive_info="$os_drive_info
   Contains: Your operating system and boot files
   Partitions: $os_partition_count partition(s)"
        
        if [ -n "$os_partitions" ]; then
            os_drive_info="$os_drive_info

   Partition Details:"
            while IFS= read -r part_line; do
                part_name=$(echo "$part_line" | awk '{print $1}')
                part_size=$(echo "$part_line" | awk '{print $2}')
                part_fstype=$(echo "$part_line" | awk '{print $3}')
                part_label=$(echo "$part_line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
                
                if [ "$part_name" = "$root_partition_name" ]; then
                    os_drive_info="$os_drive_info
   • $part_name ($part_size, $part_fstype) ← Root filesystem"
                else
                    os_drive_info="$os_drive_info
   • $part_name ($part_size, $part_fstype)"
                fi
                
                if [ -n "$part_label" ]; then
                    os_drive_info="$os_drive_info [Label: \"$part_label\"]"
                fi
            done <<< "$os_partitions"
        fi
        
        log "OS drive info collected: $os_drive_info"
    fi
    
    # Detect all physical disk devices (exclude loop, zram, rom, etc.)
    all_drives=$(lsblk -ndo NAME,SIZE,TYPE,MODEL 2>/dev/null | grep -E '\sdisk\s' | grep -vE '^(loop|zram|sr)' || echo "")
    
    if [ -z "$all_drives" ]; then
        log "ERROR: Failed to detect any physical drives"
        show_error "Failed to detect storage drives.

Possible causes:
• No physical drives detected
• Permission issue
• lsblk command failed

You can skip this step and set up storage manually later.

Check logs: $LOG_FILE"
    else
        log "All physical disk devices detected:"
        log "$all_drives"
        
        # Build simple drive selection menu (single line per drive)
        drive_list=()
        drive_details=()  # Store detailed info for confirmation dialogs
        
        while IFS= read -r line; do
            name=$(echo "$line" | awk '{print $1}')
            size=$(echo "$line" | awk '{print $2}')
            type=$(echo "$line" | awk '{print $3}')
            model=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//')
            
            # Normalize name (remove whitespace)
            name=$(echo "$name" | tr -d '[:space:]')
            
            log "Processing drive: '$name' (size: $size, type: $type, model: $model)"
            log "Comparing '$name' with root_device '$root_device'"
            
            # Check if this is the OS disk (multiple methods for safety)
            is_os_drive=0
            
            # Method 1: Direct name comparison
            if [ "$name" = "$root_device" ]; then
                log "MATCH: Direct name comparison - $name == $root_device"
                is_os_drive=1
            fi
            
            # Method 2: Check if root partition is on this disk
            if lsblk -no NAME "/dev/$name" 2>/dev/null | grep -q "^${root_partition_name}$"; then
                log "MATCH: Contains root partition $root_partition_name"
                is_os_drive=1
            fi
            
            # Method 3: Check if any partition on this disk is mounted at /
            if lsblk -no MOUNTPOINT "/dev/$name" 2>/dev/null | grep -q "^/$"; then
                log "MATCH: Has partition mounted at /"
                is_os_drive=1
            fi
            
            # Skip OS drive
            if [ $is_os_drive -eq 1 ]; then
                log "✗ SKIPPING OS DRIVE: $name (contains operating system)"
                continue
            fi
            
            log "✓ SAFE: $name is NOT the OS drive, adding to menu"
            
            # Get ALL partitions on this drive with full details
            partitions=$(lsblk -no NAME,SIZE,FSTYPE,LABEL "/dev/$name" 2>/dev/null | grep -v "^$name " || echo "")
            partition_count=0
            if [ -n "$partitions" ]; then
                partition_count=$(echo "$partitions" | wc -l)
            fi
            
            log "   Found $partition_count partition(s)"
            if [ -n "$partitions" ]; then
                log "   Partitions: $partitions"
            fi
            
            # Build user-friendly description - compact but informative
            simple_desc="$size"
            
            # Add model if exists
            if [ -n "$model" ] && [ "$model" != "" ]; then
                simple_desc="$simple_desc | $model"
            fi
            
            # Add partition summary
            if [ "$partition_count" -gt 0 ]; then
                # Build compact partition list
                part_summary=""
                part_num=0
                while IFS= read -r part_line; do
                    [ -z "$part_line" ] && continue
                    part_num=$((part_num + 1))
                    
                    part_size=$(echo "$part_line" | awk '{print $2}')
                    part_fstype=$(echo "$part_line" | awk '{print $3}')
                    part_label=$(echo "$part_line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
                    
                    if [ $part_num -gt 1 ]; then
                        part_summary="${part_summary}, "
                    fi
                    
                    part_summary="${part_summary}${part_size}"
                    
                    if [ -n "$part_fstype" ] && [ "$part_fstype" != "" ]; then
                        part_summary="${part_summary} ${part_fstype}"
                    fi
                    
                    if [ -n "$part_label" ] && [ "$part_label" != "" ]; then
                        part_summary="${part_summary} [${part_label}]"
                    fi
                done <<< "$partitions"
                
                simple_desc="$simple_desc | Has data: $part_summary"
            else
                simple_desc="$simple_desc | Empty - Ready to use"
            fi
            
            # Build detailed info for confirmation dialog
            detail_info="Drive: /dev/$name
Size: $size"
            
            if [ -n "$model" ] && [ "$model" != "" ]; then
                detail_info="$detail_info
Model: $model"
            fi
            
            if [ "$partition_count" -eq "0" ]; then
                detail_info="$detail_info
Status: Empty (no partitions)
Ready to format and use"
            else
                detail_info="$detail_info
Current partitions: $partition_count

Partition details:"
                
                # Show all partitions with their details
                while IFS= read -r part_line; do
                    [ -z "$part_line" ] && continue
                    
                    part_name=$(echo "$part_line" | awk '{print $1}')
                    part_size=$(echo "$part_line" | awk '{print $2}')
                    part_fstype=$(echo "$part_line" | awk '{print $3}')
                    part_label=$(echo "$part_line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
                    
                    detail_info="$detail_info
• $part_name: $part_size"
                    
                    if [ -n "$part_fstype" ] && [ "$part_fstype" != "" ]; then
                        detail_info="$detail_info ($part_fstype)"
                    fi
                    
                    if [ -n "$part_label" ] && [ "$part_label" != "" ]; then
                        detail_info="$detail_info
  Label: \"$part_label\""
                    fi
                done <<< "$partitions"
                
                detail_info="$detail_info

⚠️  ALL EXISTING DATA WILL BE ERASED!"
            fi
            
            # Add to menu list - FINAL SAFETY CHECK
            # Absolutely verify this is NOT the OS drive before adding
            if [ "$name" != "$root_device" ] && [ $is_os_drive -eq 0 ]; then
                drive_list+=("/dev/$name" "$simple_desc")
                drive_details+=("/dev/$name||$detail_info")
                log "✅ ADDED TO MENU: /dev/$name"
                log "   Description: $simple_desc"
            else
                log "❌ BLOCKED: /dev/$name - Failed final safety check (is OS drive)"
                if [ "$name" = "$root_device" ]; then
                    log "   Reason: name matches root_device"
                fi
                if [ $is_os_drive -eq 1 ]; then
                    log "   Reason: is_os_drive flag is set"
                fi
            fi
        done <<< "$all_drives"
        
        # ═══ ABSOLUTE FINAL SAFETY FILTER ═══
        # Remove OS drive from drive_list even if it somehow got added
        log "═══ FINAL SAFETY FILTER ═══"
        log "Scanning drive_list for OS drive to remove..."
        
        filtered_drive_list=()
        filtered_drive_details=()
        
        for ((i=0; i<${#drive_list[@]}; i+=2)); do
            device="${drive_list[i]}"
            desc="${drive_list[i+1]}"
            device_name=$(basename "$device")
            
            # Check if this is the OS drive
            if [ "$device_name" = "$root_device" ]; then
                log "⚠️  REMOVING OS DRIVE FROM MENU: $device"
                log "   This drive was incorrectly added and is now being removed!"
                continue
            fi
            
            # Check if device contains root partition
            if lsblk -no NAME "$device" 2>/dev/null | grep -q "^${root_partition_name}$"; then
                log "⚠️  REMOVING DRIVE WITH ROOT PARTITION: $device"
                continue
            fi
            
            # Safe to keep
            filtered_drive_list+=("$device" "$desc")
            
            # Find matching details
            for detail in "${drive_details[@]}"; do
                detail_device=$(echo "$detail" | cut -d'|' -f1)
                if [ "$detail_device" = "$device" ]; then
                    filtered_drive_details+=("$detail")
                    break
                fi
            done
        done
        
        # Replace arrays with filtered versions
        drive_list=("${filtered_drive_list[@]}")
        drive_details=("${filtered_drive_details[@]}")
        
        log "After filtering: ${#drive_list[@]} items remain"
        log "═══ END FINAL SAFETY FILTER ═══"
        
        log "════════════════════════════════════════════════"
        log "MENU BUILD COMPLETE"
        log "OS Drive (filtered): /dev/$root_device"
        log "Total items in drive_list array: ${#drive_list[@]}"
        log "Number of drives (pairs): $((${#drive_list[@]} / 2))"
        
        if [ ${#drive_list[@]} -gt 0 ]; then
            log "Menu items (device -> description):"
            for ((i=0; i<${#drive_list[@]}; i+=2)); do
                device="${drive_list[i]}"
                desc="${drive_list[i+1]}"
                log "  [$((i/2 + 1))] $device"
                log "      -> $desc"
                
                # Final verification
                device_name=$(basename "$device")
                if [ "$device_name" = "$root_device" ]; then
                    log "  ⚠️  WARNING: OS DRIVE FOUND IN MENU! This should not happen!"
                fi
            done
        else
            log "drive_list is EMPTY - no selectable drives"
        fi
        log "════════════════════════════════════════════════"
        
        if [ ${#drive_list[@]} -eq 0 ]; then
            log "No available drives after filtering OS disk"
            
            # Build detailed OS drive summary
            os_only_summary="🔒 /dev/$root_device | $os_drive_size"
            if [ -n "$os_drive_model" ]; then
                os_only_summary="$os_only_summary | $os_drive_model"
            fi
            os_only_summary="$os_only_summary

This drive contains your operating system and CANNOT be used for media storage.
It has been PROTECTED from selection."
            
            show_warning "No Additional Drives Detected

Your only drive is the OS drive:

$os_only_summary

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

To add media storage:
• Connect external USB drive (recommended: 500GB+)
• Install secondary internal SSD/HDD  
• Skip and configure later

Skipping drive setup..."
        else
            log "Available drives for media storage: $((${#drive_list[@]} / 2)) drive(s)"
            
            # ═══ ABSOLUTE FINAL CHECK BEFORE MENU ═══
            log "═══ PRE-MENU OS DRIVE VERIFICATION ═══"
            log "Performing final check for OS drive in menu..."
            log "OS drive to exclude: /dev/$root_device"
            
            # Final scan - remove OS drive right before showing menu
            final_clean_list=()
            final_clean_details=()
            
            for ((i=0; i<${#drive_list[@]}; i+=2)); do
                device="${drive_list[i]}"
                desc="${drive_list[i+1]}"
                device_name=$(basename "$device")
                
                # Multiple checks
                is_os=0
                
                # Check 1: Name match
                if [ "$device_name" = "$root_device" ]; then
                    log "⛔ BLOCKING: $device matches OS drive name"
                    is_os=1
                fi
                
                # Check 2: Contains root partition
                if [ $is_os -eq 0 ]; then
                    if lsblk -no NAME "$device" 2>/dev/null | grep -q "^${root_partition_name}$"; then
                        log "⛔ BLOCKING: $device contains root partition"
                        is_os=1
                    fi
                fi
                
                # Check 3: Has / mount
                if [ $is_os -eq 0 ]; then
                    if lsblk -no MOUNTPOINT "$device" 2>/dev/null | grep -q "^/$"; then
                        log "⛔ BLOCKING: $device has partition mounted at /"
                        is_os=1
                    fi
                fi
                
                if [ $is_os -eq 1 ]; then
                    log "🚫 EXCLUDED FROM MENU: $device (OS drive)"
                    continue
                fi
                
                log "✅ CLEARED FOR MENU: $device"
                final_clean_list+=("$device" "$desc")
                
                # Find matching details
                for detail in "${drive_details[@]}"; do
                    detail_device=$(echo "$detail" | cut -d'|' -f1)
                    if [ "$detail_device" = "$device" ]; then
                        final_clean_details+=("$detail")
                        break
                    fi
                done
            done
            
            # Use the final clean list
            drive_list=("${final_clean_list[@]}")
            drive_details=("${final_clean_details[@]}")
            
            log "Final menu will have: $((${#drive_list[@]} / 2)) drive(s)"
            log "═══ END PRE-MENU VERIFICATION ═══"
            
            # If no drives after final cleaning, show error
            if [ ${#drive_list[@]} -eq 0 ]; then
                log "ERROR: No drives available after final cleaning!"
                show_warning "No Selectable Drives

After safety filtering, no drives are available for selection.

Only drive detected: /dev/$root_device (OS drive - protected)

To add media storage:
• Connect external USB drive
• Install secondary SSD/HDD

Skipping drive setup..."
            else
            
            # Build simple OS drive summary
            os_summary="/dev/$root_device - $os_drive_size"
            if [ -n "$os_drive_model" ]; then
                os_summary="$os_summary - $os_drive_model"
            fi
            os_summary="$os_summary - Contains Operating System (PROTECTED)"
            
            if selected_drive=$(show_dialog --menu "═══ SELECT MEDIA STORAGE DRIVE ═══

⚠️  WARNING: Selected drive will be ERASED! ⚠️

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 OS DRIVE (Cannot be selected):
$os_summary

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💾 AVAILABLE MEDIA STORAGE DRIVES:
(Choose one for movies, music, games, ROMs)
" "${drive_list[@]}"); then
                log "Selected drive: $selected_drive"
                
                # CRITICAL SAFETY CHECK: Verify selected drive is NOT the OS drive
                selected_device=$(basename "$selected_drive")
                log "SAFETY CHECK: Verifying selected device '$selected_device' is not OS drive '$root_device'"
                
                # Check if selected drive is the OS drive
                if [ "$selected_device" = "$root_device" ]; then
                    log "CRITICAL: User somehow selected OS drive! Blocking..."
                    show_error "CRITICAL SAFETY ERROR

You cannot format the OS drive!

Selected: $selected_drive
OS Drive: /dev/$root_device

This drive contains your operating system and cannot be formatted.

This should not have appeared in the menu. Please report this issue.

Check logs: $LOG_FILE"
                    continue
                fi
                
                # Check if selected drive contains root partition
                if lsblk -no MOUNTPOINT "$selected_drive" 2>/dev/null | grep -q "^/$"; then
                    log "CRITICAL: Selected drive contains root filesystem! Blocking..."
                    show_error "CRITICAL SAFETY ERROR

This drive contains your root filesystem!

Selected: $selected_drive

This drive is mounted at / and CANNOT be formatted.

Check logs: $LOG_FILE"
                    continue
                fi
                
                log "SAFETY CHECK PASSED: $selected_device is safe to format"
                
                # Find detailed info for this drive
                selected_details=""
                for detail in "${drive_details[@]}"; do
                    drive_path=$(echo "$detail" | cut -d'|' -f1)
                    if [ "$drive_path" = "$selected_drive" ]; then
                        selected_details=$(echo "$detail" | cut -d'|' -f3-)
                        break
                    fi
                done
                
                log "Selected drive details: $selected_details"
                
                # Show detailed confirmation with all partition info
                if show_dialog --warningyesno "⚠️  CONFIRM: FORMAT AND ERASE DRIVE ⚠️

You selected: $selected_drive

$selected_details

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

THIS WILL:
✗ Delete ALL existing partitions
✗ Erase ALL data on this drive
✓ Create new partition table (GPT)
✓ Format as ext4 for media storage
✓ Auto-mount at /mnt/storage

⚠️  THIS ACTION CANNOT BE UNDONE! ⚠️

Are you ABSOLUTELY SURE?"; then
                
                    log "User confirmed format of $selected_drive"
                    
                    # ═══ UNMOUNT ALL PARTITIONS ON SELECTED DRIVE ═══
                    log "═══ UNMOUNTING PARTITIONS ═══"
                    log "Checking for mounted partitions on $selected_drive..."
                    
                    # Get all partitions on this drive
                    mounted_partitions=$(lsblk -no NAME,MOUNTPOINT "$selected_drive" 2>/dev/null | grep -v "^$(basename $selected_drive) " | awk '{if($2!="") print "/dev/"$1}' || echo "")
                    
                    if [ -n "$mounted_partitions" ]; then
                        log "Found mounted partitions:"
                        log "$mounted_partitions"
                        
                        while IFS= read -r partition; do
                            [ -z "$partition" ] && continue
                            log "Unmounting: $partition"
                            if sudo umount "$partition" 2>&1 | tee -a "$LOG_FILE"; then
                                log "✓ Successfully unmounted $partition"
                            else
                                log "⚠️  Failed to unmount $partition, trying force unmount..."
                                if sudo umount -f "$partition" 2>&1 | tee -a "$LOG_FILE"; then
                                    log "✓ Force unmounted $partition"
                                else
                                    log "✗ Could not unmount $partition"
                                fi
                            fi
                        done <<< "$mounted_partitions"
                        
                        # Wait a moment for unmounts to complete
                        sleep 1
                    else
                        log "No mounted partitions found"
                    fi
                    
                    # Remove from fstab if present
                    log "Removing any fstab entries for $selected_drive..."
                    sudo sed -i "\|${selected_drive}|d" /etc/fstab 2>&1 | tee -a "$LOG_FILE"
                    
                    log "═══ END UNMOUNTING ═══"
                    
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
                    "; then
                        log "Drive format succeeded"
                        show_info "Storage drive configured successfully!

Mount point: /mnt/storage
Media: /mnt/storage/media/
Games: /mnt/storage/games/
Backups: /mnt/storage/backups/

Your drive will auto-mount on every boot."
                    else
                        log "Drive setup failed or was cancelled by user"
                    fi
                else
                    log "User cancelled drive format"
                fi
            else
                log "User cancelled drive selection"
            fi
            fi  # Close the drive_list empty check
        fi
    fi
    fi  # Close the root_device check
else
    log "User skipped storage drive setup"
    show_info "Skipping storage drive setup.

You can configure it later using the manual setup guide."
fi

#
# Step 2: Network Storage (Optional)
#
log "=== Step 2: Network Storage Setup ==="
if [ "$NETWORK_AVAILABLE" = "yes" ]; then
    if show_dialog --yesno "Do you want to set up network storage?

This allows accessing media from your home server (NAS):
• SMB/CIFS (Windows shares, most NAS devices)
• NFS (Linux/Unix shares)

Benefits:
• Stream media without copying to external drive
• Access large ROM/game libraries
• Auto-connects when on home WiFi

You can skip this and set up later with:
  car-edge-network-mounts configure"; then
        
        log "User wants to configure network storage"
        
        # Network storage configuration
        SHARE_TYPE=""
        if show_dialog --menu "Select network storage type:" \
            "SMB/CIFS" "Windows shares, most NAS devices (Synology, QNAP, etc.)" \
            "NFS" "Linux/Unix shares"; then
            SHARE_TYPE=$(show_dialog --menu "Select network storage type:" \
                "SMB/CIFS" "Windows shares, most NAS devices" \
                "NFS" "Linux/Unix shares" 2>&1)
        fi
        
        if [ -n "$SHARE_TYPE" ]; then
            SERVER=""
            SHARE_PATH=""
            USERNAME=""
            PASSWORD=""
            
            # Get server details
            SERVER=$(show_dialog --inputbox "Enter server IP or hostname:

Example: 192.168.1.100 or nas.local" "" 2>&1 || echo "")
            
            if [ -n "$SERVER" ]; then
                SHARE_PATH=$(show_dialog --inputbox "Enter share path:

Examples:
• SMB: media or shared/media
• NFS: /export/media or /volume1/media" "" 2>&1 || echo "")
                
                if [ -n "$SHARE_PATH" ]; then
                    # Get credentials for SMB
                    if [ "$SHARE_TYPE" = "SMB/CIFS" ]; then
                        USERNAME=$(show_dialog --inputbox "Enter username:

(Leave empty for guest access)" "" 2>&1 || echo "")
                        
                        if [ -n "$USERNAME" ]; then
                            PASSWORD=$(show_dialog --password "Enter password for $USERNAME:" 2>&1 || echo "")
                        fi
                    fi
                    
                    # Save configuration
                    CONFIG_DIR="$HOME/.config/car-edge"
                    mkdir -p "$CONFIG_DIR"
                    
                    # Remove leading slash for SMB, ensure for NFS
                    if [ "$SHARE_TYPE" = "SMB/CIFS" ]; then
                        SHARE_PATH="${SHARE_PATH#/}"
                    else
                        SHARE_PATH="/${SHARE_PATH#/}"
                    fi
                    
                    # Create config file
                    cat > "$CONFIG_DIR/network-mounts.conf" << EOF
# Bazzite Car Edge Network Mount Configuration
SHARE_TYPE="$(echo "$SHARE_TYPE" | tr '[:upper:]' '[:lower:]' | cut -d'/' -f1)"
SERVER="$SERVER"
SHARE_PATH="$SHARE_PATH"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
MOUNT_POINT="/mnt/network-storage"
EOF
                    chmod 600 "$CONFIG_DIR/network-mounts.conf"
                    log "Network storage config saved"
                    
                    # Test and mount
                    if show_dialog --yesno "Configuration saved!

Test the connection and mount now?

Note: Make sure your server is reachable on the network."; then
                        log "Testing network mount..."
                        
                        # Create terminal command to run the mount setup
                        # Using konsole to show progress
                        if retry_command "konsole --hold -e bash -c 'car-edge-network-mounts enable; echo; echo Press Enter to continue...; read'" "Network storage mount"; then
                            show_info "Network storage configured!

Mounted at: /mnt/network-storage

The mount will auto-connect when on your home network."
                        else
                            show_warning "Could not mount network storage now.

Configuration is saved. Try mounting later with:
  car-edge-network-mounts enable

Check if:
• Server is powered on
• You're on the correct network
• Credentials are correct"
                        fi
                    fi
                fi
            fi
        fi
    else
        log "User skipped network storage"
    fi
else
    log "Network unavailable, skipping network storage setup"
fi

#
# Step 3: Install Applications
#
log "=== Step 3: Install Applications ==="
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
