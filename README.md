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

### `Setup-DotNetDev`
Complete .NET development environment setup for Windows with all necessary tools and SDKs.

**Features:**
- 💻 .NET SDK (latest LTS and current versions)
- 🔧 Git version control
- ⚡ PowerShell 7 (latest version)
- 🎨 Oh My Posh with automatic initialization and user theme
- 📝 VS Code with C#/DevKit extensions
- 🔲 Hyper-V verification and enablement
- 🐧 WSL2 with Ubuntu distribution (updated)
- 🐳 Docker Desktop
- 🎯 Visual Studio 2022 (optional, default: yes)
- 🚀 JetBrains Rider via Toolbox (optional, default: no)
- ☁️ Azure CLI and NuGet CLI
- ⚙️ Automatic PATH configuration

**Platform:**
- **Windows**: `scripts/windows/Setup-DotNetDev.ps1`

**Quick Start:**
```powershell
# Full installation (includes Visual Studio, no Rider)
.\scripts\windows\Setup-DotNetDev.ps1

# Skip Visual Studio, install Rider
.\scripts\windows\Setup-DotNetDev.ps1 -SkipVisualStudio -InstallRider

# Skip Docker
.\scripts\windows\Setup-DotNetDev.ps1 -SkipDocker

# Skip updates of existing tools
.\scripts\windows\Setup-DotNetDev.ps1 -SkipUpdates
```

**Parameters:**
- `-SkipVisualStudio` - Skip Visual Studio installation (default: install)
- `-InstallRider` - Install JetBrains Rider via Toolbox (default: no)
- `-SkipDocker` - Skip Docker Desktop installation
- `-SkipUpdates` - Skip updating existing tools
- `-Verbose` - Show detailed output

**What Gets Installed:**
1. **Chocolatey** - Package manager
2. **Git** - Version control
3. **PowerShell 7** - Latest PowerShell with cross-platform support
4. **Oh My Posh** - Beautiful terminal prompts (auto-configured)
5. **.NET SDK** - Latest stable version
6. **VS Code** - With C#, DevKit, PowerShell, GitLens, Docker, Copilot extensions
7. **Hyper-V** - Virtualization platform (enabled if not already)
8. **WSL2 + Ubuntu** - Linux subsystem with updated distribution
9. **Docker Desktop** - Container platform
10. **Node.js + npm** - Required for GitHub Copilot CLI
11. **GitHub Copilot CLI** - AI-powered command line assistant
12. **Visual Studio 2022** - Full IDE (optional, default: yes)
13. **JetBrains Toolbox** - For Rider installation (optional, default: no)
14. **Azure CLI** - Azure command-line tools
15. **NuGet CLI** - Package management

**Post-Installation:**
- Restart terminal for PATH changes
- Run `dotnet --info` to verify .NET installation
- Complete Docker Desktop first-run setup
- Run `wsl` to set up Ubuntu (username/password)
- Authenticate GitHub Copilot CLI: `github-copilot-cli auth`
- VS Code: Sign in with GitHub for Copilot activation
- Open Visual Studio and sign in
- Configure Oh My Posh theme as desired

**Requirements:**
- **Windows 10/11** Pro, Enterprise, or Education (for Hyper-V)
- Administrator privileges (required)
- Internet connection
- ~20GB free disk space

**Notes:**
- Reboot may be required for Hyper-V/WSL features
- Script is idempotent - safe to run multiple times
- Visual Studio includes all workloads (.NET, ASP.NET, Azure, etc.)

---

### `setup-dotnet-dev`
Complete .NET development environment setup for Linux and macOS with all necessary tools and SDKs.

**Features:**
- 💻 .NET SDK (latest LTS version)
- 🔧 Git version control
- 🎨 Oh My Posh with automatic initialization and user theme
- 📝 VS Code with C#/DevKit extensions
- 🐳 Docker Desktop/Engine
- 🤖 GitHub Copilot CLI
- 🚀 JetBrains Rider via Toolbox (optional, default: no)
- ☁️ Azure CLI
- ⚙️ Automatic PATH configuration

**Platforms:**
- **Linux**: `scripts/linux/setup-dotnet-dev.sh`
- **macOS**: `scripts/macos/setup-dotnet-dev.zsh`

