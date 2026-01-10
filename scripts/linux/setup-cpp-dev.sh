#!/usr/bin/env bash

#
# Setup C++ development environment on Linux
#
# Configures the system for C++ development by installing:
# - Git version control
# - CMake build system
# - Ninja build system
# - vcpkg package manager
# - GCC compiler
# - Clang/LLVM compiler
# - Build essentials and development tools
# - Visual Studio Code with C++ extensions
# - Oh My Posh with user theme
# 
# All tools are configured with proper PATH settings.
#
# Usage:
#   sudo ./setup-cpp-dev.sh
#   sudo ./setup-cpp-dev.sh --skip-updates
#   sudo ./setup-cpp-dev.sh -v
#
# Options:
#   --skip-updates     Skip updating existing tools
#   -v, --verbose      Show detailed output
#   -h, --help         Show this help message
#

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# Output functions
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
action() { echo -e "${WHITE}🚀 $1${NC}"; }
note() { echo -e "${MAGENTA}📝 $1${NC}"; }

# Variables
SKIP_UPDATES=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-updates)
            SKIP_UPDATES=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            grep "^#" "$0" | grep -v "#!/usr/bin/env bash" | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect package manager
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists yum; then
        echo "yum"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists zypper; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Install package based on package manager
install_package() {
    local pkg=$1
    local pm=$(detect_package_manager)
    
    case $pm in
        apt)
            apt-get update -qq && apt-get install -y "$pkg"
            ;;
        dnf)
            dnf install -y "$pkg"
            ;;
        yum)
            yum install -y "$pkg"
            ;;
        pacman)
            pacman -S --noconfirm "$pkg"
            ;;
        zypper)
            zypper install -y "$pkg"
            ;;
        *)
            error "Unknown package manager"
            return 1
            ;;
    esac
}

# Add to PATH
add_to_path() {
    local path=$1
    local user_home=$(eval echo ~${SUDO_USER})
    local shell_rc="$user_home/.bashrc"
    
    if [[ ! -d "$path" ]]; then
        warning "Path does not exist: $path"
        return
    fi
    
    # Detect shell
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$user_home/.zshrc"
    fi
    
    if ! grep -q "$path" "$shell_rc" 2>/dev/null; then
        echo "export PATH=\"\$PATH:$path\"" >> "$shell_rc"
        success "Added to PATH: $path"
    else
        info "Already in PATH: $path"
    fi
}

action "🎯 Starting C++ Development Environment Setup"
info "Platform: Linux"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (use sudo)"
    exit 1
fi

USER_HOME=$(eval echo ~${SUDO_USER})
PM=$(detect_package_manager)
info "Detected package manager: $PM"

# Install system dependencies
action "Installing system dependencies..."
case $PM in
    apt)
        apt-get update -qq
        apt-get install -y build-essential curl wget git software-properties-common \
            pkg-config autoconf automake libtool m4 unzip tar zip
        ;;
    dnf|yum)
        $PM group install -y "Development Tools"
        $PM install -y curl wget git gcc gcc-c++ make autoconf automake libtool \
            pkg-config unzip tar zip
        ;;
    pacman)
        pacman -S --noconfirm base-devel curl wget git
        ;;
    zypper)
        zypper install -t pattern -y devel_basis
        zypper install -y curl wget git gcc gcc-c++ make autoconf automake libtool \
            pkg-config unzip tar zip
        ;;
esac
success "System dependencies installed"

# Install Git
action "Checking Git..."
if ! command_exists git; then
    info "Installing Git..."
    install_package git
    success "Git installed"
else
    success "Git already installed"
fi

# Install GCC
action "Checking GCC..."
if ! command_exists g++; then
    info "Installing GCC..."
    case $PM in
        apt)
            install_package g++
            ;;
        dnf|yum)
            install_package gcc-c++
            ;;
        pacman)
            install_package gcc
            ;;
        zypper)
            install_package gcc-c++
            ;;
    esac
    success "GCC installed"
else
    success "GCC already installed"
fi

# Install Clang/LLVM
action "Installing/Updating Clang/LLVM..."
if ! command_exists clang; then
    info "Installing Clang..."
    case $PM in
        apt)
            apt-get install -y clang lldb lld
            ;;
        dnf|yum)
            $PM install -y clang llvm lld lldb
            ;;
        pacman)
            pacman -S --noconfirm clang llvm lld lldb
            ;;
        zypper)
            zypper install -y clang llvm lld lldb
            ;;
    esac
    success "Clang/LLVM installed"
else
    success "Clang/LLVM already installed"
fi

# Install CMake
action "Installing/Updating CMake..."
if ! command_exists cmake; then
    info "Installing CMake..."
    case $PM in
        apt)
            # Install latest CMake via Kitware APT repository
            wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
            apt-add-repository -y "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
            apt-get update -qq
            apt-get install -y cmake
            ;;
        dnf|yum)
            $PM install -y cmake
            ;;
        pacman)
            pacman -S --noconfirm cmake
            ;;
        zypper)
            zypper install -y cmake
            ;;
    esac
    success "CMake installed"
