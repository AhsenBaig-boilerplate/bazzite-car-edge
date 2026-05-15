#!/bin/bash
set -euo pipefail

# Bazzite Car Edge - Configuration Backup Script
# Backs up system and user configs (NOT media - that's on separate drive)

BACKUP_DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="${1:-/mnt/storage/backups/configs}"
BACKUP_NAME="car-edge-backup-${BACKUP_DATE}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚗 Bazzite Car Edge - Configuration Backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Backing up system and user configurations..."
echo "Backup location: ${BACKUP_PATH}"
echo ""

# Create backup directory
mkdir -p "${BACKUP_PATH}"

# 1. System Configuration Files
echo "📋 Backing up system configs..."
mkdir -p "${BACKUP_PATH}/system"

# Important system files
sudo cp /etc/fstab "${BACKUP_PATH}/system/fstab" 2>/dev/null || echo "  ⚠️  No custom fstab"
sudo cp -r /etc/tlp.d "${BACKUP_PATH}/system/" 2>/dev/null || echo "  ⚠️  No TLP config"

# 2. User Configuration Files
echo "⚙️  Backing up user configs..."
mkdir -p "${BACKUP_PATH}/user"

# App configs (excluding large caches)
rsync -av --exclude='cache' --exclude='Cache' --exclude='*.log' \
    ~/.config/ "${BACKUP_PATH}/user/.config/" 2>/dev/null || echo "  ⚠️  No .config"

# Syncthing config (important!)
cp -r ~/.config/syncthing "${BACKUP_PATH}/user/syncthing-config" 2>/dev/null || echo "  ⚠️  No Syncthing config yet"

# 3. Game-specific configs (not saves - those are on storage drive)
echo "🎮 Backing up game configs..."
mkdir -p "${BACKUP_PATH}/gaming"

# Steam config (not games, just settings)
rsync -av --exclude='steamapps' --exclude='shader_cache' \
    ~/.steam/steam/config/ "${BACKUP_PATH}/gaming/steam-config/" 2>/dev/null || echo "  ⚠️  No Steam config"

# RetroArch config
cp -r ~/.var/app/org.libretro.RetroArch/config/retroarch "${BACKUP_PATH}/gaming/retroarch-config" 2>/dev/null || echo "  ⚠️  No RetroArch config"

# 4. RPM-OSTree Status (for reference)
echo "📦 Recording system state..."
rpm-ostree status > "${BACKUP_PATH}/rpm-ostree-status.txt"
flatpak list --app > "${BACKUP_PATH}/flatpak-list.txt"

# 5. Create backup manifest
echo "📝 Creating backup manifest..."
cat > "${BACKUP_PATH}/backup-info.txt" << EOF
Bazzite Car Edge Configuration Backup
======================================
Date: ${BACKUP_DATE}
Hostname: $(hostname)
User: $(whoami)
Image: $(rpm-ostree status --json | jq -r '.deployments[0].origin' 2>/dev/null || echo "unknown")
Kernel: $(uname -r)

Backed Up:
- System configs (/etc/fstab, TLP, etc.)
- User configs (~/.config)
- Syncthing config
- Steam settings
- RetroArch config
- Flatpak list
- RPM-OSTree status

NOT Backed Up (on separate drive):
- Media files (/mnt/storage/media)
- Game ROMs (/mnt/storage/games/roms)
- Game saves (/mnt/storage/games/saves)
- Documents (/mnt/storage/documents)
EOF

# Create compressed archive
echo "🗜️  Compressing backup..."
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Backup saved to:"
echo "  ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo ""
echo "Size: $(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)"
echo ""
echo "💡 To restore: Extract tar.gz and manually copy configs back"
echo "💡 Media/games on /mnt/storage are NOT backed up (separate drive)"
echo ""

# List recent backups
echo "Recent backups:"
ls -lht "${BACKUP_DIR}"/*.tar.gz 2>/dev/null | head -5 || echo "  (no previous backups)"
echo ""
