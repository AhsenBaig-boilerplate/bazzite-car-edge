# Detailed Test Execution Plan

**Bazzite Car Edge v2.0 - Pre-Production Testing**

This document provides step-by-step instructions for executing the complete test suite. Follow these tests in order before declaring production-ready.

---

## 📋 Test Environment Requirements

### Required Hardware
- **Primary:** Beelink Mini S13 (Intel N150, 16GB RAM, 512GB SSD)
- **Alternative:** Any x86_64 PC with 8GB+ RAM
- **VM Software:** VirtualBox, GNOME Boxes, or VMware
- **External Drive:** USB 3.0 SSD/HDD (128GB+ recommended)
- **USB Flash Drive:** 8GB+ for ISO (for hardware testing)
- **Network:** WiFi access or Ethernet
- **Optional:** NAS/SMB server for network storage testing

### Required Software
- USB flash tool: Balena Etcher or Rufus
- Terminal access
- Web browser for documentation

### Test Media (Optional but Recommended)
- Sample video files (MP4, MKV)
- Sample music files (MP3, FLAC)
- ROM files for testing RetroArch
- Controller (USB or Bluetooth)

---

## Phase 1: Pre-Flight Checks (15 minutes)

### Test 1.1: Build Verification
**Objective:** Confirm latest build succeeded

**Steps:**
1. Visit: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/actions
2. Find latest workflow run (commit: cd3cc1b or later)
3. Verify status: ✅ Green checkmark
4. Check build time: Should complete in ~15 minutes

**Expected Results:**
- Build completes successfully
- No errors in build logs
- ISO artifact available for download

**Pass Criteria:** ✅ Build succeeds with green checkmark

---

### Test 1.2: Download Build Artifacts
**Objective:** Obtain bootable ISO image

**Steps:**
1. Click on successful build
2. Scroll to "Artifacts" section
3. Download ISO file
4. Verify checksum (if provided)
5. Note file size: Should be ~3-5GB

**Expected Results:**
- ISO downloads completely
- File is not corrupted
- Size matches expected range

**Pass Criteria:** ✅ ISO file downloaded and verified

---

### Test 1.3: Documentation Review
**Objective:** Verify all docs are current and accurate

**Steps:**
1. Open each doc in `docs/` directory
2. Check for broken links
3. Verify instructions match current code
4. Check for typos or inconsistencies

**Files to Review:**
- README.md
- ROADMAP.md
- TESTING.md
- docs/QUICK-START.md
- docs/NETWORK-STORAGE.md
- docs/ERROR-HANDLING.md

**Expected Results:**
- All links work
- No references to old filenames
- Command examples are accurate
- Screenshots/examples match current UI

**Pass Criteria:** ✅ Documentation is accurate and complete

---

## Phase 2: Automated Testing (30 minutes)

### Test 2.1: Rebase to Image (Fastest Method)
**Objective:** Deploy via rpm-ostree rebase

**Prerequisites:** 
- Existing Bazzite system (VM or hardware)
- Internet connection

**Steps:**
```bash
# Rebase to Car Edge
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest

# Check status
rpm-ostree status

# Reboot
systemctl reboot
```

**Expected Results:**
- Rebase completes without errors
- New deployment created
- System reboots to Car Edge

**Pass Criteria:** ✅ Rebase succeeds, system boots

---

### Test 2.2: Run Automated Test Suite
**Objective:** Execute automated checks

**Steps:**
```bash
# Switch to Desktop Mode (if in Gaming Mode)
# Press: Ctrl+Alt+F3

# Open Konsole terminal

# Run automated tests
cd /usr/share/doc/bazzite-car-edge  # If tests copied, or
git clone https://github.com/AhsenBaig-boilerplate/bazzite-car-edge.git
cd bazzite-car-edge
./test-system.sh
```

**Expected Results:**
```
Tests Run:    30
Tests Passed: 30
Tests Failed: 0

✅ OVERALL: PASS
```

**Pass Criteria:** ✅ All 30+ tests pass

**If tests fail:**
1. Note which tests failed
2. Check logs for details
3. Document in bug report
4. Continue with manual tests

---

## Phase 3: Manual Wizard Testing (2 hours)

### Test 3.1: Happy Path - Everything Works
**Objective:** Test wizard with ideal conditions

**Setup:**
- External USB drive connected
- Internet connected
- 50GB+ free space

**Steps:**
1. **First Boot:**
   - System should boot to Gaming Mode
   - Wait for wizard to appear (may take 30-60 seconds)
   - Or manually switch to Desktop Mode (Ctrl+Alt+F3)

2. **Welcome Screen:**
   - Verify welcome message appears
   - Check "What will be installed" list
   - Click "Next"

