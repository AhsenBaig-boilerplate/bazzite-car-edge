# Backup & Restore - Bazzite Car Edge

## 💾 Backup Strategy

Bazzite Car Edge uses a multi-layered backup approach:

1. **OS Rollback** - Automatic (rpm-ostree keeps 2 previous versions)
2. **Config Backup** - Manual script (`car-edge-backup`)
3. **Home Sync** - Automatic (Syncthing to home lab)
4. **Media Storage** - Separate drive (not touched by OS)

---

## 🔄 OS Rollback (Automatic)

### How It Works

Every system update keeps the previous version. You can instantly rollback if something breaks.

### View Available Versions

```bash
rpm-ostree status
```

**Example output:**
```
State: idle
Deployments:
● ostree://bazzite-car-edge:0
                   Version: 2026.05.14.1 (2026-05-14T12:00:00Z)
                    Commit: abc123...
  ostree://bazzite-car-edge:1
                   Version: 2026.05.10.1 (2026-05-10T08:30:00Z)
                    Commit: def456...
```

### Rollback to Previous Version

```bash
rpm-ostree rollback
systemctl reboot
```

**Recovery time:** ~2 minutes (instant switch + reboot)

### Pin a Specific Version

**Prevent auto-cleanup:**
```bash
sudo ostree admin pin 0
```

**Unpin:**
```bash
sudo ostree admin pin --unpin 0
```

---

## 📦 Configuration Backup

### Quick Backup

```bash
car-edge-backup
```

**Creates archive at:**
```
/mnt/storage/backups/configs/bazzite-car-edge-backup-YYYYMMDD-HHMMSS.tar.gz
```

### What Gets Backed Up

- System configs: `/etc/fstab`, TLP settings
- User configs: `~/.config/`
- Syncthing settings
- Steam settings (not games)
- RetroArch config
- RPM-ostree deployment status
- Flatpak application list

### What's NOT Backed Up

- Media files (movies, TV, music) - separate drive
- Game ROMs - separate drive
- Game saves - separate drive (or synced via Syncthing)
- Steam games - re-downloadable

### Manual Backup

```bash
# Custom backup location
BACKUP_DIR="/path/to/usb/drive" car-edge-backup

# Verify backup contents
tar -tzf /mnt/storage/backups/configs/backup-file.tar.gz | less
```

---

## 🔄 Restore from Backup

### Full Config Restore

```bash
# Extract to root (careful!)
cd /
sudo tar -xzf /mnt/storage/backups/configs/bazzite-car-edge-backup-YYYYMMDD-HHMMSS.tar.gz

# Reboot to apply
systemctl reboot
```

### Selective Restore

**Restore specific directory:**
```bash
# Example: Restore only Kodi config
tar -xzf /mnt/storage/backups/configs/backup-file.tar.gz \
    -C ~ \
    --strip-components=2 \
    home/$(whoami)/.config/kodi/
```

**Restore fstab:**
```bash
sudo tar -xzf /mnt/storage/backups/configs/backup-file.tar.gz \
    -C / \
    etc/fstab
```

### Restore Flatpak Applications

**Backup includes list of installed Flatpaks.**

Extract list:
```bash
tar -xzf backup-file.tar.gz -O etc/flatpak-installed.txt
```

Reinstall from list:
```bash
cat flatpak-installed.txt | xargs -I {} flatpak install -y flathub {}
```

---

## 🏠 Syncthing Home Sync

### Setup Automatic Backup

**Files synced continuously:**
- Documents
- Photos
- Game saves (selective)
- Kodi settings

**Configuration:**
1. Launch SyncThingy from Desktop Mode
2. Add folders to sync
3. Configure "Send & Receive" mode
4. Enable versioning on home server

### Restore from Syncthing

Files automatically sync when reconnected to home network.

**Manual restore:**
1. Connect to home network
2. Open SyncThingy
3. Select folder → Advanced → Rescan
4. Wait for sync completion

