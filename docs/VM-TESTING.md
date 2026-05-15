# VM Testing Guide

**Quick guide for testing Bazzite Car Edge in a virtual machine**

Use this guide to safely test the system before deploying to real hardware.

---

## 🖥️ Recommended VM Software

### Option 1: GNOME Boxes (Easiest)
**Best for:** Linux users, beginners  
**Pros:** Simple, one-click setup  
**Cons:** Fewer advanced options

```bash
# Install on Fedora/RHEL
sudo dnf install gnome-boxes

# Install on Ubuntu/Debian
sudo apt install gnome-boxes
```

### Option 2: VirtualBox (Most Compatible)
**Best for:** All platforms (Windows, Mac, Linux)  
**Pros:** Free, widely used, good documentation  
**Cons:** Some performance overhead

**Download:** https://www.virtualbox.org/

### Option 3: VMware Workstation/Player
**Best for:** Advanced users  
**Pros:** Best performance  
**Cons:** Commercial (Workstation), limited (Player)

**Download:** https://www.vmware.com/

### Option 4: virt-manager (KVM/QEMU)
**Best for:** Linux power users  
**Pros:** Native virtualization, best performance on Linux  
**Cons:** Linux-only, more complex

```bash
# Install on Fedora/RHEL
sudo dnf install virt-manager

# Install on Ubuntu/Debian
sudo apt install virt-manager
```

---

## 💾 VM Requirements

### Minimum Configuration
- **CPU:** 2 cores (x86_64)
- **RAM:** 4GB
- **Disk:** 50GB
- **Network:** NAT or Bridged
- **Graphics:** 128MB video memory
- **USB:** USB 3.0 controller (for external drive testing)

### Recommended Configuration
- **CPU:** 4 cores (x86_64, enable VT-x/AMD-V)
- **RAM:** 8GB
- **Disk:** 100GB (thin provisioned)
- **Network:** Bridged (for network storage testing)
- **Graphics:** 256MB video memory, 3D acceleration
- **USB:** USB 3.0 controller
- **Audio:** Enabled (for media playback testing)

---

## 📥 Get the ISO

### Option 1: Download from GitHub Actions
1. Visit: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/actions
2. Click latest successful workflow run
3. Scroll to "Artifacts" section
4. Download ISO file

### Option 2: Use Container Image (Advanced)
```bash
# Pull image
podman pull ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest

# Generate ISO (requires bootc)
# (Advanced users only)
```

---

## 🚀 VirtualBox Setup (Step-by-Step)

### Step 1: Create New VM
1. Open VirtualBox
2. Click "New"
3. **Name:** Bazzite-Car-Edge-Test
4. **Type:** Linux
5. **Version:** Fedora (64-bit)
6. Click "Next"

### Step 2: Configure Memory
- **RAM:** 8192 MB (8GB)
- Click "Next"

### Step 3: Create Virtual Hard Disk
- Select "Create a virtual hard disk now"
- Click "Create"
- **Type:** VDI (VirtualBox Disk Image)
- **Storage:** Dynamically allocated
- **Size:** 100 GB
- Click "Create"

### Step 4: Configure VM Settings
1. Select the VM
2. Click "Settings"

**System Tab:**
- Processor: 4 CPUs, enable PAE/NX
- Acceleration: Enable VT-x/AMD-V
- Boot Order: Optical, Hard Disk

**Display Tab:**
- Video Memory: 128 MB (or maximum available)
- Graphics Controller: VMSVGA
- Enable 3D Acceleration (if available)

**Storage Tab:**
- Click Empty CD icon
- Click disk icon → "Choose a disk file"
- Select downloaded ISO

**Network Tab:**
- Adapter 1: Enable
- Attached to: Bridged Adapter (for network storage testing)
- Or NAT (for internet only)

**USB Tab:**
- Enable USB Controller
- Select USB 3.0 (xHCI)

**Audio Tab:**
- Enable Audio
- Audio Controller: Intel HD Audio

