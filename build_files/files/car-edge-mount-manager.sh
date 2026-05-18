#!/usr/bin/env bash
# Bazzite Car Edge - Mount Manager
# Persistent, user-level multi-drive mounting (data, games, media, etc.)

set -euo pipefail

CONFIG_DIR="$HOME/.config/car-edge"
CONFIG_FILE="$CONFIG_DIR/mounts.conf"

mkdir -p "$CONFIG_DIR"

# List all available drives (excluding OS/root)
list_drives() {
    lsblk -ndo NAME,SIZE,TYPE | grep disk | while read -r name size type; do
        dev="/dev/$name"
        # Skip root device
        if mountpoint -q /; then
            rootdev=$(findmnt -n -o SOURCE /)
            [[ "$dev" == "$rootdev" ]] && continue
        fi
        echo "$dev|$size"
    done
}

# List configured mounts
list_configured() {
    [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || true
}

# Add a new mount
add_mount() {
    local dev="$1"
    local mount_point="$2"
    local fs_type="$3"
    local label="$4"
    uuid=$(blkid -s UUID -o value "$dev" || true)
    if [ -z "$uuid" ]; then
        echo "Could not get UUID for $dev" >&2
        return 1
    fi
    echo "$uuid|$mount_point|$fs_type|$label" >> "$CONFIG_FILE"
}

# Mount all configured drives
mount_all() {
    [ -f "$CONFIG_FILE" ] || return 0
    while IFS='|' read -r uuid mount_point fs_type label; do
        sudo mkdir -p "$mount_point"
        sudo mount -U "$uuid" "$mount_point" -t "$fs_type" -o defaults,nofail,uid=1000,gid=1000 || true
    done < "$CONFIG_FILE"
}

# Interactive menu
menu() {
    echo "Bazzite Car Edge - Mount Manager"
    echo "---------------------------------"
    echo "Configured mounts:"
    list_configured
    echo ""
    echo "Available drives:"
    list_drives
    echo ""
    echo "Options:"
    echo "1) Add new mount"
    echo "2) Mount all"
    echo "3) Exit"
    read -p "Select option: " opt
    case "$opt" in
        1)
            read -p "Device (/dev/sdX1): " dev
            read -p "Mount point (e.g. /mnt/games): " mp
            read -p "Filesystem type (e.g. exfat, ext4): " fs
            read -p "Label (optional): " label
            add_mount "$dev" "$mp" "$fs" "$label"
            ;;
        2)
            mount_all
            ;;
        *)
            exit 0
            ;;
    esac
}

if [[ "${1:-}" == "--mount-all" ]]; then
    mount_all
    exit 0
fi

menu
