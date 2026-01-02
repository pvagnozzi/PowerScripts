# Install-VSCode

## 📋 Overview

Cross-platform development environment installation scripts that set up a complete modern development stack including VS Code, Git, PowerShell 7, Oh My Posh with beautiful theming, and optionally Docker.

## ✨ Features

### All Platforms
- 📝 **Visual Studio Code** - Latest version with essential extensions
- 📦 **Git** - Complete version control system
- 💻 **PowerShell 7** - Cross-platform PowerShell (latest)
- 🎨 **Oh My Posh** - Beautiful prompt themes (Dracula default)
- 🔤 **Nerd Fonts** - Icon support in terminal
- 🔌 **VS Code Extensions** - Automatic installation
- ⚙️ **Profile Configuration** - Automatic PowerShell profile setup
- 🐳 **Docker Integration** - Optional Docker installation

### VS Code Extensions Installed
1. **PowerShell** - PowerShell language support
2. **GitLens** - Supercharged Git capabilities
3. **Dev Containers** - Container-based development (optional)
4. **Docker** - Docker support and management (optional)

### Oh My Posh Features
- **Dracula theme** by default (customizable)
- **PSReadLine** integration with history prediction
- **Useful aliases** pre-configured
- **Cross-shell** support (PowerShell, Bash, Zsh)

## 🚀 Usage

### Windows

```powershell
# Full installation (Administrator required)
.\scripts\windows\Install-VSCode.ps1

# Skip Docker installation
.\scripts\windows\Install-VSCode.ps1 -SkipDocker

# Skip specific components
.\scripts\windows\Install-VSCode.ps1 -SkipGit -SkipPowerShell

# Use different Oh My Posh theme
.\scripts\windows\Install-VSCode.ps1 -OhMyPoshTheme "paradox"

# Skip all optional components
.\scripts\windows\Install-VSCode.ps1 -SkipDocker -SkipDevContainers -SkipOhMyPosh

# Show help
.\scripts\windows\Install-VSCode.ps1 -Help
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-SkipDocker` | Switch | `$false` | Skip Docker installation |
| `-SkipDevContainers` | Switch | `$false` | Skip Dev Containers extension |
| `-SkipGit` | Switch | `$false` | Skip Git installation |
| `-SkipPowerShell` | Switch | `$false` | Skip PowerShell 7 installation |
| `-SkipOhMyPosh` | Switch | `$false` | Skip Oh My Posh installation |
| `-OhMyPoshTheme` | String | `"dracula"` | Oh My Posh theme name |
| `-Help` | Switch | `$false` | Display help |

### Linux

```bash
# Make executable (first time only)
chmod +x scripts/linux/install-vscode.sh

# Full installation (sudo required)
sudo ./scripts/linux/install-vscode.sh

# Skip Docker installation
sudo ./scripts/linux/install-vscode.sh --skip-docker

# Use different theme
sudo ./scripts/linux/install-vscode.sh --ohmyposh-theme "paradox"

# Skip multiple components
sudo ./scripts/linux/install-vscode.sh --skip-docker --skip-devcontainers

# Show help
./scripts/linux/install-vscode.sh --help
```

**Options:**
| Option | Description |
|--------|-------------|
| `--skip-docker` | Skip Docker installation |
| `--skip-devcontainers` | Skip Dev Containers extension |
| `--skip-git` | Skip Git installation |
| `--skip-powershell` | Skip PowerShell 7 installation |
| `--skip-ohmyposh` | Skip Oh My Posh installation |
| `--ohmyposh-theme NAME` | Oh My Posh theme (default: dracula) |
| `-h`, `--help` | Display help |

### macOS

```zsh
# Make executable (first time only)
chmod +x scripts/macos/install-vscode.zsh

# Full installation
./scripts/macos/install-vscode.zsh

# Skip Docker installation
./scripts/macos/install-vscode.zsh --skip-docker

# Use different theme
./scripts/macos/install-vscode.zsh --ohmyposh-theme "night-owl"

# Show help
./scripts/macos/install-vscode.zsh --help
```

**Options:** Same as Linux

## 📋 Requirements

### Windows
- **OS**: Windows 10/11
- **Privileges**: Administrator
- **Prerequisites**: Winget (App Installer from Microsoft Store)

### Linux
- **Distributions**: Ubuntu, Debian, Fedora, CentOS, Arch Linux
- **Privileges**: Root/sudo
- **Kernel**: Modern kernel (3.10+)

### macOS
- **Version**: macOS 11.0 (Big Sur) or later
- **Internet**: Required (Homebrew auto-installed if needed)

## 🔧 What Gets Installed

### 1. Git
- **Windows**: Latest Git for Windows via Winget
- **Linux**: Git from distribution repositories
- **macOS**: Git via Homebrew

### 2. PowerShell 7
- **Windows**: Latest PowerShell 7 via Winget
- **Linux**: PowerShell from Microsoft repositories
- **macOS**: PowerShell via Homebrew Cask

### 3. Oh My Posh
- **Windows**: Oh My Posh via Winget
- **Linux**: Oh My Posh via install script
- **macOS**: Oh My Posh via Homebrew

**Includes:**
- Dracula theme configuration (customizable)
- CascadiaCode/CaskaydiaCove Nerd Font
- Automatic profile configuration

### 4. Visual Studio Code
- **Windows**: VS Code via Winget
- **Linux**: VS Code from Microsoft repositories
- **macOS**: VS Code via Homebrew Cask

### 5. VS Code Extensions
- **ms-vscode.powershell** - PowerShell language support
- **eamodio.gitlens** - Git supercharged
- **ms-vscode-remote.remote-containers** - Dev Containers (optional)
- **ms-azuretools.vscode-docker** - Docker support (optional)

