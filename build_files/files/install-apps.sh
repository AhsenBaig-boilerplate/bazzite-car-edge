#!/bin/bash
# Bazzite Car Edge - Application Installer (GUI)
# Installs entertainment Flatpak apps with a progress dialog.
set -euo pipefail

LOG_FILE="$HOME/.cache/car-edge-install-apps.log"
mkdir -p "$HOME/.cache"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "═══════════════════════════════════════"
log "App installer started"
log "═══════════════════════════════════════"

# ── Require kdialog ────────────────────────────────────────────────────────────
if ! command -v kdialog &>/dev/null; then
    echo "ERROR: kdialog not found — this installer requires KDE Plasma."
    exit 1
fi

# ── App catalogue ──────────────────────────────────────────────────────────────
# Format: "APP_ID|Friendly name|Description|grant_storage(yes/no)"
APPS=(
    "tv.kodi.Kodi|Kodi|🎬 Media center — movies, TV, music|yes"
    "org.mozilla.firefox|Firefox|🦊 Web browser — Netflix, YouTube, streaming|no"
    "com.heroicgameslauncher.hgl|Heroic|🎮 Epic Games and GOG launcher|yes"
    "org.prismlauncher.PrismLauncher|Minecraft|🎮 Minecraft with mod support|yes"
    "org.videolan.VLC|VLC|🎬 Video player (backup media player)|yes"
    "com.github.iwalton3.jellyfin-media-player|Jellyfin|📺 Stream from your home Jellyfin server|yes"
    "com.github.zocker_160.SyncThingy|Syncthing|🔄 Auto-sync files with your home computer|yes"
    "org.kiwix.desktop|Kiwix|📚 Offline Wikipedia and reference books|yes"
    "net.davidotek.pupgui2|ProtonUp-Qt|⚙️  Manage Proton/Wine compatibility versions|no"
    "com.visualstudio.code|VS Code|💻 Code editor and text viewer|no"
)

# ── Build checklist args ───────────────────────────────────────────────────────
checklist_args=()
for entry in "${APPS[@]}"; do
    id=$(echo "$entry" | cut -d'|' -f1)
    name=$(echo "$entry" | cut -d'|' -f2)
    desc=$(echo "$entry" | cut -d'|' -f3)
    checklist_args+=("$id" "$name — $desc" "on")
done

