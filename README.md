# Easy Linux Configuration

A collection of installation and configuration scripts organized by Linux distribution and version.

## Structure

Scripts are organized by OS distribution and version:
- `ubuntu` - Common packages installation for Ubuntu
- `debian` - Common packages installation for Debian

## Usage

Download and run the script directly:

```bash
# Using wget
wget -O- https://raw.githubusercontent.com/kangwijen/easy-linux-config/main/ubuntu/24_04.sh | bash

# Or using curl
curl -fsSL https://raw.githubusercontent.com/kangwijen/easy-linux-config/main/ubuntu/24_04.sh | bash
```

## What's Installed

Each script installs a comprehensive set of packages organized by category:

### Build & Development Tools
- Build essentials (gcc, g++, make, cmake)
- Version control (git)
- Package managers (curl, wget)
- Text editors (vim, nano)

### System Utilities
- Process monitoring (htop)
- File management (tree, unzip, zip, tar)
- JSON processor (jq)
- Terminal multiplexers (tmux, screen)
- Remote access (SSH client/server, rsync)

### Network Tools
- Network utilities (net-tools, ping, traceroute, netcat)
- Network analysis (nmap, tcpdump, wireshark-common)
- DNS tools (dnsutils, whois)

### Development Environments
- **Python**: Python 3 with pip, venv, and development headers
- **Node.js**: Node.js 24.x via nvm (Node Version Manager) with npm
- **Docker**: Docker Engine with CLI, containerd, Buildx, and Compose plugins

### Multimedia
- Ubuntu restricted extras
- FFmpeg and additional codecs

### Terminal Enhancements
- Alternative shell (zsh)
