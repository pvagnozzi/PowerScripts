# Install-Docker

## 📋 Overview

Cross-platform Docker installation scripts that automate the complete setup process including all prerequisites, dependencies, and post-installation configuration.

## ✨ Features

### All Platforms
- 🔍 Automatic OS/distribution detection
- 📦 Dependency installation
- 🐳 Docker installation (Engine or Desktop)
- ⚙️ Post-installation configuration
- ✅ Installation verification
- 📝 Detailed logging
- 🎨 Colorful CLI output with emoji

### Platform-Specific

#### Windows
- 🪟 WSL2 installation and configuration
- 🖥️ Hyper-V enablement verification
- 🐳 Docker Desktop via Winget
- 🔄 Automatic reboot handling

#### Linux
- 🐧 Multi-distro support (Ubuntu, Debian, Fedora, CentOS, Arch)
- 🔧 Official Docker repository setup
- 🔨 Docker Compose installation
- 👥 User group configuration

#### macOS
- 🍺 Homebrew integration
- 🍎 Apple Silicon (ARM64) support
- 🔧 Rosetta 2 installation
- 🖥️ Docker Desktop via Homebrew Cask

## 🚀 Usage

### Windows

```powershell
# Full installation (Administrator required)
.\scripts\windows\Install-Docker.ps1

# Skip WSL2 configuration
.\scripts\windows\Install-Docker.ps1 -SkipWSL

# Skip Hyper-V check
.\scripts\windows\Install-Docker.ps1 -SkipHyperV

# Only check prerequisites
.\scripts\windows\Install-Docker.ps1 -SkipDocker

# Show help
.\scripts\windows\Install-Docker.ps1 -Help
```

**Parameters:**
- `-SkipWSL` - Skip WSL2 installation/configuration
- `-SkipHyperV` - Skip Hyper-V verification
- `-SkipDocker` - Skip Docker Desktop installation
- `-Help` / `-h` / `-?` - Display help information

### Linux

```bash
# Make executable (first time only)
chmod +x scripts/linux/install-docker.sh

# Full installation (sudo required)
sudo ./scripts/linux/install-docker.sh

# Skip Docker Compose
sudo ./scripts/linux/install-docker.sh --skip-compose

# Skip user group configuration
sudo ./scripts/linux/install-docker.sh --skip-user-group

# Show help
./scripts/linux/install-docker.sh --help
```

**Options:**
- `--skip-compose` - Skip Docker Compose installation
- `--skip-user-group` - Skip adding user to docker group
- `-h`, `--help` - Display help information

### macOS

```zsh
# Make executable (first time only)
chmod +x scripts/macos/install-docker.zsh

# Full installation
./scripts/macos/install-docker.zsh

# Skip Homebrew check
./scripts/macos/install-docker.zsh --skip-homebrew

# Skip Rosetta 2 (Apple Silicon only)
./scripts/macos/install-docker.zsh --skip-rosetta

# Show help
./scripts/macos/install-docker.zsh --help
```

**Options:**
- `--skip-homebrew` - Skip Homebrew installation check
- `--skip-rosetta` - Skip Rosetta 2 installation (Apple Silicon)
- `-h`, `--help` - Display help information

## 📋 Requirements

### Windows
- **OS**: Windows 10 version 2004+ (Build 19041) or Windows 11
- **Edition**: Pro, Enterprise, or Education (Home supported via WSL2 only)
- **Privileges**: Administrator
- **Features**: WSL2, Hyper-V (enabled by script)
- **Optional**: Winget (for automated installation)

### Linux
- **Distributions**: Ubuntu, Debian, Fedora, CentOS, RHEL, Arch Linux
- **Privileges**: Root/sudo
- **Kernel**: 3.10+ (4.0+ recommended)
- **Internet**: Required for package downloads

### macOS
- **Version**: macOS 11.0 (Big Sur) or later
- **Privileges**: Administrator
- **Processor**: Intel or Apple Silicon
- **Internet**: Required for Homebrew and Docker Desktop

## 🔧 What Gets Installed

### Windows
1. **WSL2** (if not present)
   - Windows Subsystem for Linux
   - Virtual Machine Platform
   - WSL2 kernel update
2. **Hyper-V** (Pro/Enterprise only)
   - Hyper-V platform
   - Hyper-V management tools
3. **Docker Desktop**
   - Docker Engine
   - Docker Compose
   - Docker CLI
   - Kubernetes (optional)