### Step 5: Boot VM
1. Click "Start"
2. VM should boot from ISO
3. Follow Bazzite installation prompts

---

## 🎮 GNOME Boxes Setup (Simplified)

### Quick Setup
1. Open GNOME Boxes
2. Click "+" → "Create Virtual Machine"
3. Select downloaded ISO
4. Choose "Operating System" → Fedora
5. Set memory: 8GB
6. Set disk: 100GB
7. Click "Create"
8. VM boots automatically

### USB Passthrough
1. With VM running
2. Click VM → Preferences → Devices
3. Select USB device to pass through
4. Device appears in guest OS

---

## 🧪 Testing Scenarios in VM

### Test 1: Basic Installation
**Objective:** Verify installer works

**Steps:**
1. Boot VM from ISO
2. Follow installation wizard
3. Create user account
4. Install to virtual disk
5. Reboot

**Expected:** Clean install, system boots to Gaming Mode

**Time:** 10-15 minutes

---

### Test 2: Setup Wizard - No External Drive
**Objective:** Test wizard without hardware

**Steps:**
1. First boot → Desktop Mode
2. Wait for wizard or run: `car-edge-setup-wizard`
3. Skip external drive setup
4. Skip network storage
5. Install applications

**Expected:** Apps install successfully, wizard completes

**Time:** 15-20 minutes

---

### Test 3: Setup Wizard - Virtual USB Drive
**Objective:** Test external drive formatting

**Setup:**
1. Create virtual USB disk:
   - VirtualBox: Settings → Storage → Add hard disk
   - Create new disk: 20GB, dynamically allocated
   - Name it "USB-Test"

**Steps:**
1. Start VM
2. Run wizard
3. Select virtual USB disk
4. Format as ext4
5. Verify directory structure

**Expected:** Drive formatted, directories created

**Time:** 10 minutes

---

### Test 4: Network Storage - SMB/NFS
**Objective:** Test network mount capabilities

**Prerequisites:**
- Host machine has SMB share (Windows shared folder or Samba)
- Or NFS server running

**Host Setup (Linux - SMB):**
```bash
# Install Samba
sudo dnf install samba

# Create test share
sudo mkdir -p /srv/samba/media
sudo chmod 777 /srv/samba/media

# Configure Samba
sudo tee /etc/samba/smb.conf << EOF
[media]
   path = /srv/samba/media
   browseable = yes
   read only = no
   guest ok = yes
EOF

# Start Samba
sudo systemctl start smb
sudo systemctl enable smb

# Get host IP
ip addr show
```

**VM Testing:**
1. Run: `car-edge-network-mounts configure`
2. Select SMB/CIFS
3. Server: Host IP (e.g., 192.168.1.100)
4. Share: media
5. Test connection

**Expected:** Mount succeeds, can browse `/mnt/network-storage`

---

### Test 5: Application Testing
**Objective:** Verify all apps launch

**Steps:**
1. Desktop Mode
2. Launch each app from menu:
   - Kodi
   - Firefox
   - VLC
   - VS Code
   - Others

**Expected:** All apps open without errors

**Time:** 10 minutes

---

### Test 6: Gaming Mode Navigation
**Objective:** Test controller/keyboard navigation

**Steps:**
1. Return to Gaming Mode
2. Use keyboard (arrow keys, Enter) or controller
3. Navigate Steam menu
4. Access Library
5. Launch non-Steam apps

**Expected:** Navigation works smoothly

**Time:** 5 minutes

---

### Test 7: Error Scenarios

#### 7a: No Internet
**Steps:**
1. Disable VM network adapter
2. Run wizard
3. Try to install apps

**Expected:** Clear error, skip with instructions

#### 7b: Disk Space
**Steps:**
1. Fill disk to <5GB free
2. Run wizard
3. Try to install apps

**Expected:** Pre-flight check warns about space

#### 7c: User Cancellation
**Steps:**
1. Start wizard
2. Cancel mid-process
3. Restart wizard

**Expected:** Can restart cleanly