**Quick Start:**

**Linux:**
```bash
# Make executable (first time)
chmod +x scripts/linux/setup-dotnet-dev.sh

# Full installation (no Rider)
sudo ./scripts/linux/setup-dotnet-dev.sh

# Install with Rider
sudo ./scripts/linux/setup-dotnet-dev.sh --install-rider

# Skip Docker
sudo ./scripts/linux/setup-dotnet-dev.sh --skip-docker

# Show help
./scripts/linux/setup-dotnet-dev.sh --help
```

**macOS:**
```zsh
# Make executable (first time)
chmod +x scripts/macos/setup-dotnet-dev.zsh

# Full installation (no Rider)
./scripts/macos/setup-dotnet-dev.zsh

# Install with Rider
./scripts/macos/setup-dotnet-dev.zsh --install-rider

# Skip Docker
./scripts/macos/setup-dotnet-dev.zsh --skip-docker

# Show help
./scripts/macos/setup-dotnet-dev.zsh --help
```

**Options:**
- `--install-rider` - Install JetBrains Rider via Toolbox (default: no)
- `--skip-docker` - Skip Docker installation
- `--skip-updates` - Skip updating existing tools
- `-v, --verbose` - Show detailed output

**What Gets Installed:**
1. **Package Manager** - Homebrew (macOS) / system package manager (Linux)
2. **Git** - Version control
3. **.NET SDK** - Latest stable version (8.0+)
4. **VS Code** - With C#, DevKit, PowerShell, GitLens, Docker, Copilot extensions
5. **Oh My Posh** - Beautiful terminal prompts (auto-configured for bash/zsh)
6. **Docker** - Desktop (macOS) / Engine (Linux)
7. **GitHub Copilot CLI** - AI-powered command line assistant
8. **Node.js + npm** - Required for Copilot CLI
9. **Azure CLI** - Azure command-line tools
10. **JetBrains Toolbox** - For Rider installation (optional)

**Post-Installation:**
- Restart terminal for PATH changes
- Run `dotnet --info` to verify .NET installation
- Authenticate GitHub Copilot CLI: `github-copilot-cli auth`
- Sign in to VS Code with GitHub for Copilot
- Complete Docker Desktop setup (macOS)
- Log out/in for Docker group membership (Linux)

**Requirements:**
- **Linux**: sudo privileges, supported distro (Ubuntu, Debian, Fedora, RHEL, Arch, openSUSE)
- **macOS**: Administrator privileges, macOS 11.0+

**Notes:**
- Scripts are idempotent - safe to run multiple times
- GitHub Copilot requires a GitHub account with Copilot subscription
- Docker group membership requires logout/login on Linux

---

### `setup-flutter-dev`
Complete Flutter development environment setup with all necessary tools and SDKs.

**Features:**
- 📱 Flutter SDK installation and configuration
- 🎨 Android Studio with Android SDK
- 📝 VS Code with Flutter/Dart extensions
- 🔧 Git version control
- 📦 Platform-specific package managers (Chocolatey/Homebrew)
- 🍎 iOS development setup (macOS only - Xcode, CocoaPods)
- 🎨 Oh My Posh with custom theme
- ⚙️ Automatic PATH configuration
- 🔄 Updates for all tools (optional)

**Platforms:**
- **Windows**: `scripts/windows/setup-flutter-dev.ps1`
- **Linux**: `scripts/linux/setup-flutter-dev.sh`
- **macOS**: `scripts/macos/setup-flutter-dev.zsh`

**Quick Start:**

**Windows:**
```powershell
# Full installation
.\scripts\windows\setup-flutter-dev.ps1

# Skip updates of existing tools
.\scripts\windows\setup-flutter-dev.ps1 -SkipUpdates

# Verbose output
.\scripts\windows\setup-flutter-dev.ps1 -Verbose
```

**Linux:**
```bash
# Make executable (first time)
chmod +x scripts/linux/setup-flutter-dev.sh

# Full installation
./scripts/linux/setup-flutter-dev.sh

# Skip updates
./scripts/linux/setup-flutter-dev.sh --skip-updates

# Show help
./scripts/linux/setup-flutter-dev.sh --help
```