### 6. Docker (Optional)
- Calls the `Install-Docker` script for complete Docker setup
- Includes all Docker prerequisites (WSL2, Hyper-V on Windows)

## ⚙️ PowerShell Profile Configuration

The script creates/updates PowerShell profiles with:

### Profile Content
```powershell
# Oh My Posh initialization with Dracula theme
oh-my-posh init pwsh --config "path/to/dracula.omp.json" | Invoke-Expression

# PSReadLine configuration for better editing
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Useful aliases
Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value docker-compose
```

### Profile Locations
- **Windows PowerShell 7**: `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- **Windows PowerShell 5.1**: `$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- **Linux/macOS**: `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
- **Bash**: `~/.bashrc` (Linux)
- **Zsh**: `~/.zshrc` (macOS)

## 🎨 Available Oh My Posh Themes

Popular themes you can use:

- `dracula` (default) - Dark theme with purple accents
- `paradox` - Minimalist with Git status
- `agnoster` - Powerline-style
- `powerlevel10k_rainbow` - Colorful segments
- `night-owl` - Dark blue theme
- `jandedobbeleer` - Creator's theme
- `atomic` - Minimal and clean
- `capr4n` - Elegant and simple

Browse all themes: https://ohmyposh.dev/docs/themes

Change theme:
```powershell
# Windows
.\Install-VSCode.ps1 -OhMyPoshTheme "night-owl"

# Linux/macOS
./install-vscode.zsh --ohmyposh-theme "night-owl"
```

## 💡 Examples

### Example 1: Full Development Environment
```powershell
# Windows - Everything included
.\scripts\windows\Install-VSCode.ps1

# After installation:
# - Launch PowerShell 7 (pwsh)
# - Open VS Code (code .)
# - Start Docker Desktop
```

### Example 2: Minimal Setup (No Docker)
```bash
# Linux - Skip Docker for lightweight setup
sudo ./scripts/linux/install-vscode.sh --skip-docker

# Perfect for development without containers
```

### Example 3: Custom Theme
```zsh
# macOS - Use night-owl theme
./scripts/macos/install-vscode.zsh --ohmyposh-theme "night-owl"
```

### Example 4: Code-Only Setup
```powershell
# Windows - Only VS Code and extensions
.\scripts\windows\Install-VSCode.ps1 -SkipGit -SkipPowerShell -SkipOhMyPosh -SkipDocker
```

## 📊 Post-Installation

### All Platforms

1. **Restart Terminal**
   ```bash
   # Close and reopen terminal to apply changes
   ```

2. **Launch PowerShell 7**
   ```bash
   pwsh
   ```

3. **Verify Oh My Posh**
   - You should see the Dracula-themed prompt
   - Icons require Nerd Font in terminal

4. **Configure Terminal Font**
   - **Windows Terminal**: Settings > Profiles > PowerShell > Font Face > "CaskaydiaCove Nerd Font"
   - **VS Code**: Settings > Terminal > Font Family > "CaskaydiaCove Nerd Font"
   - **iTerm2**: Preferences > Profiles > Text > Font > "CaskaydiaCove Nerd Font"

5. **Open VS Code**
   ```bash
   code .
   ```

6. **Verify Extensions**
   - Open Extensions panel (Ctrl+Shift+X)
   - Verify PowerShell, GitLens, Dev Containers, Docker are installed

### macOS-Specific

Install `code` command if not available:
- Open VS Code
- Command Palette (Cmd+Shift+P)
- Type: "Shell Command: Install 'code' command in PATH"

## 🐛 Troubleshooting

### Windows

**Winget not found:**
- Install "App Installer" from Microsoft Store
- Or download from: https://aka.ms/getwinget

**Oh My Posh theme not showing:**
- Verify font is set to Nerd Font in terminal
- Restart terminal after installation
- Check: `oh-my-posh --version`

**PowerShell profile not loading:**
- Check execution policy: `Get-ExecutionPolicy`
- Set if needed: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify profile exists: `Test-Path $PROFILE`

### Linux

**PowerShell installation failed:**
- Verify distribution is supported
- Update package lists: `sudo apt update`
- Check Microsoft repository setup

**VS Code extensions not installing:**
- Run `code` command manually first
- Verify user permissions
- Install extensions manually: `code --install-extension <extension-id>`

**Oh My Posh not showing:**
- Verify installation: `which oh-my-posh`
- Check PATH: `echo $PATH`
- Source profile: `source ~/.bashrc` or `source ~/.config/powershell/profile.ps1`

### macOS

**Homebrew installation fails:**
- Install manually: https://brew.sh
- Check Xcode Command Line Tools: `xcode-select --install`

**Code command not found:**
- Open VS Code
- Install shell command from Command Palette
- Or add to PATH: `export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"`

**Font not displaying correctly:**
- Install font manually: `brew install --cask font-caskaydia-cove-nerd-font`
- Configure terminal to use installed font
- Restart terminal

## 🔒 Security Considerations

- Scripts require elevated privileges
- Official repositories used for all installations
- No credentials stored or transmitted
- Logs stored in temporary directories
- Downloads via HTTPS

## 📚 Related Resources

- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- [PowerShell 7](https://github.com/PowerShell/PowerShell)
- [Oh My Posh](https://ohmyposh.dev/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

## 📄 Version History

- **v1.0** - Initial release with full cross-platform support

---

**Author**: PowerScripts  
**License**: MIT  
**Repository**: [PowerScripts](https://github.com/yourusername/PowerScripts)
