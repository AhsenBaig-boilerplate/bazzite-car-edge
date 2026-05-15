#!/bin/bash
set -euo pipefail

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  🚗 BAZZITE CAR EDGE v2.0 - Minimal Base Build                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# PHASE 1: SYSTEM UTILITIES
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Phase 1: Installing system utilities"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

rpm-ostree install \
    git \
    vim \
    htop \
    tmux \
    curl \
    wget \
    jq

echo "✅ System utilities installed"
echo ""

# ============================================================================
# PHASE 2: POWER MANAGEMENT
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ Phase 2: Configuring power management"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p /etc/tlp.d
cat > /etc/tlp.d/90-car-edge.conf << 'EOF'
# TLP power management for car entertainment (Intel N150)
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
USB_AUTOSUSPEND=0
DISK_APM_LEVEL_ON_AC="254 254"
DISK_APM_LEVEL_ON_BAT="128 128"
PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersave
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto
EOF

echo "✅ Power management configured"
echo ""

# ============================================================================
# PHASE 3: STORAGE STRUCTURE
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 Phase 3: Setting up storage structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p /etc/tmpfiles.d
cat > /etc/tmpfiles.d/bazzite-car-edge.conf << 'EOF'
# Storage directory structure (created on first boot)
d /mnt/storage                0755 - - - -
d /mnt/storage/media          0755 - - - -
d /mnt/storage/media/movies   0755 - - - -
d /mnt/storage/media/tv       0755 - - - -
d /mnt/storage/media/music    0755 - - - -
d /mnt/storage/media/photos   0755 - - - -
d /mnt/storage/games          0755 - - - -
d /mnt/storage/games/roms     0755 - - - -
d /mnt/storage/games/saves    0755 - - - -
d /mnt/storage/documents      0755 - - - -
d /mnt/storage/archives       0755 - - - -
d /mnt/storage/sync           0755 - - - -
EOF

echo "✅ Storage structure configured"
echo ""

# ============================================================================
# PHASE 4: RETROARCH CONFIGURATION
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 Phase 4: Configuring RetroArch"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p /var/config/retroarch
cat > /var/config/retroarch/retroarch.cfg << 'EOF'
# RetroArch paths for car entertainment system
rgui_browser_directory = "/mnt/storage/games/roms"
savefile_directory = "/mnt/storage/games/saves"
savestate_directory = "/mnt/storage/games/saves"
screenshot_directory = "/mnt/storage/games/screenshots"
system_directory = "/var/config/retroarch/system"
EOF

echo "✅ RetroArch configured"
echo ""

# ============================================================================
# PHASE 5: DOCUMENTATION
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Phase 5: Installing documentation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p /usr/share/doc/bazzite-car-edge
cat > /usr/share/doc/bazzite-car-edge/README.txt << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  🚗 BAZZITE CAR EDGE v2.0                                     ║
║     Minimal Car Entertainment System                          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

🎉 WELCOME!

This is a minimal base image. Applications are installed AFTER first boot.

📱 INSTALL APPLICATIONS

Run this command from Desktop Mode:
  car-edge-install-apps

This will install:
  • Kodi Media Center
  • Firefox (web streaming)
  • Minecraft (PrismLauncher)
  • Syncthing (home lab sync)
  • Kiwix (offline Wikipedia)

📂 STORAGE SETUP

1. Find your storage partition UUID:
   sudo blkid

2. Edit /etc/fstab:
   sudo nano /etc/fstab
   
3. Add line:
   UUID=your-uuid /mnt/storage ext4 defaults,nofail 0 2

4. Mount:
   sudo mount -a

� BACKUP CONFIGS

Backup your system and user configs (media is on separate drive):
  car-edge-backup

This saves to: /mnt/storage/backups/configs/

�📚 DOCUMENTATION

Full docs: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge

🎮 GAMING MODE

Press STEAM button to return to Gaming Mode

EOF

echo "✅ Documentation installed"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ BUILD COMPLETE - Minimal base image ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Image size: Minimal (~2-3GB compressed)"
echo "⚡ Build time: ~10-15 minutes"
echo "🚀 ISO size: ~3-5GB"
echo ""
echo "👉 Next: Install apps post-boot with 'car-edge-install-apps'"
echo ""
