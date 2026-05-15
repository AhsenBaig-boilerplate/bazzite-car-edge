# Testing Checklist - Bazzite Car Edge

## 🎯 Test Categories

### ✅ Level 1: Smoke Tests (Must Pass)
### 🔥 Level 2: Error Handling Tests (Critical)
### 🎮 Level 3: Integration Tests (Important)
### 👥 Level 4: User Experience Tests (Quality)

---

## ✅ Level 1: Smoke Tests

### Build Verification
- [ ] GitHub Actions build completes successfully
- [ ] Image is published to GHCR
- [ ] Image size is reasonable (~3-5GB)
- [ ] Cosign signature verification passes
- [ ] ISO artifact is created (if enabled)

### Basic Boot Test
- [ ] System boots to Gaming Mode (Steam Deck UI)
- [ ] Desktop Mode accessible via Ctrl+Alt+F3
- [ ] KDE Plasma loads without errors
- [ ] No critical errors in journal: `journalctl -b -p err`

### Script Availability
- [ ] `car-edge-setup-wizard` command exists
- [ ] `car-edge-install-apps` command exists
- [ ] `car-edge-backup` command exists
- [ ] `car-edge-upgrade` command exists
- [ ] All scripts have execute permissions

### Auto-Run Verification
- [ ] Setup wizard desktop entry exists in `/etc/skel/`
- [ ] Systemd user service installed correctly
- [ ] Completion marker path is correct

---

## 🔥 Level 2: Error Handling Tests

### No Internet Connection
**Setup:** Disconnect network before running wizard
- [ ] Wizard detects no network
- [ ] Warning dialog appears
- [ ] User can choose to continue
- [ ] Log file records "Network: Not connected"
- [ ] App installation is skipped with clear message
- [ ] Rest of wizard completes successfully
- [ ] Manual install command is shown

**Expected Behavior:**
```
⚠️ No internet connection detected.
Skip app installation?
Command to run later: car-edge-install-apps
```

### No External Drive
**Setup:** Run wizard without external drive connected
- [ ] Wizard detects no drives
- [ ] Clear message: "No external drives detected"
- [ ] Instructions to connect drive are shown
- [ ] User can skip this step
- [ ] Wizard continues to next steps
- [ ] Log shows "No external drives detected"

**Expected Behavior:**
```
⚠️ No external drives detected.
Please connect a drive and run again.
Skip drive setup? [Yes/No]
```

### Insufficient Disk Space
**Setup:** Fill disk to leave <5GB free
- [ ] Pre-flight check detects insufficient space
- [ ] Clear error message with available/required space
- [ ] Wizard exits gracefully
- [ ] Log shows exact space available
- [ ] User gets clear instruction to free space

**Expected Behavior:**
```
❌ Insufficient disk space!
Available: 2GB
Required: 5GB
Please free up space and run again.
```

### Drive Format Failure
**Setup:** Use read-only drive or simulate failure
- [ ] Format command fails
- [ ] Retry dialog appears
- [ ] User can retry (up to 3 times)
- [ ] User can skip after failures
- [ ] Error is logged with details
- [ ] Wizard continues if skipped

**Expected Behavior:**
```
❌ Drive format failed.
Retry? (Attempt 1 of 3)
[Retry] [Skip] [Exit]
```

### Flatpak Install Timeout
**Setup:** Slow network or disable Flathub temporarily
- [ ] Install times out or fails
- [ ] Retry mechanism activates
- [ ] User gets clear error message
- [ ] Manual install command shown
- [ ] Log contains full error details
- [ ] Wizard completes other steps

**Expected Behavior:**
```
❌ Application installation failed.
You can install later: car-edge-install-apps
Continue with other setup? [Yes/No]
```

### Permission Denied
**Setup:** Run wizard as non-sudo user where sudo needed
- [ ] Permission error caught
- [ ] Clear message about needing sudo
- [ ] Retry option offered
- [ ] Skip option available
- [ ] Log shows permission error details

### User Cancels Mid-Process
**Setup:** Click cancel/close during various steps
- [ ] Wizard exits gracefully
- [ ] No completion marker created
- [ ] Can re-run wizard later
- [ ] Log shows "User cancelled"
- [ ] No partial configuration left

