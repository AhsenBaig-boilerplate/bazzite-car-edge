# Network Storage Guide

**Access your home media server from your car entertainment system**

Bazzite Car Edge supports mounting network storage (SMB/CIFS and NFS) to access media files from your home server without needing to copy everything to an external drive.

---

## 🌐 What is Network Storage?

Network storage allows your car system to:
- **Stream media** from your home NAS/server when parked at home
- **Access large libraries** without local storage limitations
- **Sync automatically** when connected to home WiFi
- **Backup configs** to home server

---

## 🔧 Supported Protocols

### SMB/CIFS (Recommended)
- **Best for:** Windows shares, Synology, QNAP, most NAS devices
- **Setup complexity:** Easy
- **Authentication:** Username/password
- **Performance:** Excellent

### NFS
- **Best for:** Linux/Unix servers, advanced users
- **Setup complexity:** Moderate
- **Authentication:** IP-based
- **Performance:** Excellent (slightly faster than SMB)

---

## 🚀 Quick Setup

### Option 1: During First Boot (Recommended)

The setup wizard includes an optional network storage configuration step:

1. **Run the wizard:** `car-edge-setup-wizard` (or it runs automatically on first boot)
2. **Choose network storage:** When prompted, say "Yes"
3. **Select protocol:** SMB/CIFS or NFS
4. **Enter server details:**
   - Server IP/hostname: `192.168.1.100` or `nas.local`
   - Share path: `media` (SMB) or `/export/media` (NFS)
5. **Enter credentials:** (SMB only) username and password
6. **Test connection:** Wizard will mount and verify

**Done!** Network storage will auto-mount when on your home network.

### Option 2: Manual Configuration

```bash
# Run interactive configuration
car-edge-network-mounts configure

# Follow the prompts to configure SMB or NFS
```

---

## 📋 Configuration Examples

### Example 1: Synology NAS (SMB)
```
Server: 192.168.1.10
Share Path: media
Username: caruser
Password: <your-password>
```

### Example 2: TrueNAS (NFS)
```
Server: 192.168.1.20
Share Path: /mnt/tank/media
Username: (not needed)
Password: (not needed)
```

### Example 3: Raspberry Pi NFS Server
```
Server: raspberrypi.local
Share Path: /srv/storage
Username: (not needed)
Password: (not needed)
```

### Example 4: Windows Share
```
Server: DESKTOP-PC
Share Path: SharedMedia
Username: YourWindowsUser
Password: <your-password>
```

---

## 🎮 Usage

### Auto-Mounting

Network storage auto-mounts when:
- ✅ Connected to home WiFi
- ✅ Server is reachable
- ✅ System boots

**Mount point:** `/mnt/network-storage`

### Manual Control

```bash
# Check mount status
car-edge-network-mounts status

# Test connection
car-edge-network-mounts test

# Mount now
car-edge-network-mounts enable

# Unmount
car-edge-network-mounts disable

# Remount (fix connection issues)
car-edge-network-mounts remount

# Reconfigure
car-edge-network-mounts configure
```

### In Kodi

Network storage appears automatically in Kodi:
1. **Open Kodi**
2. **Add media source:** `/mnt/network-storage`
3. **Kodi scans** movies, TV shows, music

---

## 🔒 Security Best Practices

### For SMB/CIFS

1. **Create dedicated user** on your NAS
   - Limited to media access only
   - No admin privileges

2. **Use strong password**
   - Stored encrypted in `~/.config/car-edge/`
   - File mode 600 (owner-only access)

3. **Configure NAS firewall**
   - Allow SMB only from home network
   - Block external access

### For NFS

1. **Configure NFS exports** with IP restrictions
   ```
   # Example /etc/exports on server:
   /export/media 192.168.1.0/24(ro,sync,no_subtree_check)
   ```

2. **Use read-only** for media
   - Prevents accidental deletion
   - Safer for car environment

3. **Firewall rules**
   - Allow NFS only from home network

---

## 🐛 Troubleshooting

### Mount Fails

**Check network connectivity:**
```bash
# Test if server is reachable
ping 192.168.1.10

# Test if you're on correct WiFi
nmcli connection show --active
```

**Check server is running:**
```bash
# For SMB
smbclient -L //192.168.1.10 -U username

# For NFS
showmount -e 192.168.1.20
```

**Check credentials:**
```bash
# Edit config file
nano ~/.config/car-edge/network-mounts.conf

# Then remount
car-edge-network-mounts remount
```

### Mount is Slow

**For SMB:**
- Check WiFi signal strength
- Try switching to 5GHz WiFi
- Reduce streaming quality in Kodi

