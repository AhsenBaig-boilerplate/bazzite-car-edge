# First Boot Setup - Bazzite Car Edge

## 🎮 Welcome Screen

After first boot, you'll see the Steam Deck UI (Gaming Mode).

---

## 📱 Step 1: Install Applications (15-20 minutes)

### Switch to Desktop Mode

Press `Ctrl+Alt+F3` or:
- Steam button → Power → Switch to Desktop

### Open Terminal (Konsole)

From Desktop Mode, open Konsole (KDE's terminal).

### Run the Installer

```bash
car-edge-install-apps
```

This installs:
- 📺 Kodi Media Center
- 🦊 Firefox web browser
- 🎮 Minecraft (PrismLauncher)
- 🔄 Syncthing (home lab sync)
- 📚 Kiwix (offline Wikipedia)
- 💻 VS Code
- 🎬 VLC media player
- 🎮 ProtonUp-Qt
- 🎮 Heroic Games Launcher
- 📺 Jellyfin Media Player

**Wait for installation to complete** (~15-20 minutes)

---

## 📂 Step 2: Configure External Storage

### Find Your Storage UUID

```bash
sudo blkid
```

Look for your external SSD (e.g., `/dev/sdb1`)

### Edit fstab

```bash
sudo nano /etc/fstab
```

Add this line (replace `your-uuid` with actual UUID):

```
UUID=your-uuid /mnt/storage ext4 defaults,nofail 0 2
```

Save: `Ctrl+O`, Enter, `Ctrl+X`

### Mount the Drive

```bash
sudo mount -a

# Verify it mounted
ls /mnt/storage
```

---

## 🎬 Step 3: Set Up Kodi

### Launch Kodi

From Gaming Mode Library or Desktop Mode

### Add Media Sources

1. **Videos → Files → Add videos...**
   - Path: `/mnt/storage/media/movies`
   - Name: "Movies"
   - Set content type: Movies
   - Choose scraper: The Movie Database

2. **Add TV Shows:**
   - Path: `/mnt/storage/media/tv`
   - Name: "TV Shows"
   - Set content type: TV Shows

3. **Add Music:**
   - Path: `/mnt/storage/media/music`
   - Name: "Music"

### Scan Libraries

Kodi will scan and add metadata/artwork automatically.

---

## 🔄 Step 4: Configure Syncthing

### Open Syncthing

From Desktop Mode, launch SyncThingy.

### Connect to Home Lab

1. **Note your device ID** (shown in GUI)
2. **On home server:** Add this device ID
3. **Accept connection** on car system
4. **Configure folders** to sync:
   - Documents
   - Game saves
   - Photos
   - etc.

### Enable Auto-Start (Optional)

```bash
# Add to KDE autostart
cp /var/lib/flatpak/app/com.github.zocker_160.SyncThingy/current/active/export/share/applications/com.github.zocker_160.SyncThingy.desktop ~/.config/autostart/
```

---

## 🕹️ Step 5: Add RetroArch ROMs

### Copy ROMs

```bash
# Copy your ROM files to:
/mnt/storage/games/roms/nes/
/mnt/storage/games/roms/snes/
/mnt/storage/games/roms/genesis/
/mnt/storage/games/roms/ps1/
/mnt/storage/games/roms/ps2/
# etc.
```

### Launch RetroArch

From Gaming Mode Library → RetroArch

ROMs will be automatically detected in the configured paths.

---

## 💾 Step 6: Create First Backup

```bash
car-edge-backup
```

This backs up your configs to: `/mnt/storage/backups/configs/`

---

## 🎮 Step 7: Return to Gaming Mode

From Desktop Mode:
- K menu → Leave → Switch to Gaming Mode
- Or press `Steam button`

---

## ✅ Setup Complete!

Your car entertainment system is ready to use:

- **Gaming Mode:** Controller-only interface, perfect for kids
- **Media:** Kodi for movies/TV/music
- **Games:** Steam, Minecraft, RetroArch
- **Sync:** Auto-syncs with home when on Wi-Fi

---

## 🔄 Optional Configuration

### Set Display Resolution

```bash
# From Desktop Mode
System Settings → Display → Resolution
```

### Configure Controllers

Gaming Mode automatically detects Xbox, PlayStation, and Nintendo controllers.

For custom mapping:
- Gaming Mode → Settings → Controller

### Download Wikipedia for Kiwix

1. Open Kiwix
2. Get Content → Browse Library
3. Download desired language pack (e.g., "wikipedia_en_all")

---

## ⏭️ Next Steps

- **[CONFIGURATION.md](CONFIGURATION.md)** - Advanced configuration
- **[BACKUP-RESTORE.md](BACKUP-RESTORE.md)** - Backup and restore procedures
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Command cheat sheet
