# Advanced Configuration - Bazzite Car Edge

## 🔧 System Configuration

### TLP Power Management

The system is pre-configured for Intel N150 with optimized power profiles.

**View current config:**
```bash
cat /etc/tlp.d/90-car-edge.conf
```

**Customize settings:**
```bash
sudo nano /etc/tlp.d/90-car-edge.conf
# Edit values, then:
sudo tlp start
```

**Key settings:**
- `CPU_SCALING_GOVERNOR_ON_AC=performance` - Max performance on AC power
- `CPU_SCALING_GOVERNOR_ON_BAT=powersave` - Battery saving mode
- `CPU_ENERGY_PERF_POLICY_ON_AC=performance` - Intel EPB on AC
- `CPU_ENERGY_PERF_POLICY_ON_BAT=power` - Intel EPB on battery
- `PLATFORM_PROFILE_ON_AC=performance` - ACPI platform profile
- `RUNTIME_PM_ON_AC=auto` - PCI/USB power management

---

## 📂 External Storage Configuration

### Automatic Mount Setup

**Find your drive UUID:**
```bash
sudo blkid
```

**Edit fstab:**
```bash
sudo nano /etc/fstab
```

**Add mount entry:**
```
# Bazzite Car Edge - External Storage
UUID=your-actual-uuid-here /mnt/storage ext4 defaults,nofail 0 2
```

**Options explained:**
- `defaults` - Standard mount options (rw, suid, dev, exec, auto, nouser, async)
- `nofail` - Don't fail boot if drive is missing
- `0` - No dump backup
- `2` - fsck order (1=root, 2=others)

**Apply changes:**
```bash
sudo systemctl daemon-reload
sudo mount -a
```

### Directory Structure

Pre-configured at `/mnt/storage/`:
```
/mnt/storage/
├── media/
│   ├── movies/
│   ├── tv/
│   └── music/
├── games/
│   ├── roms/
│   │   ├── nes/
│   │   ├── snes/
│   │   ├── genesis/
│   │   └── ps1/
│   └── saves/
└── backups/
    └── configs/
```

---

## 🎬 Kodi Advanced Configuration

### Network Sources

**Add SMB/NFS shares:**

1. **Videos → Files → Add videos...**
2. Browse → Add network location
3. Protocol: Windows network (SMB) or Network File System (NFS)
4. Server address: `192.168.1.100`
5. Remote path: `/mnt/media`
6. Username/password (if required)

**Example SMB URL:**
```
smb://username:password@192.168.1.100/media/movies
```

### Video Playback Settings

**For 4K/HEVC content:**
- Settings → Player → Videos
- Enable: "Allow hardware acceleration"
- Enable: "Allow using VAAPI"

**For HDR:**
- Settings → System → Display
- Enable: "Use limited color range"

### Library Auto-Update

**Settings → Media → Library:**
- Enable: "Update library on startup"
- Enable: "Scan for new content"

---

## 🔄 Syncthing Configuration

### Access Web GUI

From Desktop Mode:
```bash
xdg-open http://127.0.0.1:8384
```

Or launch SyncThingy app.

### Connect to Home Lab

1. **Get Device IDs:**
   - Car system: Settings → Show ID
   - Home server: Settings → Show ID

2. **Add Devices:**
   - Car: Actions → Add Remote Device → Paste home server ID
   - Home: Add car device ID

3. **Share Folders:**
   - Select folder → Edit → Sharing → Add device
   - Accept on remote device

### Recommended Sync Folders

```
~/Documents         → Documents backup
~/Pictures          → Photo sync
~/.var/app/*/saves  → Game saves (selective)
~/.config/kodi      → Kodi settings sync
```

### Auto-Start on Boot

**Desktop Mode:**
```bash
# Copy to autostart
cp /var/lib/flatpak/app/com.github.zocker_160.SyncThingy/current/active/export/share/applications/com.github.zocker_160.SyncThingy.desktop ~/.config/autostart/
```

---

## 🕹️ RetroArch Configuration

### Core Installation

From RetroArch:
1. Main Menu → Load Core
2. Download Core
3. Select emulator core (e.g., "Nestopia UE" for NES)

**Recommended cores:**
- NES: Mesen or Nestopia UE
- SNES: Snes9x
- Genesis: Genesis Plus GX
- PS1: Beetle PSX HW
- N64: Mupen64Plus-Next

### Controller Configuration

**Per-core remapping:**
1. Start game
2. Quick Menu → Controls → Port 1 Controls
3. Remap buttons
4. Save Core Remap File or Save Game Remap File

### Save States

