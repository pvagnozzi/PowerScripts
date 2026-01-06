#!/usr/bin/env zsh

#
# Setup .NET development environment on macOS
#
# Configures the system for .NET development by installing and configuring:
# - Git version control
# - Oh My Posh with automatic initialization and user theme
# - Visual Studio Code with C# extensions
# - Docker Desktop
# - .NET SDK (latest LTS and current versions)
# - GitHub Copilot CLI
# - JetBrains Rider (optional, default: no)
# 
# All tools are configured with proper PATH settings and integrations.
#
# Usage:
#   ./setup-dotnet-dev.zsh
#   ./setup-dotnet-dev.zsh --install-rider
#   ./setup-dotnet-dev.zsh --skip-docker
#
# Options:
#   --install-rider    Install JetBrains Rider (default: no)
#   --skip-docker      Skip Docker installation
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
INSTALL_RIDER=false
SKIP_DOCKER=false
SKIP_UPDATES=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install-rider)
            INSTALL_RIDER=true
            shift
            ;;
        --skip-docker)
            SKIP_DOCKER=true
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

action "🎯 Starting .NET Development Environment Setup"
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

# Install .NET SDK
action "Installing/Updating .NET SDK..."
if ! command_exists dotnet; then
    info "Installing .NET SDK..."
    brew install --cask dotnet-sdk
    success ".NET SDK installed"
else
    success ".NET SDK already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade --cask dotnet-sdk 2>/dev/null || true
    fi
fi

# Display .NET info
if command_exists dotnet; then
    info "Installed .NET SDKs:"
    dotnet --list-sdks
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
        "ms-dotnettools.csharp"
        "ms-dotnettools.csdevkit"
        "ms-vscode.powershell"
        "eamodio.gitlens"
        "ms-vscode-remote.remote-containers"
        "ms-azuretools.vscode-docker"
        "GitHub.copilot"
        "GitHub.copilot-chat"
    )
    for ext in "${extensions[@]}"; do
        info "Installing extension: $ext"
        code --install-extension "$ext" --force 2>/dev/null || true
    done
    success "VS Code extensions installed"
fi

# Install Docker Desktop
if [[ "$SKIP_DOCKER" != true ]]; then
    action "Installing/Updating Docker Desktop..."
    if [[ ! -d "/Applications/Docker.app" ]]; then
        brew install --cask docker
        success "Docker Desktop installed"
        note "Please open Docker Desktop to complete setup"
    else
        success "Docker Desktop already installed"
        if [[ "$SKIP_UPDATES" != true ]]; then
            brew upgrade --cask docker 2>/dev/null || true
        fi
    fi
else
    info "Skipping Docker Desktop installation"
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

# Configure for both bash and zsh
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

# Install GitHub Copilot CLI
action "Installing GitHub Copilot CLI..."
if ! command_exists github-copilot-cli; then
    info "Installing GitHub Copilot CLI via npm..."
    
    # Install Node.js if not present
    if ! command_exists npm; then
        info "Installing Node.js..."
        brew install node
        success "Node.js installed"
    fi
    
    # Install GitHub Copilot CLI
    npm install -g @githubnext/github-copilot-cli
    success "GitHub Copilot CLI installed"
    
    note "Run 'github-copilot-cli auth' to authenticate"
else
    success "GitHub Copilot CLI already installed"
fi

# Install JetBrains Rider
if [[ "$INSTALL_RIDER" == true ]]; then
    action "Installing JetBrains Rider..."
    
    if [[ ! -d "/Applications/Rider.app" ]]; then
        info "Installing JetBrains Toolbox..."
        brew install --cask jetbrains-toolbox
        success "JetBrains Toolbox installed"
        note "Use JetBrains Toolbox to install and manage Rider"
    else
        success "JetBrains Rider already installed"
        if [[ "$SKIP_UPDATES" != true ]]; then
            brew upgrade --cask jetbrains-toolbox 2>/dev/null || true
        fi
    fi
else
    info "Skipping JetBrains Rider installation"
fi

# Install additional useful tools
action "Installing additional development tools..."

# Azure CLI
if ! command_exists az; then
    brew install azure-cli
    success "Azure CLI installed"
else
    success "Azure CLI already installed"
fi

# Final summary
action ""
action "📊 Installation Summary"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

command_exists git && success "Git is ready" || warning "Git needs attention"
command_exists dotnet && success ".NET SDK is ready" || warning ".NET SDK needs attention"
command_exists code && success "VS Code is ready" || warning "VS Code needs attention"
command_exists oh-my-posh && success "Oh My Posh is ready" || warning "Oh My Posh needs attention"
command_exists docker && success "Docker is ready" || warning "Docker needs attention"
command_exists github-copilot-cli && success "GitHub Copilot CLI is ready" || warning "GitHub Copilot CLI needs attention"
command_exists az && success "Azure CLI is ready" || warning "Azure CLI needs attention"

# Display versions
action ""
action "📋 Installed Versions"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists git; then
    info "Git: $(git --version)"
fi

if command_exists dotnet; then
    info ".NET SDK: $(dotnet --version)"
fi

if command_exists code; then
    info "VS Code: $(code --version | head -n1)"
fi

if command_exists docker; then
    info "Docker: $(docker --version)"
fi

if command_exists az; then
    info "Azure CLI: $(az --version | head -n1)"
fi

action ""
action "✨ Setup Complete!"
note "Next steps:"
info "1. Restart your terminal to apply PATH changes"
info "2. Run 'dotnet --info' to verify .NET installation"
info "3. Configure Oh My Posh theme as desired"
info "4. Open Docker Desktop and complete initial setup"
info "5. Authenticate GitHub Copilot CLI: github-copilot-cli auth"
info "6. VS Code: Sign in with GitHub for Copilot activation"
if [[ "$INSTALL_RIDER" == true ]]; then
    info "7. Open JetBrains Toolbox and install Rider"
fi
success ""
success "Happy coding! 🚀"