**macOS:**
```zsh
# Make executable (first time)
chmod +x scripts/macos/setup-flutter-dev.zsh

# Full installation (includes iOS support)
./scripts/macos/setup-flutter-dev.zsh

# Skip updates
./scripts/macos/setup-flutter-dev.zsh --skip-updates

# Show help
./scripts/macos/setup-flutter-dev.zsh --help
```

**What Gets Installed:**
1. **Flutter SDK** - Latest stable version
2. **Android Studio** - IDE with Android SDK
3. **Android SDK** - Platform tools, build tools, emulator, and system images
4. **Android Emulator** - Pre-configured device (flutter_emulator)
5. **VS Code** - With Dart, Flutter, snippets, Copilot, and emulator support
6. **Git** - Version control
7. **Oh My Posh** - Beautiful terminal prompts
8. **CocoaPods** - iOS dependency management (macOS only)
9. **Xcode** - iOS development (macOS only, manual completion required)
10. **KVM Support** - For faster Android emulation (Linux only)

**Post-Installation:**
- Run `flutter doctor` to verify installation
- Complete Android Studio first-run setup
- Accept Android licenses: `flutter doctor --android-licenses`
- Test Android emulator: `flutter emulators --launch flutter_emulator`
- VS Code: Sign in with GitHub for Copilot activation
- **macOS**: Open Xcode, accept license, test iOS simulator
- **Linux**: Log out/in for KVM group membership (faster emulation)

**Requirements:**
- **Windows**: Administrator privileges recommended, PowerShell 5.1+
- **Linux**: sudo privileges, supported package manager
- **macOS**: Administrator privileges, macOS 11.0+

---

### `setup-esp32-dev`
Complete ESP32 embedded development environment setup for all platforms with ESP-IDF and PlatformIO.

**Features:**
- 🔧 Git version control
- 🎨 Oh My Posh with automatic initialization and user theme
- 📝 VS Code with C/C++, ESP32, PlatformIO, and Copilot extensions
- ⚡ PowerShell 7 (Windows only)
- 🛠️ ESP-IDF (Espressif IoT Development Framework)
- 🚀 PlatformIO Core and IDE
- 🔨 C/C++ build tools (CMake, Ninja, GCC)
- 🐍 Python with pip (required for ESP-IDF)
- 🔌 USB drivers for ESP32 boards
- ⚙️ Automatic PATH configuration

**Platforms:**
- **Windows**: `scripts/windows/setup-esp32-dev.ps1`
- **Linux**: `scripts/linux/setup-esp32-dev.sh`
- **macOS**: `scripts/macos/setup-esp32-dev.zsh`

**Quick Start:**

**Windows:**
```powershell
# Full installation
.\scripts\windows\setup-esp32-dev.ps1

# Skip updates
.\scripts\windows\setup-esp32-dev.ps1 -SkipUpdates

# Verbose output
.\scripts\windows\setup-esp32-dev.ps1 -Verbose
```

**Linux:**
```bash
# Make executable (first time)
chmod +x scripts/linux/setup-esp32-dev.sh

# Full installation
sudo ./scripts/linux/setup-esp32-dev.sh

# Skip updates
sudo ./scripts/linux/setup-esp32-dev.sh --skip-updates

# Show help
./scripts/linux/setup-esp32-dev.sh --help
```

**macOS:**
```zsh
# Make executable (first time)
chmod +x scripts/macos/setup-esp32-dev.zsh

# Full installation
./scripts/macos/setup-esp32-dev.zsh

# Skip updates
./scripts/macos/setup-esp32-dev.zsh --skip-updates

# Show help
./scripts/macos/setup-esp32-dev.zsh --help
```

**What Gets Installed:**
1. **Git** - Version control
2. **PowerShell 7** - Latest shell (Windows only)
3. **Python 3** - With pip for ESP-IDF tools
4. **VS Code** - With comprehensive ESP32 extensions
5. **C/C++ Tools** - CMake, Ninja, GCC compiler chain
6. **ESP-IDF** - Official Espressif SDK (~$HOME/esp/esp-idf)
7. **PlatformIO** - Modern embedded development platform
8. **Oh My Posh** - Beautiful terminal prompts (auto-configured)
9. **USB Drivers** - CP210x/CH340 for ESP32 boards
10. **udev Rules** - USB permissions (Linux only)

