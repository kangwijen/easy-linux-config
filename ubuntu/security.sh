#!/bin/bash

# Ubuntu Security Tools Installation Script
# This script installs and configures essential security tools for Ubuntu

set -e  # Exit on error

echo "Starting Ubuntu security tools installation..."
echo "Updating package lists..."

# Update package lists
sudo apt update

# Install security tools
echo "Installing security tools..."
sudo apt install -y \
    fail2ban \
    apparmor \
    apparmor-utils \
    unattended-upgrades \
    apt-listchanges \
    auditd \
    rkhunter \
    chkrootkit \
    aide \
    logwatch \
    rsyslog

# Configure fail2ban (active mode - enabled and running)
echo "Configuring fail2ban (active mode - IP banning enabled)..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "fail2ban installed and enabled (active mode - will ban malicious IPs)"

# Configure AppArmor (passive mode - complain mode instead of enforce)
echo "Configuring AppArmor (passive mode - complain mode)..."
sudo systemctl enable apparmor
sudo systemctl start apparmor
# Set all AppArmor profiles to complain mode
for profile in /etc/apparmor.d/*; do
    if [ -f "$profile" ]; then
        sudo aa-complain "$profile" 2>/dev/null || true
    fi
done
echo "AppArmor configured in complain mode (logs violations but doesn't block)"

# Configure unattended-upgrades for automatic security updates
echo "Configuring automatic security updates..."
sudo systemctl enable unattended-upgrades
sudo systemctl start unattended-upgrades

# Create unattended-upgrades configuration
sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

# Enable automatic updates
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "Automatic security updates configured"

# Initialize AIDE (Advanced Intrusion Detection Environment)
echo "Initializing AIDE database..."
if [ ! -f /var/lib/aide/aide.db ]; then
    # aideinit may require interactive input, use yes to auto-confirm
    yes | sudo aideinit 2>/dev/null || sudo aideinit -y 2>/dev/null || sudo aideinit
    # Move the new database file if it exists
    if [ -f /var/lib/aide/aide.db.new ]; then
        sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    elif [ -f /var/lib/aide/aide.db.gz ]; then
        sudo gunzip /var/lib/aide/aide.db.gz
    fi
    echo "AIDE database initialized"
else
    echo "AIDE database already exists"
fi

# Update rkhunter database
echo "Updating rkhunter database..."
sudo rkhunter --update 2>/dev/null || true
sudo rkhunter --propupd 2>/dev/null || true
echo "rkhunter database updated"

# Configure auditd
echo "Configuring auditd..."
sudo systemctl enable auditd
sudo systemctl start auditd

# Configure logwatch (basic configuration)
echo "Configuring logwatch..."
sudo tee /etc/cron.daily/00logwatch > /dev/null <<'EOF'
#!/bin/bash
/usr/sbin/logwatch --output mail --mailto root --detail high
EOF
sudo chmod +x /etc/cron.daily/00logwatch
echo "logwatch configured"

# Clean up
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo ""
echo "Security installation complete!"
echo ""
echo "Installed and configured security tools:"
echo "  - fail2ban (ACTIVE - monitors logs and bans malicious IPs)"
echo "  - AppArmor (complain mode - logs violations, doesn't block)"
echo "  - unattended-upgrades (automatic security updates)"
echo "  - auditd (system audit daemon - passive logging)"
echo "  - rkhunter (rootkit hunter - passive scanning)"
echo "  - chkrootkit (rootkit detector - passive scanning)"
echo "  - AIDE (file integrity checker - passive monitoring)"
echo "  - logwatch (log file analyzer - passive reporting)"
echo ""
echo "Important notes:"
echo "  - fail2ban is ACTIVE and will automatically ban IPs showing malicious activity"
echo "  - Automatic security updates are ENABLED and will install automatically"
echo "  - AppArmor logs policy violations but doesn't block them (complain mode)"
echo "  - Most other tools are in PASSIVE MODE - they monitor and report but don't take automatic actions"
echo "  - Run 'sudo rkhunter --check' periodically to scan for rootkits"
echo "  - Run 'sudo chkrootkit' periodically to check for rootkits"
echo "  - Run 'sudo aide --check' to verify file integrity"
echo "  - Review logwatch reports in /var/log/logwatch/"
echo ""

