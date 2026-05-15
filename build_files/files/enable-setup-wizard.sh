#!/usr/bin/env bash
# Auto-enable setup wizard for all users on first boot
# This script runs once during image build

set -euo pipefail

echo "Configuring first-boot setup wizard..."

# Install user service file
mkdir -p /etc/skel/.config/systemd/user
cp /tmp/car-edge-setup-wizard.service /etc/skel/.config/systemd/user/

# Create autostart directory in skeleton
mkdir -p /etc/skel/.config/autostart

# Create desktop autostart entry (fallback if systemd user service doesn't work)
cat > /etc/skel/.config/autostart/car-edge-setup-wizard.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Bazzite Car Edge Setup Wizard
Exec=/usr/bin/car-edge-setup-wizard --auto
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
X-KDE-autostart-phase=2
Hidden=false
NoDisplay=false
Comment=First boot setup wizard for Bazzite Car Edge
OnlyShowIn=KDE;
EOF

# Enable for existing deck user (default Bazzite user)
if [ -d "/var/home/deck" ]; then
    echo "Enabling wizard for deck user..."
    
    # Create user systemd directory
    mkdir -p /var/home/deck/.config/systemd/user
    cp /tmp/car-edge-setup-wizard.service /var/home/deck/.config/systemd/user/
    chown -R 1000:1000 /var/home/deck/.config/systemd
    
    # Create autostart directory
    mkdir -p /var/home/deck/.config/autostart
    cp /etc/skel/.config/autostart/car-edge-setup-wizard.desktop /var/home/deck/.config/autostart/
    chown -R 1000:1000 /var/home/deck/.config/autostart
fi

echo "✅ Setup wizard configured for auto-run on first boot"
