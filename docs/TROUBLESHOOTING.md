# Troubleshooting - Bazzite Car Edge

## 🔧 Common Issues & Solutions

---

## 🚫 System Won't Boot

### Issue: Black screen after boot
**Symptoms:** System powers on, but display stays black

**Solutions:**
1. **Wait 2-3 minutes** - First boot takes longer
2. **Check HDMI connection** - Try different cable/port
3. **BIOS display settings** - Ensure correct output selected
4. **Boot to previous deployment:**
   - At GRUB menu, select previous ostree entry
   - System will boot last-known-good version

### Issue: Stuck at GRUB menu
**Symptoms:** Boot menu appears but system won't proceed

**Solutions:**
1. **Select first boot entry** - Usually auto-selected in 5 seconds
2. **Boot previous deployment** - Try second entry in list
3. **Check boot order in BIOS** - Ensure correct drive is first

### Issue: "Emergency mode" after boot
**Symptoms:** Dropped to emergency shell

**Solutions:**
```bash
# Check what failed
systemctl --failed

# Common cause: /mnt/storage not mounted
# Remove 'nofail' temporarily:
nano /etc/fstab
# Comment out storage line with #
# Ctrl+O, Enter, Ctrl+X
reboot

# Or mount manually after boot:
sudo mount UUID=your-uuid /mnt/storage
```

---

## 📦 Flatpak Issues

### Issue: "car-edge-install-apps" fails
**Symptoms:** Script errors during app installation

**Solutions:**
```bash
# Run with verbose output
car-edge-install-apps 2>&1 | tee install-log.txt

# Check specific failure
cat install-log.txt | grep -i error

# Manual install problematic app
flatpak install -y flathub tv.kodi.Kodi
```

### Issue: Flatpak app won't launch
**Symptoms:** Click app, nothing happens

**Solutions:**
```bash
# Repair Flatpak
flatpak repair

# Check app is installed
flatpak list --app | grep -i kodi

# Try launching from terminal
flatpak run tv.kodi.Kodi

# Reinstall if needed
flatpak uninstall tv.kodi.Kodi
flatpak install flathub tv.kodi.Kodi
```

### Issue: Permission denied in Flatpak apps
**Symptoms:** Can't access external drives or folders

**Solutions:**
```bash
# Grant filesystem access (example: Kodi)
flatpak override tv.kodi.Kodi --filesystem=/mnt/storage

# Grant network access
flatpak override tv.kodi.Kodi --share=network

# View current permissions
flatpak info --show-permissions tv.kodi.Kodi

# Use Flatseal for GUI management
flatpak install flathub com.github.tchx84.Flatseal
flatpak run com.github.tchx84.Flatseal
```

---

## 💾 Storage Issues

### Issue: External drive won't mount
**Symptoms:** `/mnt/storage` empty or missing

**Solutions:**
```bash
# Check drive is detected
lsblk
# Look for your drive (e.g., sdb1)

# Check drive health
sudo smartctl -H /dev/sdb

# Get UUID
sudo blkid | grep /dev/sdb1

# Manual mount test
sudo mount /dev/sdb1 /mnt/storage
ls /mnt/storage

# Fix fstab if needed
sudo nano /etc/fstab
# Verify UUID matches blkid output
```

### Issue: "Read-only file system"
**Symptoms:** Can't write to /mnt/storage

**Solutions:**
```bash
# Remount read-write
sudo mount -o remount,rw /mnt/storage

# Check filesystem
sudo umount /mnt/storage
sudo fsck.ext4 /dev/sdb1
sudo mount /mnt/storage

# Check permissions
ls -la /mnt/storage
# Should show your user as owner, or use chmod
```

### Issue: Out of space on root
**Symptoms:** System says disk full, but /mnt/storage has space

**Solutions:**
```bash
# Check actual usage
df -h

# Clean up old deployments
sudo rpm-ostree cleanup -bp

# Remove old container images
podman system prune -a

# Clear system cache
sudo rm -rf /var/cache/*

# Check journal logs size
journalctl --disk-usage
# Clean if needed:
sudo journalctl --vacuum-size=100M
```

---

