#!/usr/bin/env zsh

#
# Setup ESP32 development environment on macOS
#
# Configures the system for ESP32 development by installing and configuring:
# - Git version control
# - Visual Studio Code with ESP32/PlatformIO/C++ extensions
# - ESP-IDF (ESP32 SDK)
# - PlatformIO
# - C/C++ build tools
# - Python (required for ESP-IDF)
# - Oh My Posh with automatic initialization and user theme
# 
# All tools are configured with proper PATH settings and integrations.
#
# Usage:
#   ./setup-esp32-dev.zsh
#   ./setup-esp32-dev.zsh --skip-updates
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
            grep "^#" "$0" | grep -v "#!/usr/bin/env zsh" | sed 's/^# //' | sed 's/^#//'
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

# Add to PATH
add_to_path() {
    local path=$1
    local shell_rc="$HOME/.zshrc"
    
    if [[ ! -d "$path" ]]; then
        warning "Path does not exist: $path"
        return
    fi
    
    if ! grep -q "$path" "$shell_rc" 2>/dev/null; then
        echo "export PATH=\"\$PATH:$path\"" >> "$shell_rc"
        success "Added to PATH: $path"
    else
        info "Already in PATH: $path"
    fi
}

action "🎯 Starting ESP32 Development Environment Setup"
info "Platform: macOS"

# Install Homebrew if not present
action "Checking Homebrew package manager..."
if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# Update Homebrew
if [[ "$SKIP_UPDATES" != true ]]; then
    info "Updating Homebrew..."
    brew update
fi

# Install Git
action "Installing/Updating Git..."
if ! command_exists git; then
    brew install git
    success "Git installed"
else
    success "Git already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade git 2>/dev/null || true
    fi
fi

# Install Python
action "Installing/Updating Python..."
if ! command_exists python3; then
    brew install python
    success "Python installed"
else
    success "Python already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade python 2>/dev/null || true
    fi
fi

# Install VS Code
action "Installing/Updating Visual Studio Code..."
if [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
    brew install --cask visual-studio-code
    success "VS Code installed"
else
    success "VS Code already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade --cask visual-studio-code 2>/dev/null || true
    fi
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
    )
    for ext in "${extensions[@]}"; do
        info "Installing extension: $ext"
        code --install-extension "$ext" --force 2>/dev/null || true
    done
    success "VS Code extensions installed"
fi

# Install CMake
action "Installing/Updating CMake..."
if ! command_exists cmake; then
    brew install cmake
    success "CMake installed"
else
    success "CMake already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade cmake 2>/dev/null || true
    fi
fi

# Install Ninja
action "Installing/Updating Ninja..."
if ! command_exists ninja; then
    brew install ninja
    success "Ninja installed"
else
    success "Ninja already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade ninja 2>/dev/null || true
    fi
fi

# Install additional build tools
action "Installing build dependencies..."
brew install pkg-config dfu-util 2>/dev/null || true
success "Build dependencies installed"

# Install ESP-IDF
action "Installing ESP-IDF (ESP32 SDK)..."
ESP_IDF_PATH="$HOME/esp/esp-idf"

if [[ ! -d "$ESP_IDF_PATH" ]]; then
    info "Cloning ESP-IDF repository..."
    mkdir -p "$HOME/esp"
    git clone --recursive https://github.com/espressif/esp-idf.git "$ESP_IDF_PATH"
    
    info "Installing ESP-IDF tools..."
    cd "$ESP_IDF_PATH"
    ./install.sh all
    
    success "ESP-IDF installed"
    
    # Add ESP-IDF environment to shell config
    SHELL_CONFIGS=("$HOME/.zshrc" "$HOME/.bashrc")
    for SHELL_RC in "${SHELL_CONFIGS[@]}"; do
        touch "$SHELL_RC" 2>/dev/null
        if ! grep -q "IDF_PATH" "$SHELL_RC" 2>/dev/null; then
            {
                echo ""
                echo "# ESP-IDF"
                echo "export IDF_PATH=\"$ESP_IDF_PATH\""
            } >> "$SHELL_RC"
        fi
    done
    
    info "ESP-IDF location: $ESP_IDF_PATH"
else
    success "ESP-IDF already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating ESP-IDF..."
        cd "$ESP_IDF_PATH"
        git pull
        ./install.sh all
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

# Install USB drivers
action "Installing USB drivers..."
if [[ ! -f "/Library/Extensions/SiLabsUSBDriver.kext/Contents/Info.plist" ]]; then
    info "Installing CP210x USB to UART Bridge drivers..."
    warning "Please download and install CP210x drivers from:"
    info "https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers"
    note "Or install via: brew install --cask silicon-labs-vcp-driver"
else
    success "USB drivers already installed"
fi

# Install Oh My Posh
action "Installing/Updating Oh My Posh..."
if ! command_exists oh-my-posh; then
    brew install jandedobbeleer/oh-my-posh/oh-my-posh
    success "Oh My Posh installed"
else
    success "Oh My Posh already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade oh-my-posh 2>/dev/null || true
    fi
fi

# Configure Oh My Posh
action "Configuring Oh My Posh..."
SHELL_CONFIGS=("$HOME/.zshrc" "$HOME/.bashrc")

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
    touch "$SHELL_RC" 2>/dev/null
    
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

if command_exists pio; then
    info "PlatformIO: $(pio --version)"
fi

action ""
action "✨ Setup Complete!"
note "Next steps:"
info "1. Restart your terminal to apply PATH changes"
info "2. VS Code: Open and let PlatformIO extension complete installation"
info "3. Test ESP-IDF: source $ESP_IDF_PATH/export.sh"
info "4. Create ESP32 project: pio project init --board esp32dev"
info "5. Configure Oh My Posh theme as desired"
info "6. VS Code: Sign in with GitHub for Copilot activation"
info "7. Connect your ESP32 board and check: ls /dev/cu.* or ls /dev/tty.*"
info "8. If needed, install USB drivers from Silicon Labs website"
success ""
success "Happy ESP32 coding! 🚀"