### Linux
1. **Prerequisites**
   - ca-certificates
   - curl, gnupg
   - apt-transport-https (Debian/Ubuntu)
   - Repository management tools
2. **Docker Engine**
   - Docker CE (Community Edition)
   - containerd
   - Docker CLI
3. **Docker Compose**
   - Docker Compose plugin or standalone
4. **Docker Buildx**
   - Build enhancement plugin

### macOS
1. **Homebrew** (if not present)
   - macOS package manager
2. **Rosetta 2** (Apple Silicon only)
   - x86 compatibility layer
3. **Docker Desktop**
   - Docker Engine
   - Docker Compose
   - Docker CLI
   - Kubernetes (optional)

## 🔄 Idempotency

All scripts are idempotent and can be run multiple times safely:
- Detects existing installations
- Skips already-configured components
- Updates existing installations when appropriate
- No duplicate installations or conflicts

## 📊 Post-Installation

### All Platforms

After installation completes:

1. **Verify Installation**
   ```bash
   docker --version
   docker compose version
   ```

2. **Test Docker**
   ```bash
   docker run hello-world
   ```

3. **Check Status**
   ```bash
   docker info
   ```

### Windows-Specific

- **Reboot may be required** for WSL2/Hyper-V
- Start Docker Desktop from Start Menu
- Complete initial setup wizard
- Configure resources in Docker Desktop settings

### Linux-Specific

- **Log out and back in** for group permissions
- Service starts automatically
- Configure daemon: `/etc/docker/daemon.json`

### macOS-Specific

- Docker Desktop starts automatically
- Access from menu bar icon
- Configure resources in Docker Desktop preferences
- Grant necessary permissions when prompted

## 💡 Examples

### Example 1: Fresh Windows Installation
```powershell
# Complete installation with all prerequisites
.\scripts\windows\Install-Docker.ps1

# System will prompt for reboot if needed
# After reboot, start Docker Desktop from Start Menu
```

### Example 2: Linux Server Setup
```bash
# Full installation with Compose and user group
sudo ./scripts/linux/install-docker.sh

# Log out and back in
# Verify without sudo
docker run hello-world
```

### Example 3: macOS Developer Setup
```zsh
# Install everything including Rosetta 2
./scripts/macos/install-docker.zsh

# Wait for Docker Desktop to initialize
# Start using Docker
```

### Example 4: CI/CD Environment (Linux)
```bash
# Minimal installation without user group
sudo ./scripts/linux/install-docker.sh --skip-user-group

# Docker commands will require sudo
sudo docker run hello-world
```

## 🐛 Troubleshooting

### Windows

**WSL2 installation fails:**
- Enable virtualization in BIOS/UEFI
- Check Windows version (requires 2004+)
- Run: `wsl --install` manually

**Hyper-V conflicts:**
- Disable other virtualization software (VirtualBox, VMware)
- Check: `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V`

**Docker Desktop won't start:**
- Check WSL2 is running: `wsl --status`
- Restart Docker Desktop
- Check logs: `%LOCALAPPDATA%\Docker\log.txt`

### Linux

**Repository setup fails:**
- Check internet connection
- Verify distribution is supported
- Update package lists: `sudo apt update` / `sudo dnf update`

**Permission denied:**
- Add user to docker group: `sudo usermod -aG docker $USER`
- Log out and back in
- Or use sudo for docker commands

**Service won't start:**
- Check status: `sudo systemctl status docker`
- View logs: `sudo journalctl -u docker`
- Restart: `sudo systemctl restart docker`

### macOS

**Homebrew installation fails:**
- Install manually: https://brew.sh
- Check Xcode Command Line Tools: `xcode-select --install`

**Docker Desktop won't start:**
- Check macOS version (requires 11.0+)
- Grant necessary permissions in System Preferences
- Check logs: `~/Library/Containers/com.docker.docker/Data/log`

**Rosetta 2 issues (Apple Silicon):**
- Install manually: `softwareupdate --install-rosetta`
- Required for x86 container support

## 🔒 Security Considerations

- Scripts require elevated privileges
- Official Docker repositories used
- No credentials stored or transmitted
- Logs stored in temporary directories
- HTTPS used for all downloads

## 📚 Related Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- [Docker Engine for Linux](https://docs.docker.com/engine/install/)
- [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- [WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Homebrew](https://brew.sh/)

## 📄 Version History

- **v1.0** - Initial release with cross-platform support

---

**Author**: PowerScripts  
**License**: MIT  
**Repository**: [PowerScripts](https://github.com/yourusername/PowerScripts)
