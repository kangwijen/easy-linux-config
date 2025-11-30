#!/bin/bash

# Ubuntu 24.04 Common Packages Installation Script
# This script installs the most commonly used packages for Ubuntu 24.04

set -e  # Exit on error

echo "Starting Ubuntu 24.04 package installation..."

# Set non-interactive frontend to prevent any interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Pre-configure common packages that require interactive input
echo "Pre-configuring packages to prevent interactive prompts..."
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

# Find and handle any packages in broken or half-configured states
echo "Checking for broken or problematic packages..."
BROKEN_PACKAGES=$(dpkg -l | awk '/^..r|^..iU|^..iF/ {print $2}' | grep -v "^$" || true)

if [ -n "$BROKEN_PACKAGES" ]; then
    echo "Found packages requiring attention: $BROKEN_PACKAGES"
    # Fix any broken package states first
    sudo dpkg --configure -a 2>/dev/null || true
    
    # Remove problematic packages and their cached data
    for pkg in $BROKEN_PACKAGES; do
        echo "Removing package and cached data for: $pkg"
        # Remove the package
        sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge "$pkg" 2>/dev/null || true
        # Remove cached download data
        sudo rm -rf "/var/lib/update-notifier/package-data-downloads/partial/${pkg}"* 2>/dev/null || true
        sudo rm -rf "/var/lib/update-notifier/package-data-downloads/${pkg}"* 2>/dev/null || true
        sudo rm -rf "/tmp/${pkg}"* 2>/dev/null || true
        # Remove package info files
        sudo rm -rf "/var/lib/dpkg/info/${pkg}."* 2>/dev/null || true
        # Remove from debconf database
        echo "$pkg" | sudo debconf-communicate purge 2>/dev/null || true
    done
fi

# Clean up general apt cache and temporary files
echo "Cleaning up apt cache and temporary files..."
sudo rm -rf /var/lib/update-notifier/package-data-downloads/partial/* 2>/dev/null || true
sudo rm -rf /tmp/apt* 2>/dev/null || true
sudo rm -rf /tmp/*.deb 2>/dev/null || true
sudo rm -rf /var/cache/apt/archives/partial/* 2>/dev/null || true

# Clean up debconf database entries for removed packages
echo "Cleaning up debconf database..."
sudo sed -i '/^ttf-mscorefonts-installer/d' /var/cache/debconf/config.dat 2>/dev/null || true
sudo sed -i '/^ttf-mscorefonts-installer/d' /var/cache/debconf/passwords.dat 2>/dev/null || true

# Re-apply debconf settings for known problematic packages
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

echo "Updating package lists..."

# Update package lists
sudo DEBIAN_FRONTEND=noninteractive apt update

# Upgrade existing packages
echo "Upgrading existing packages..."
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Install build essentials and development tools
echo "Installing build essentials and development tools..."
sudo apt install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    vim \
    nano \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install system utilities
echo "Installing system utilities..."
sudo apt install -y \
    htop \
    tree \
    unzip \
    zip \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    net-tools \
    iputils-ping \
    traceroute \
    netcat-openbsd \
    jq \
    tmux \
    screen \
    rsync \
    openssh-client \
    openssh-server

# Install multimedia codecs
echo "Installing multimedia codecs..."
sudo apt install -y \
    ffmpeg

# Install network and internet tools
echo "Installing network tools..."
sudo apt install -y \
    dnsutils \
    whois \

# Install terminal enhancements
echo "Installing terminal enhancements..."
sudo apt install -y \
    zsh

# Install Python development tools
echo "Installing Python development tools..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools

# Install Node.js (via nvm)
echo "Installing Node.js via nvm..."
if ! command -v node &> /dev/null; then
    # Download and install nvm
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        # Source nvm in the current shell session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    else
        # Source nvm if it already exists
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Install Node.js 24
    nvm install 24
    nvm use 24
    nvm alias default 24
    
    echo "Node.js $(node --version) and npm $(npm --version) installed successfully"
else
    echo "Node.js is already installed: $(node --version)"
fi

# Install Docker Engine (via official Docker repository)
echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index
    sudo apt update
    
    # Install Docker Engine, CLI, containerd, and plugins
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add current user to docker group (requires logout/login to take effect)
    sudo usermod -aG docker $USER
    
    # Start and enable Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
    
    echo "Docker $(docker --version) installed successfully"
    echo "Note: You may need to log out and log back in for docker group membership to take effect"
else
    echo "Docker is already installed: $(docker --version)"
fi

# Clean up
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo ""
echo "Installation complete!"
echo "You may need to log out and log back in for some changes to take effect."
echo ""
echo "Installed packages include:"
echo "  - Build tools (gcc, make, cmake)"
echo "  - Development tools (git, curl, wget)"
echo "  - Text editors (vim, nano)"
echo "  - System utilities (htop, tree, unzip, net-tools, ping, traceroute, netcat)"
echo "  - Network tools (dnsutils, whois)"
echo "  - Multimedia codecs (ffmpeg)"
echo "  - Python and Node.js development tools"
echo "  - Docker Engine with plugins"
echo "  - Terminal enhancements (zsh)"
echo ""

