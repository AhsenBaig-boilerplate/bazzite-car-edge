# System Updates - Bazzite Car Edge

## 🔄 Update System Overview

Bazzite Car Edge uses an **automatic background update system** designed for car entertainment use:

1. **Downloads updates in the background** while you use the system
2. **Shows persistent notification** in system tray when ready
3. **You choose when to apply** the update (system restart required)
4. **Entertainment functions uninterrupted** during download

This is similar to Windows Update or modern Linux update managers.

---

## 🎯 How It Works

### Automatic Update Process

```
Timer Runs (Daily 11 AM + 30 min after boot)
    ↓
Checks for new :latest image version
    ↓
If update available → Downloads in background
    ↓
Shows system tray notification "Update Ready"
    ↓
You continue using system normally
    ↓
When convenient → Click to apply update
    ↓
System reboots to apply update
    ↓
Updated system boots up
```

### Background Download

**Key Feature:** Updates download while you use the system:
- ✅ Watch movies in Kodi
- ✅ Play games
- ✅ Browse the web
- ✅ Listen to music

The download happens **silently in the background** without interrupting your entertainment.

---

## 💻 User Experience

### 1. Update Available Notification

When an update is found, you'll see:

**System Tray Notification (Persistent):**
```
┌───────────────────────────────────────┐
│  🔄 Update Ready to Install           │
├───────────────────────────────────────┤
│  System update downloaded!            │
│                                        │
│  Version: 1a2b3c4                     │
│                                        │
│  Restart when convenient to apply.    │
│  Use: car-edge-apply-update           │
└───────────────────────────────────────┘
```

**This notification stays visible** in your system tray until you apply the update.

### 2. Download in Progress

While downloading:
```
┌───────────────────────────────────────┐
│  ⬇️ Downloading Update                 │
├───────────────────────────────────────┤
│  Downloading system update in the     │
│  background...                         │
│                                        │
│  Your entertainment system will       │
│  remain fully functional.             │
└───────────────────────────────────────┘
```

### 3. Applying the Update

When you're ready to apply:

**Option A: Use GUI Command**
1. Open Konsole
2. Run: `car-edge-apply-update`
3. Confirm when prompted
4. System reboots in 10 seconds

**Option B: Manual Reboot**
1. Save any work
2. Reboot system (Start Menu → Leave → Restart)
3. Update applies automatically on boot

---

## 🛠️ Commands

### Check for Updates Now
```bash
# Manually trigger update check
car-edge-check-updates
```

This command:
- Checks if update is available
- Downloads in background if found
- Shows notification when ready

### Apply Staged Update
```bash
# Apply downloaded update (requires reboot)
car-edge-apply-update
```

This command:
- Checks if update is staged
- Shows confirmation dialog
- Reboots system to apply

### View Update Status
```bash
# See current and staged deployments
rpm-ostree status
```

Output:
```
State: idle
Deployments:
● ostree://bazzite-car-edge:latest
                   Version: 41.20250515.0 (2025-05-15T12:00:00Z)
                    Commit: 1a2b3c4...
              GPGSignature: (signed by...)

  ostree://bazzite-car-edge:latest
                   Version: 41.20250514.0 (2025-05-14T12:00:00Z)
                    Commit: 5d6e7f8...
              GPGSignature: (signed by...)
                     State: pending    👈 Update staged!
```

If you see `State: pending`, an update is ready to apply on next reboot.

---

## ⚙️ Configuration

### Automatic Update Schedule

Updates are checked:
- **Daily at 11:00 AM**
- **30 minutes after boot**
- **Persistent** (catches up if system was off)

### View Update Timer Status
```bash
# See when next check will run
systemctl --user list-timers

# View service status
systemctl --user status car-edge-update-checker.timer
```

### Disable Automatic Updates (Optional)
```bash
# Stop automatic update checks
systemctl --user disable car-edge-update-checker.timer
systemctl --user stop car-edge-update-checker.timer

# Re-enable later
systemctl --user enable car-edge-update-checker.timer
systemctl --user start car-edge-update-checker.timer
```

### Check Update Logs
```bash
# View update check history
cat ~/.cache/car-edge-update-checker.log

# Check if update is staged
cat ~/.cache/car-edge-update-staged
```

---

## 🚨 Common Scenarios

