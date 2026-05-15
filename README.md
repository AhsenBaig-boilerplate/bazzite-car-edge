# Bazzite Car Edge

**Minimal, Gaming-Optimized Entertainment System for Cars**

A custom [Bazzite](https://bazzite.gg) image built specifically for in-car entertainment systems. Based on Steam Deck UI with minimal base image size and post-boot application installation for faster deployment.

![Bazzite](https://img.shields.io/badge/Based%20on-Bazzite%20Deck-orange)
![Universal Blue](https://img.shields.io/badge/Universal%20Blue-Image-blue)
![License](https://img.shields.io/github/license/AhsenBaig-boilerplate/bazzite-car-edge)
![Build Status](https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/actions/workflows/build.yml/badge.svg)

---

## 🚗 What is This?

Bazzite Car Edge is a **minimal, bootable OS image** designed for:
- **In-car entertainment systems** (media, games, offline content)
- **Edge computing nodes** (lightweight, persistent, updateable)
- **Gaming-first interface** (Steam Deck UI, controller-optimized)
- **Low-power x86 devices** (optimized for Intel N150 / similar)

**Target Hardware:** Beelink Mini S13, Intel N150, 16GB RAM, 512GB SSD

---

## ✨ Features

### 🎮 Gaming-Optimized
- **Steam Deck UI** (Gaming Mode) - controller-only interface
- **RetroArch** pre-installed with configured ROM paths
- **Steam, Heroic, PrismLauncher** for modern and retro gaming
- **Desktop Mode** available (KDE Plasma) for configuration

### 📺 Media Center
- **Kodi** - full-featured media player
- **Jellyfin Media Player** - home server integration
- **VLC** - universal video player
- Pre-configured for `/mnt/storage` external media drive

### 🔧 Edge Computing
- **Immutable OS** (rpm-ostree) - atomic updates, instant rollback
- **Minimal base image** - applications installed post-boot
- **Syncthing** - sync with home lab
- **Power-optimized** - TLP configured for Intel N150

### 📦 Fast Deployment
- **Small image size** - minimal system packages
- **GUI setup wizard** - `car-edge-setup-wizard` (NEW!)
- **Zero terminal commands** - fully automated first boot
- **Auto-configure** - Kodi, permissions, storage
- **Backup/Restore** - `car-edge-backup` for configurations
- **External storage** - keeps OS updates fast, media on separate drive

---

## 🚀 Quick Start

### 1️⃣ Installation

**Option A: Rebase (Fastest!)**
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest
systemctl reboot
```

**Option B: Fresh Install**
1. Download ISO from [GitHub Actions](https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/actions)
2. Flash to USB with Rufus/Ventoy
3. Install as normal Bazzite system

📖 **Full Instructions:** [docs/INSTALLATION.md](docs/INSTALLATION.md)

### 2️⃣ First Boot - Automated!

**The setup wizard launches automatically on first boot!**

Just switch to Desktop Mode (Ctrl+Alt+F3) and follow the on-screen wizard.

**The wizard handles everything:**
- ✅ External drive detection & auto-format
- ✅ Directory structure creation
- ✅ Application installation with progress bar
- ✅ Kodi media source configuration
- ✅ Permission grants to all apps
- ✅ Syncthing setup (optional)
- ✅ First backup

**Time:** 5-10 minutes, fully automated!

**Manual run (if needed):**
```bash
car-edge-setup-wizard         # Run wizard manually
car-edge-setup-wizard --force # Re-run wizard
```

📖 **Full Guide:** [docs/AUTOMATED-SETUP.md](docs/AUTOMATED-SETUP.md)

### Manual Setup (Optional)
For power users who want control:
```bash
car-edge-install-apps     # Install apps only
car-edge-backup           # Create backup
# Edit /etc/fstab manually  # Full control
```

📖 **Manual Steps:** [docs/FIRST-BOOT.md](docs/FIRST-BOOT.md)

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[AUTOMATED-SETUP.md](docs/AUTOMATED-SETUP.md)** | **NEW!** GUI wizard for zero-config setup |
| **[INSTALLATION.md](docs/INSTALLATION.md)** | Installation methods (rebase, ISO, USB flashing) |
| **[FIRST-BOOT.md](docs/FIRST-BOOT.md)** | Manual setup guide (optional) |
| **[CONFIGURATION.md](docs/CONFIGURATION.md)** | Advanced configuration (TLP, networking, RetroArch) |
| **[BACKUP-RESTORE.md](docs/BACKUP-RESTORE.md)** | Backup strategy and disaster recovery |
| **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** | Common issues and solutions |
| **[QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)** | Command cheat sheet |

---

## 🎯 Installed Applications

### Pre-Installed (Base Image)
- Steam (with Proton)
- RetroArch (emulation)
- Firefox web browser
- Desktop Mode (KDE Plasma)

### Post-Boot Install (`car-edge-install-apps`)
- 📺 **Kodi** - Media center
- 🦊 **Firefox** - Web browser
- 🎮 **PrismLauncher** - Minecraft
- 🔄 **Syncthing** - Home lab sync
- 📚 **Kiwix** - Offline Wikipedia
- 💻 **VS Code** - Code editor
- 🎬 **VLC** - Media player
- 🎮 **ProtonUp-Qt** - Proton manager
- 🎮 **Heroic** - Epic/GOG games
- 📺 **Jellyfin Media Player** - Server client

---

## 🛠️ Custom Commands
Setup Wizard (NEW!)
```bash
car-edge-setup-wizard    # GUI wizard - zero config needed!
```

### 
### Application Management
```bash
car-edge-install-apps    # Install all Flatpak applications
flatpak update           # Update all applications
```

### Backup & Restore
```bash
car-edge-backup          # Backup configs to /mnt/storage/backups/
tar -xzf backup.tar.gz   # Restore from backup
```

### System Updates
```bash
rpm-ostree status        # Check current version
rpm-ostree upgrade       # Update system
rpm-ostree rollback      # Revert to previous version
```

📖 **More Commands:** [docs/QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)

---

## 🏗️ Build System

This image is built using:
- **Base:** `ghcr.io/ublue-os/bazzite-deck:stable`
- **Build Tool:** `bootc` (bootable container)
- **CI/CD:** GitHub Actions
- **Signing:** Cosign (for security)
- **Registry:** GitHub Container Registry (GHCR)

### Build Locally
```bash
git clone https://github.com/AhsenBaig-boilerplate/bazzite-car-edge.git
cd bazzite-car-edge
just build
```

---

## 📦 Repository Structure

```
bazzite-car-edge/
├── Containerfile              # OCI image definition
├── Justfile                   # Build automation
├── build_files/
│   ├── build.sh               # System package installation
│   └── files/
│       ├── install-apps.sh    # Flatpak installer
│       └── backup-configs.sh  # Backup script
├── docs/                      # Documentation
│   ├── INSTALLATION.md
│   ├── FIRST-BOOT.md
│   ├── CONFIGURATION.md
│   ├── BACKUP-RESTORE.md
│   ├── TROUBLESHOOTING.md
│   └── QUICK-REFERENCE.md
└── .github/workflows/
    └── build.yml              # Automated builds
```

---

## 💻 Target Hardware

**Recommended:**
- **Device:** Beelink Mini S13
- **CPU:** Intel N150 (4C/4T, 6W TDP)
- **RAM:** 16GB
- **Storage:** 512GB SSD (OS) + external SSD (media)
- **Graphics:** Intel UHD Graphics (Xe-LP)

**Works on:** Any x86_64 PC supporting UEFI boot

---

## 🤝 Contributing

This is a personal project, but feel free to:
- Fork for your own use cases
- Report issues on GitHub
- Submit pull requests with improvements

Based on [ublue-os/image-template](https://github.com/ublue-os/image-template)

---

## 📄 License

This project is licensed under the Apache License 2.0 - see [LICENSE](LICENSE) file.

---

## 🆘 Support

- **GitHub Issues:** [Report a problem](https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/issues)
- **Universal Blue:** [Forums](https://universal-blue.discourse.group/) | [Discord](https://discord.gg/WEu6BdFEtp)
- **Bazzite Docs:** https://bazzite.gg

---

## 🙏 Credits

Built with:
- **[Bazzite](https://bazzite.gg)** - Gaming-optimized Fedora image
- **[Universal Blue](https://universal-blue.org)** - Custom image framework
- **[bootc](https://github.com/bootc-dev/bootc)** - Bootable containers
- **[rpm-ostree](https://coreos.github.io/rpm-ostree/)** - Hybrid image/package system

---

## 📊 Project Status

🚧 **Active Development** - First stable release target: Q2 2026

- [x] Base image configuration
- [x] Application installer
- [x] Backup system
- [x] Documentation
- [ ] First stable release
- [ ] ISO generation testing
- [ ] Real hardware deployment

---

**Made with ❤️ for in-car entertainment and edge computing**