# ── App selection dialog ───────────────────────────────────────────────────────
selected_raw=$(kdialog --title "📦 Install Applications" \
    --checklist "Choose which apps to install.
All are pre-selected — uncheck any you don't want.

Installation takes 10–20 minutes depending on your connection." \
    "${checklist_args[@]}" 2>/dev/null || echo "")

if [ -z "$selected_raw" ]; then
    log "User cancelled app selection"
    exit 0
fi

# Parse space-separated quoted IDs into an array
selected_ids=()
while IFS= read -r -d '' token; do
    [ -n "$token" ] && selected_ids+=("$token")
done < <(echo "$selected_raw" | xargs -n1 printf '%s\0' 2>/dev/null || true)

# Fallback: split on spaces if xargs failed
if [ ${#selected_ids[@]} -eq 0 ]; then
    read -ra selected_ids <<< "$selected_raw"
fi

total=${#selected_ids[@]}
if [ "$total" -eq 0 ]; then
    kdialog --msgbox "No apps selected.\n\nYou can install apps later from the Control Panel → Applications."
    exit 0
fi

log "Selected $total apps: ${selected_ids[*]}"

# ── Confirm ────────────────────────────────────────────────────────────────────
confirm_list=""
for id in "${selected_ids[@]}"; do
    for entry in "${APPS[@]}"; do
        if [[ "$entry" == "$id|"* ]]; then
            name=$(echo "$entry" | cut -d'|' -f2)
            confirm_list+="  • $name\n"
            break
        fi
    done
done

if ! kdialog --yesno "Install these $total apps?

$confirm_list
This will take 10–20 minutes.
You can use the computer while it runs.

Continue?"; then
    log "User cancelled confirmation"
    exit 0
fi

# ── Progress dialog ────────────────────────────────────────────────────────────
dbus_ref=$(kdialog --title "📦 Installing Apps" \
    --progressbar "Starting installation..." "$total" 2>/dev/null || echo "")
dbus_service=""
dbus_path=""
if [ -n "$dbus_ref" ]; then
    dbus_service=$(echo "$dbus_ref" | awk '{print $1}')
    dbus_path=$(echo "$dbus_ref" | awk '{print $2}')
fi

set_progress() {
    local val="$1" label="$2"
    if [ -n "$dbus_service" ] && command -v qdbus &>/dev/null; then
        qdbus "$dbus_service" "$dbus_path" Set "" value "$val" 2>/dev/null || true
        qdbus "$dbus_service" "$dbus_path" setLabelText "$label" 2>/dev/null || true
    fi
    log "$label"
}

close_progress() {
    if [ -n "$dbus_service" ] && command -v qdbus &>/dev/null; then
        qdbus "$dbus_service" "$dbus_path" close 2>/dev/null || true
    fi
}

# ── Install loop ───────────────────────────────────────────────────────────────
installed=()
failed=()
idx=0

for app_id in "${selected_ids[@]}"; do
    (( idx++ )) || true

    # Look up friendly name
    app_name="$app_id"
    grant_storage="no"
    for entry in "${APPS[@]}"; do
        if [[ "$entry" == "$app_id|"* ]]; then
            app_name=$(echo "$entry" | cut -d'|' -f2)
            grant_storage=$(echo "$entry" | cut -d'|' -f4)
            break
        fi
    done

    set_progress "$idx" "Installing $app_name ($idx/$total)..."

    attempt=1
    success=false
    while [ $attempt -le 2 ]; do
        log "Installing $app_id (attempt $attempt)..."
        if flatpak install --system --noninteractive --assumeyes flathub "$app_id" \
               >> "$LOG_FILE" 2>&1; then
            success=true
            log "✓ Installed: $app_id"
            break
        fi
        log "Attempt $attempt failed for $app_id"
        (( attempt++ )) || true
    done

    if $success; then
        installed+=("$app_name")

        # Grant /mnt/storage access for media apps
        if [ "$grant_storage" = "yes" ] && mountpoint -q /mnt/storage 2>/dev/null; then
            flatpak override --user --filesystem=/mnt/storage "$app_id" 2>/dev/null || true
            log "  → Granted /mnt/storage access to $app_id"
        fi
    else
        failed+=("$app_name")
        log "✗ Failed: $app_id"
    fi
done

close_progress

# VS Code on Bazzite is usually sandboxed as Flatpak. These permissions improve
# workspace and host-tool interoperability for common dev workflows.
flatpak override --user com.visualstudio.code --filesystem=host || true
flatpak override --user com.visualstudio.code --talk-name=org.freedesktop.Flatpak || true
flatpak override --user com.visualstudio.code --socket=ssh-auth || true

# ── Summary ────────────────────────────────────────────────────────────────────
ok_list=""
for n in "${installed[@]}"; do ok_list+="  ✅ $n\n"; done

fail_list=""
for n in "${failed[@]}"; do fail_list+="  ❌ $n\n"; done

if [ ${#failed[@]} -eq 0 ]; then
    kdialog --title "✅ Installation Complete" --msgbox \
"All $total apps installed successfully!

$ok_list
💡 Media apps have been given access to /mnt/storage automatically.

You can manage apps anytime from:
Control Panel → Applications"
else
    kdialog --title "⚠️ Installation Finished" --msgbox \
"Installation finished with some failures.

Installed (${#installed[@]}):
$ok_list
Failed (${#failed[@]}):
$fail_list
For failures, check your internet connection and try again:
Control Panel → Applications → Install Applications

Log: $LOG_FILE"
fi

log "Installation complete. Installed: ${#installed[@]}, Failed: ${#failed[@]}"