**VS Code Extensions:**
- C/C++ IntelliSense and debugging
- C/C++ Extension Pack
- CMake Tools
- PlatformIO IDE
- ESP-IDF Extension
- Python support
- GitHub Copilot + Chat
- GitLens
- Error Lens
- Better C++ Syntax

**Post-Installation:**
- Restart terminal for PATH changes
- VS Code: Let PlatformIO complete background installation
- Test ESP-IDF: `source ~/esp/esp-idf/export.sh` (Unix) or run `export.ps1` (Windows)
- Create project: `pio project init --board esp32dev`
- Connect ESP32 and verify: Device Manager (Windows), `ls /dev/ttyUSB*` (Linux), `ls /dev/cu.*` (macOS)
- Log out/in for USB permissions (Linux)
- VS Code: Sign in with GitHub for Copilot

**Requirements:**
- **Windows**: Administrator privileges, PowerShell 5.1+, ~3GB disk space
- **Linux**: sudo privileges, supported distro, ~3GB disk space
- **macOS**: Administrator privileges, macOS 11.0+, ~3GB disk space

**Notes:**
- Scripts are idempotent - safe to run multiple times
- ESP-IDF installs to `~/esp/esp-idf` (cross-platform)
- USB drivers may require manual installation on macOS
- Linux users must log out/in for dialout/plugdev group membership

---

### `Setup-TypeScript-Dev` / `setup-typescript-dev`
Complete TypeScript/JavaScript development environment setup with Node.js, NVM, React, Angular, and Vue support.

**Features:**
- 🟢 Node.js LTS via NVM (Node Version Manager)
- 📘 TypeScript compiler and ts-node
- ⚛️ React development tools (Create React App, Vite)
- 🅰️ Angular CLI (optional)
- 💚 Vue CLI (optional)
- 📦 Package managers (npm, Yarn, PNPM)
- 🔧 Git version control
- ⚡ PowerShell 7 (Windows only)
- 🎨 Oh My Posh with automatic initialization and user theme
- 📝 VS Code with TypeScript, React, Angular, Vue extensions
- 🔍 ESLint and Prettier for code quality
- 🤖 GitHub Copilot CLI
- 🚀 WebStorm IDE (optional, default: no)
- ⚙️ Automatic PATH configuration

**Platforms:**
- **Windows**: `scripts/windows/Setup-TypeScript-Dev.ps1`
- **Linux**: `scripts/linux/setup-typescript-dev.sh`
- **macOS**: `scripts/macos/setup-typescript-dev.zsh`

**Quick Start:**

**Windows:**
```powershell
# Full installation (includes Angular and Vue)
.\scripts\windows\Setup-TypeScript-Dev.ps1

# Install with WebStorm
.\scripts\windows\Setup-TypeScript-Dev.ps1 -InstallWebStorm

# Skip Angular and Vue
.\scripts\windows\Setup-TypeScript-Dev.ps1 -SkipAngular -SkipVue

# Skip updates
.\scripts\windows\Setup-TypeScript-Dev.ps1 -SkipUpdates
```

**Linux:**
```bash
# Make executable (first time)
chmod +x scripts/linux/setup-typescript-dev.sh

# Full installation
sudo ./scripts/linux/setup-typescript-dev.sh

# Install with WebStorm, skip Angular and Vue
sudo ./scripts/linux/setup-typescript-dev.sh --install-webstorm --skip-angular --skip-vue

# Show help
./scripts/linux/setup-typescript-dev.sh --help
```

**macOS:**
```zsh
# Make executable (first time)
chmod +x scripts/macos/setup-typescript-dev.zsh

# Full installation
./scripts/macos/setup-typescript-dev.zsh

# Install with WebStorm
./scripts/macos/setup-typescript-dev.zsh --install-webstorm

# Skip Angular and Vue
./scripts/macos/setup-typescript-dev.zsh --skip-angular --skip-vue

# Show help
./scripts/macos/setup-typescript-dev.zsh --help
```