## 🎬 Kodi Issues

### Issue: Kodi won't scan media
**Symptoms:** Library empty despite files present

**Solutions:**
```bash
# Check Kodi can access files
flatpak override tv.kodi.Kodi --filesystem=/mnt/storage

# Verify file permissions
ls -la /mnt/storage/media/movies/

# Force rescan from Kodi
Settings → Media → Library → Update Library

# Check Kodi logs
flatpak run tv.kodi.Kodi 2>&1 | grep -i error
```

### Issue: Kodi playback stuttering
**Symptoms:** Video lag or audio sync issues

**Solutions:**
1. **Enable hardware acceleration:**
   - Settings → Player → Videos
   - Enable "Allow hardware acceleration - VAAPI"

2. **Check system load:**
   ```bash
   htop
   # Look for high CPU usage
   ```

3. **Adjust video cache:**
   - Create/edit `~/.var/app/tv.kodi.Kodi/data/userdata/advancedsettings.xml`
   - Add buffer settings

4. **Use different video output:**
   - Settings → Player → Videos → Render method

### Issue: Kodi remote not working
**Symptoms:** Phone app can't connect

**Solutions:**
```bash
# Enable web server in Kodi
Settings → Services → Control → Allow remote control via HTTP

# Check firewall
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

# Verify Kodi is listening
netstat -tuln | grep 8080
```

---

## 🔄 Syncthing Issues

### Issue: Syncthing won't connect to home
**Symptoms:** Device shows "Disconnected"

**Solutions:**
1. **Check network:**
   ```bash
   ping 192.168.1.100  # Your home server IP
   ```

2. **Verify device IDs match**
   - Both sides must add each other

3. **Check firewall:**
   ```bash
   # On car system
   sudo firewall-cmd --add-service=syncthing --permanent
   sudo firewall-cmd --reload
   ```

4. **Use relay servers:**
   - Settings → Connections → Enable relaying

### Issue: Syncthing using too much battery
**Symptoms:** High power drain when on battery

**Solutions:**
- Disable syncing on battery in TLP:
  ```bash
  sudo nano /etc/tlp.d/90-car-edge.conf
  # Add:
  # DEVICES_TO_DISABLE_ON_BAT="com.github.zocker_160.SyncThingy"
  ```

- Or pause syncing manually when on battery

---

## 🎮 Gaming Issues

### Issue: Steam won't launch games
**Symptoms:** Click Play, nothing happens

**Solutions:**
```bash
# Check Proton compatibility layer
# In Steam: Right-click game → Properties → Compatibility
# Enable: "Force the use of a specific Steam Play compatibility tool"
# Select: Proton 9.0 or Proton Experimental

# Update Proton via ProtonUp-Qt
flatpak run net.davidotek.pupgui2

# Check logs
journalctl -b | grep -i steam
```

### Issue: RetroArch core won't load
**Symptoms:** ROM won't start, returns to menu

**Solutions:**
```bash
# Download core from RetroArch
Main Menu → Load Core → Download Core

# Check ROM file format is correct
# NES should be .nes, not .zip

# Verify ROM path permissions
ls -la /mnt/storage/games/roms/

# Grant RetroArch access
flatpak override org.libretro.RetroArch --filesystem=/mnt/storage
```

### Issue: Controller not detected
**Symptoms:** Gamepad doesn't work in Gaming Mode

**Solutions:**
1. **Wired controllers:**
   - Unplug and replug
   - Try different USB port

2. **Bluetooth controllers:**
   ```bash
   # From Desktop Mode
   bluetoothctl
   power on
   scan on
   # Wait for device to appear
   pair XX:XX:XX:XX:XX:XX
   connect XX:XX:XX:XX:XX:XX
   trust XX:XX:XX:XX:XX:XX
   ```

3. **Steam controller config:**
   - Steam → Settings → Controller
   - Set up custom layout if needed

---

## 🌐 Network Issues

### Issue: Wi-Fi won't connect
**Symptoms:** Network appears but connection fails

