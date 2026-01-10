#!/usr/bin/env zsh

#
# Setup C++ development environment on macOS
#
# Configures the system for C++ development by installing:
# - Git version control
# - Xcode Command Line Tools
# - Homebrew package manager
# - CMake build system
# - Ninja build system
# - vcpkg package manager
# - GCC compiler
# - LLVM/Clang compiler
# - Visual Studio Code with C++ extensions
# - Oh My Posh with user theme
# 
# All tools are configured with proper PATH settings.
#
# Usage:
#   ./setup-cpp-dev.zsh
#   ./setup-cpp-dev.zsh --skip-updates
#   ./setup-cpp-dev.zsh -v
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

action "🎯 Starting C++ Development Environment Setup"
info "Platform: macOS"

# Install Xcode Command Line Tools
action "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    note "Please complete the Xcode Command Line Tools installation in the dialog"
    note "Press any key after installation completes..."
    read -k1 -s
    
    success "Xcode Command Line Tools installed"
else
    success "Xcode Command Line Tools already installed"
fi

# Install Homebrew
action "Checking Homebrew..."
if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    success "Homebrew installed"
else
    success "Homebrew already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating Homebrew..."
        brew update
    fi
fi

# Install Git
action "Installing/Updating Git..."
if ! command_exists git; then
    brew install git
    success "Git installed"
else
    success "Git already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade git || true
    fi
fi

# Install CMake
action "Installing/Updating CMake..."
if ! command_exists cmake; then
    brew install cmake
    success "CMake installed"
else
    success "CMake already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade cmake || true
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
        brew upgrade ninja || true
    fi
fi

# Install GCC
action "Installing/Updating GCC..."
if ! command_exists gcc-13 && ! command_exists gcc-12 && ! brew list gcc &>/dev/null; then
    brew install gcc
    success "GCC installed"
else
    success "GCC already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade gcc || true
    fi
fi

# Install LLVM
action "Installing/Updating LLVM..."
if ! brew list llvm &>/dev/null; then
    brew install llvm
    
    # Add LLVM to PATH
    LLVM_PATH="$(brew --prefix llvm)/bin"
    if ! grep -q "$LLVM_PATH" ~/.zshrc 2>/dev/null; then
        echo "export PATH=\"$LLVM_PATH:\$PATH\"" >> ~/.zshrc
        export PATH="$LLVM_PATH:$PATH"
        success "LLVM installed and added to PATH"
    else
        success "LLVM installed"
    fi
else
    success "LLVM already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade llvm || true
    fi
fi

# Install vcpkg
action "Installing/Updating vcpkg..."
VCPKG_ROOT="$HOME/vcpkg"
if [[ ! -f "$VCPKG_ROOT/vcpkg" ]]; then
    info "Cloning vcpkg repository..."
    git clone https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"
    
    info "Bootstrapping vcpkg..."
    "$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics
    
    # Add to PATH
    if ! grep -q "$VCPKG_ROOT" ~/.zshrc 2>/dev/null; then
        echo "export PATH=\"\$PATH:$VCPKG_ROOT\"" >> ~/.zshrc
        echo "export VCPKG_ROOT=\"$VCPKG_ROOT\"" >> ~/.zshrc
        export PATH="$PATH:$VCPKG_ROOT"
        export VCPKG_ROOT="$VCPKG_ROOT"
        success "vcpkg installed and added to PATH"
    else
        success "vcpkg installed"
    fi
else
    success "vcpkg already installed"
    
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating vcpkg..."
        cd "$VCPKG_ROOT"
        git pull
        ./bootstrap-vcpkg.sh -disableMetrics
        success "vcpkg updated"
    fi
fi

# Install VS Code
action "Installing/Updating Visual Studio Code..."
if ! command_exists code; then
    brew install --cask visual-studio-code
    success "VS Code installed"
else
    success "VS Code already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade --cask visual-studio-code || true
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
        code --install-extension "$ext" --force 2>/dev/null || true
    done
    success "VS Code extensions installed"
fi

# Configure VS Code settings
action "Configuring VS Code C++ settings..."
VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

mkdir -p "$VSCODE_SETTINGS_DIR"

# Get compiler paths
CMAKE_PATH=$(which cmake 2>/dev/null || echo "cmake")
CLANG_PATH=$(which clang 2>/dev/null || echo "clang")
CLANGPP_PATH=$(which clang++ 2>/dev/null || echo "clang++")
CLANGD_PATH="$(brew --prefix llvm)/bin/clangd"

# Get GCC path (Homebrew version)
if brew list gcc &>/dev/null; then
    GCC_VERSION=$(ls $(brew --prefix)/bin/gcc-* 2>/dev/null | head -n1)
    GPP_VERSION=$(ls $(brew --prefix)/bin/g++-* 2>/dev/null | head -n1)
else
    GCC_VERSION="gcc"
    GPP_VERSION="g++"
fi