### "I saw a notification but dismissed it"

No problem! The update is already downloaded and staged.

To apply:
```bash
car-edge-apply-update
```

Or just reboot your system - the update will apply automatically.

### "I'm in the middle of a movie/game"

**Perfect!** The update is designed for this:
1. Update downloads in the background
2. Notification appears but doesn't interrupt
3. **Apply the update later** when you're done
4. Update will still be there (staged) whenever you're ready

### "I want to update right now"

```bash
# Check and download
car-edge-check-updates

# Wait for download to complete (watch logs)
tail -f ~/.cache/car-edge-update-checker.log

# Apply when ready
car-edge-apply-update
```

### "Update failed to download"

The system will automatically retry at the next scheduled check (11 AM or 30 min after next boot).

To retry manually:
```bash
car-edge-check-updates
```

### "I want to see what changed in the update"

```bash
# Compare current vs staged
rpm-ostree status

# View commit details
rpm-ostree db diff <old-commit> <new-commit>
```

---

## 🔄 Rollback (If Needed)

If an update causes issues:

```bash
# Rollback to previous version
rpm-ostree rollback

# Reboot to activate rollback
systemctl reboot
```

After reboot, you'll be back on the previous working version.

---

## 🎯 Why This Design?

### Car Entertainment System Priorities

1. **Never interrupt entertainment**
   - Download in background
   - Apply when convenient
   
2. **Simple user experience**
   - Persistent visual indicator
   - One command to apply
   
3. **Safe and reliable**
   - Updates staged before applying
   - Easy rollback if needed
   
4. **Automatic maintenance**
   - No need to remember to check
   - Downloads automatically

### Comparison to Other Systems

| Feature | Car Edge | Windows Update | GNOME Software | Manual rpm-ostree |
|---------|----------|----------------|----------------|-------------------|
| Background download | ✅ | ✅ | ✅ | ❌ |
| Persistent notification | ✅ | ✅ | ✅ | ❌ |
| Apply when ready | ✅ | ✅ | ✅ | ✅ |
| No interruptions | ✅ | ❌ (forced) | ✅ | ✅ |
| Automatic checks | ✅ | ✅ | ✅ | ❌ |
| One-command apply | ✅ | ✅ | ✅ | ❌ |

---

## 📝 Technical Details

### rpm-ostree Update Model

Bazzite Car Edge uses **rpm-ostree**, an immutable OS model:

1. **Check**: `rpm-ostree upgrade --check` queries registry
2. **Download & Stage**: `rpm-ostree upgrade` downloads and prepares
3. **Apply**: Reboot to activate staged deployment
4. **Rollback**: Previous deployment kept for safety

### Update States

- **No update available**: System is current
- **Update available**: Detected but not downloaded
- **Downloading**: Update being downloaded
- **Staged (pending)**: Downloaded, ready to apply on reboot
- **Applied**: Active after reboot

### Notification System

Uses standard Linux notification daemon:
- **notify-send**: Cross-desktop notifications
- **Urgency: critical**: Persistent in system tray
- **Timeout: 0**: Doesn't auto-dismiss
- **Actions**: Can trigger commands (future enhancement)

---

## 🐛 Troubleshooting

### Updates not appearing

```bash
# Check timer is running
systemctl --user status car-edge-update-checker.timer

# Manually trigger check
car-edge-check-updates

# View logs
cat ~/.cache/car-edge-update-checker.log
```

### Notification not showing

```bash
# Check if update is staged
rpm-ostree status | grep pending

# If staged, apply manually
car-edge-apply-update

# Check DISPLAY variable
echo $DISPLAY

# Test notification system
notify-send "Test" "Testing notifications"
```

### Download stuck or slow

```bash
# Check network
ping -c 3 ghcr.io

# Cancel current download
rpm-ostree cancel

# Retry
car-edge-check-updates
```

### Update fails to apply

```bash
# Check for errors
rpm-ostree status

# Try manual upgrade
rpm-ostree upgrade

# If still fails, check logs
journalctl -u rpm-ostreed -b
```

---

## 📚 Additional Resources

- [BACKUP-RESTORE.md](BACKUP-RESTORE.md) - Backup before updates
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues
- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Command cheat sheet
- [rpm-ostree documentation](https://coreos.github.io/rpm-ostree/)
