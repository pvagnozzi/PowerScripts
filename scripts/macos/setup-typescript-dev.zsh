#!/usr/bin/env zsh

#
# Setup TypeScript development environment on macOS
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
#   ./setup-typescript-dev.zsh
#   ./setup-typescript-dev.zsh --install-webstorm
#   ./setup-typescript-dev.zsh --skip-angular --skip-vue
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

action "🎯 Starting TypeScript Development Environment Setup"
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

# Install Oh My Posh
action "Installing/Updating Oh My Posh..."
if ! command_exists oh-my-posh; then
    info "Installing Oh My Posh..."
    brew install jandedobbeleer/oh-my-posh/oh-my-posh
    success "Oh My Posh installed"
else
    success "Oh My Posh already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade oh-my-posh 2>/dev/null || true
    fi
fi

# Configure Oh My Posh
SHELL_RC="$HOME/.zshrc"
if ! grep -q "oh-my-posh" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Oh My Posh" >> "$SHELL_RC"
    echo 'eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/powerlevel10k_rainbow.omp.json)"' >> "$SHELL_RC"
    success "Oh My Posh configured"
else
    info "Oh My Posh already configured"
fi

# Install NVM
action "Installing/Updating NVM..."
NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
    info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    success "NVM installed"
else
    success "NVM already installed"
fi

# Source NVM
export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Configure NVM in .zshrc
if ! grep -q "NVM_DIR" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# NVM" >> "$SHELL_RC"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$SHELL_RC"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$SHELL_RC"
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$SHELL_RC"
    success "NVM configured in .zshrc"
fi

# Install Node.js LTS via NVM
action "Installing Node.js LTS via NVM..."
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    success "Node.js LTS installed"

    # Verify installation
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    success "Node.js version: $NODE_VERSION"
    success "npm version: $NPM_VERSION"
else
    warning "NVM not properly installed"
fi

# Install global npm packages
action "Installing/Updating global npm packages..."

info "Installing TypeScript..."
npm install -g typescript
success "TypeScript installed"

info "Installing ts-node..."
npm install -g ts-node
success "ts-node installed"

info "Installing Yarn..."
npm install -g yarn
success "Yarn installed"

info "Installing PNPM..."
npm install -g pnpm
success "PNPM installed"

info "Installing Create React App..."
npm install -g create-react-app
success "Create React App installed"

info "Installing Vite..."
npm install -g vite
success "Vite installed"

if [[ "$SKIP_ANGULAR" != true ]]; then
    info "Installing Angular CLI..."
    npm install -g @angular/cli
    success "Angular CLI installed"
fi

if [[ "$SKIP_VUE" != true ]]; then
    info "Installing Vue CLI..."
    npm install -g @vue/cli
    success "Vue CLI installed"
fi

info "Installing ESLint..."
npm install -g eslint
success "ESLint installed"

info "Installing Prettier..."
npm install -g prettier
success "Prettier installed"

info "Installing GitHub Copilot CLI..."
npm install -g @githubnext/github-copilot-cli
success "GitHub Copilot CLI installed"

# Install Visual Studio Code
action "Installing/Updating Visual Studio Code..."
if ! command_exists code; then
    info "Installing Visual Studio Code..."
    brew install --cask visual-studio-code
    success "Visual Studio Code installed"
else
    success "Visual Studio Code already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade --cask visual-studio-code 2>/dev/null || true
    fi
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
        if ! code --list-extensions | grep -q "^$ext\$"; then
            info "Installing extension: $ext"
            code --install-extension "$ext" --force >/dev/null 2>&1
        fi
    done
    success "VS Code extensions installed"
fi

# Install WebStorm (optional)
if [[ "$INSTALL_WEBSTORM" == true ]]; then
    action "Installing JetBrains WebStorm..."
    if ! brew list --cask webstorm &>/dev/null; then
        brew install --cask webstorm
        success "WebStorm installed"
    else
        success "WebStorm already installed"
        if [[ "$SKIP_UPDATES" != true ]]; then
            brew upgrade --cask webstorm 2>/dev/null || true
        fi
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
[[ "$INSTALL_WEBSTORM" == true ]] && info "  • JetBrains WebStorm"

note "Next steps:"
info "  1. Restart your terminal or run: source ~/.zshrc"
info "  2. Verify installation: node --version && npm --version && tsc --version"
info "  3. Create a new project:"
info "     - React: npx create-react-app my-app"
info "     - React (Vite): npm create vite@latest my-app -- --template react-ts"
[[ "$SKIP_ANGULAR" != true ]] && info "     - Angular: ng new my-app"
[[ "$SKIP_VUE" != true ]] && info "     - Vue: vue create my-app"
info "  4. Configure Git: git config --global user.name 'Your Name'"
info "                   git config --global user.email 'your.email@example.com'"
