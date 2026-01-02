# 🚀 PowerScripts

A cross-platform collection of utility scripts for Windows, Linux, and macOS. Beautiful, idempotent, and inspired by GitHub CLI.

## ✨ Features

- 🎨 **Colorful CLI Output** - Rich visual feedback with emoji and colors
- 🔄 **Idempotent** - Safe to run multiple times
- 🌐 **Cross-Platform** - Windows (PowerShell), Linux (Bash), macOS (Zsh)
- 📦 **Synchronized** - Same functionality across all platforms
- 🛡️ **Robust** - Comprehensive error handling and validation

## 📁 Structure

```
PowerScripts/
├── scripts/
│   ├── windows/    # PowerShell scripts (.ps1)
│   ├── linux/      # Bash scripts (.sh)
│   └── macos/      # Zsh scripts (.zsh)
├── .github/
│   └── copilot-instructions.md
├── README.md
└── ...
```

## 🚦 Getting Started

### Windows (PowerShell)
```powershell
# Run a script
.\scripts\windows\script-name.ps1

# Get help
.\scripts\windows\script-name.ps1 -h
```

### Linux (Bash)
```bash
# Make executable (first time only)
chmod +x scripts/linux/script-name.sh

# Run a script
./scripts/linux/script-name.sh

# Get help
./scripts/linux/script-name.sh --help
```

### macOS (Zsh)
```zsh
# Make executable (first time only)
chmod +x scripts/macos/script-name.zsh

# Run a script
./scripts/macos/script-name.zsh

# Get help
./scripts/macos/script-name.zsh --help
```

## 📚 Available Scripts

### `Windows-Check-Health`
Comprehensive Windows system update and maintenance script with full automation support.

**Features:**
- 🪟 Windows Updates installation
- 🏥 System health checks (DISM, SFC)
- 📦 Winget package updates
- 🍫 Chocolatey package updates (if installed)
- 🥄 Scoop package updates (if installed)
- 🏪 Microsoft Store app updates

**Platforms:**
- **Windows**: `scripts/windows/Windows-Check-Health.ps1`

**Quick Start:**
```powershell
# Run all operations (default)
.\scripts\windows\Windows-Check-Health.ps1

# Disable specific operations
.\scripts\windows\Windows-Check-Health.ps1 -WindowsUpdate:$false -SystemHealth:$false

# Show help
.\scripts\windows\Windows-Check-Health.ps1 -Help
```

**Parameters:**
- `-WindowsUpdate` - Enable/disable Windows Updates (default: enabled)
- `-SystemHealth` - Enable/disable system health checks (default: enabled)
- `-Winget` - Enable/disable Winget updates (default: enabled)
- `-Chocolatey` - Enable/disable Chocolatey updates (default: enabled)
- `-Scoop` - Enable/disable Scoop updates (default: enabled)
- `-MicrosoftStore` - Enable/disable Microsoft Store updates (default: enabled)
- `-Help` / `-h` / `-?` - Display help information

**Requirements:**
- Administrator privileges
- PowerShell 5.1 or higher

📖 **[Full Documentation](docs/Windows-Check-Health.md)**

---

### `Install-Docker`
Automated Docker installation with all necessary prerequisites and dependencies.

**Features:**
- 🔍 Automatic distribution/OS detection
- 📦 Dependency installation
- 🐳 Docker Engine/Desktop installation
- ⚙️ Post-installation configuration
- ✅ Installation verification
- 🎨 Platform-specific optimizations

**Platforms:**
- **Windows**: `scripts/windows/Install-Docker.ps1`
- **Linux**: `scripts/linux/install-docker.sh`
- **macOS**: `scripts/macos/install-docker.zsh`

**Quick Start:**

**Windows:**
```powershell
# Full installation (checks WSL2 + Hyper-V)
.\scripts\windows\Install-Docker.ps1

# Skip specific components
.\scripts\windows\Install-Docker.ps1 -SkipWSL

# Show help
.\scripts\windows\Install-Docker.ps1 -Help
```

**Linux:**
```bash
# Make executable (first time)
chmod +x scripts/linux/install-docker.sh

# Full installation
sudo ./scripts/linux/install-docker.sh

# Skip Docker Compose
sudo ./scripts/linux/install-docker.sh --skip-compose

# Show help
./scripts/linux/install-docker.sh --help
```

**macOS:**
```zsh
# Make executable (first time)
chmod +x scripts/macos/install-docker.zsh

# Full installation
./scripts/macos/install-docker.zsh

# Skip Rosetta 2 (Apple Silicon)
./scripts/macos/install-docker.zsh --skip-rosetta

# Show help
./scripts/macos/install-docker.zsh --help
```

