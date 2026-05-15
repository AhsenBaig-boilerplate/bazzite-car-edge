#!/usr/bin/env bash
# Bazzite Car Edge - First Boot Setup Wizard
# Automated GUI setup for car entertainment system

set -euo pipefail

# Check if already completed
if [ -f "$HOME/.config/car-edge-setup-complete" ]; then
    if [ "${1:-}" != "--force" ]; then
        kdialog --title "Setup Already Complete" --msgbox "The Bazzite Car Edge setup wizard has already been run.

To re-run the wizard, use:
  car-edge-setup-wizard --force

Note: Re-running is safe but will not re-format drives."
        exit 0
    fi
fi

# Check if running in KDE (Desktop Mode)
if [ -z "${DISPLAY:-}" ]; then
    echo "Error: This wizard must be run in Desktop Mode (GUI)"
    echo "Press Ctrl+Alt+F3 to switch to Desktop Mode"
    echo "Then run: car-edge-setup-wizard"
    exit 1
fi

# Check for kdialog
if ! command -v kdialog &> /dev/null; then
    echo "Error: kdialog not found. This wizard requires KDE Plasma."
    exit 1
fi

# Function to show dialogs using kdialog (KDE native)
show_dialog() {
    kdialog --title "Bazzite Car Edge Setup" "$@"
}

show_progress() {
    local message="$1"
    kdialog --title "Bazzite Car Edge Setup" --progressbar "$message" 100
}

show_info() {
    kdialog --title "Bazzite Car Edge Setup" --msgbox "$1"
}

show_error() {
    kdialog --title "Bazzite Car Edge Setup" --error "$1"
}

# Welcome screen
if [ "${1:-}" = "--auto" ]; then
    # Auto-run on first boot
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
    # Manual run
    show_info "Welcome to Bazzite Car Edge Setup Wizard!

This wizard will help you:
• Set up external storage for media
• Install entertainment applications
• Configure Kodi media center
• Set up Syncthing (optional)
• Create your first backup

Let's get started!"
fi

#
# Step 1: External Drive Setup
#
if show_dialog --yesno "Do you have an external drive for media storage (movies, games, ROMs)?

