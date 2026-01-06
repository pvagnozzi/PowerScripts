#!/usr/bin/env bash

#
# Setup .NET development environment on Linux
#
# Configures the system for .NET development by installing and configuring:
# - Git version control
# - Oh My Posh with automatic initialization and user theme
# - Visual Studio Code with C# extensions
# - Docker Desktop/Engine
# - .NET SDK (latest LTS and current versions)
# - GitHub Copilot CLI
# - JetBrains Rider (optional, default: no)
# 
# All tools are configured with proper PATH settings and integrations.
#
# Usage:
#   sudo ./setup-dotnet-dev.sh
#   sudo ./setup-dotnet-dev.sh --install-rider
#   sudo ./setup-dotnet-dev.sh --skip-docker
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

action "🎯 Starting .NET Development Environment Setup"
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
        apt-get install -y curl wget git apt-transport-https software-properties-common
        ;;
    dnf|yum)
        $PM install -y curl wget git
        ;;
    pacman)
        pacman -S --noconfirm curl wget git
        ;;
    zypper)
        zypper install -y curl wget git
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

# Install .NET SDK
action "Installing/Updating .NET SDK..."
if ! command_exists dotnet; then
    info "Installing .NET SDK..."
    
    case $PM in
        apt)
            # Add Microsoft package repository
            wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
            dpkg -i /tmp/packages-microsoft-prod.deb
            rm /tmp/packages-microsoft-prod.deb
            
            apt-get update -qq
            apt-get install -y dotnet-sdk-8.0
            ;;
        dnf)
            # Add Microsoft package repository
            rpm --import https://packages.microsoft.com/keys/microsoft.asc
            wget -q https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/prod.repo -O /etc/yum.repos.d/microsoft-prod.repo
            dnf install -y dotnet-sdk-8.0
            ;;
        yum)
            # For RHEL/CentOS
            rpm --import https://packages.microsoft.com/keys/microsoft.asc
            wget -q https://packages.microsoft.com/config/rhel/8/prod.repo -O /etc/yum.repos.d/microsoft-prod.repo
            yum install -y dotnet-sdk-8.0
            ;;
        pacman)
            pacman -S --noconfirm dotnet-sdk
            ;;
        zypper)
            rpm --import https://packages.microsoft.com/keys/microsoft.asc
            zypper addrepo https://packages.microsoft.com/opensuse/15/prod/ microsoft-prod
            zypper install -y dotnet-sdk-8.0
            ;;
    esac
    success ".NET SDK installed"
else
    success ".NET SDK already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        warning ".NET SDK updates should be done manually or via system package manager"
    fi
fi

# Display .NET info
if command_exists dotnet; then
    info "Installed .NET SDKs:"
    sudo -u $SUDO_USER dotnet --list-sdks
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
        sudo -u $SUDO_USER code --install-extension "$ext" --force 2>/dev/null || true
    done
    success "VS Code extensions installed"
fi

# Install Docker
if [[ "$SKIP_DOCKER" != true ]]; then
    action "Installing/Updating Docker..."
    if ! command_exists docker; then
        info "Installing Docker..."
        
        case $PM in
            apt)
                # Remove old versions
                apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
                
                # Install Docker
                curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
                sh /tmp/get-docker.sh
                rm /tmp/get-docker.sh
                
                # Add user to docker group
                usermod -aG docker $SUDO_USER
                ;;
            dnf|yum)
                $PM remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true
                $PM install -y dnf-plugins-core
                $PM config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo 2>/dev/null || $PM config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                $PM install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                systemctl start docker
                systemctl enable docker
                usermod -aG docker $SUDO_USER
                ;;
            pacman)
                pacman -S --noconfirm docker docker-compose
                systemctl start docker
                systemctl enable docker
                usermod -aG docker $SUDO_USER
                ;;
            zypper)
                zypper install -y docker docker-compose
                systemctl start docker
                systemctl enable docker
                usermod -aG docker $SUDO_USER
                ;;
        esac
        success "Docker installed"
    else
        success "Docker already installed"
    fi
else
    info "Skipping Docker installation"
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

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
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

# Install GitHub Copilot CLI
action "Installing GitHub Copilot CLI..."
if ! command_exists github-copilot-cli; then
    info "Installing GitHub Copilot CLI via npm..."
    
    # Install Node.js and npm if needed
    if ! command_exists npm; then
        info "Installing Node.js and npm..."
        case $PM in
            apt)
                curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
                apt-get install -y nodejs
                ;;
            dnf|yum)
                curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -
                $PM install -y nodejs
                ;;
            pacman)
                pacman -S --noconfirm nodejs npm
                ;;
            zypper)
                zypper install -y nodejs npm
                ;;
        esac
        success "Node.js and npm installed"
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
    
    if [[ ! -d "/opt/rider" ]] && [[ ! -d "$USER_HOME/.local/share/JetBrains/Toolbox" ]]; then
        info "Installing JetBrains Toolbox..."
        
        # Download and install Toolbox
        TOOLBOX_VERSION=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -Po '"version":.*?[^\\]",' | awk -F'"' '{print $4}')
        TOOLBOX_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-${TOOLBOX_VERSION}.tar.gz"
        
        wget -q --show-progress "$TOOLBOX_URL" -O /tmp/jetbrains-toolbox.tar.gz
        tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /tmp
        
        TOOLBOX_DIR=$(find /tmp -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -n1)
        sudo -u $SUDO_USER "$TOOLBOX_DIR/jetbrains-toolbox" &
        
        rm -rf /tmp/jetbrains-toolbox*
        success "JetBrains Toolbox installed"
        note "Use JetBrains Toolbox to install and manage Rider"
    else
        success "JetBrains Toolbox/Rider already installed"
    fi
else
    info "Skipping JetBrains Rider installation"
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

# Display versions
action ""
action "📋 Installed Versions"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists git; then
    info "Git: $(git --version)"
fi

if command_exists dotnet; then
    info ".NET SDK: $(sudo -u $SUDO_USER dotnet --version)"
fi

if command_exists code; then
    info "VS Code: $(code --version | head -n1)"
fi

if command_exists docker; then
    info "Docker: $(docker --version)"
fi

action ""
action "✨ Setup Complete!"
note "Next steps:"
info "1. Restart your terminal to apply PATH changes"
info "2. Run 'dotnet --info' to verify .NET installation"
info "3. Configure Oh My Posh theme as desired"
info "4. Log out and log back in for Docker group membership to take effect"
info "5. Authenticate GitHub Copilot CLI: github-copilot-cli auth"
info "6. VS Code: Sign in with GitHub for Copilot activation"
if [[ "$INSTALL_RIDER" == true ]]; then
    info "7. Open JetBrains Toolbox and install Rider"
fi
success ""
success "Happy coding! 🚀"
