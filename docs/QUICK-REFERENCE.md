# Quick Reference - Bazzite Car Edge

## 🚀 Essential Commands

### Application Management
```bash
# Install all applications (run once after first boot)
car-edge-install-apps

# Update all Flatpak applications
flatpak update -y

# List installed Flatpaks
flatpak list --app
```

### Backup & Restore
```bash
# Create backup of configurations
car-edge-backup

# Manual backup location
ls /mnt/storage/backups/configs/

# Restore from backup (example)
tar -xzf /mnt/storage/backups/configs/bazzite-car-edge-backup-YYYYMMDD-HHMMSS.tar.gz -C /
```

### System Updates
```bash
# Check for updates (downloads in background if available)
car-edge-check-updates

# Switch to specific version (interactive GUI)
car-edge-switch-version

# Apply staged update (reboots system)
car-edge-apply-update

# View update status
rpm-ostree status

# Manual update commands
rpm-ostree upgrade          # Download and stage
systemctl reboot           # Apply staged update

# Rollback to previous version
rpm-ostree rollback
systemctl reboot
```

### Storage Management
```bash
# Check mounted drives
df -h

# Mount external storage
sudo mount -a

# Check fstab configuration
cat /etc/fstab

# View storage structure
tree -L 2 /mnt/storage
```

### Power Management
```bash
# View TLP status
sudo tlp-stat --battery

# Check current power mode
cat /sys/firmware/acpi/platform_profile

# Manual power profile (on AC)
sudo tlp start
```

---

## 🎮 Gaming Mode Shortcuts

- **Steam Button** - Open Steam menu
- **Steam + A** - Take screenshot
- **Steam + X** - Show keyboard
- **Steam + B** - Force close game
- **Ctrl + Alt + F3** - Switch to Desktop Mode

---

## 📺 Application Locations

### Installed Flatpaks
- **Kodi:** `flatpak run tv.kodi.Kodi`
- **Firefox:** `flatpak run org.mozilla.firefox`
- **VS Code:** `flatpak run com.visualstudio.code`
- **Syncthing:** `flatpak run com.github.zocker_160.SyncThingy`
- **Kiwix:** `flatpak run org.kiwix.desktop`
- **VLC:** `flatpak run org.videolan.VLC`

### System Utilities
- **Terminal (Konsole):** From Desktop Mode → K Menu → System
- **Discover (App Store):** K Menu → Applications

---

## 🗂️ Important Paths

### System Configuration
```
/etc/fstab                                    # Drive mount configuration
/etc/tlp.d/90-car-edge.conf                   # Power management settings
/usr/share/doc/bazzite-car-edge/README.txt    # Quick info file
```

### User Data
```
~/.config/                                    # Application configs
~/.var/app/                                   # Flatpak app data
~/.local/share/Steam/                         # Steam games/saves
```

### External Storage
```
/mnt/storage/media/                           # Movies, TV, Music
/mnt/storage/games/roms/                      # RetroArch ROMs
/mnt/storage/games/saves/                     # Game saves
/mnt/storage/backups/                         # Config backups
```

### RetroArch Configuration
```
/var/config/retroarch/retroarch.cfg           # Main config
~/.var/app/org.libretro.RetroArch/config/     # User overrides
```

---

## 🔧 Troubleshooting Quick Fixes

### Flatpak Issues
```bash
# Repair Flatpak installation
flatpak repair

# Reinstall specific app (example: Kodi)
flatpak uninstall tv.kodi.Kodi
flatpak install flathub tv.kodi.Kodi
```

### System Not Booting
```bash
# From GRUB menu, select previous deployment
# System keeps 2 previous versions automatically
```

### External Drive Not Mounting
```bash
# Check drive is detected
lsblk

# Manual mount (replace UUID)
sudo mount UUID=your-uuid /mnt/storage

# Fix fstab permissions
sudo nano /etc/fstab
```

### Kodi Library Not Scanning
```bash
# Check permissions
ls -la /mnt/storage/media/

# Rescan from Kodi
Settings → Media → Library → Clean Library
Settings → Media → Library → Update Library
```

---

## 📦 Installed Applications

### Entertainment
- 📺 **Kodi** - Media center (movies, TV, music)
- 🎬 **VLC** - Video player
- 📺 **Jellyfin** - Media player (server client)

### Gaming
- 🎮 **Steam** - PC gaming (pre-installed)
- 🎮 **RetroArch** - Retro gaming (pre-installed)
- 🎮 **PrismLauncher** - Minecraft launcher
- 🎮 **Heroic** - Epic/GOG games
- 🎮 **ProtonUp-Qt** - Proton version manager

### Utilities
- 🦊 **Firefox** - Web browser
- 💻 **VS Code** - Code editor
- 🔄 **Syncthing** - File sync with home lab
- 📚 **Kiwix** - Offline Wikipedia

---

## 🌐 Network

### Wi-Fi Management
```bash
# From Desktop Mode
nmcli device wifi list
nmcli device wifi connect "SSID" password "PASSWORD"
```

### Check Connection
```bash
ping -c 4 google.com
ip addr show
```

---

## 💡 Tips

- **Updates:** System auto-checks daily, but doesn't auto-update (you control when to reboot)
- **Rollback:** Always keep 2 previous versions - instant rollback if something breaks
- **Backups:** Run `car-edge-backup` before major changes
- **Performance:** TLP automatically manages power - runs cool on battery, fast on AC
- **Storage:** Keep OS backups on external drive, media won't be touched by OS updates
