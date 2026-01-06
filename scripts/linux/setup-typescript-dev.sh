#!/usr/bin/env bash

#
# Setup TypeScript development environment on Linux
#
# Configures the system for TypeScript/JavaScript development by installing and configuring:
# - Git version control
# - Oh My Posh with automatic initialization and user theme
# - Visual Studio Code with TypeScript, React, Angular, and Vue extensions
# - NVM (Node Version Manager)
# - Node.js LTS version via NVM
# - TypeScript compiler (global)
# - React development tools
# - Angular CLI (global)
# - Vue CLI (global)
# - Yarn package manager (global)
# - PNPM package manager (global)
# - GitHub Copilot CLI
# - WebStorm IDE (optional, default: no)
#
# All tools are configured with proper PATH settings and integrations.
#
# Usage:
#   sudo ./setup-typescript-dev.sh
#   sudo ./setup-typescript-dev.sh --install-webstorm
#   sudo ./setup-typescript-dev.sh --skip-angular --skip-vue
#
# Options:
#   --install-webstorm    Install JetBrains WebStorm (default: no)
#   --skip-angular        Skip Angular CLI installation
#   --skip-vue            Skip Vue CLI installation
#   --skip-updates        Skip updating existing tools
#   -v, --verbose         Show detailed output
#   -h, --help            Show this help message
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
INSTALL_WEBSTORM=false
SKIP_ANGULAR=false
SKIP_VUE=false
SKIP_UPDATES=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install-webstorm)
            INSTALL_WEBSTORM=true
            shift
            ;;
        --skip-angular)
            SKIP_ANGULAR=true
            shift
            ;;
        --skip-vue)
            SKIP_VUE=true
            shift
            ;;
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

action "🎯 Starting TypeScript Development Environment Setup"
info "Platform: Linux"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use sudo)"
   exit 1
fi

PM=$(detect_package_manager)
if [[ "$PM" == "unknown" ]]; then
    error "Could not detect package manager"
    exit 1
fi
info "Detected package manager: $PM"

# Get the actual user (when using sudo)
ACTUAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$ACTUAL_USER)

# Install basic dependencies
action "Installing basic dependencies..."
case $PM in
    apt)
        apt-get update -qq
        install_package "curl"
        install_package "wget"
        install_package "build-essential"
        ;;
    dnf|yum)
        install_package "curl"
        install_package "wget"
        install_package "gcc-c++"
        install_package "make"
        ;;
    pacman)
        install_package "curl"
        install_package "wget"
        install_package "base-devel"
        ;;
    zypper)
        install_package "curl"
        install_package "wget"
        install_package "gcc-c++"
        install_package "make"
        ;;
esac
success "Basic dependencies installed"

# Install Git
action "Installing/Updating Git..."
if ! command_exists git; then
    install_package "git"
    success "Git installed"
else
    success "Git already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        case $PM in
            apt) apt-get upgrade -y git ;;
            dnf) dnf upgrade -y git ;;
            yum) yum update -y git ;;
            pacman) pacman -Syu --noconfirm git ;;
            zypper) zypper update -y git ;;
        esac
    fi
fi

# Install Oh My Posh
action "Installing/Updating Oh My Posh..."
if ! command_exists oh-my-posh; then
    info "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
    success "Oh My Posh installed"
else
    success "Oh My Posh already installed"
fi

# Configure Oh My Posh
SHELL_RC="$USER_HOME/.bashrc"
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$USER_HOME/.zshrc"
fi

if ! grep -q "oh-my-posh" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Oh My Posh" >> "$SHELL_RC"
    echo 'eval "$(oh-my-posh init bash --config /usr/local/share/oh-my-posh/themes/powerlevel10k_rainbow.omp.json)"' >> "$SHELL_RC"
    success "Oh My Posh configured"
else
    info "Oh My Posh already configured"
fi

# Install NVM
action "Installing/Updating NVM..."
NVM_DIR="$USER_HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
    info "Installing NVM..."
    su - $ACTUAL_USER -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
    success "NVM installed"
else
    success "NVM already installed"
fi

# Source NVM
export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS via NVM
action "Installing Node.js LTS via NVM..."
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    su - $ACTUAL_USER -c 'source ~/.nvm/nvm.sh && nvm install --lts && nvm use --lts'
    success "Node.js LTS installed"

    # Verify installation
    NODE_VERSION=$(su - $ACTUAL_USER -c 'source ~/.nvm/nvm.sh && node --version')
    NPM_VERSION=$(su - $ACTUAL_USER -c 'source ~/.nvm/nvm.sh && npm --version')
    success "Node.js version: $NODE_VERSION"
    success "npm version: $NPM_VERSION"