else
    success "CMake already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        case $PM in
            apt)
                apt-get install -y --only-upgrade cmake
                ;;
            dnf|yum)
                $PM update -y cmake
                ;;
            pacman)
                pacman -S --noconfirm cmake
                ;;
            zypper)
                zypper update -y cmake
                ;;
        esac
    fi
fi

# Install Ninja
action "Installing/Updating Ninja..."
if ! command_exists ninja; then
    info "Installing Ninja..."
    case $PM in
        apt)
            apt-get install -y ninja-build
            ;;
        dnf|yum)
            $PM install -y ninja-build
            ;;
        pacman)
            pacman -S --noconfirm ninja
            ;;
        zypper)
            zypper install -y ninja
            ;;
    esac
    success "Ninja installed"
else
    success "Ninja already installed"
fi

# Install vcpkg
action "Installing/Updating vcpkg..."
VCPKG_ROOT="$USER_HOME/vcpkg"
if [[ ! -f "$VCPKG_ROOT/vcpkg" ]]; then
    info "Cloning vcpkg repository..."
    sudo -u $SUDO_USER git clone https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"
    
    info "Bootstrapping vcpkg..."
    sudo -u $SUDO_USER "$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics
    
    add_to_path "$VCPKG_ROOT"
    
    # Set environment variable
    SHELL_RC="$USER_HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="$USER_HOME/.zshrc"
    fi
    
    if ! grep -q "VCPKG_ROOT" "$SHELL_RC" 2>/dev/null; then
        echo "export VCPKG_ROOT=\"$VCPKG_ROOT\"" >> "$SHELL_RC"
        success "VCPKG_ROOT environment variable set"
    fi
    
    success "vcpkg installed"
else
    success "vcpkg already installed"
    add_to_path "$VCPKG_ROOT"
    
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating vcpkg..."
        cd "$VCPKG_ROOT"
        sudo -u $SUDO_USER git pull
        sudo -u $SUDO_USER ./bootstrap-vcpkg.sh -disableMetrics
        success "vcpkg updated"
    fi
fi

# Install VS Code
action "Installing/Updating Visual Studio Code..."
if ! command_exists code; then
    case $PM in
        apt)
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
            install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/
            sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f /tmp/packages.microsoft.gpg
            apt-get update -qq
            apt-get install -y code
            ;;
        dnf|yum)
            rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            $PM check-update
            $PM install -y code
            ;;
        pacman)
            pacman -S --noconfirm code
            ;;
        *)
            warning "Please install VS Code manually from https://code.visualstudio.com/"
            ;;
    esac
    success "VS Code installed"
else
    success "VS Code already installed"
fi

# Install VS Code extensions
action "Installing VS Code extensions..."
if command_exists code; then
    extensions=(
        "ms-vscode.cpptools"
        "ms-vscode.cpptools-extension-pack"
        "ms-vscode.cmake-tools"
        "twxs.cmake"
        "llvm-vs-code-extensions.vscode-clangd"
        "vadimcn.vscode-lldb"
        "usernamehw.errorlens"
        "eamodio.gitlens"
        "GitHub.copilot"
        "GitHub.copilot-chat"
        "ms-vscode-remote.remote-containers"
        "ms-azuretools.vscode-docker"
    )
    for ext in "${extensions[@]}"; do
        info "Installing extension: $ext"
        sudo -u $SUDO_USER code --install-extension "$ext" --force 2>/dev/null || true
    done
    success "VS Code extensions installed"
fi

# Configure VS Code settings
action "Configuring VS Code C++ settings..."
VSCODE_SETTINGS_DIR="$USER_HOME/.config/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

sudo -u $SUDO_USER mkdir -p "$VSCODE_SETTINGS_DIR"

# Get compiler paths
CMAKE_PATH=$(which cmake 2>/dev/null || echo "cmake")
GCC_PATH=$(which gcc 2>/dev/null || echo "gcc")
GPP_PATH=$(which g++ 2>/dev/null || echo "g++")
CLANG_PATH=$(which clang 2>/dev/null || echo "clang")
CLANGPP_PATH=$(which clang++ 2>/dev/null || echo "clang++")
CLANGD_PATH=$(which clangd 2>/dev/null || echo "clangd")

if [[ -f "$VSCODE_SETTINGS_FILE" ]]; then
    # Update existing settings
    TEMP_FILE=$(mktemp)
    python3 -c "