3. **External Drive Setup:**
   - Click "Yes" when asked about external drive
   - Verify drive is detected
   - Select correct drive from list
   - Confirm formatting warning
   - Wait for format to complete
   - Verify success message

4. **Network Storage Setup (Optional):**
   - Click "Yes" if you have SMB/NFS server
   - Select protocol (SMB or NFS)
   - Enter server details:
     * Server: 192.168.1.100 (your NAS IP)
     * Share: media (your share name)
     * Username/password (for SMB)
   - Test connection
   - Verify mount succeeds
   - Or click "No" to skip

5. **Application Installation:**
   - Review app list (10 apps)
   - Click "Yes" to install
   - Monitor progress bar
   - Time installation: Should take 8-15 minutes
   - Verify all apps install successfully

6. **Completion:**
   - Read completion message
   - Note next steps
   - Click "Finish"
   - Verify wizard doesn't run again on next login

**Expected Results:**
- All steps complete successfully
- No errors shown
- Wizard completion marker created
- Log file exists: `~/.cache/car-edge-setup.log`

**Pass Criteria:** ✅ Complete wizard without errors

**Time:** ~20-30 minutes

---

### Test 3.2: No Internet Connection
**Objective:** Test offline behavior

**Setup:**
- Disconnect network BEFORE starting wizard
- External drive connected

**Steps:**
1. Start wizard
2. Proceed through external drive setup
3. Skip network storage (no internet)
4. Observe application installation step

**Expected Results:**
- Pre-flight check detects no network
- Warning message: "Skipping app installation (no internet)"
- Wizard continues without apps
- Instructions shown: `car-edge-install-apps` to run later
- Wizard completes successfully

**Pass Criteria:** ✅ Graceful skip with clear message

**Time:** ~5 minutes

---

### Test 3.3: No External Drive
**Objective:** Test without external storage

**Setup:**
- NO external drive connected
- Internet connected

**Steps:**
1. Start wizard
2. Click "No" when asked about external drive
3. Skip network storage
4. Proceed to app installation

**Expected Results:**
- Wizard continues normally
- Apps install successfully
- No errors about missing drive
- User can add drive later

**Pass Criteria:** ✅ Completes without external drive

**Time:** ~15 minutes

---

### Test 3.4: Drive Format Failure Simulation
**Objective:** Test drive format error handling

**Setup:**
- Use external drive with read-only filesystem
- Or disconnect drive mid-format (if safe to do so)

**Steps:**
1. Start wizard
2. Select external drive
3. Attempt to format
4. Observe error handling

**Expected Results:**
- Clear error message shown
- Retry option offered
- User can skip drive setup
- Wizard doesn't crash

**Pass Criteria:** ✅ Error handled gracefully with retry option

**Time:** ~10 minutes

---

### Test 3.5: User Cancellation
**Objective:** Test canceling mid-wizard

**Setup:**
- Normal conditions

**Steps:**
1. Start wizard
2. Click through first few screens
3. Cancel during app installation (if possible)
4. Restart wizard

**Expected Results:**
- Cancel option works (if available)
- Wizard can be restarted
- No corruption or hung processes
- Log shows cancellation

**Pass Criteria:** ✅ Safe cancellation, can restart

**Time:** ~5 minutes

---

### Test 3.6: Network Storage - SMB/CIFS
**Objective:** Test SMB network mount

**Setup:**
- SMB/CIFS server available (Synology, Windows share, etc.)
- Valid credentials

**Steps:**
1. Start wizard
2. Select "Yes" for network storage
3. Choose "SMB/CIFS"
4. Enter server: `192.168.1.x` or `nas.local`
5. Enter share path: `media`
6. Enter username and password
7. Test connection

**Expected Results:**
- Connection test succeeds
- Mount created at `/mnt/network-storage`
- Can browse files: `ls /mnt/network-storage`
- Auto-mount configured
- Credentials stored securely (mode 600)

**Verification:**
```bash
# Check mount
mount | grep network-storage

# Check systemd service
systemctl --user status mnt-network\\x2dstorage.mount

# Test access
ls /mnt/network-storage
```

**Pass Criteria:** ✅ SMB mount works, files accessible

**Time:** ~10 minutes

---

### Test 3.7: Network Storage - NFS
**Objective:** Test NFS network mount

**Setup:**
- NFS server available (Linux server, TrueNAS, etc.)
- Exports configured

**Steps:**
1. Start wizard (or run: `car-edge-network-mounts configure`)
2. Select "Yes" for network storage
3. Choose "NFS"
4. Enter server: `192.168.1.x`
5. Enter path: `/export/media`
6. Test connection

**Expected Results:**
- Connection test succeeds
- Mount created at `/mnt/network-storage`
- Can browse files
- Auto-mount configured

**Pass Criteria:** ✅ NFS mount works, files accessible

