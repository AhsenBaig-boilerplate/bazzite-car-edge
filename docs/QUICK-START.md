# 🚗 Bazzite Car Edge - Quick Start Guide

**Transform your Beelink Mini S13 into a complete car entertainment system in under 30 minutes!**

---

## 📦 What You Need

- **Beelink Mini S13** (or similar Intel N150 mini PC)
- **USB flash drive** (8GB+) for installation
- **External drive** (128GB+ USB/SSD) for media storage
- **Internet connection** (WiFi or Ethernet)
- **Optional:** USB game controllers, Bluetooth devices

---

## ⚡ Installation (10 minutes)

### Step 1: Download the Image
```
https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/releases
```
Download: `bazzite-car-edge-<version>.iso`

### Step 2: Flash to USB Drive
**Windows/Mac/Linux:**
- Download [Balena Etcher](https://www.balena.io/etcher/)
- Select the `.iso` file
- Select your USB drive
- Click "Flash!"

**Alternative:** Use `dd` on Linux/Mac or Rufus on Windows

### Step 3: Install on Beelink
1. Insert USB drive into Beelink
2. Power on and press `F7` or `Delete` for boot menu
3. Select USB drive
4. Choose "Install Bazzite Car Edge"
5. Follow on-screen prompts (automatic partitioning)
6. Reboot when complete

---

## 🎮 First Boot Setup (15 minutes)

### What Happens Automatically
✅ **Gaming Mode launches** (Steam Deck UI)  
✅ **Setup Wizard appears** (no terminal needed!)  
✅ **Guided configuration** with error recovery  

### Setup Wizard Walkthrough

**Screen 1: Welcome**
- Explains what will be installed
- Shows disk space requirements
- Click "Next" to continue

**Screen 2: External Drive Setup**
- **Have a drive ready?** Click "Yes" → Auto-formats and mounts
- **No drive yet?** Click "Skip" → Set up later with `car-edge-setup-wizard`

**Screen 3: App Installation** (8-10 minutes)
Installs automatically:
- 🎬 **Kodi** - Media center
- 🌐 **Firefox** - Web browser
- 🎮 **Heroic** - Epic Games launcher
- 🎮 **Prism Launcher** - Minecraft
- 🔄 **Syncthing** - File sync
- 📚 **Kiwix** - Offline Wikipedia
- 🎥 **VLC** - Video player
- ⚙️ **ProtonUp-Qt** - Game compatibility
- 📺 **Jellyfin** - Media streaming
- 💻 **VS Code** - (Optional) Code editor

**Screen 4: Complete!**
- Shows next steps
- Provides documentation links
- Wizard won't run again

---

## 🎯 Quick Reference

### Launch Applications
- **Gaming Mode**: Press Steam button → Library → Non-Steam Games
- **Desktop Mode**: Press Steam button → Power → Switch to Desktop

### Essential Shortcuts
| Action | Gaming Mode | Desktop Mode |
|--------|-------------|--------------|
| **Steam Menu** | Steam button | — |
| **Desktop Mode** | Power → Switch | — |
| **Gaming Mode** | — | Return to Gaming Mode icon |
| **Kodi** | Library → Kodi | Applications → Kodi |
| **Firefox** | Library → Firefox | Applications → Firefox |

### Storage Locations
- **System**: `/` (immutable, read-only)
- **Home**: `~/.var` (configs, saves)
- **Media**: `/mnt/storage` (external drive)
- **ROMs**: `/mnt/storage/ROMs`
- **Movies**: `/mnt/storage/Videos`
- **Music**: `/mnt/storage/Music`

### Common Commands (Desktop Mode)
```bash
# Re-run setup wizard
car-edge-setup-wizard

# Install/update applications
car-edge-install-apps

# Backup configurations
car-edge-backup

# System updates
rpm-ostree upgrade

# Rollback updates
rpm-ostree rollback
```

---

## 🔧 Troubleshooting

### Wizard Doesn't Start
1. Switch to Desktop Mode
2. Open Konsole (terminal)
3. Run: `car-edge-setup-wizard`

### External Drive Not Detected
- Check drive is plugged in before wizard
- Try different USB port
- Format manually: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Apps Won't Launch
```bash
# Reinstall applications
car-edge-install-apps
```

### System Update Issues
```bash
# Check status
rpm-ostree status

# Force update
rpm-ostree upgrade

# Rollback to previous version
rpm-ostree rollback
```

### WiFi Not Working
- Gaming Mode: Settings → Internet
- Desktop Mode: System Settings → Connections

---

## 📚 Full Documentation

**In-Depth Guides:**
- [INSTALLATION.md](INSTALLATION.md) - Detailed installation
- [FIRST-BOOT.md](FIRST-BOOT.md) - Complete first boot guide
- [CONFIGURATION.md](CONFIGURATION.md) - Advanced configuration
- [BACKUP-RESTORE.md](BACKUP-RESTORE.md) - Backup strategies
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Complete troubleshooting

**Reference:**
- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Command cheat sheet
- [UPGRADE.md](UPGRADE.md) - Upgrade from standard Bazzite
- [ERROR-HANDLING.md](ERROR-HANDLING.md) - Wizard error handling

**Development:**
- [README.md](../README.md) - Project overview
- [ROADMAP.md](../ROADMAP.md) - Development roadmap
- [TESTING.md](../TESTING.md) - Testing procedures

---

## 🎮 Gaming Setup

### Add ROMs (Retro Gaming)
1. Copy ROMs to `/mnt/storage/ROMs/<system>/`
2. Launch RetroArch from Gaming Mode
3. Settings → Directory → Update paths (already configured!)
4. Load Content → Navigate to ROMs

### Install Steam Games
- Already configured! Just log into Steam

### Install Epic/GOG Games
- Launch Heroic Games Launcher
- Log into Epic or GOG
- Install games normally

### Minecraft
- Launch Prism Launcher
- Add Microsoft account or offline account
- Install preferred version/modpack

---

## 💡 Pro Tips

✨ **Controller Support**: Bluetooth/USB controllers auto-configure in Gaming Mode  
✨ **Media Playback**: Kodi auto-scans `/mnt/storage` for media  
✨ **Offline Mode**: Kiwix provides offline Wikipedia access  
✨ **File Sync**: Use Syncthing to sync saves between devices  
✨ **Power Saving**: TLP automatically optimizes for car use (battery/AC)  
✨ **Backup Before Updates**: `car-edge-backup` before major changes  
✨ **Immutable OS**: System is read-only, updates are atomic (safe rollback)  

---

## 🆘 Need Help?

**Documentation:** `/usr/share/doc/bazzite-car-edge/README.txt`  
**GitHub Issues:** https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/issues  
**Logs:** `~/.cache/car-edge-setup.log`

---

## ⚖️ License & Credits

**Bazzite Car Edge** is built on:
- [Bazzite](https://github.com/ublue-os/bazzite) by Universal Blue
- [Fedora Atomic Desktop](https://fedoraproject.org/atomic-desktops/)
- [Steam Deck UI](https://www.steamdeck.com/) by Valve

**License:** Apache 2.0  
**Designed for:** Non-technical users, zero terminal commands required  
**Target Hardware:** Beelink Mini S13 (Intel N150, 16GB RAM)

---

**🚀 Enjoy your car entertainment system! Questions? Check the full docs above.**
