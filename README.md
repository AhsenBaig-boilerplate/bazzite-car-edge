# Bazzite Car Edge

**Minimal, Gaming-Optimized Entertainment System for Cars**

A custom [Bazzite](https://bazzite.gg) image built specifically for in-car entertainment systems. Based on Steam Deck UI with minimal base image size and post-boot application installation for faster deployment.

![Bazzite](https://img.shields.io/badge/Based%20on-Bazzite%20Deck-orange)
![Universal Blue](https://img.shields.io/badge/Universal%20Blue-Image-blue)
![License](https://img.shields.io/github/license/AhsenBaig-boilerplate/bazzite-car-edge)
![Build Status](https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/actions/workflows/build.yml/badge.svg)

**🎯 Current Status:** Feature Complete - Testing Phase | [See STATUS.md](STATUS.md) for details

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
- **Network Storage** - SMB/NFS support for home media server (NEW!)
- Pre-configured for `/mnt/storage` external media drive

### 🔧 Edge Computing
- **Immutable OS** (rpm-ostree) - atomic updates, instant rollback
- **Minimal base image** - applications installed post-boot
- **Syncthing** - sync with home lab
- **Network mounts** - auto-connect to home NAS when in WiFi range (NEW!)
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

### 🎯 **[📖 Complete Quick Start Guide](docs/QUICK-START.md)**

**New User?** Start here! Our **1-page Quick Start Guide** walks you through:
- ⚡ Installation (10 minutes)
- 🎮 Automated first boot setup (15 minutes)
- 🎯 Essential shortcuts and commands
- 🔧 Common troubleshooting

**👉 [Read the Quick Start Guide](docs/QUICK-START.md) for a complete walkthrough!**

---

### Installation (3 Steps)

**1. Download ISO**
```
https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/releases
```

**2. Flash to USB**
- Use [Balena Etcher](https://www.balena.io/etcher/) or Rufus

**3. Boot & Install**
- Insert USB, reboot, select USB drive
- Follow installer prompts
- Reboot when complete

**Already running Bazzite?** 
```bash
# Rebase to Car Edge (fastest upgrade path)
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest
systemctl reboot
car-edge-upgrade  # Enable Car Edge features (one-time)
```

**📦 Available Image Tags (Use the simple ones!):**

| Tag | Example | Use Case |
|-----|---------|----------|
| **`latest`** ⭐ | `...:latest` | **Recommended** - Always newest version |
| **`stable`** | `...:stable` | Alias for latest (same image) |
| `20260516` | `...:20260516` | Specific date (no commit hash needed!) |
| `20260516-636d6e7` | `...:20260516-636d6e7` | Date + commit (for debugging) |

**💡 Tip:** Just use `:latest` or `:stable` - they're the easiest to type!

```bash
# Simple update (recommended)
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:stable

# Or use date if you want specific version
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:20260516
```

📖 **Detailed Instructions:** [INSTALLATION.md](docs/INSTALLATION.md) | [UPGRADE.md](docs/UPGRADE.md)

---

### First Boot - Zero Configuration Required! ✨

**The setup wizard launches automatically!**

- 🎮 Launches in Gaming Mode (Steam Deck UI)
- 🪄 GUI wizard guides you through setup
- 📦 Installs 10 applications automatically
- 💾 Configures external storage
- ⚡ Ready in 15 minutes - no terminal needed!

**What gets installed:**
- 🎬 Kodi, 🌐 Firefox, 🎮 Heroic, 🎮 Prism Launcher
- 🔄 Syncthing, 📚 Kiwix, 🎥 VLC, ⚙️ ProtonUp-Qt
- 📺 Jellyfin, 💻 VS Code

**Manual launch (if needed):**
```bash
car-edge-setup-wizard         # Run wizard
car-edge-install-apps         # Install apps only
```

📖 **Setup Guides:** [AUTOMATED-SETUP.md](docs/AUTOMATED-SETUP.md) | [FIRST-BOOT.md](docs/FIRST-BOOT.md)

---

## 🎛️ Control Panel - Manage Everything with One Click!

**🚗 Bazzite Car Edge Control Panel** - Your central hub for system management!

<img src="https://img.shields.io/badge/GUI-Friendly-green" alt="GUI Friendly"/> <img src="https://img.shields.io/badge/No%20Terminal-Required-blue" alt="No Terminal Required"/>

### Launch from Desktop

Find **"Car Edge Control Panel"** in your application menu, or run:
```bash
car-edge-control-panel
```

### What You Can Do:

| Feature | Description |
|---------|-------------|
| **🔄 System Updates** | Check for updates, browse versions, apply staged updates |
| **💾 Storage Management** | Configure drives, browse folders, change paths |
| **📦 Applications** | Install apps, configure Kodi/Steam, view installed software |
| **🌐 Network Storage** | Connect to home server, configure auto-mount |
| **💼 Backup & Restore** | Save and restore your configurations |
| **⚙️  Advanced Settings** | Power management, logs, terminal access |
| **ℹ️  About & Help** | Version info, documentation links |

### Key Benefits:

✅ **No terminal commands needed** - Everything in a friendly GUI  
✅ **Industry-standard interface** - Familiar menus and dialogs  
✅ **Safe operations** - Confirmation prompts for destructive actions  
✅ **Change settings without data loss** - Reconfigure paths safely  
✅ **Perfect for end users** - Anyone can manage the system  

**Made for everyone, not just power users!** 🎉

---

## 📚 Documentation

### 🌟 Start Here
| Document | Description |
|----------|-------------|
| **[🚀 QUICK-START.md](docs/QUICK-START.md)** | **⭐ 1-page guide: Install → Setup → Use (30 minutes!)** |
| **[STATUS.md](STATUS.md)** | Current project status and progress |
| **[ROADMAP.md](ROADMAP.md)** | Production roadmap and feature timeline |

### Setup & Installation
| Document | Description |
|----------|-------------|
| **[INSTALLATION.md](docs/INSTALLATION.md)** | Installation methods (rebase, ISO, USB flashing) |
| **[VERSION-TAGS.md](docs/VERSION-TAGS.md)** | **📦 Simple version tags guide (latest, stable, dates)** |
| **[AUTOMATED-SETUP.md](docs/AUTOMATED-SETUP.md)** | GUI wizard walkthrough (zero terminal commands) |
| **[FIRST-BOOT.md](docs/FIRST-BOOT.md)** | Manual setup guide (optional, for power users) |
| **[UPGRADE.md](docs/UPGRADE.md)** | Upgrade from standard Bazzite to Car Edge |

### Configuration & Maintenance
| Document | Description |
|----------|-------------|
| **[CONFIGURATION.md](docs/CONFIGURATION.md)** | Advanced configuration (TLP, networking, RetroArch) |
| **[UPDATES.md](docs/UPDATES.md)** | System updates - automatic background downloads & notifications |
| **[NETWORK-STORAGE.md](docs/NETWORK-STORAGE.md)** | Network storage setup (SMB/NFS home server access) |
| **[BACKUP-RESTORE.md](docs/BACKUP-RESTORE.md)** | Backup strategy and disaster recovery |
| **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** | Common issues and solutions |
| **[ERROR-HANDLING.md](docs/ERROR-HANDLING.md)** | Setup wizard error scenarios and recovery |
| **[QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)** | Command cheat sheet |

### Testing & Development
| Document | Description |
|----------|-------------|
| **[TESTING.md](TESTING.md)** | Comprehensive test suite and procedures |
| **[TEST-EXECUTION-PLAN.md](TEST-EXECUTION-PLAN.md)** | Step-by-step testing guide (7 phases) |
| **[VM-TESTING.md](docs/VM-TESTING.md)** | Virtual machine testing guide |

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

**Current Version:** v0.5-alpha (Active Development)

**Phase 1: Foundation** ✅ **COMPLETE**
- [x] Core build system and minimal image
- [x] GUI setup wizard with auto-run
- [x] Application installer and backup system
- [x] Complete documentation (8 files)

**Phase 2: Testing & Polish** 🚧 **IN PROGRESS**
- [ ] Real hardware testing (Beelink Mini S13)
- [ ] Video demo and screenshots
- [ ] Error handling and edge cases
- [ ] User acceptance testing

**Phase 3: Production Ready** 📋 **PLANNED**
- [ ] Network drive (SMB/NFS) wizard
- [ ] RetroArch core auto-installer
- [ ] Controller pairing wizard
- [ ] Settings management GUI
- [ ] Gaming Mode enhancements

📖 **Full Roadmap:** [ROADMAP.md](ROADMAP.md)

**Target:** First stable release (v1.0) in 3-6 months
**Focus:** Non-technical users, family-friendly, zero-config

---

**Made with ❤️ for in-car entertainment and edge computing**