**Default locations** (pre-configured):
```
/mnt/storage/games/saves/retroarch/states/
```

**Change in RetroArch:**
- Settings → Directory → Savefile
- Settings → Directory → Savestate

---

## 🎮 Steam Configuration

### Library Locations

**Add external storage:**
1. Steam Settings → Storage
2. Add Drive → Select `/mnt/storage/games/steam`

### Controller Configuration

Gaming Mode auto-configures most controllers.

**For custom layouts:**
- Steam → Settings → Controller → Desktop Configuration

### Shader Cache

**Store on faster drive:**
1. Steam Settings → Shader Pre-Caching
2. Enable for supported games

---

## 🌐 Network Configuration

### Static IP (Optional)

**For consistent car network:**
```bash
# Using NetworkManager
nmcli connection show
nmcli connection modify "Your-Wifi-SSID" ipv4.addresses 192.168.1.50/24
nmcli connection modify "Your-Wifi-SSID" ipv4.gateway 192.168.1.1
nmcli connection modify "Your-Wifi-SSID" ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection modify "Your-Wifi-SSID" ipv4.method manual
nmcli connection up "Your-Wifi-SSID"
```

### Hotspot Mode (Car Network)

**Create mobile hotspot:**
```bash
nmcli device wifi hotspot ssid "CarEdge" password "your-password"
```

**Or from Desktop Mode:**
- System Settings → Network → Add → Wi-Fi Shared

---

## 🖥️ Display Configuration

### Resolution & Refresh Rate

**Desktop Mode:**
```bash
# List available modes
xrandr

# Set specific mode (example)
xrandr --output HDMI-1 --mode 1920x1080 --rate 60
```

**Make permanent:**
- System Settings → Display → Resolution

### Multiple Displays

**Gaming Mode:**
- Steam → Settings → Display → Arrange Displays

**Desktop Mode:**
- System Settings → Display → Configure displays

---

## ⚙️ System Customization

### Gaming Mode Startup

**Boot directly to Gaming Mode:**
```bash
# Already default, but to verify:
systemctl get-default
# Should show: graphical.target with steam-session
```

**Switch to Desktop Mode default:**
```bash
# Not recommended for car use
systemctl set-default plasma.desktop
```

### Auto-Login

**Enable (already configured):**
```bash
# Check current setting
cat /etc/sddm.conf.d/autologin.conf
```

### Disable Screen Timeout (Car Use)

**Desktop Mode:**
- System Settings → Power Management → Energy Saving
- Set "Screen Energy Saving" to "Never"

**Gaming Mode:**
- Steam → Settings → Display → Set screen timeout to "Disabled"

---

## 🔐 Security Considerations

### User Password

**Set/change password:**
```bash
passwd
```

**Disable auto-login (if needed):**
```bash
sudo rm /etc/sddm.conf.d/autologin.conf
```

### Firewall

**Enable firewall:**
```bash
sudo systemctl enable --now firewalld
sudo firewall-cmd --set-default-zone=public
```

---

## 📦 Layer Additional Packages

**Install RPM packages permanently:**
```bash
rpm-ostree install <package-name>
systemctl reboot
```

**Example - Install development tools:**
```bash
rpm-ostree install gcc make python3-devel
```

**Remove packages:**
```bash
rpm-ostree uninstall <package-name>
systemctl reboot
```

---

## 🎨 Customization

### Desktop Theme

**Desktop Mode:**
- System Settings → Appearance → Global Theme
- Try: "Breeze Dark" or "Breeze Light"

### Gaming Mode Skin

- Steam → Settings → Interface → Select Skin

---

## 🔄 Update Management

### Automatic Updates

**Check current setting:**
```bash
systemctl status rpm-ostreed-automatic.timer
```

**Enable automatic download (manual reboot):**
```bash
sudo systemctl enable rpm-ostreed-automatic.timer
```

**Disable (manual control):**
```bash
sudo systemctl disable rpm-ostreed-automatic.timer
```

---

## 📋 Post-Configuration Checklist

- [ ] External storage mounted and accessible
- [ ] TLP power profile optimized for use case
- [ ] Kodi media sources configured
- [ ] Syncthing connected to home lab
- [ ] RetroArch cores installed for desired systems
- [ ] Steam library locations set
- [ ] Network configured (static IP or hotspot)
- [ ] Display resolution optimized
- [ ] Screen timeout disabled for car use
- [ ] Initial backup created (`car-edge-backup`)

---

## ⏭️ Next Steps

- **[BACKUP-RESTORE.md](BACKUP-RESTORE.md)** - Backup and restore procedures
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Command cheat sheet