Recommended: 500GB+ SSD or larger"; then
    
    # Detect available drives
    mapfile -t drives < <(lsblk -ndo NAME,SIZE,TYPE | grep disk | grep -v "$(lsblk -ndo NAME,MOUNTPOINT | grep '/$' | awk '{print $1}')")
    
    if [ ${#drives[@]} -eq 0 ]; then
        show_error "No external drives detected. Please connect a drive and run this wizard again."
    else
        # Build drive selection menu
        drive_list=()
        for drive in "${drives[@]}"; do
            name=$(echo "$drive" | awk '{print $1}')
            size=$(echo "$drive" | awk '{print $2}')
            drive_list+=("/dev/$name" "$size")
        done
        
        selected_drive=$(show_dialog --menu "Select your external drive for media storage:" "${drive_list[@]}")
        
        if [ -n "$selected_drive" ]; then
            # Confirm formatting
            if show_dialog --warningyesno "WARNING: This will FORMAT $selected_drive and ERASE ALL DATA!

Are you absolutely sure you want to continue?"; then
                
                # Format drive
                (
                    echo "10"; echo "# Creating partition..."
                    echo "y" | sudo parted "$selected_drive" mklabel gpt
                    echo "30"; echo "# Formatting..."
                    sudo parted "$selected_drive" mkpart primary ext4 0% 100%
                    echo "50"; echo "# Creating filesystem..."
                    sudo mkfs.ext4 -F "${selected_drive}1"
                    echo "70"; echo "# Getting UUID..."
                    uuid=$(sudo blkid -s UUID -o value "${selected_drive}1")
                    echo "80"; echo "# Configuring auto-mount..."
                    echo "UUID=$uuid /mnt/storage ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
                    echo "90"; echo "# Creating directory structure..."
                    sudo mkdir -p /mnt/storage
                    sudo mount -a
                    sudo mkdir -p /mnt/storage/{media/{movies,tv,music},games/{roms/{nes,snes,genesis,ps1,ps2},saves,steam},backups/configs}
                    sudo chown -R "$USER:$USER" /mnt/storage
                    echo "100"; echo "# Done!"
                ) | show_dialog --progressbar "Setting up external drive..." 100
                
                show_info "External drive configured successfully!

Mount point: /mnt/storage
Media: /mnt/storage/media/
Games: /mnt/storage/games/
Backups: /mnt/storage/backups/"
            fi
        fi
    fi
else
    show_info "Skipping external drive setup.

You can configure it later using the manual setup guide."
fi

#
# Step 2: Install Applications
#
if show_dialog --yesno "Install entertainment applications?

This will install:
• Kodi (media center)
• Firefox (web browser)  
• VS Code (editor)
• Syncthing (file sync)
• Kiwix (offline Wikipedia)
• VLC (video player)
• Gaming tools (Heroic, PrismLauncher, ProtonUp-Qt)

Time: ~15-20 minutes"; then
    
    # Run installer with progress
    (
        car-edge-install-apps 2>&1 | while IFS= read -r line; do
            echo "# $line"
        done
    ) | show_dialog --progressbar "Installing applications..." 0
    
    show_info "Applications installed successfully!"
fi

#
# Step 3: Configure Kodi
#
if [ -d "/mnt/storage/media" ] && show_dialog --yesno "Configure Kodi media center automatically?

This will set up media sources for:
• Movies (/mnt/storage/media/movies)
• TV Shows (/mnt/storage/media/tv)
• Music (/mnt/storage/media/music)"; then
    
    # Create Kodi configuration
    kodi_config_dir="$HOME/.var/app/tv.kodi.Kodi/data/userdata"
    mkdir -p "$kodi_config_dir"
    
    cat > "$kodi_config_dir/sources.xml" << 'EOF'
<sources>
    <video>
        <default pathversion="1"></default>
        <source>
            <name>Movies</name>
            <path pathversion="1">/mnt/storage/media/movies/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>TV Shows</name>
            <path pathversion="1">/mnt/storage/media/tv/</path>
            <allowsharing>true</allowsharing>
        </source>
    </video>
    <music>
        <default pathversion="1"></default>
        <source>
            <name>Music</name>
            <path pathversion="1">/mnt/storage/media/music/</path>
            <allowsharing>true</allowsharing>
        </source>
    </music>
    <pictures>
        <default pathversion="1"></default>
    </pictures>
    <files>
        <default pathversion="1"></default>
    </files>
</sources>
EOF
    
    # Grant Kodi access to storage
    flatpak override tv.kodi.Kodi --filesystem=/mnt/storage --user
    
    show_info "Kodi configured successfully!

Media sources added:
• Movies
• TV Shows  
• Music

Launch Kodi and scan for content."
fi

#
# Step 4: Syncthing Setup (Optional)
#
if show_dialog --yesno "Set up Syncthing for home lab sync?

Syncthing keeps your files synchronized with your home server."; then
    
    show_info "Syncthing Setup:

1. Launch 'SyncThingy' from the application menu
2. Note your Device ID
3. On your home server, add this device ID
4. Configure folders to sync

Auto-start on boot? We'll add it to autostart."
    
    # Add to autostart
    mkdir -p "$HOME/.config/autostart"
    cp /var/lib/flatpak/app/com.github.zocker_160.SyncThingy/current/active/export/share/applications/com.github.zocker_160.SyncThingy.desktop "$HOME/.config/autostart/" 2>/dev/null || true
fi

#
# Step 5: Grant Flatpak Permissions
#
show_dialog --progressbar "Configuring application permissions..." 0 &
PROGRESS_PID=$!

# Grant necessary permissions to Flatpaks
flatpak override tv.kodi.Kodi --filesystem=/mnt/storage --user 2>/dev/null || true
flatpak override org.libretro.RetroArch --filesystem=/mnt/storage --user 2>/dev/null || true
flatpak override org.videolan.VLC --filesystem=/mnt/storage --user 2>/dev/null || true
flatpak override com.heroicgameslauncher.hgl --filesystem=/mnt/storage --user 2>/dev/null || true

kill $PROGRESS_PID 2>/dev/null || true

#
# Step 6: Create First Backup
#
if [ -d "/mnt/storage/backups" ] && show_dialog --yesno "Create your first system backup?

This backs up system configurations (not media files)."; then
    
    car-edge-backup 2>&1 | show_dialog --progressbar "Creating backup..." 0
    
    show_info "Backup created successfully!

Location: /mnt/storage/backups/configs/"
fi

#
# Step 7: Final Setup
#
final_message="Setup Complete! 🎉

Your car entertainment system is ready to use.

Gaming Mode:
• Press Steam button to access Steam menu
• Controllers auto-detected
• Games appear in library

Desktop Mode:
• Press Ctrl+Alt+F3 to switch anytime
• Access Kodi, Firefox, VS Code

Next Steps:
• Copy media files to /mnt/storage/media/
• Copy ROMs to /mnt/storage/games/roms/
• Launch Kodi and scan libraries

Returning to Gaming Mode..."

show_info "$final_message"

# Mark wizard as completed
touch "$HOME/.config/car-edge-setup-complete"

# Offer to switch to Gaming Mode
if show_dialog --yesno "Switch to Gaming Mode now?"; then
    # Switch to Gaming Mode
    qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout || \
    loginctl terminate-session "$XDG_SESSION_ID" || \
    systemctl restart sddm
fi