**Time:** ~10 minutes

---

## Phase 4: Application Testing (1 hour)

### Test 4.1: Verify All Apps Installed
**Objective:** Confirm all 10 apps are present

**Steps:**
```bash
# List installed Flatpak apps
flatpak list | grep -E "(Kodi|Firefox|Heroic|Prism|Syncthing|Kiwix|VLC|ProtonUp|Jellyfin|Code)"
```

**Expected Apps:**
1. tv.kodi.Kodi
2. org.mozilla.firefox
3. com.heroicgameslauncher.hgl
4. org.prismlauncher.PrismLauncher
5. me.kozec.syncthingtk
6. org.kiwix.desktop
7. org.videolan.VLC
8. net.davidotek.pupgui2
9. com.github.iwalton3.jellyfin-media-player
10. com.visualstudio.code

**Pass Criteria:** ✅ All 10 apps listed

---

### Test 4.2: Launch Each Application
**Objective:** Verify apps start without errors

**From Desktop Mode:**
1. **Kodi:** Applications → Kodi
   - Should launch to main menu
   - Check for media sources
   
2. **Firefox:** Applications → Firefox
   - Opens to home page
   - Can navigate to websites

3. **VS Code:** Applications → VS Code
   - Opens editor
   - Can create/edit files

4. **VLC:** Applications → VLC
   - Opens player interface
   - Can play test video

5. **Others:** Launch remaining apps, verify they open

**Pass Criteria:** ✅ All apps launch successfully

---

### Test 4.3: Gaming Mode Access
**Objective:** Verify apps accessible from Gaming Mode

**Steps:**
1. Return to Gaming Mode: Steam Menu → Power → Return to Gaming Mode
2. Press Steam button
3. Go to Library
4. Find "Non-Steam Games" section
5. Check for: Kodi, Firefox, Heroic, etc.

**Expected Results:**
- Apps appear in library
- Can launch from Gaming Mode
- Controller navigation works

**Pass Criteria:** ✅ Apps accessible in Gaming Mode

---

## Phase 5: System Integration Testing (1 hour)

### Test 5.1: External Storage Structure
**Objective:** Verify directory structure

**Steps:**
```bash
# Check mount point
ls -la /mnt/storage

# Verify subdirectories
ls -la /mnt/storage/media
ls -la /mnt/storage/games/roms
```

**Expected Structure:**
```
/mnt/storage/
├── media/
│   ├── movies/
│   ├── tv/
│   ├── music/
│   └── photos/
├── games/
│   ├── roms/
│   └── saves/
├── documents/
├── archives/
└── sync/
```

**Pass Criteria:** ✅ All directories exist with correct permissions

---

### Test 5.2: Kodi Media Library
**Objective:** Test Kodi media scanning

**Steps:**
1. Copy test media files to `/mnt/storage/media/movies/`
2. Launch Kodi
3. Add media source: `/mnt/storage/media/movies`
4. Scan library
5. Verify movies appear

**Expected Results:**
- Kodi detects media source
- Scanning completes
- Metadata/posters downloaded
- Movies playable

**Pass Criteria:** ✅ Kodi successfully scans and plays media

---

### Test 5.3: RetroArch Configuration
**Objective:** Verify RetroArch paths

**Steps:**
1. Launch RetroArch
2. Settings → Directory
3. Check paths:
   - ROMs: `/mnt/storage/games/roms`
   - Saves: `/mnt/storage/games/saves`

4. Copy test ROM to `/mnt/storage/games/roms/NES/`
5. Load Content → Navigate to ROM
6. Select core and launch

**Expected Results:**
- Paths pre-configured correctly
- Can load ROM
- Game runs (if core installed)

**Pass Criteria:** ✅ RetroArch configured, ROMs accessible

---

### Test 5.4: Backup System
**Objective:** Test configuration backup

**Steps:**
```bash
# Run backup
car-edge-backup

# Check backup location
ls -la ~/.config/car-edge-backups/

# Verify backup contents
tar -tzf ~/.config/car-edge-backups/backup-YYYYMMDD-HHMMSS.tar.gz
```

**Expected Results:**
- Backup created successfully
- Tar file exists
- Contains config files
- Media not included (too large)

**Pass Criteria:** ✅ Backup completes, file created

---

### Test 5.5: System Updates
**Objective:** Test rpm-ostree updates

**Steps:**
```bash
# Check for updates
rpm-ostree upgrade --check

# If updates available, apply
rpm-ostree upgrade

# Check status
rpm-ostree status

# Reboot if needed
systemctl reboot

# After reboot, verify rollback capability
rpm-ostree rollback --preview
```

**Expected Results:**
- Can check for updates
- Updates apply cleanly
- New deployment created
- Rollback available

**Pass Criteria:** ✅ Update system works, rollback available

