# Development Notes - Bazzite Car Edge

## Project Context (May 17, 2026)

**Purpose:** Professional car entertainment system for parents/families  
**Repository:** https://github.com/AhsenBaig-boilerplate/bazzite-car-edge  
**Registry:** ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge  
**Current Version:** v1.0.0 (production-ready)

---

## Latest Session Summary

### Recent Commits (May 17, 2026)
- **677681b**: Fix control panel launch, passwordless storage, data persistence, and stubs ← LATEST
- **89e0715**: Commit format
- **308e790**: Fix Control Panel launch + diagnostic tool
- **d531737**: Professional semantic versioning system

### Current Status
✅ **COMPLETE:**
- Professional semantic versioning (v1.0.0-build.N-hash)
- Complete GUI Control Panel with 25+ features
- All documentation commands integrated into GUI
- Composefs OS drive detection (critical safety fix)
- exFAT cross-platform filesystem
- Auto-update system with background downloads
- SHA digest filtering (no cryptographic hashes in GUI)
- **Control Panel desktop icon launch (FIXED 677681b)**
- **Passwordless storage setup (FIXED 677681b — sudoers drop-in)**
- **Dynamic UID/GID in fstab (FIXED 677681b — was hardcoded 1000)**
- **Mount-existing-drive path in wizard (ADDED 677681b)**
- **System status dashboard in Control Panel (ADDED 677681b)**
- **Backup restore + auto-backup timer (ADDED 677681b)**

⏳ **AWAITING HARDWARE TEST:**
- All fixes need confirmation on Beelink at 192.168.8.191

### Root Causes Fixed in 677681b

**Control Panel desktop icon (3 separate bugs):**
1. `.desktop` Exec pointed to `/home/admins/.local/bin/` — image installs to `/usr/bin/`
2. `DISPLAY=:0` in Exec broke Wayland (Bazzite default session type)
3. `show_main_menu()` used `yad`/`zenity` — neither installed; all submenus correctly used `kdialog`
4. Per-command `trap '...' DEBUG` caused silent exits under `set -euo pipefail`

**Storage — passwordless:** `99-car-edge-storage` sudoers drop-in, installed at `/etc/sudoers.d/` with mode 440.

**Data persistence:** fstab now writes `uid=$(id -u),gid=$(id -g)` instead of `uid=1000,gid=1000`.

**Mount-existing:** wizard detects exFAT on selected drive → offers Mount/Format/Cancel before touching anything.

**Shared function:** `configure_apps_for_storage()` (wizard line 179) — Kodi sources.xml + Steam libraryfolders.vdf + Steam shortcuts. Called by both format and mount paths.

---

## Version System

### Format
```
v{MAJOR}.{MINOR}.{PATCH}-build.{BUILD}-{COMMIT}
```

**Example:** `v1.0.0-build.123-abc1234`

**Components:**
- `v1` - Major version (breaking changes)
- `.0` - Minor version (new features)
- `.0` - Patch version (bug fixes)
- `build.123` - Auto-incremented by GitHub Actions
- `abc1234` - Short git commit hash (7 chars)

### How to Bump Versions
Edit `.github/workflows/build.yml` lines 28-32:

```yaml
VERSION_MAJOR: "1"  # Bump for breaking changes
VERSION_MINOR: "0"  # Bump for new features
VERSION_PATCH: "0"  # Bump for bug fixes
```

**Build numbers auto-increment automatically** with each push to main.

### Tags Created Per Build
- `latest` - Always newest release
- `stable` - Production channel (same as latest)
- `v1.0.0-build.123-abc1234` - Full version with commit
- `v1.0.0-build.123` - Version without commit
- `build.123` - Simple build reference

---

## Critical Technical Details

### Hardware Configuration
- **OS Drive:** nvme0n1 (447.1G) → nvme0n1p3 as root partition
- **Data Drive:** nvme1n1 (476.9G PCIe SSD)
- **Filesystem:** exFAT (cross-platform: Windows/Mac/Linux)
- **Target:** Beelink Mini S13, Intel N150, 16GB RAM, 512GB SSD

### Composefs Issue (CRITICAL SAFETY FIX)
rpm-ostree uses **composefs** overlay filesystem.  
`df /` returns "composefs" NOT the real device `/dev/nvme0n1p3`.

**Problem:** Setup wizard couldn't detect OS drive, allowed users to wipe it!

**Solution:** Use `findmnt /sysroot` to get real device path.  
**Code:** `build_files/files/car-edge-setup-wizard-v2.sh` lines 228-276

### Key Scripts (Installed to /usr/bin/)
- `car-edge-control-panel` - Main GUI app (700+ lines)
- `car-edge-setup-wizard` - First-boot storage setup
- `car-edge-check-updates` - Auto-update checker (systemd timer)
- `car-edge-switch-version` - GUI version browser
- `car-edge-apply-update` - Update applier
- `car-edge-upgrade` - Legacy upgrade command