**Parameters/Options:**
- `--install-webstorm` / `-InstallWebStorm` - Install JetBrains WebStorm (default: no)
- `--skip-angular` / `-SkipAngular` - Skip Angular CLI installation
- `--skip-vue` / `-SkipVue` - Skip Vue CLI installation
- `--skip-updates` / `-SkipUpdates` - Skip updating existing tools
- `-v, --verbose` / `-Verbose` - Show detailed output

**What Gets Installed:**
1. **Package Manager** - Chocolatey (Windows) / Homebrew (macOS) / system package manager (Linux)
2. **Git** - Version control
3. **PowerShell 7** - Latest shell (Windows only)
4. **Oh My Posh** - Beautiful terminal prompts (auto-configured)
5. **NVM** - Node Version Manager for managing Node.js versions
6. **Node.js LTS** - Long-term support version via NVM
7. **TypeScript** - TypeScript compiler (global)
8. **ts-node** - TypeScript execution engine (global)
9. **Yarn** - Alternative package manager (global)
10. **PNPM** - Fast, disk space efficient package manager (global)
11. **Create React App** - Official React project generator (global)
12. **Vite** - Next generation frontend tooling (global)
13. **Angular CLI** - Angular development tools (optional, global)
14. **Vue CLI** - Vue.js development tools (optional, global)
15. **ESLint** - JavaScript/TypeScript linter (global)
16. **Prettier** - Code formatter (global)
17. **VS Code** - With comprehensive TypeScript/JavaScript extensions
18. **GitHub Copilot CLI** - AI-powered command line assistant
19. **WebStorm** - JetBrains IDE (optional)

**VS Code Extensions:**
- TypeScript and JavaScript Language Features
- ESLint integration
- Prettier - Code formatter
- ES7+ React/Redux/React-Native snippets
- Angular Language Service
- Vue Language Features (Volar)
- Tailwind CSS IntelliSense
- GitHub Copilot + Chat
- JavaScript Debugger
- Jest test runner

**Post-Installation:**
- Restart terminal for PATH changes
- Verify: `node --version && npm --version && tsc --version`
- Create React project: `npx create-react-app my-app` or `npm create vite@latest my-app -- --template react-ts`
- Create Angular project: `ng new my-app` (if Angular installed)
- Create Vue project: `vue create my-app` (if Vue installed)
- Configure Git: `git config --global user.name "Your Name"`
- Configure Git email: `git config --global user.email "your.email@example.com"`
- Authenticate GitHub Copilot CLI: `github-copilot-cli auth`
- VS Code: Sign in with GitHub for Copilot activation

**Requirements:**
- **Windows**: Administrator privileges, PowerShell 5.1+
- **Linux**: sudo privileges, supported package manager
- **macOS**: Administrator privileges, macOS 11.0+

**Notes:**
- Scripts are idempotent - safe to run multiple times
- NVM allows switching between Node.js versions: `nvm use <version>`
- Check available Node.js versions: `nvm list` (Windows) or `nvm ls` (Linux/macOS)
- Install specific Node version: `nvm install <version>`
- WebStorm requires JetBrains account (free trial or license)
- GitHub Copilot requires GitHub account with Copilot subscription

---

### `Setup-Cpp-Dev` / `setup-cpp-dev`
Complete C++ development environment setup with CMake, vcpkg, GCC, Clang, and all necessary build tools.

**Features:**
- 🔧 Git version control
- 🏗️ CMake build system (latest version)
- ⚡ Ninja build system for fast builds
- 📦 vcpkg package manager (Microsoft)
- 🔨 GCC compiler (MinGW-w64 on Windows, native on Linux/macOS)
- 🦙 Clang/LLVM compiler toolchain
- 🏢 MSVC Build Tools (Windows only, optional)
- 📝 VS Code with comprehensive C++ extensions
- ⚡ PowerShell 7 (Windows only)
- 🎨 Oh My Posh with automatic initialization and user theme
- 📚 Common development libraries (OpenSSL, Curl, Boost, etc.)
- ⚙️ Automatic PATH and environment configuration

**Platforms:**
- **Windows**: `scripts/windows/Setup-Cpp-Dev.ps1`
- **Linux**: `scripts/linux/setup-cpp-dev.sh`
- **macOS**: `scripts/macos/setup-cpp-dev.zsh`

