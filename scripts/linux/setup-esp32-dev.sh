#!/usr/bin/env bash

#
# Setup ESP32 development environment on Linux
#
# Configures the system for ESP32 development by installing and configuring:
# - Git version control
# - Visual Studio Code with ESP32/PlatformIO/C++ extensions
# - ESP-IDF (ESP32 SDK)
# - CMake, GCC, Clang
# - PlatformIO
# - C/C++ build tools
# - Python (required for ESP-IDF)
# - Oh My Posh with automatic initialization and user theme
# 
# All tools are configured with proper PATH settings and integrations.
#
# Usage:
#   sudo ./setup-esp32-dev.sh
#   sudo ./setup-esp32-dev.sh --skip-updates
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

action "🎯 Starting ESP32 Development Environment Setup"
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
        apt-get install -y git wget curl python3 python3-pip python3-venv \
            gcc g++ clang make cmake ninja-build \
            libusb-1.0-0 libusb-1.0-0-dev \
            flex bison gperf ccache libffi-dev libssl-dev dfu-util
        ;;
    dnf|yum)
        $PM install -y git wget curl python3 python3-pip \
            gcc gcc-c++ clang make cmake ninja-build \
            libusbx-devel \
            flex bison gperf ccache libffi-devel openssl-devel dfu-util
        ;;
    pacman)
        pacman -S --noconfirm git wget curl python python-pip \
            gcc clang make cmake ninja \
            libusb \
            flex bison gperf ccache dfu-util
        ;;
    zypper)
        zypper install -y git wget curl python3 python3-pip \
            gcc gcc-c++ clang make cmake ninja \
            libusb-1_0-devel \
            flex bison gperf ccache libffi-devel libopenssl-devel dfu-util
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
        "platformio.platformio-ide"
        "espressif.esp-idf-extension"
        "ms-python.python"
        "ms-python.vscode-pylance"
        "eamodio.gitlens"
        "GitHub.copilot"
        "GitHub.copilot-chat"
        "usernamehw.errorlens"
        "jeff-hykin.better-cpp-syntax"
        "llvm-vs-code-extensions.vscode-clangd"
    )
    for ext in "${extensions[@]}"; do
        info "Installing extension: $ext"
        sudo -u $SUDO_USER code --install-extension "$ext" --force 2>/dev/null || true
    done
    success "VS Code extensions installed"
fi

# Install ESP-IDF
action "Installing ESP-IDF (ESP32 SDK)..."
ESP_IDF_PATH="$USER_HOME/esp/esp-idf"

if [[ ! -d "$ESP_IDF_PATH" ]]; then
    info "Cloning ESP-IDF repository..."
    sudo -u $SUDO_USER mkdir -p "$USER_HOME/esp"
    sudo -u $SUDO_USER git clone --recursive https://github.com/espressif/esp-idf.git "$ESP_IDF_PATH"
    
    info "Installing ESP-IDF tools..."
    cd "$ESP_IDF_PATH"
    sudo -u $SUDO_USER ./install.sh all
    
    success "ESP-IDF installed"
    
    # Add ESP-IDF environment to shell config
    SHELL_CONFIGS=("$USER_HOME/.bashrc" "$USER_HOME/.zshrc")
    for SHELL_RC in "${SHELL_CONFIGS[@]}"; do
        if [[ -f "$SHELL_RC" ]]; then
            if ! grep -q "IDF_PATH" "$SHELL_RC" 2>/dev/null; then
                {
                    echo ""
                    echo "# ESP-IDF"
                    echo "export IDF_PATH=\"$ESP_IDF_PATH\""
                } >> "$SHELL_RC"
            fi
        fi
    done
    
    info "ESP-IDF location: $ESP_IDF_PATH"
else
    success "ESP-IDF already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating ESP-IDF..."
        cd "$ESP_IDF_PATH"
        sudo -u $SUDO_USER git pull
        sudo -u $SUDO_USER ./install.sh all
    fi
fi

# Install PlatformIO
action "Installing/Updating PlatformIO Core..."
if ! command_exists pio; then
    info "Installing PlatformIO..."
    python3 -m pip install --upgrade pip
    pip3 install --upgrade platformio
    success "PlatformIO installed"