---

## Phase 6: Hardware-Specific Testing (Beelink Mini S13)

### Test 6.1: Performance Validation
**Objective:** Verify Intel N150 optimization

**Steps:**
1. Boot on Beelink Mini S13
2. Check CPU governor:
   ```bash
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   ```
3. Verify TLP config:
   ```bash
   cat /etc/tlp.d/90-car-edge.conf
   ```
4. Test under load:
   - Launch Kodi + game simultaneously
   - Monitor CPU usage: `htop`
   - Check temperatures
   - Verify fan behavior

**Expected Results:**
- AC: performance governor
- Battery: powersave governor
- TLP active
- No thermal throttling
- Smooth UI performance

**Pass Criteria:** ✅ System optimized for N150

---

### Test 6.2: Controller Detection
**Objective:** Test USB and Bluetooth controllers

**Steps:**
1. Connect USB controller
2. Verify automatic detection
3. Test in Gaming Mode
4. Test in RetroArch
5. Try Bluetooth pairing (if available)

**Expected Results:**
- USB controllers auto-detected
- Work in Steam UI
- Work in games
- Bluetooth pairing (if hardware supports)

**Pass Criteria:** ✅ Controllers work without configuration

---

### Test 6.3: WiFi and Network Storage
**Objective:** Test real-world network usage

**Steps:**
1. Connect to WiFi
2. Verify network storage auto-mounts
3. Disconnect WiFi
4. Verify unmount
5. Reconnect WiFi
6. Verify remount

**Expected Results:**
- WiFi connects reliably
- Network storage auto-mounts
- Graceful handling of network changes
- No errors or hangs

**Pass Criteria:** ✅ Network storage auto-mount works

---

## Phase 7: User Experience Testing

### Test 7.1: Non-Technical User Walkthrough
**Objective:** Have someone unfamiliar test setup

**Steps:**
1. Give fresh install to non-technical person
2. Provide only Quick Start Guide
3. Observe (don't help unless stuck >5 minutes)
4. Note pain points
5. Collect feedback

**Expected Results:**
- User completes setup without help
- Wizard is intuitive
- Errors are clear
- User feels confident

**Pass Criteria:** ✅ Non-tech user succeeds independently

---

### Test 7.2: Wizard UX Evaluation

**Evaluate:**
- [ ] Clear progress indication
- [ ] Helpful error messages
- [ ] Reasonable timeouts
- [ ] Can cancel/retry
- [ ] Estimated time accurate
- [ ] Success confirmation clear

**Pass Criteria:** ✅ Positive UX feedback

---

## Test Results Summary

### Test Completion Checklist

- [ ] Phase 1: Pre-Flight Checks (15 min)
- [ ] Phase 2: Automated Testing (30 min)
- [ ] Phase 3: Manual Wizard Testing (2 hours)
- [ ] Phase 4: Application Testing (1 hour)
- [ ] Phase 5: System Integration Testing (1 hour)
- [ ] Phase 6: Hardware-Specific Testing (2 hours)
- [ ] Phase 7: User Experience Testing (1 hour)

**Total Estimated Time:** 7-8 hours

---

## Bug Reporting Template

**Use this template for any issues found:**

```markdown
## Bug Report

**Test Phase:** [Phase X.Y]
**Test Name:** [Test name]
**Severity:** [Critical / High / Medium / Low]
**Date:** [YYYY-MM-DD]

### Description
[What went wrong]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior
[What should have happened]

### Actual Behavior
[What actually happened]

### Environment
- Hardware: [VM / Beelink Mini S13 / Other]
- Build: [Commit SHA / ISO name]
- Network: [Connected / Disconnected]
- External Drive: [Connected / Not connected]

### Logs
```
[Paste relevant logs from ~/.cache/car-edge-setup.log]
```

### Screenshots
[If applicable]

### Workaround
[If found]
```

---

## Sign-Off Criteria

**Ready for production when:**

✅ All Phase 1-5 tests pass  
✅ Phase 6 hardware tests pass (or N/A if no hardware)  
✅ Phase 7 UX tests show positive feedback  
✅ Zero critical bugs  
✅ High severity bugs have documented workarounds  
✅ Documentation accurately reflects system behavior  
✅ Video demo recorded and published  

**Sign-Off:** 
- [ ] Developer approval
- [ ] Test lead approval
- [ ] UX validation complete
- [ ] Documentation review complete

---

## Next Steps After Testing

1. **Fix Critical Bugs** - Block release
2. **Document Known Issues** - Add to TROUBLESHOOTING.md
3. **Record Video Demo** - 2-5 minute walkthrough
4. **Create Release** - Tag version, publish ISO
5. **Announce** - README badge, social media, etc.

**Target:** Production-ready Bazzite Car Edge v2.0