**Quick Start:**

**Windows:**
```powershell
# Full installation (includes MSVC Build Tools)
.\scripts\windows\Setup-Cpp-Dev.ps1

# Skip Visual Studio Build Tools
.\scripts\windows\Setup-Cpp-Dev.ps1 -SkipVisualStudio

# Skip updates
.\scripts\windows\Setup-Cpp-Dev.ps1 -SkipUpdates

# Verbose output
.\scripts\windows\Setup-Cpp-Dev.ps1 -Verbose
```

**Linux:**
```bash
# Make executable (first time)
chmod +x scripts/linux/setup-cpp-dev.sh

# Full installation
sudo ./scripts/linux/setup-cpp-dev.sh

# Skip updates
sudo ./scripts/linux/setup-cpp-dev.sh --skip-updates

# Show help
./scripts/linux/setup-cpp-dev.sh --help
```

**macOS:**
```zsh
# Make executable (first time)
chmod +x scripts/macos/setup-cpp-dev.zsh

# Full installation
./scripts/macos/setup-cpp-dev.zsh

# Skip updates
./scripts/macos/setup-cpp-dev.zsh --skip-updates

# Show help
./scripts/macos/setup-cpp-dev.zsh --help
```

**Parameters/Options:**
- `--skip-updates` / `-SkipUpdates` - Skip updating existing tools
- `-SkipVisualStudio` - Skip MSVC Build Tools installation (Windows only)
- `-v, --verbose` / `-Verbose` - Show detailed output

**What Gets Installed:**
1. **Package Manager** - Chocolatey (Windows) / Homebrew (macOS) / system package manager (Linux)
2. **Git** - Version control
3. **PowerShell 7** - Latest shell (Windows only)
4. **Oh My Posh** - Beautiful terminal prompts (auto-configured)
5. **CMake** - Cross-platform build system generator
6. **Ninja** - Small build system with focus on speed
7. **GCC/G++** - GNU Compiler Collection (MinGW-w64 on Windows)
8. **Clang/LLVM** - Modern C/C++ compiler with excellent diagnostics
9. **MSVC Build Tools** - Microsoft C++ compiler (Windows only, optional)
10. **vcpkg** - C++ library manager (~/.vcpkg or ~/vcpkg)
11. **VS Code** - With comprehensive C++ extensions
12. **Development Libraries** - OpenSSL, libcurl, zlib, Boost, jsoncpp

**VS Code Extensions:**
- C/C++ IntelliSense and debugging (Microsoft)
- C/C++ Extension Pack
- CMake Tools
- CMake language support
- clangd (LLVM language server)
- LLDB Debugger
- Error Lens
- GitLens
- GitHub Copilot + Chat
- Dev Containers
- Docker support

**Post-Installation:**
- Restart terminal for PATH changes
- Test CMake: `cmake --version`
- Test GCC: `g++ --version`
- Test Clang: `clang --version`
- Test vcpkg: `vcpkg search <package-name>`
- Install libraries: `vcpkg install fmt nlohmann-json boost catch2 spdlog`
- Create CMake project: `cmake -B build -G Ninja`
- Build project: `cmake --build build`
- VS Code: Sign in with GitHub for Copilot activation

**Sample vcpkg Packages:**
- `fmt` - Modern formatting library
- `nlohmann-json` - JSON for Modern C++
- `boost` - Comprehensive C++ libraries
- `catch2` - Modern testing framework
- `spdlog` - Fast logging library
- `range-v3` - Range library
- `abseil` - Google's C++ library collection

**Environment Variables Set:**
- `VCPKG_ROOT` - Path to vcpkg installation
- `PATH` - Updated with all tool paths

**Requirements:**
- **Windows**: Administrator privileges recommended, PowerShell 5.1+
- **Linux**: sudo privileges, supported package manager
- **macOS**: Administrator privileges, macOS 11.0+, Xcode Command Line Tools

**Notes:**
- Scripts are idempotent - safe to run multiple times
- vcpkg integrates with CMake automatically
- MSVC Build Tools required for some vcpkg packages on Windows
- macOS: Apple Clang is default, LLVM Clang available via Homebrew
- Linux: GCC is default system compiler

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
