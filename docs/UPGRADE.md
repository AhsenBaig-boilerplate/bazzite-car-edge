# Upgrade Guide - Rebasing to Bazzite Car Edge

## 🔄 For Existing Bazzite Users

If you're running standard Bazzite or Bazzite-Deck and want to upgrade to Bazzite Car Edge, follow this guide.

---

## ✅ What Gets Updated

When you rebase to Bazzite Car Edge, you **automatically get**:

### System Changes
- ✅ All Car Edge scripts (`car-edge-*` commands)
- ✅ TLP power management configuration
- ✅ Storage directory structure templates
- ✅ RetroArch path configurations
- ✅ System documentation
- ✅ Auto-run setup wizard (for new users)

### What Stays the Same
- ✅ Your user data and files
- ✅ Your installed Flatpaks (unless you reinstall)
- ✅ Your settings and configurations
- ✅ Your home directory

---

## 📋 Upgrade Steps

### Step 1: Rebase to Car Edge

```bash
# From your current Bazzite system
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest

# Reboot to apply
systemctl reboot
```

**What happens:**
- Downloads the new image (~2-3GB)
- Switches your system to Car Edge
- Keeps your home directory intact
- Takes 5-10 minutes + reboot

---

### Step 2: Enable Car Edge Features

After reboot, switch to Desktop Mode (Ctrl+Alt+F3) and run:

```bash
car-edge-upgrade
```

**What this does:**
- Creates necessary config directories
- Enables Car Edge features for your user
- Shows next steps
- Marks your account as upgraded (runs once)

**Output:**
```
╔═══════════════════════════════════════════════════════════════╗
║  🚗 Bazzite Car Edge - Upgrade Helper                         ║
╚═══════════════════════════════════════════════════════════════╝

✅ Car Edge features enabled!

Next Steps:
1. Run the setup wizard: car-edge-setup-wizard
2. Install applications (Kodi, Firefox, etc.)
3. Configure external storage
```

---

### Step 3: Run Setup Wizard

```bash
car-edge-setup-wizard
```

**The wizard guides you through:**
1. External drive setup (format, mount, structure)
2. Application installation (progress bars)
3. Kodi media source configuration
4. Syncthing setup (optional)
5. First backup creation

**Time:** 5-10 minutes

---

## 🆚 Fresh Install vs Rebase

### Fresh ISO Install
- ✅ Setup wizard auto-runs on first boot
- ✅ Clean slate, no previous config
- ⏱️ ~30 minutes total (install + setup)

### Rebase from Bazzite
- ✅ Keep your existing data
- ✅ Faster (just image swap)
- 📝 Need to run `car-edge-upgrade` once
- 📝 Need to run wizard manually
- ⏱️ ~15 minutes total (rebase + setup)

---

## 🔄 Future Updates

**After initial upgrade, getting future updates is automatic:**

```bash
# Check for updates
rpm-ostree status

# Update to latest
rpm-ostree upgrade

# Reboot to apply
systemctl reboot
```

**All new features are automatically included!**
- New scripts appear in `/usr/bin/`
- Updated configurations take effect
- No manual intervention needed

---

## 🧪 Verify Upgrade

After upgrading, verify everything works:

```bash
# Check Car Edge commands exist
which car-edge-setup-wizard
which car-edge-install-apps
which car-edge-backup
which car-edge-upgrade

# Check version
rpm-ostree status

# Should show:
# ● ostree://bazzite-car-edge:0
#   Version: <date>
#   Commit: <hash>
```

---

## 🆘 Troubleshooting

### Rebase fails
```bash
# Clean up and retry
rpm-ostree cleanup -p
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest --reboot
```

### Want to go back to standard Bazzite
```bash
# Rollback to previous deployment
rpm-ostree rollback
systemctl reboot
```

### Car Edge commands not found
```bash
# Check image is correct
rpm-ostree status | grep bazzite-car-edge

# If not on car-edge, rebase again
```

### Wizard not working
```bash
# Run in Desktop Mode (Ctrl+Alt+F3)
# Check if in KDE
echo $XDG_SESSION_DESKTOP  # Should show: KDE

# Run with verbose output
car-edge-setup-wizard 2>&1 | tee wizard-log.txt
```

---

## 📝 What's Different from Standard Bazzite?

### Added to Car Edge
- 🚗 Car-focused applications (Kodi pre-configured)
- 📦 Post-boot app installation (smaller image)
- ⚡ TLP power management for Intel N150
- 📂 Pre-configured storage structure
- 🎮 RetroArch paths for external ROMs
- 🧙 Setup wizard for zero-config experience
- 💾 Backup system for configs

### Same as Standard Bazzite
- 🎮 Steam Deck UI (Gaming Mode)
- 🖥️ KDE Plasma (Desktop Mode)
- 🎮 Steam, RetroArch, gaming tools
- 🔄 rpm-ostree immutable system
- 🚀 All Bazzite optimizations

---

## 💡 Tips for Rebase Users

### Keep Your Existing Apps
Your Flatpaks are preserved during rebase. To add Car Edge apps:
```bash
car-edge-install-apps  # Adds: Kodi, Firefox, Syncthing, etc.
```

### External Drive Already Set Up?
The wizard can skip drive setup:
- Wizard detects existing `/mnt/storage`
- Just click "Skip" on drive setup
- Still runs app install and Kodi config

### Want to Reinstall Fresh?
If you prefer a clean start:
1. Backup your data
2. Download Car Edge ISO
3. Fresh install
4. Restore data from backup

---

## 🎯 Summary

**For existing Bazzite users upgrading:**

```bash
# 1. Rebase (5-10 min)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest
systemctl reboot

# 2. Enable features (1 min)
car-edge-upgrade

# 3. Run wizard (5-10 min)
car-edge-setup-wizard

# Done! 🎉
```

**Total time:** 15-20 minutes  
**Your data:** Preserved  
**Future updates:** Automatic with `rpm-ostree upgrade`

---

## 📚 More Information

- **Installation Guide:** [INSTALLATION.md](INSTALLATION.md)
- **Setup Wizard:** [AUTOMATED-SETUP.md](AUTOMATED-SETUP.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Roadmap:** [../ROADMAP.md](../ROADMAP.md)
