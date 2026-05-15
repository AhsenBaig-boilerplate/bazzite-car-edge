#!/usr/bin/env bash
# Bazzite Car Edge - Network Mount Manager
# Handles SMB/NFS/CIFS network storage mounts

set -euo pipefail

CONFIG_DIR="${HOME}/.config/car-edge"
CONFIG_FILE="${CONFIG_DIR}/network-mounts.conf"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
MOUNT_POINT="/mnt/network-storage"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# Create config directory
init_config() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$SYSTEMD_USER_DIR"
}

# Parse existing config
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        return 0
    fi
    return 1
}

# Save configuration
save_config() {
    local share_type="$1"
    local server="$2"
    local share_path="$3"
    local username="$4"
    local password="$5"
    
    cat > "$CONFIG_FILE" << EOF
# Bazzite Car Edge Network Mount Configuration
# Generated: $(date)
SHARE_TYPE="${share_type}"
SERVER="${server}"
SHARE_PATH="${share_path}"
USERNAME="${username}"
PASSWORD="${password}"
MOUNT_POINT="${MOUNT_POINT}"
EOF
    
    chmod 600 "$CONFIG_FILE"
    success "Configuration saved to $CONFIG_FILE"
}

# Create systemd mount unit for SMB/CIFS
create_smb_mount() {
    local server="$1"
    local share_path="$2"
    local username="$3"
    local password="$4"
    
    local credentials_file="${CONFIG_DIR}/smb-credentials"
    
    # Create credentials file
    cat > "$credentials_file" << EOF
username=${username}
password=${password}
EOF
    chmod 600 "$credentials_file"
    
    # Create systemd mount unit
    local mount_unit="${SYSTEMD_USER_DIR}/mnt-network\\x2dstorage.mount"
    
    cat > "$mount_unit" << EOF
[Unit]
Description=Bazzite Car Edge Network Storage (SMB)
After=network-online.target
Wants=network-online.target

[Mount]
What=//${server}/${share_path}
Where=${MOUNT_POINT}
Type=cifs
Options=credentials=${credentials_file},uid=$(id -u),gid=$(id -g),file_mode=0755,dir_mode=0755,iocharset=utf8

[Install]
WantedBy=default.target
EOF
    
    success "Created SMB mount unit"
}

# Create systemd mount unit for NFS
create_nfs_mount() {
    local server="$1"
    local share_path="$2"
    
    # Create systemd mount unit
    local mount_unit="${SYSTEMD_USER_DIR}/mnt-network\\x2dstorage.mount"
    
    cat > "$mount_unit" << EOF
[Unit]
Description=Bazzite Car Edge Network Storage (NFS)
After=network-online.target
Wants=network-online.target

[Mount]
What=${server}:/${share_path}
Where=${MOUNT_POINT}
Type=nfs
Options=noauto,x-systemd.automount,x-systemd.idle-timeout=300

[Install]
WantedBy=default.target
EOF
    
    success "Created NFS mount unit"
}

# Enable and start mount
enable_mount() {
    # Create mount point
    sudo mkdir -p "$MOUNT_POINT"
    sudo chown "$(id -u):$(id -g)" "$MOUNT_POINT"
    
    # Reload systemd user daemon
    systemctl --user daemon-reload
    
    # Enable and start mount
    systemctl --user enable mnt-network\\x2dstorage.mount
    systemctl --user start mnt-network\\x2dstorage.mount || {
        error "Failed to mount network storage"
        return 1
    }
    
    success "Network storage mounted at $MOUNT_POINT"
}

# Disable and stop mount
disable_mount() {
    systemctl --user stop mnt-network\\x2dstorage.mount 2>/dev/null || true
    systemctl --user disable mnt-network\\x2dstorage.mount 2>/dev/null || true
    systemctl --user daemon-reload
    
    success "Network mount disabled"
}

# Check mount status
check_mount() {
    if systemctl --user is-active --quiet mnt-network\\x2dstorage.mount; then
        success "Network storage is mounted at $MOUNT_POINT"
        df -h "$MOUNT_POINT" 2>/dev/null || true
        return 0
    else
        error "Network storage is not mounted"
        return 1
    fi
}

# Interactive configuration
configure_interactive() {
    echo "=== Network Storage Configuration ==="
    echo ""
    
    # Choose protocol
    echo "Select network storage type:"
    echo "1) SMB/CIFS (Windows shares, NAS)"
    echo "2) NFS (Linux/Unix shares)"
    read -p "Enter choice [1-2]: " choice
    
    case "$choice" in
        1)
            SHARE_TYPE="smb"
            ;;
        2)
            SHARE_TYPE="nfs"
            ;;
        *)
            error "Invalid choice"
            return 1
            ;;
    esac
    
    # Get server details
    read -p "Server IP or hostname: " SERVER
    read -p "Share path (e.g., media or /export/media): " SHARE_PATH
    
    # Remove leading slash for SMB, ensure leading slash for NFS
    if [ "$SHARE_TYPE" = "smb" ]; then
        SHARE_PATH="${SHARE_PATH#/}"
    else
        SHARE_PATH="/${SHARE_PATH#/}"
    fi
    
    # Get credentials for SMB
    if [ "$SHARE_TYPE" = "smb" ]; then
        read -p "Username: " USERNAME
        read -sp "Password: " PASSWORD
        echo ""
    else
        USERNAME=""
        PASSWORD=""
    fi
    
    # Save configuration
    save_config "$SHARE_TYPE" "$SERVER" "$SHARE_PATH" "$USERNAME" "$PASSWORD"
    
    # Create mount unit
    if [ "$SHARE_TYPE" = "smb" ]; then
        create_smb_mount "$SERVER" "$SHARE_PATH" "$USERNAME" "$PASSWORD"
    else
        create_nfs_mount "$SERVER" "$SHARE_PATH"
    fi
    
    # Enable mount
    enable_mount
}

# Test connection
test_connection() {
    if ! load_config; then
        error "No configuration found. Run: $0 configure"
        return 1
    fi
    
    log "Testing connection to $SERVER..."
    
    if [ "$SHARE_TYPE" = "smb" ]; then
        # Test SMB connection
        if ping -c 1 -W 2 "$SERVER" &>/dev/null; then
            success "Server is reachable"
        else
            error "Cannot reach server $SERVER"
            return 1
        fi
    else
        # Test NFS connection
        if showmount -e "$SERVER" &>/dev/null; then
            success "NFS server is reachable"
        else
            error "Cannot contact NFS server $SERVER"
            return 1
        fi
    fi
}

# Show usage
usage() {
    cat << EOF
Bazzite Car Edge - Network Mount Manager

Usage: $(basename "$0") <command>

Commands:
    configure       Interactive configuration wizard
    enable          Enable network mount
    disable         Disable network mount
    status          Check mount status
    test            Test network connection
    remount         Unmount and remount
    help            Show this help message

Examples:
    $(basename "$0") configure      # Set up network storage
    $(basename "$0") status         # Check if mounted
    $(basename "$0") remount        # Fix connection issues

Config Location: ${CONFIG_FILE}
Mount Point: ${MOUNT_POINT}
EOF
}

# Main command handler
main() {
    init_config
    
    case "${1:-}" in
        configure)
            configure_interactive
            ;;
        enable)
            if ! load_config; then
                error "No configuration found. Run: $0 configure"
                exit 1
            fi
            enable_mount
            ;;
        disable)
            disable_mount
            ;;
        status)
            check_mount
            ;;
        test)
            test_connection
            ;;
        remount)
            disable_mount
            sleep 2
            enable_mount
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