**Solutions:**
```bash
# From Desktop Mode terminal
nmcli device wifi list

# Connect with explicit command
nmcli device wifi connect "SSID" password "PASSWORD"

# Check for MAC filtering on router
ip link show
# Note MAC address, add to router whitelist

# Forget and reconnect
nmcli connection delete "SSID"
nmcli device wifi connect "SSID" password "PASSWORD"
```

### Issue: No internet after connecting
**Symptoms:** Wi-Fi connected but no web access

**Solutions:**
```bash
# Check DNS
nmcli device show | grep DNS

# Set DNS manually
nmcli connection modify "SSID" ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection up "SSID"

# Test connectivity
ping 8.8.8.8       # Google DNS (tests routing)
ping google.com    # Tests DNS resolution
```

---

## ⚡ Performance Issues

### Issue: System feels slow
**Symptoms:** Laggy UI, delayed inputs

**Solutions:**
```bash
# Check system load
htop

# Check disk I/O
iotop

# Verify TLP is active
sudo tlp-stat --processor

# Check for thermal throttling
sensors
# Temps should be below 80°C

# Clean up space
rpm-ostree cleanup -bp
podman system prune -a
```

### Issue: High temperature
**Symptoms:** Fan loud, system hot

**Solutions:**
```bash
# Monitor temps
watch -n 2 sensors

# Verify TLP is running
sudo systemctl status tlp

# Check if dust blocking vents
# Clean Beelink Mini S13 vents with compressed air

# Adjust TLP for cooler operation
sudo nano /etc/tlp.d/90-car-edge.conf
# Change:
# CPU_SCALING_GOVERNOR_ON_AC=powersave
```

---

## 🔄 Update Issues

### Issue: "rpm-ostree upgrade" fails
**Symptoms:** Update errors out midway

**Solutions:**
```bash
# Check available space
df -h /

# Clean up old deployments
rpm-ostree cleanup -bp

# Retry update
rpm-ostree upgrade

# Force refresh metadata
rpm-ostree upgrade --check

# Manual rebase (if corrupted)
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest
```

### Issue: System broke after update
**Symptoms:** Boots but things don't work

**Solutions:**
```bash
# Rollback immediately
rpm-ostree rollback
systemctl reboot

# Report issue at GitHub
# Then wait for fix and re-update
```

---

## 🆘 Emergency Recovery

### Complete system unresponsive

**From hard reset:**
1. Power off (hold power button 10 seconds)
2. Power on, press F12/DEL for boot menu
3. Select previous boot entry in GRUB
4. System boots last-known-good state

### Lost root access

**Reset password:**
1. Boot to GRUB
2. Press `e` to edit boot entry
3. Find line starting with `linux`
4. Add `rd.break` at end
5. Press `Ctrl+X` to boot
6. At emergency shell:
   ```bash
   mount -o remount,rw /sysroot
   chroot /sysroot
   passwd
   # Set new password
   touch /.autorelabel
   exit
   reboot
   ```

---

## 📝 Getting Help

### Collect System Information

```bash
# Create debug report
rpm-ostree status > ~/debug-info.txt
uname -a >> ~/debug-info.txt
lsblk >> ~/debug-info.txt
flatpak list >> ~/debug-info.txt
journalctl -b -p err >> ~/debug-info.txt
```

### Report Issue on GitHub

1. Go to: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/issues
2. Click "New Issue"
3. Include:
   - What you were trying to do
   - What happened instead
   - Output of debug commands
   - Screenshots if helpful

### Community Support

- **Universal Blue Discord:** https://discord.gg/WEu6BdFEtp
- **Bazzite Community:** https://universal-blue.discourse.group/
- **Reddit:** r/bazzite

---

## 💡 Prevention Tips

- ✅ Always backup before major changes (`car-edge-backup`)
- ✅ Test updates on non-critical times
- ✅ Keep external drive properly unmounted before unplugging
- ✅ Don't force power off during updates
- ✅ Monitor system health periodically
- ✅ Keep documentation of custom changes

---

## ⏭️ Related Documentation

- **[BACKUP-RESTORE.md](BACKUP-RESTORE.md)** - Recovery procedures
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Command reference
- **[CONFIGURATION.md](CONFIGURATION.md)** - System configuration