else
    warning "NVM not properly installed"
fi

# Install global npm packages
action "Installing/Updating global npm packages..."

install_npm_global() {
    local package=$1
    su - $ACTUAL_USER -c "source ~/.nvm/nvm.sh && npm install -g $package"
}

info "Installing TypeScript..."
install_npm_global "typescript"
success "TypeScript installed"

info "Installing ts-node..."
install_npm_global "ts-node"
success "ts-node installed"

info "Installing Yarn..."
install_npm_global "yarn"
success "Yarn installed"

info "Installing PNPM..."
install_npm_global "pnpm"
success "PNPM installed"

info "Installing Create React App..."
install_npm_global "create-react-app"
success "Create React App installed"

info "Installing Vite..."
install_npm_global "vite"
success "Vite installed"

if [[ "$SKIP_ANGULAR" != true ]]; then
    info "Installing Angular CLI..."
    install_npm_global "@angular/cli"
    success "Angular CLI installed"
fi

if [[ "$SKIP_VUE" != true ]]; then
    info "Installing Vue CLI..."
    install_npm_global "@vue/cli"
    success "Vue CLI installed"
fi

info "Installing ESLint..."
install_npm_global "eslint"
success "ESLint installed"

info "Installing Prettier..."
install_npm_global "prettier"
success "Prettier installed"

info "Installing GitHub Copilot CLI..."
install_npm_global "@githubnext/github-copilot-cli"
success "GitHub Copilot CLI installed"

# Install Visual Studio Code
action "Installing/Updating Visual Studio Code..."
if ! command_exists code; then
    info "Installing Visual Studio Code..."
    case $PM in
        apt)
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg
            apt-get update -qq
            install_package "code"
            ;;
        dnf)
            rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            dnf check-update
            install_package "code"
            ;;
        *)
            warning "Automatic VS Code installation not supported for $PM"
            note "Please install VS Code manually from https://code.visualstudio.com"
            ;;
    esac
    success "Visual Studio Code installed"
else
    success "Visual Studio Code already installed"
fi

# Install VS Code extensions
if command_exists code; then
    action "Installing VS Code extensions..."

    extensions=(
        "ms-vscode.vscode-typescript-next"
        "dbaeumer.vscode-eslint"
        "esbenp.prettier-vscode"
        "dsznajder.es7-react-js-snippets"
        "Angular.ng-template"
        "Vue.volar"
        "bradlc.vscode-tailwindcss"
        "GitHub.copilot"
        "GitHub.copilot-chat"
        "ms-vscode.js-debug"
        "orta.vscode-jest"
    )

    for ext in "${extensions[@]}"; do
        if ! su - $ACTUAL_USER -c "code --list-extensions" | grep -q "^$ext\$"; then
            info "Installing extension: $ext"
            su - $ACTUAL_USER -c "code --install-extension $ext --force" >/dev/null 2>&1
        fi
    done
    success "VS Code extensions installed"
fi

# Install WebStorm (optional)
if [[ "$INSTALL_WEBSTORM" == true ]]; then
    action "Installing JetBrains WebStorm..."
    if ! command_exists webstorm; then
        warning "WebStorm installation via package manager not implemented"
        note "Please download from: https://www.jetbrains.com/webstorm/download/"
        note "Or use JetBrains Toolbox: https://www.jetbrains.com/toolbox-app/"
    else
        success "WebStorm already installed"
    fi
fi

success "✨ TypeScript Development Environment Setup Complete!"
note "Installed tools:"
info "  • Git"
info "  • Oh My Posh"
info "  • NVM"
info "  • Node.js LTS (via NVM)"
info "  • TypeScript, ts-node"
info "  • Yarn, PNPM"
info "  • Create React App, Vite"
[[ "$SKIP_ANGULAR" != true ]] && info "  • Angular CLI"
[[ "$SKIP_VUE" != true ]] && info "  • Vue CLI"
info "  • ESLint, Prettier"
info "  • Visual Studio Code with extensions"
info "  • GitHub Copilot CLI"

note "Next steps:"
info "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
info "  2. Verify installation: node --version && npm --version && tsc --version"
info "  3. Create a new project:"
info "     - React: npx create-react-app my-app"
info "     - React (Vite): npm create vite@latest my-app -- --template react-ts"
[[ "$SKIP_ANGULAR" != true ]] && info "     - Angular: ng new my-app"
[[ "$SKIP_VUE" != true ]] && info "     - Vue: vue create my-app"
info "  4. Configure Git: git config --global user.name 'Your Name'"
info "                   git config --global user.email 'your.email@example.com'"