import json
import sys
try:
    with open('$VSCODE_SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
except:
    settings = {}

# CMake settings
settings['cmake.cmakePath'] = '$CMAKE_PATH'
settings['cmake.generator'] = 'Ninja'
settings['cmake.configureSettings'] = {
    'CMAKE_C_COMPILER': '$GCC_PATH',
    'CMAKE_CXX_COMPILER': '$GPP_PATH'
}

# C++ IntelliSense
settings['C_Cpp.default.compilerPath'] = '$GPP_PATH'

# Clangd settings
settings['clangd.path'] = '$CLANGD_PATH'

# vcpkg integration
if '$VCPKG_ROOT' and '$VCPKG_ROOT' != '':
    settings['cmake.configureSettings']['CMAKE_TOOLCHAIN_FILE'] = '$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake'

with open('$TEMP_FILE', 'w') as f:
    json.dump(settings, f, indent=4)
" 2>/dev/null || echo '{}' > "$TEMP_FILE"
    
    sudo -u $SUDO_USER cp "$TEMP_FILE" "$VSCODE_SETTINGS_FILE"
    rm -f "$TEMP_FILE"
else
    # Create new settings
    sudo -u $SUDO_USER cat > "$VSCODE_SETTINGS_FILE" <<EOF
{
    "cmake.cmakePath": "$CMAKE_PATH",
    "cmake.generator": "Ninja",
    "cmake.configureSettings": {
        "CMAKE_C_COMPILER": "$GCC_PATH",
        "CMAKE_CXX_COMPILER": "$GPP_PATH",
        "CMAKE_TOOLCHAIN_FILE": "$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
    },
    "C_Cpp.default.compilerPath": "$GPP_PATH",
    "clangd.path": "$CLANGD_PATH"
}
EOF
fi

success "VS Code configured with C++ toolchain paths"

# Install Oh My Posh
action "Installing/Updating Oh My Posh..."
if ! command_exists oh-my-posh; then
    info "Downloading Oh My Posh..."
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    chmod +x /usr/local/bin/oh-my-posh
    success "Oh My Posh installed"
else
    success "Oh My Posh already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating Oh My Posh..."
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        chmod +x /usr/local/bin/oh-my-posh
    fi
fi

# Configure Oh My Posh
action "Configuring Oh My Posh..."
SHELL_CONFIGS=("$USER_HOME/.bashrc" "$USER_HOME/.zshrc")

for SHELL_RC in "${SHELL_CONFIGS[@]}"; do
    # Determine init command based on shell config file
    if [[ "$SHELL_RC" == *"zshrc"* ]]; then
        INIT_CMD='eval "$(oh-my-posh init zsh)"'
        SHELL_NAME="zsh"
    else
        INIT_CMD='eval "$(oh-my-posh init bash)"'
        SHELL_NAME="bash"
    fi
    
    sudo -u $SUDO_USER touch "$SHELL_RC" 2>/dev/null
    
    if ! grep -q "oh-my-posh init" "$SHELL_RC" 2>/dev/null; then
        {
            echo ""
            echo "# Oh My Posh initialization"
            echo "$INIT_CMD"
        } >> "$SHELL_RC"
        success "Oh My Posh configured for $SHELL_NAME"
    else
        info "Oh My Posh already configured in $(basename $SHELL_RC)"
    fi
done

# Install additional development libraries
action "Installing common C++ development libraries..."
case $PM in
    apt)
        apt-get install -y libssl-dev libcurl4-openssl-dev zlib1g-dev \
            libboost-all-dev libjsoncpp-dev
        ;;
    dnf|yum)
        $PM install -y openssl-devel libcurl-devel zlib-devel \
            boost-devel jsoncpp-devel
        ;;
    pacman)
        pacman -S --noconfirm openssl curl zlib boost jsoncpp
        ;;
    zypper)
        zypper install -y libopenssl-devel libcurl-devel zlib-devel \
            boost-devel libjsoncpp-devel
        ;;
esac
success "Development libraries installed"

# Final summary
action ""
action "📊 Installation Summary"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

command_exists git && success "Git is ready" || warning "Git needs attention"
command_exists g++ && success "GCC is ready" || warning "GCC needs attention"
command_exists clang && success "Clang is ready" || warning "Clang needs attention"
command_exists cmake && success "CMake is ready" || warning "CMake needs attention"
command_exists ninja && success "Ninja is ready" || warning "Ninja needs attention"
[[ -f "$VCPKG_ROOT/vcpkg" ]] && success "vcpkg is ready" || warning "vcpkg needs attention"
command_exists code && success "VS Code is ready" || warning "VS Code needs attention"
command_exists oh-my-posh && success "Oh My Posh is ready" || warning "Oh My Posh needs attention"

# Display versions
action ""
action "📋 Installed Versions"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists git; then
    info "Git: $(git --version)"
fi

if command_exists g++; then
    info "GCC: $(g++ --version | head -n1)"
fi

if command_exists clang; then
    info "Clang: $(clang --version | head -n1)"
fi

if command_exists cmake; then
    info "CMake: $(cmake --version | head -n1)"
fi

if command_exists ninja; then
    info "Ninja: $(ninja --version)"
fi

if command_exists code; then
    info "VS Code: $(code --version | head -n1)"
fi

action ""
action "✨ Setup Complete!"
note "Next steps:"
info "1. Restart your terminal to apply PATH changes"
info "2. Test CMake: cmake --version"
info "3. Test GCC: g++ --version"
info "4. Test Clang: clang --version"
info "5. Install packages with vcpkg: vcpkg install <package-name>"
info "6. Create a CMake project and configure with: cmake -B build -G Ninja"
info "7. VS Code: Sign in with GitHub for Copilot activation"
note "Sample vcpkg packages: fmt, nlohmann-json, boost, catch2, spdlog"
success ""
success "Happy coding! 🚀"