**Desktop File:** `/usr/share/applications/car-edge-control-panel.desktop`

### Dependencies
**Required:** kdialog, rpm-ostree, jq, exfatprogs, skopeo  
**Optional:** konsole, dolphin, Kodi, Steam

---

## Known Issues & Solutions

### Issue: OS Drive Selectable in Setup Wizard ❌→✅
**Status:** FIXED (commit 636d6e7)  
**Root Cause:** Composefs made root appear as "composefs" not /dev/nvme0n1p3  
**Solution:** Added composefs detection + `findmnt /sysroot` method  
**Code:** Lines 228-276 in setup wizard

### Issue: :latest Tag Not Pulling New Content ❌→✅
**Status:** FIXED (commit 18835b5)  
**Root Cause:** rpm-ostree compares tag names, not content  
**Solution:** Resolve :latest to digest, compare, rebase to specific version tag  
**Code:** `car-edge-check-updates.sh` lines 75-115

### Issue: SHA Digests Shown in Version Selector ❌→✅
**Status:** FIXED (commit f9adb0c)  
**Root Cause:** Registry publishes sha256:*, sha256-*, *.sig tags automatically  
**Solution:** Filter these tags in version switcher  
**Code:** `car-edge-switch-version.sh` - skip sha256 patterns

### Issue: Control Panel Won't Open ❌→✅
**Status:** FIXED (commit 677681b)  
**Root Causes:** Wrong Exec path in .desktop, DISPLAY=:0 broke Wayland, main menu used yad/zenity (not installed), DEBUG trap caused silent exits  
**Fix:** Correct Exec to `/usr/bin/car-edge-control-panel`, remove DISPLAY override, rewrite `show_main_menu()` with kdialog, remove per-command DEBUG trap  
**Awaiting:** Hardware confirmation at 192.168.8.191

---

## Remote Testing Setup

**IP:** 192.168.8.191  
**User:** admins  
**OS:** Bazzite Car Edge (latest build)  
**SSH:** `ssh admins@192.168.8.191`

**Test Commands:**
```bash
# Diagnostic check
car-edge-control-panel --check

# Try launch
car-edge-control-panel

# View logs
cat ~/.cache/car-edge-control-panel.log
cat ~/.cache/car-edge-control-panel-startup.log

# Check version
rpm-ostree status

# Check storage
df -h /mnt/storage
lsblk
```

---

## Important Commands

### Update System
```bash
rpm-ostree upgrade  # Downloads and stages update
systemctl reboot    # Applies update
```

### Switch Versions
```bash
# GUI (recommended)
car-edge-switch-version

# Manual
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:v1.0.0-build.123
systemctl reboot
```

### Check Status
```bash
rpm-ostree status
df -h
lsblk
systemctl --user status car-edge-update-checker.timer
```

### Build & Deploy
```bash
git add -A
git commit -m "Description"
git push origin main
# Wait ~10 minutes for GitHub Actions
```

---

## Design Philosophy

1. **GUI-First** - No terminal commands needed for end users
2. **Parent-Friendly** - Clear language, no technical jargon
3. **Commercial-Grade** - Professional versioning and UX
4. **Safety-First** - Multiple checks to prevent OS drive wipes
5. **Cross-Platform** - exFAT for Windows/Mac/Linux compatibility
6. **Debuggable** - Diagnostic tools and comprehensive logging

---

## Documentation Structure

- **README.md** - Project overview and quick start
- **QUICK-REFERENCE.md** - Command reference (deprecated - use GUI)
- **VERSION-TAGS.md** - Semantic versioning guide
- **TROUBLESHOOTING.md** - Common issues and solutions
- **CONFIG.md** - Configuration details
- **ISO-FLASHING.md** - Installation guide
- **DEVELOPMENT-NOTES.md** - This file (session context)

---

## Files Modified in Last Session

- `.github/workflows/build.yml` - Added semantic versioning
- `build_files/files/car-edge-switch-version.sh` - Parse semantic versions
- `build_files/files/car-edge-check-updates.sh` - Version resolution
- `build_files/files/car-edge-control-panel.sh` - Error handling + diagnostic
- `build_files/files/car-edge-control-panel.desktop` - KDE integration
- `README.md` - Updated version table
- `docs/VERSION-TAGS.md` - Complete rewrite for semantic versioning

---

## Next Steps

1. 🎯 Push to GitHub, wait for build, rebase Beelink at 192.168.8.191
2. 🎯 Verify: desktop icon opens panel, wizard runs passwordless, mount-existing works
3. 🎯 Run: `bash test-system.sh` — all checks should pass
4. 🔮 Phase 4 feature: parental controls / app install UX / Gaming Mode Kodi autostart
5. 🔮 Video demo once hardware confirmed working

---

**Last Updated:** May 17, 2026  
**Latest Commit:** 677681b (Fix control panel launch, passwordless storage, data persistence, stubs)  
**Status:** Fixes committed, awaiting hardware validation