else
    success "PlatformIO already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        pip3 install --upgrade platformio
    fi
fi

# Configure ESP-IDF extension in VS Code
action "Configuring ESP-IDF extension..."
VSCODE_SETTINGS_DIR="$USER_HOME/.config/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

sudo -u $SUDO_USER mkdir -p "$VSCODE_SETTINGS_DIR"

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

settings['idf.espIdfPath'] = '$ESP_IDF_PATH'
settings['idf.toolsPath'] = '$USER_HOME/.espressif'
settings['idf.pythonBinPath'] = '$(which python3)'

with open('$TEMP_FILE', 'w') as f:
    json.dump(settings, f, indent=4)
" 2>/dev/null || echo '{}' > "$TEMP_FILE"
    
    sudo -u $SUDO_USER cp "$TEMP_FILE" "$VSCODE_SETTINGS_FILE"
    rm -f "$TEMP_FILE"
else
    # Create new settings
    sudo -u $SUDO_USER cat > "$VSCODE_SETTINGS_FILE" <<EOF
{
    "idf.espIdfPath": "$ESP_IDF_PATH",
    "idf.toolsPath": "$USER_HOME/.espressif",
    "idf.pythonBinPath": "$(which python3)"
}
EOF
fi

success "ESP-IDF extension configured with path: $ESP_IDF_PATH"

# Configure USB permissions for ESP32
action "Configuring USB permissions..."
UDEV_RULE="/etc/udev/rules.d/99-platformio-udev.rules"
if [[ ! -f "$UDEV_RULE" ]]; then
    info "Creating udev rules for ESP32..."
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules -o "$UDEV_RULE"
    udevadm control --reload-rules
    udevadm trigger
    usermod -aG dialout $SUDO_USER 2>/dev/null || true
    usermod -aG plugdev $SUDO_USER 2>/dev/null || true
    success "USB permissions configured"
    note "Log out and log back in for USB permissions to take effect"
else
    success "USB permissions already configured"
fi

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
    
    # Create file if it doesn't exist
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

# Final summary
action ""
action "📊 Installation Summary"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

command_exists git && success "Git is ready" || warning "Git needs attention"
command_exists code && success "VS Code is ready" || warning "VS Code needs attention"
command_exists cmake && success "CMake is ready" || warning "CMake needs attention"
command_exists ninja && success "Ninja is ready" || warning "Ninja needs attention"
command_exists gcc && success "GCC is ready" || warning "GCC needs attention"
command_exists clang && success "Clang is ready" || warning "Clang needs attention"
[[ -d "$ESP_IDF_PATH" ]] && success "ESP-IDF is ready" || warning "ESP-IDF needs attention"
command_exists pio && success "PlatformIO is ready" || warning "PlatformIO needs attention"
command_exists oh-my-posh && success "Oh My Posh is ready" || warning "Oh My Posh needs attention"

# Display versions
action ""
action "📋 Installed Versions"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists git; then
    info "Git: $(git --version)"
fi

if command_exists python3; then
    info "Python: $(python3 --version)"
fi

if command_exists code; then
    info "VS Code: $(code --version | head -n1)"
fi

if command_exists cmake; then
    info "CMake: $(cmake --version | head -n1)"
fi

if command_exists gcc; then
    info "GCC: $(gcc --version | head -n1)"
fi

if command_exists clang; then
    info "Clang: $(clang --version | head -n1)"
fi

if command_exists pio; then
    info "PlatformIO: $(pio --version)"
fi

action ""
action "✨ Setup Complete!"
note "Next steps:"
info "1. Restart your terminal to apply PATH changes"
info "2. Log out and log back in for USB permissions (dialout group)"
info "3. VS Code: Open and let PlatformIO extension complete installation"
info "4. Test ESP-IDF: source $ESP_IDF_PATH/export.sh"
info "5. Create ESP32 project: pio project init --board esp32dev"
info "6. Configure Oh My Posh theme as desired"
info "7. VS Code: Sign in with GitHub for Copilot activation"
info "8. Connect your ESP32 board and check: ls /dev/ttyUSB* or ls /dev/ttyACM*"
success ""
success "Happy ESP32 coding! 🚀"