---

## 🚨 Disaster Recovery

### Complete System Failure

**Option 1: Reinstall from ISO**
1. Boot from USB installer
2. Fresh install
3. Restore configs from `/mnt/storage/backups/`
4. Reinstall Flatpaks

**Time:** 30-45 minutes

**Option 2: Rebase from Live USB**
```bash
# Boot live USB (any Bazzite/Fedora)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest
systemctl reboot
```

**Time:** 15-20 minutes

### External Drive Failure

**Media drive lost:**
- Re-download/copy media files
- ROMs and saves hopefully backed up elsewhere
- Kodi will need media sources re-added

**Backup drive lost:**
- Create new backup with `car-edge-backup`
- If Syncthing was configured, most user data safe

### Corrupted Flatpak

**Repair installation:**
```bash
flatpak repair

# Or remove and reinstall
flatpak remove tv.kodi.Kodi
flatpak install flathub tv.kodi.Kodi
```

### Boot Failure

**From GRUB menu:**
1. Select previous ostree deployment
2. System boots into last-known-good state
3. Investigate issue from stable system

---

## 📅 Backup Schedule Recommendations

### Daily (Automatic)
- Syncthing to home lab (continuous)

### Weekly (Manual)
```bash
car-edge-backup
```

### Before Major Changes
```bash
# Before system update
rpm-ostree status
car-edge-backup
rpm-ostree upgrade
```

### Monthly
- Verify backups are restorable
- Clean old backups (keep last 3-6 months)

```bash
# Clean old backups
cd /mnt/storage/backups/configs/
ls -lt | tail -n +10 | awk '{print $9}' | xargs rm
```

---

## 🧪 Test Your Backups

### Verify Backup Integrity

```bash
# Test archive is not corrupted
tar -tzf /mnt/storage/backups/configs/backup-file.tar.gz > /dev/null
echo $?  # Should return 0
```

### Practice Restore

**In a safe test environment:**
1. Boot from live USB
2. Attempt full restore
3. Verify system boots and works
4. Document any issues

---

## 💡 Backup Best Practices

### DO:
- ✅ Test restores periodically
- ✅ Keep backups on separate physical drive
- ✅ Backup before major changes
- ✅ Use Syncthing for important personal files
- ✅ Document custom configurations

### DON'T:
- ❌ Rely on single backup location
- ❌ Backup large media files (separate drive)
- ❌ Forget to verify backups work
- ❌ Keep only one backup version
- ❌ Store backup on system drive

---

## 📦 Backup Script Customization

### Edit Backup Script

```bash
sudo nano /usr/bin/car-edge-backup
```

### Add Custom Directories

**Find the section:**
```bash
# Backup user configs
tar -czf "$BACKUP_FILE" \
    --exclude='*/.cache/*' \
    ...
```

**Add your paths:**
```bash
# Backup user configs
tar -czf "$BACKUP_FILE" \
    --exclude='*/.cache/*' \
    /etc/fstab \
    /home/$USER/.config/ \
    /home/$USER/my-custom-folder/ \
    ...
```

### Change Backup Location

**Edit default path:**
```bash
# Find this line:
BACKUP_DIR="${BACKUP_DIR:-/mnt/storage/backups/configs}"

# Change to:
BACKUP_DIR="${BACKUP_DIR:-/path/to/new/location}"
```

---

## 🔐 Encrypted Backups (Optional)

### Create Encrypted Archive

```bash
# After running car-edge-backup
gpg -c /mnt/storage/backups/configs/backup-file.tar.gz
# Enter passphrase
rm backup-file.tar.gz  # Remove unencrypted
```

### Restore Encrypted Backup

```bash
gpg -d backup-file.tar.gz.gpg | tar -xzf - -C /
```

---

## ⏭️ Related Documentation

- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Backup command reference
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Recovery procedures
- **[CONFIGURATION.md](CONFIGURATION.md)** - Syncthing setup
