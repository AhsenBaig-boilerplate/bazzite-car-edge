# Automated Setup - NEW in v2.1

## 🎯 The Problem

**Previously:** Users had to manually:
- Edit `/etc/fstab` with UUIDs
- Run terminal commands
- Configure Kodi media sources by hand
- Set up Syncthing manually
- Follow 6-step markdown documentation

**Result:** Too technical for non-tech users (family, kids)

---

## ✨ The Solution: GUI Setup Wizard

**New first-boot experience:**

1. **System boots** → Automatic GUI wizard launches
2. **Welcome screen** → Friendly introduction
3. **Drive setup** → Auto-detect, offer format, configure mount
4. **App installation** → Progress bar, automated Flatpak install
5. **Kodi configuration** → Auto-configure media sources
6. **Syncthing setup** → Optional guided setup
7. **Done!** → Return to Gaming Mode

---

## 🚀 How It Works

### Setup Wizard Command
```bash
car-edge-setup-wizard
```

### What It Does Automatically

#### 1. External Drive Setup
- **Detects** all connected drives
- **Shows GUI menu** to select drive
- **Warns** before formatting (safety check)
- **Formats** drive with ext4
- **Creates** mount point at `/mnt/storage`
- **Adds** fstab entry automatically
- **Creates** directory structure:
  ```
  /mnt/storage/
  ├── media/movies/
  ├── media/tv/
  ├── media/music/
  ├── games/roms/
  ├── games/saves/
  └── backups/configs/
  ```

#### 2. Application Installation
- **Shows progress bar** during Flatpak installs
- **Installs** all 10 applications
- **Grants permissions** automatically

#### 3. Kodi Auto-Configuration
- **Creates** `sources.xml` with media paths
- **Grants** filesystem access to `/mnt/storage`
- **Pre-configures** Movies, TV Shows, Music sources
- **Ready to scan** on first Kodi launch

#### 4. Flatpak Permissions
- **Grants** `/mnt/storage` access to:
  - Kodi
  - RetroArch
  - VLC
  - Heroic Games Launcher

#### 5. First Backup
- **Creates** initial system backup
- **Saves** to `/mnt/storage/backups/configs/`

---

## 📱 User Experience

### Before (Manual)
```
User: *boots system*
User: *presses Ctrl+Alt+F3*
User: *opens terminal*
User: *runs: sudo blkid*
User: *copies UUID*
User: *runs: sudo nano /etc/fstab*
User: *types UUID line*
User: *saves file*
User: *runs: sudo mount -a*
User: *runs: car-edge-install-apps*
User: *waits 15 minutes*
User: *opens Kodi*
User: *adds media sources manually*
...
```

### After (Automated)
```
User: *boots system*
Wizard: "Welcome! Let's set up your entertainment system"
User: *clicks Next*
Wizard: "Select your drive for media"
User: *selects drive, clicks Yes to format*
Wizard: *shows progress bar*
Wizard: "Installing applications..."
Wizard: *shows progress*
Wizard: "Setting up Kodi..."
Wizard: "Done! Enjoy!"
User: *clicks "Return to Gaming Mode"*
User: *plays games*
```

---

## 🔧 Technical Implementation

### Components

1. **`car-edge-setup-wizard.sh`**
   - Main wizard script
   - Uses `kdialog` for GUI (KDE native)
   - Handles drive detection, formatting, mounting
   - Orchestrates all setup steps

2. **`car-edge-setup-wizard.service`** (future)
   - Systemd service for auto-run on first boot
   - Runs once, creates completion marker
   - Never runs again after setup complete

### Dialog System

