# Installation Guide - Bazzite Car Edge

## 📋 Prerequisites

- Beelink Mini S13 (Intel N150) or similar x86_64 PC
- USB drive (8GB+ for minimal ISO)
- Internet connection for first-time setup
- Optional: External SSD for media storage

---

## 🚀 Installation Methods

### Option A: Rebase from Existing Bazzite (Fastest!)

If you already have Bazzite or Bazzite-Deck installed:

```bash
# Switch to the custom image
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest

# Reboot to apply
systemctl reboot
```

**Time:** ~5-10 minutes + reboot

---

### Option B: Fresh ISO Installation

#### 1. Download the ISO

**From GitHub Actions:**
1. Go to: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/actions
2. Click the latest successful build
3. Download the ISO artifact (or use pre-built release)

**Or build locally:**
```bash
cd /home/admins/bazzite-car-edge
just build
just build-iso
# ISO created at: ./output/bootiso/install.iso
```

#### 2. Flash to USB

**On Linux:**
```bash
# Find USB device
lsblk

# Flash (replace sdX with your device!)
sudo dd if=./output/bootiso/install.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

**On Windows:**
- Use [Rufus](https://rufus.ie/) in DD mode
- Or [Ventoy](https://www.ventoy.net/) (copy ISO, no flashing needed)

**On WSL2:**
```bash
# Copy to Windows Downloads folder
cp ./output/bootiso/install.iso /mnt/c/Users/YOUR_USERNAME/Downloads/
# Then use Rufus from Windows
```

#### 3. Install

1. Insert USB into Beelink
2. Boot from USB (F12/F2/DEL for boot menu)
3. Follow Anaconda installer
4. Reboot when complete

**Time:** ~20-30 minutes total

---

## 🎮 First Boot

System will boot directly into **Steam Deck UI (Gaming Mode)**

To access Desktop Mode:
- Press `Ctrl+Alt+F3`
- Or: Steam button → Power → Switch to Desktop

---

## ⏭️ Next Steps

After installation, proceed to:
- **[FIRST-BOOT.md](FIRST-BOOT.md)** - Initial setup and configuration
- **[CONFIGURATION.md](CONFIGURATION.md)** - Detailed system configuration

---

## 🆘 Troubleshooting

### ISO won't boot
- Verify UEFI/BIOS is set to boot from USB
- Try different USB port (USB 2.0 sometimes more reliable)
- Re-flash the USB drive

### Rebase fails
- Check internet connection
- Verify image name is correct
- Try: `rpm-ostree rebase --reboot ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest`

### Black screen after install
- Wait 2-3 minutes (first boot takes time)
- Try different HDMI cable/port
- Check display resolution in BIOS

---

## 📚 More Information

- **GitHub Repo:** https://github.com/AhsenBaig-boilerplate/bazzite-car-edge
- **Bazzite Docs:** https://bazzite.gg
- **Universal Blue:** https://universal-blue.org
