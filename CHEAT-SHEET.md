# 🚗 Bazzite Car Edge - Quick Reference Card

**Version 2.0** | Print this page and keep in your car! | [Full Docs →](README.md)

---

## ⚡ Essential Commands

| Command | Purpose |
|---------|---------|
| `car-edge-setup-wizard` | Run/re-run setup wizard |
| `car-edge-install-apps` | Install/update applications |
| `car-edge-backup` | Backup configurations |
| `car-edge-network-mounts` | Manage network storage |
| `car-edge-upgrade` | Enable Car Edge features (rebase users) |

---

## 🎮 Gaming Mode Shortcuts

| Action | Key/Button |
|--------|------------|
| **Open Steam Menu** | Steam Button |
| **Switch to Desktop** | Power → Switch to Desktop |
| **Launch Apps** | Library → Non-Steam Games |
| **Power Options** | Power Menu |
| **Settings** | Steam → Settings |

---

## 💻 Desktop Mode Shortcuts

| Action | Keys |
|--------|------|
| **Return to Gaming Mode** | Desktop Icon: "Return to Gaming Mode" |
| **Open Terminal** | Konsole (from app menu) |
| **File Manager** | Dolphin (from app menu) |
| **System Settings** | Settings app |

---

## 📂 Important Paths

| Location | Purpose |
|----------|---------|
| `/mnt/storage` | External drive (media, games, ROMs) |
| `/mnt/network-storage` | Network storage (SMB/NFS) |
| `~/.var` | App configs and saves |
| `~/.cache/car-edge-setup.log` | Setup wizard log |
| `/usr/share/doc/bazzite-car-edge` | Documentation |

---

## 🎬 Media & Games

### Kodi
- **Launch:** Gaming Mode → Library → Kodi
- **Media Location:** `/mnt/storage/media/`
- **Movies:** `/mnt/storage/media/movies/`
- **TV Shows:** `/mnt/storage/media/tv/`
- **Music:** `/mnt/storage/media/music/`

### RetroArch (Emulation)
- **Launch:** Gaming Mode → Library → RetroArch
- **ROMs:** `/mnt/storage/games/roms/<system>/`
- **Saves:** `/mnt/storage/games/saves/`
- **Cores:** Download in RetroArch → Online Updater

### Steam Games
- **Already configured!** Just log in and install

---

## 🔧 System Maintenance

### Updates
```bash
# Check for updates
rpm-ostree upgrade --check

# Apply updates
rpm-ostree upgrade

# Reboot to new version
systemctl reboot
```

### Rollback (if update breaks something)
```bash
# View deployments
rpm-ostree status

# Rollback to previous
rpm-ostree rollback

# Reboot
systemctl reboot
```

### Backup
```bash
# Create backup
car-edge-backup

# Backup location
~/.config/car-edge-backups/
```

---

## 🌐 Network Storage

### Configure
```bash
car-edge-network-mounts configure
# Follow prompts for SMB/NFS setup
```

### Manage
```bash
# Check status
car-edge-network-mounts status

# Test connection
car-edge-network-mounts test

# Mount now
car-edge-network-mounts enable

# Unmount
car-edge-network-mounts disable

# Remount (fix issues)
car-edge-network-mounts remount
```

---

## 🐛 Troubleshooting

### Wizard Won't Start
```bash
# Desktop Mode → Terminal
car-edge-setup-wizard --force
```

### Apps Won't Launch
```bash
# Reinstall applications
car-edge-install-apps
```

### External Drive Not Mounted
```bash
# Check if detected
lsblk

# Manual mount (replace sdX1)
sudo mount /dev/sdX1 /mnt/storage
```

### Network Storage Won't Mount
```bash
# Check network
ping <your-server-ip>

# Check status
car-edge-network-mounts status

# View logs
journalctl --user -u mnt-network\\x2dstorage.mount

# Remount
car-edge-network-mounts remount
```

### System Frozen
- **Gaming Mode:** Hold Power Button → Force Shutdown
- **Desktop Mode:** Ctrl+Alt+F2 → Login → `systemctl reboot`

### Boot Issues
- **Select previous deployment** at boot menu
- **Or:** Boot from USB and reinstall

---

## 📦 Installed Applications

| App | Purpose | Launch From |
|-----|---------|-------------|
| **Kodi** | Media center | Gaming Mode → Library |
| **Firefox** | Web browser | Gaming Mode or Desktop |
| **VLC** | Video player | Desktop Mode |
| **Heroic** | Epic Games | Gaming Mode → Library |
| **Prism Launcher** | Minecraft | Gaming Mode → Library |
| **Syncthing** | File sync | Desktop Mode |
| **Kiwix** | Offline Wikipedia | Desktop Mode |
| **ProtonUp-Qt** | Game compatibility | Desktop Mode |
| **Jellyfin** | Media streaming | Desktop or Gaming Mode |
| **VS Code** | Code editor | Desktop Mode |

---

## 🆘 Quick Fixes

| Problem | Solution |
|---------|----------|
| **No WiFi** | Gaming Mode → Settings → Internet |
| **Controller not working** | Gaming Mode → Settings → Controller |
| **No sound** | Desktop → System Settings → Audio |
| **Display issues** | Gaming Mode → Settings → Display |
| **Can't find app** | Desktop → Car Edge → Install Apps |
| **Wizard runs every boot** | Check if `~/.config/car-edge-setup-complete` exists |
| **Out of space** | Delete old deployments: `rpm-ostree cleanup -rpmb` |

---

## 📚 Documentation Quick Links

**Installation:** `docs/INSTALLATION.md`  
**First Boot:** `docs/AUTOMATED-SETUP.md`  
**Configuration:** `docs/CONFIGURATION.md`  
**Network Storage:** `docs/NETWORK-STORAGE.md`  
**Backup/Restore:** `docs/BACKUP-RESTORE.md`  
**Troubleshooting:** `docs/TROUBLESHOOTING.md`  
**Full Reference:** `docs/QUICK-REFERENCE.md`

**Quick Start:** `docs/QUICK-START.md` ⭐ **Start here!**

---

## 🔐 Default Credentials

**User:** `deck` (Bazzite default)  
**Password:** Set during installation  
**Root:** Use `sudo` - no separate root password needed

---

## 💡 Pro Tips

✅ **Controllers auto-detect** - Just plug in USB or pair Bluetooth  
✅ **External drive auto-mounts** - After wizard setup  
✅ **Network storage auto-mounts** - When on home WiFi  
✅ **Updates are safe** - Rollback anytime with `rpm-ostree rollback`  
✅ **Backup before major changes** - Run `car-edge-backup` first  
✅ **Gaming Mode is default** - Press Ctrl+Alt+F3 for Desktop  
✅ **Log files help debug** - Check `~/.cache/car-edge-setup.log`  
✅ **Immutable system** - Can't break OS, only user data affected  

---

## 📞 Get Help

**Documentation:** `/usr/share/doc/bazzite-car-edge/README.txt`  
**GitHub:** https://github.com/AhsenBaig-boilerplate/bazzite-car-edge  
**Issues:** https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/issues  
**Logs:** `~/.cache/car-edge-setup.log`

---

**🚀 Happy Driving! Enjoy your car entertainment system!**

*Bazzite Car Edge v2.0 | Built on Bazzite Deck | Powered by Universal Blue*

---

**Print Tips:**  
- Print double-sided to save paper  
- Laminate for durability  
- Keep in car's glove compartment  
- Share with passengers who want to help!