**For NFS:**
- Verify server NFS settings
- Check network latency: `ping <server>`

### Automount Not Working

**Check systemd service:**
```bash
# Check service status
systemctl --user status mnt-network\\x2dstorage.mount

# View logs
journalctl --user -u mnt-network\\x2dstorage.mount

# Restart service
systemctl --user restart mnt-network\\x2dstorage.mount
```

### Connection Works at Home But Not Elsewhere

This is **expected behavior**! Network storage only works when:
- Connected to home WiFi
- Server is reachable

When away from home:
- External drive at `/mnt/storage` works normally
- No errors shown
- Auto-reconnects when home

---

## ⚙️ Advanced Configuration

### Custom Mount Options

Edit systemd mount unit:
```bash
# Edit mount unit
nano ~/.config/systemd/user/mnt-network\\x2dstorage.mount

# Add custom options to [Mount] section
# For SMB: vers=3.0,cache=loose,actimeo=1
# For NFS: rsize=8192,wsize=8192,timeo=14

# Reload and restart
systemctl --user daemon-reload
systemctl --user restart mnt-network\\x2dstorage.mount
```

### Multiple Network Shares

You can mount multiple shares:
1. Create additional mount points: `/mnt/network-storage2`, etc.
2. Create additional systemd mount units
3. Customize each with different credentials

### Auto-Unmount on Network Change

Network storage auto-unmounts when WiFi disconnects (systemd handles this automatically).

---

## 📊 Performance Tips

### For Best Streaming Performance

1. **Use 5GHz WiFi** (less interference)
2. **Position closer to router** when parked
3. **Reduce Kodi cache:** Settings → Player → Network Buffer
4. **Use H.264 video** (better than HEVC for streaming)

### For Best Battery Life

Network access uses more power than local storage. When running on battery:
- Use local storage (`/mnt/storage`) instead
- Disable network mount: `car-edge-network-mounts disable`

---

## 🔄 Integration with Other Features

### With Kodi
- Automatically scans network storage
- Add `/mnt/network-storage` as media source
- Works alongside local `/mnt/storage`

### With Syncthing
- Can sync to network storage
- Configure Syncthing folders: `~/.config/syncthing/`

### With Backup
The `car-edge-backup` script can backup to network storage:
```bash
# Backup to network storage
cp -r ~/.config /mnt/network-storage/backups/
```

---

## 📂 Directory Structure

**Recommended structure on your server:**
```
/media/                    (or your share path)
├── Movies/
│   ├── Action/
│   └── Comedy/
├── TV Shows/
│   ├── Show1/
│   └── Show2/
├── Music/
│   ├── Artist1/
│   └── Artist2/
├── ROMs/
│   ├── NES/
│   ├── SNES/
│   └── PS1/
└── Backups/
    └── car-edge/
```

**Kodi will scan and organize automatically!**

---

## 🎯 Use Cases

### Use Case 1: Streaming Media
- **Setup:** SMB to Synology NAS
- **Content:** Large movie/TV library
- **Benefit:** No need to sync everything locally

### Use Case 2: ROM Library
- **Setup:** NFS to Raspberry Pi
- **Content:** 100GB+ retro game collection
- **Benefit:** Access full library without local copy

### Use Case 3: Photo Backup
- **Setup:** SMB to home server
- **Content:** Photos/videos from car trips
- **Benefit:** Automatic backup when parked at home

### Use Case 4: Music Streaming
- **Setup:** SMB to NAS
- **Content:** FLAC music library
- **Benefit:** Full quality audio, no local storage needed

---

## 🚨 Important Notes

⚠️ **Network storage requires:**
- Home WiFi connection (WPA2/WPA3)
- Server powered on and accessible
- Correct credentials

⚠️ **Limitations:**
- Only works when server is reachable
- Requires stable network connection
- Higher power usage than local storage

✅ **Best Practice:**
- Keep frequently used content on local drive (`/mnt/storage`)
- Use network storage for large libraries accessed occasionally
- Configure both local and network storage for flexibility

---

## 🔗 Related Documentation

- [QUICK-START.md](QUICK-START.md) - Setup wizard walkthrough
- [CONFIGURATION.md](CONFIGURATION.md) - Advanced system configuration
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting
- [BACKUP-RESTORE.md](BACKUP-RESTORE.md) - Backup strategies

---

## 📞 Support

**Config Location:** `~/.config/car-edge/network-mounts.conf`  
**Mount Point:** `/mnt/network-storage`  
**Log Command:** `journalctl --user -u mnt-network\\x2dstorage.mount`

**Need Help?** Check the [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide or open an issue on GitHub.