# Get LLVM Clang path
LLVM_CLANG="$(brew --prefix llvm)/bin/clang"
LLVM_CLANGPP="$(brew --prefix llvm)/bin/clang++"

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
    'CMAKE_C_COMPILER': '$CLANG_PATH',
    'CMAKE_CXX_COMPILER': '$CLANGPP_PATH'
}

# C++ IntelliSense
settings['C_Cpp.default.compilerPath'] = '$CLANGPP_PATH'

# Clangd settings (LLVM version)
if '$CLANGD_PATH':
    settings['clangd.path'] = '$CLANGD_PATH'

# vcpkg integration
if '$VCPKG_ROOT' and '$VCPKG_ROOT' != '':
    settings['cmake.configureSettings']['CMAKE_TOOLCHAIN_FILE'] = '$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake'

# Additional compilers available
settings['cmake.additionalCompilerSearchDirs'] = [
    '$(brew --prefix llvm)/bin',
    '$(brew --prefix)/bin'
]

with open('$TEMP_FILE', 'w') as f:
    json.dump(settings, f, indent=4)
" 2>/dev/null || echo '{}' > "$TEMP_FILE"
    
    cp "$TEMP_FILE" "$VSCODE_SETTINGS_FILE"
    rm -f "$TEMP_FILE"
else
    # Create new settings
    cat > "$VSCODE_SETTINGS_FILE" <<EOF
{
    "cmake.cmakePath": "$CMAKE_PATH",
    "cmake.generator": "Ninja",
    "cmake.configureSettings": {
        "CMAKE_C_COMPILER": "$CLANG_PATH",
        "CMAKE_CXX_COMPILER": "$CLANGPP_PATH",
        "CMAKE_TOOLCHAIN_FILE": "$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
    },
    "C_Cpp.default.compilerPath": "$CLANGPP_PATH",
    "clangd.path": "$CLANGD_PATH",
    "cmake.additionalCompilerSearchDirs": [
        "$(brew --prefix llvm)/bin",
        "$(brew --prefix)/bin"
    ]
}
EOF
fi

success "VS Code configured with C++ toolchain paths"

# Install Oh My Posh
action "Installing/Updating Oh My Posh..."
if ! command_exists oh-my-posh; then
    brew install jandedobbeleer/oh-my-posh/oh-my-posh
    success "Oh My Posh installed"
else
    success "Oh My Posh already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade oh-my-posh || true
    fi
fi

# Configure Oh My Posh
action "Configuring Oh My Posh..."
if ! grep -q "oh-my-posh init" ~/.zshrc 2>/dev/null; then
    {
        echo ""
        echo "# Oh My Posh initialization"
        echo 'eval "$(oh-my-posh init zsh)"'
    } >> ~/.zshrc
    success "Oh My Posh configured"
else
    info "Oh My Posh already configured"
fi

# Install common development libraries
action "Installing common C++ development libraries..."
brew install openssl curl zlib boost jsoncpp || true
success "Development libraries installed"

# Final summary
action ""
action "📊 Installation Summary"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

command_exists git && success "Git is ready" || warning "Git needs attention"
command_exists clang && success "Clang (Apple) is ready" || warning "Clang needs attention"
command_exists cmake && success "CMake is ready" || warning "CMake needs attention"
command_exists ninja && success "Ninja is ready" || warning "Ninja needs attention"
brew list gcc &>/dev/null && success "GCC is ready" || warning "GCC needs attention"
brew list llvm &>/dev/null && success "LLVM is ready" || warning "LLVM needs attention"
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

if command_exists clang; then
    info "Clang (Apple): $(clang --version | head -n1)"
fi

if brew list gcc &>/dev/null; then
    GCC_VERSION=$(ls $(brew --prefix)/bin/gcc-* 2>/dev/null | head -n1)
    if [[ -n "$GCC_VERSION" ]]; then
        info "GCC: $($GCC_VERSION --version | head -n1)"
    fi
fi

if brew list llvm &>/dev/null; then
    LLVM_CLANG="$(brew --prefix llvm)/bin/clang"
    if [[ -f "$LLVM_CLANG" ]]; then
        info "LLVM Clang: $($LLVM_CLANG --version | head -n1)"
    fi
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
info "1. Restart your terminal to apply all changes: source ~/.zshrc"
info "2. Test CMake: cmake --version"
info "3. Test Clang: clang --version"
info "4. Test GCC: check available versions with 'ls \$(brew --prefix)/bin/gcc-*'"
info "5. Install packages with vcpkg: vcpkg install <package-name>"
info "6. Create a CMake project and configure with: cmake -B build -G Ninja"
info "7. VS Code: Sign in with GitHub for Copilot activation"
note "Sample vcpkg packages: fmt, nlohmann-json, boost, catch2, spdlog"
note "To use LLVM tools, they are in: \$(brew --prefix llvm)/bin"
success ""
success "Happy coding! 🚀"