Uses `kdialog` (KDE's native dialog tool):
- `--yesno` - Yes/No questions
- `--menu` - Selection menus
- `--progressbar` - Progress indicators
- `--msgbox` - Information messages
- `--error` - Error dialogs

### Safety Features

- **Warns before formatting** with prominent warning dialog
- **Confirms each action** before proceeding
- **Optional steps** (external drive, Syncthing)
- **Completion marker** (`~/.config/car-edge-setup-complete`)
- **Idempotent** - safe to run multiple times

---

## 🎮 Manual Mode Still Available

For power users who want control:
```bash
# Individual commands still work
car-edge-install-apps          # Just install apps
car-edge-backup                # Just backup
# Manual fstab editing           # Full control
```

---

## 📋 Setup Wizard Steps (Detailed)

### Step 1: Welcome
- Introduces the wizard
- Lists what will be configured
- User clicks "OK" to proceed

### Step 2: External Drive (Optional)
- Asks: "Do you have an external drive?"
- If No → Skip to Step 3
- If Yes:
  - Detects drives with `lsblk`
  - Shows menu with drive names and sizes
  - User selects drive
  - **WARNING DIALOG**: "This will ERASE ALL DATA"
  - If confirmed:
    - Formats with ext4
    - Creates UUID-based fstab entry
    - Mounts drive
    - Creates directory structure
    - Sets permissions

### Step 3: Applications
- Asks: "Install entertainment applications?"
- If Yes:
  - Runs `car-edge-install-apps`
  - Shows progress bar
  - Streams output to dialog
  - Waits for completion
  - Shows "Success!" message

### Step 4: Kodi Configuration (if drive exists)
- Asks: "Configure Kodi automatically?"
- If Yes:
  - Creates `~/.var/app/tv.kodi.Kodi/data/userdata/sources.xml`
  - Adds media sources:
    - Movies → `/mnt/storage/media/movies`
    - TV Shows → `/mnt/storage/media/tv`
    - Music → `/mnt/storage/media/music`
  - Grants Kodi filesystem access
  - Shows "Kodi configured!" message

### Step 5: Syncthing (Optional)
- Asks: "Set up Syncthing?"
- If Yes:
  - Shows instructions for connecting devices
  - Adds Syncthing to autostart
  - User can configure folders later in GUI

### Step 6: Permissions
- Silent step (no user interaction)
- Grants `/mnt/storage` access to all media apps
- Uses `flatpak override --filesystem=/mnt/storage`

### Step 7: Backup (if drive exists)
- Asks: "Create first backup?"
- If Yes:
  - Runs `car-edge-backup`
  - Shows progress
  - Shows backup location

### Step 8: Completion
- Shows "Setup Complete!" message
- Lists what was configured
- Mentions next steps
- Asks: "Return to Gaming Mode?"
- If Yes → Logs out (returns to Gaming Mode)

---

## 🚀 Future Enhancements

### Phase 1 (Current)
- [x] GUI setup wizard
- [x] Automated drive setup
- [x] Kodi auto-configuration
- [x] Permission grants

### Phase 2 (Planned)
- [ ] Auto-run on first boot (systemd service)
- [ ] Network drive (SMB/NFS) setup
- [ ] RetroArch core installation
- [ ] Controller pairing wizard

### Phase 3 (Future)
- [ ] Remote control app pairing
- [ ] Home Assistant integration
- [ ] OTA update notifications in GUI
- [ ] Backup scheduling UI

---

## 💡 Benefits

### For Users
- **Zero terminal commands** required
- **No documentation reading** needed
- **Visual feedback** with progress bars
- **Safe** with confirmation dialogs
- **Fast** - 5-10 minute setup vs 30-60 minutes manual

### For Project
- **Lower barrier to entry** - anyone can use it
- **Fewer support requests** - automation reduces errors
- **Better first impression** - polished experience
- **True "car-ready"** system - not just a custom image

---

## 🎯 Target Audience Shift

### Before
- **Target**: Linux enthusiasts, tinkerers
- **Requirement**: Comfortable with terminal
- **Use case**: Personal project

### After
- **Target**: Families, kids, non-technical users
- **Requirement**: Can click Next button
- **Use case**: Production car entertainment system

---

## 📚 Documentation Updates Needed

- [x] Create `docs/AUTOMATED-SETUP.md` (this file)
- [ ] Update `docs/FIRST-BOOT.md` to feature wizard first
- [ ] Update `README.md` to highlight automation
- [ ] Add screenshots/video of wizard in action
- [ ] Create troubleshooting section for wizard

---

## 🔍 Testing Plan

1. **Fresh ISO install** → Wizard runs automatically
2. **Rebase from Bazzite** → User runs wizard manually
3. **Multiple drives** → Wizard shows correct selection menu
4. **No external drive** → Wizard skips drive setup gracefully
5. **Network failure** → Wizard handles Flatpak install errors
6. **Re-run wizard** → Idempotent, no duplicate entries
7. **Cancel mid-wizard** → System still usable, can re-run

---

## ✅ Success Criteria

- ✅ User can set up system without reading documentation
- ✅ No terminal commands required for basic setup
- ✅ Kodi works out-of-box (just add media files)
- ✅ Apps have correct permissions
- ✅ External drive auto-mounts on boot
- ✅ System is backed up
- ✅ User returns to Gaming Mode with working system

---

**This changes Bazzite Car Edge from a "technical custom image" to a "production-ready car entertainment system".**
