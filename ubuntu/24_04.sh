#!/bin/bash

# Ubuntu 24.04 Common Packages Installation Script
# This script installs the most commonly used packages for Ubuntu 24.04

set -e  # Exit on error

echo "Starting Ubuntu 24.04 package installation..."
echo "Updating package lists..."

# Update package lists
sudo apt update

# Upgrade existing packages
echo "Upgrading existing packages..."
sudo apt upgrade -y

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
    nmap \
    tcpdump \
    wireshark-common

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
echo "  - System utilities (htop, tree, unzip)"
echo "  - Network tools (net-tools, ping, nmap)"
echo "  - Multimedia codecs"
echo "  - Python and Node.js development tools"
echo "  - Docker Engine with plugins"
echo "  - Terminal enhancements"
echo ""