### Multiple Drives Connected
**Setup:** Connect 2+ external drives
- [ ] All drives detected and listed
- [ ] Drive selection menu shows all options
- [ ] Correct drive is formatted (user's choice)
- [ ] Wrong drive is not touched
- [ ] Log shows selected drive clearly

---

## 🎮 Level 3: Integration Tests

### Complete Happy Path
**Setup:** Fresh install, all conditions good
- [ ] Boot system for first time
- [ ] Switch to Desktop Mode
- [ ] Wizard auto-launches after 5 seconds
- [ ] Welcome screen appears
- [ ] Select external drive from list
- [ ] Confirm format warning
- [ ] Drive formats successfully
- [ ] Directory structure created
- [ ] Applications install (15-20 min)
- [ ] Progress shown during install
- [ ] Kodi sources configured
- [ ] Permissions granted to Flatpaks
- [ ] First backup created
- [ ] Completion screen shown
- [ ] Return to Gaming Mode option works
- [ ] Completion marker created
- [ ] Wizard doesn't run again on next boot

### Rebase from Standard Bazzite
**Setup:** Start with clean Bazzite system
- [ ] Run: `rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest`
- [ ] Reboot completes successfully
- [ ] All car-edge commands available
- [ ] Run: `car-edge-upgrade`
- [ ] Upgrade helper shows instructions
- [ ] Run: `car-edge-setup-wizard`
- [ ] Wizard runs normally
- [ ] All features work
- [ ] User's existing data preserved

### Application Installation
**Setup:** After wizard completes
- [ ] All 10 applications installed
- [ ] Kodi launches successfully
- [ ] Firefox launches successfully
- [ ] VS Code launches successfully
- [ ] Syncthing launches successfully
- [ ] Kiwix launches successfully
- [ ] VLC launches successfully
- [ ] ProtonUp-Qt launches successfully
- [ ] Heroic Launcher launches successfully
- [ ] PrismLauncher launches successfully
- [ ] Jellyfin Player launches successfully

### External Storage
**Setup:** External drive configured via wizard
- [ ] Drive mounted at `/mnt/storage`
- [ ] fstab entry created with correct UUID
- [ ] Drive auto-mounts on reboot
- [ ] Directory structure exists:
  - [ ] `/mnt/storage/media/movies`
  - [ ] `/mnt/storage/media/tv`
  - [ ] `/mnt/storage/media/music`
  - [ ] `/mnt/storage/games/roms/`
  - [ ] `/mnt/storage/games/saves/`
  - [ ] `/mnt/storage/backups/configs/`
- [ ] Correct permissions (user owns directories)
- [ ] Can write files to all directories

### Kodi Configuration
**Setup:** After wizard completes with external drive
- [ ] Kodi sources.xml created
- [ ] Movies source points to `/mnt/storage/media/movies`
- [ ] TV Shows source points to `/mnt/storage/media/tv`
- [ ] Music source points to `/mnt/storage/media/music`
- [ ] Kodi has permission to access `/mnt/storage`
- [ ] Can navigate to sources in Kodi
- [ ] Can scan for media
- [ ] Metadata scraper works (if online)

### Backup System
**Setup:** After wizard completes
- [ ] First backup created at `/mnt/storage/backups/configs/`
- [ ] Backup file exists with timestamp
- [ ] Backup contains expected files
- [ ] Can extract backup: `tar -tzf backup.tar.gz`
- [ ] fstab included in backup
- [ ] User configs included in backup
- [ ] Flatpak list included in backup
- [ ] RPM-ostree status included in backup

### Logging
**Setup:** After any wizard run
- [ ] Log file created at `~/.cache/car-edge-setup.log`
- [ ] Log has timestamps
- [ ] Log shows all major steps
- [ ] Errors logged with details
- [ ] User choices logged
- [ ] Can review log for troubleshooting

---

## 👥 Level 4: User Experience Tests

### First-Time User (Non-Technical)
**Setup:** Fresh system, handed to non-tech user
- [ ] Can find power button
- [ ] Gaming Mode is intuitive
- [ ] Can switch to Desktop Mode with hint
- [ ] Wizard welcome is understandable
- [ ] Each step has clear instructions
- [ ] Warnings are noticeable
- [ ] Error messages make sense
- [ ] Can complete setup without help
- [ ] Knows what to do next after setup
- [ ] Can find apps in Gaming Mode

### Wizard UX
- [ ] Dialog buttons are clear (Yes/No, Retry/Skip)
- [ ] Progress indicators show during long operations
- [ ] Can't accidentally format wrong drive
- [ ] Warning dialogs are prominent
- [ ] Success messages are encouraging
- [ ] Can skip optional steps easily
- [ ] Instructions are concise
- [ ] No technical jargon in user-facing messages

### Performance
- [ ] Wizard launches within 5 seconds
- [ ] Dialogs appear promptly (no lag)
- [ ] Drive format completes in reasonable time
- [ ] App installation shows progress
- [ ] System remains responsive during install
- [ ] No noticeable freezing
- [ ] Log file doesn't grow too large

### Gaming Mode Integration
- [ ] Can return to Gaming Mode from Desktop
- [ ] Steam Deck UI works normally
- [ ] Controllers detected automatically
- [ ] Installed apps appear in library
- [ ] Kodi accessible from library
- [ ] RetroArch accessible
- [ ] System settings accessible

---

## 🧪 Test Execution Plan

### Phase 1: Smoke Tests (15 minutes)
1. Boot fresh image
2. Verify basic functionality
3. Check all commands exist
4. Review build artifacts

### Phase 2: Error Handling (1 hour)
1. Test each error scenario systematically
2. Document actual vs expected behavior
3. Note any bugs or issues
4. Test retry mechanisms

### Phase 3: Integration Tests (2 hours)
1. Complete happy path walkthrough
2. Test rebase scenario
3. Verify all applications
4. Test storage configuration
5. Verify Kodi setup
6. Test backup system

### Phase 4: User Experience (30 minutes)
1. Simulate non-technical user
2. Look for confusing messages
3. Check timing and performance
4. Verify Gaming Mode integration

---

## 📊 Test Results Template

### Test Run: [Date/Time]
**Tester:** [Name]  
**Environment:** [VM/Hardware]  
**Image Version:** [Commit SHA]  

#### Smoke Tests: [Pass/Fail]
- Build: ✅/❌
- Boot: ✅/❌
- Scripts: ✅/❌
- Auto-run: ✅/❌

#### Error Handling: [Pass/Fail]
- No Internet: ✅/❌
- No Drive: ✅/❌
- Disk Space: ✅/❌
- Format Fail: ✅/❌
- Install Timeout: ✅/❌

#### Integration: [Pass/Fail]
- Happy Path: ✅/❌
- Rebase: ✅/❌
- Applications: ✅/❌
- Storage: ✅/❌
- Kodi: ✅/❌

#### UX: [Pass/Fail]
- First-Time User: ✅/❌
- Wizard Flow: ✅/❌
- Performance: ✅/❌
- Gaming Mode: ✅/❌

**Issues Found:**
1. [Issue description]
2. [Issue description]

**Overall Status:** ✅ PASS / ⚠️ PASS WITH ISSUES / ❌ FAIL

---

## 🐛 Bug Report Template

### Bug: [Short Description]

**Severity:** Critical / High / Medium / Low  
**Category:** Smoke / Error Handling / Integration / UX

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Logs:**
```
[Relevant log entries]
```

**Screenshots:**
[If applicable]

**Environment:**
- Image: [commit SHA]
- Hardware: [VM/Beelink/Other]
- Date: [YYYY-MM-DD]

**Workaround:**
[If any]

---

## ✅ Sign-Off Checklist

Before marking testing complete:

- [ ] All smoke tests pass
- [ ] All critical error scenarios handled
- [ ] Happy path works end-to-end
- [ ] At least 3 error scenarios tested
- [ ] Logging verified
- [ ] Non-technical user can complete setup
- [ ] No data-loss bugs
- [ ] Performance is acceptable
- [ ] Documentation matches actual behavior
- [ ] Test results documented
- [ ] Bugs filed for any issues

**Test Status:** ⏳ IN PROGRESS / ✅ COMPLETE / ❌ BLOCKED

**Blocker Issues:** [List any blocking bugs]

**Ready for Production:** YES / NO / WITH CAVEATS

---

## 📋 Next Steps After Testing

### If All Tests Pass ✅
1. Mark wizard as production-ready
2. Replace v1 with v2 as default
3. Update documentation
4. Record video demo
5. Deploy to test hardware

### If Critical Issues Found ❌
1. File bugs with details
2. Fix critical issues
3. Re-test affected areas
4. Don't proceed until fixed

### If Minor Issues Found ⚠️
1. Document workarounds
2. Add to known issues list
3. Decide if blocking or not
4. Plan fix for next iteration