**Windows Parameters:**
- `-SkipWSL` - Skip WSL2 installation
- `-SkipHyperV` - Skip Hyper-V verification
- `-SkipDocker` - Skip Docker Desktop installation
- `-Help` - Display help

**Linux Options:**
- `--skip-compose` - Skip Docker Compose installation
- `--skip-user-group` - Skip adding user to docker group
- `--help` - Display help

**macOS Options:**
- `--skip-homebrew` - Skip Homebrew check
- `--skip-rosetta` - Skip Rosetta 2 installation
- `--help` - Display help

**Requirements:**
- **Windows**: Administrator privileges, Windows 10/11 Pro/Enterprise
- **Linux**: Root/sudo privileges, supported distro (Ubuntu, Debian, Fedora, CentOS, Arch)
- **macOS**: macOS 11.0+, administrator privileges

📖 **[Full Documentation](docs/Install-Docker.md)**

---

### `Install-VSCode`
Complete development environment setup with VS Code, Git, PowerShell 7, Oh My Posh, and Docker.

**Features:**
- 📝 Visual Studio Code installation
- 📦 Git version control
- 💻 PowerShell 7 (latest version)
- 🎨 Oh My Posh with Dracula theme
- 🐳 Docker (optional, calls Install-Docker script)
- 🔌 VS Code extensions (Dev Containers, Docker, PowerShell, GitLens)
- ⚙️ Automatic profile configuration
- 🔤 Nerd Font installation

**Platforms:**
- **Windows**: `scripts/windows/Install-VSCode.ps1`
- **Linux**: `scripts/linux/install-vscode.sh`
- **macOS**: `scripts/macos/install-vscode.zsh`

**Quick Start:**

**Windows:**
```powershell
# Full installation
.\scripts\windows\Install-VSCode.ps1

# Skip Docker
.\scripts\windows\Install-VSCode.ps1 -SkipDocker

# Use different Oh My Posh theme
.\scripts\windows\Install-VSCode.ps1 -OhMyPoshTheme "paradox"
```

**Linux:**
```bash
# Make executable (first time)
chmod +x scripts/linux/install-vscode.sh

# Full installation
sudo ./scripts/linux/install-vscode.sh

# Skip Docker and use different theme
sudo ./scripts/linux/install-vscode.sh --skip-docker --ohmyposh-theme "paradox"
```

**macOS:**
```zsh
# Make executable (first time)
chmod +x scripts/macos/install-vscode.zsh

# Full installation
./scripts/macos/install-vscode.zsh

# Skip Docker
./scripts/macos/install-vscode.zsh --skip-docker
```

**What Gets Installed:**
1. **Git** - Version control system
2. **PowerShell 7** - Latest PowerShell with cross-platform support
3. **Oh My Posh** - Prompt theme engine with Dracula theme
4. **Nerd Font** - CascadiaCode/CaskaydiaCove for icons
5. **VS Code** - Latest Visual Studio Code
6. **Extensions**: PowerShell, GitLens, Dev Containers, Docker
7. **Docker** - Full Docker installation (optional)

**PowerShell Profile:**
- Configured with Oh My Posh and Dracula theme
- PSReadLine with history prediction
- Useful aliases (g=git, d=docker, dc=docker-compose)

📖 **[Full Documentation](docs/Install-VSCode.md)**

---

### `Docker-Cleanup-Shrink`
Docker cleanup and disk space recovery utility.

**Platforms:**
- **Windows**: `scripts/windows/Docker-Cleanup-Shrink.ps1`

---

## 🎨 Output Style

All scripts follow a consistent visual language:

- ✅ **Success** - Green text
- ❌ **Error** - Red text
- ⚠️ **Warning** - Yellow text
- ℹ️ **Info** - Cyan text
- 📝 **Note** - Magenta text
- 🚀 **Action** - Bold/bright text

## 🤝 Contributing

When adding new scripts:

1. Create versions for **all three platforms** (Windows, Linux, macOS)
2. Ensure **functional parity** across platforms
3. Follow the **style guide** in `.github/copilot-instructions.md`
4. Test **idempotency** (run twice, verify same result)
5. Update this README with script documentation

## 📋 Requirements

- **Windows**: PowerShell 5.1+ (PowerShell 7+ recommended)
- **Linux**: Bash 4.0+
- **macOS**: Zsh 5.0+ (default on macOS 10.15+)

## 📄 License

[MIT License](LICENSE) - feel free to use and modify these scripts.

## 🙏 Acknowledgments

Inspired by the excellent UX of [GitHub CLI](https://cli.github.com/).

---

Made with ❤️ for cross-platform automation