**Time:** 15 minutes total

---

### Test 8: Automated Tests
**Objective:** Run test suite

**Steps:**
```bash
# Clone repository (if not in image)
git clone https://github.com/AhsenBaig-boilerplate/bazzite-car-edge.git
cd bazzite-car-edge

# Run automated tests
./test-system.sh
```

**Expected:** 30+ tests pass

**Time:** 5 minutes

---

## 📸 Documentation Testing

### Capture Screenshots
While testing, capture screenshots for documentation:

1. **Welcome screen**
2. **External drive selection**
3. **Network storage config**
4. **App installation progress**
5. **Completion screen**
6. **Gaming Mode with apps**
7. **Kodi interface**

**VirtualBox:** `Host+E` (usually Right Ctrl+E)  
**GNOME Boxes:** Screenshot tool or `PrtSc`

---

## 🐛 Bug Reporting from VM

When you find issues:

1. **Collect logs:**
   ```bash
   cat ~/.cache/car-edge-setup.log
   journalctl --user -u mnt-network\\x2dstorage.mount
   rpm-ostree status
   ```

2. **Note environment:**
   - VM software and version
   - Host OS
   - VM configuration (RAM, CPU, etc.)
   - Network setup

3. **Create bug report** using template in TESTING.md

---

## 💡 VM Tips & Tricks

### Performance Optimization

**VirtualBox:**
- Enable VT-x/AMD-V in BIOS
- Allocate more CPU cores
- Increase video memory
- Use VDI (not VMDK) for better performance

**GNOME Boxes:**
- Enable 3D acceleration
- Allocate 50% of host RAM
- Use virtio drivers

### USB Device Testing

**VirtualBox:**
1. Install Extension Pack for USB 3.0
2. Settings → USB → Add filter for device
3. Device auto-passes through when connected

**GNOME Boxes:**
- Automatic USB passthrough
- Click Preferences → Devices → Select device

### Snapshot Before Testing

**Always create snapshot before destructive tests:**

**VirtualBox:**
1. Machine → Take Snapshot
2. Name it: "Clean Install" or "Pre-Test"
3. Restore if something breaks

**GNOME Boxes:**
- Limited snapshot support
- Consider cloning VM instead

### Network Debugging

**Check VM network:**
```bash
# In VM
ip addr show
ping google.com
ping host-ip

# Check DNS
resolvectl status
```

**Bridge vs NAT:**
- **Bridged:** VM gets own IP, can access host services
- **NAT:** VM behind firewall, can't access host easily

---

## ✅ VM Testing Checklist

Complete testing in VM before hardware:

- [ ] ISO boots successfully
- [ ] Installation completes
- [ ] First boot wizard runs
- [ ] External drive setup works (virtual disk)
- [ ] Network storage works (host SMB/NFS)
- [ ] All 10 apps install
- [ ] Apps launch from Desktop Mode
- [ ] Apps accessible in Gaming Mode
- [ ] Automated tests pass
- [ ] Error scenarios handled gracefully
- [ ] System updates work
- [ ] Rollback works
- [ ] Performance acceptable

**When all checked:** Ready for hardware testing!

---

## 🔄 Transition to Hardware

After VM validation:

1. **Document findings** - Note any issues
2. **Fix critical bugs** - Before hardware testing
3. **Update docs** - Based on VM experience
4. **Flash ISO to USB** - Use Balena Etcher
5. **Test on Beelink** - Follow hardware test plan

---

## 📞 Need Help?

**VM-specific issues:**
- VirtualBox forums: https://forums.virtualbox.org/
- GNOME Boxes: https://help.gnome.org/users/gnome-boxes/
- Fedora virtualization: https://docs.fedoraproject.org/

**Bazzite Car Edge issues:**
- GitHub Issues: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/issues
- Check: TROUBLESHOOTING.md
- Review: ERROR-HANDLING.md

---

**Remember:** VM testing is safe! Take snapshots, experiment freely, and document everything you find.
