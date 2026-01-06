#!/usr/bin/env bash

#
# Install Visual Studio Code with development tools
#
# Description:
#   This script automates the installation of a complete development environment:
#   - Visual Studio Code
#   - Git version control
#   - PowerShell 7 (latest)
#   - Oh My Posh with Dracula theme
#   - Docker (optional)
#   - VS Code extensions (Dev Containers, Docker)
#
# Usage:
#   ./install-vscode.sh [OPTIONS]
#
# Options:
#   --skip-docker          Skip Docker installation
#   --skip-devcontainers   Skip Dev Containers extension
#   --skip-git             Skip Git installation
#   --skip-powershell      Skip PowerShell 7 installation
#   --skip-ohmyposh        Skip Oh My Posh installation
#   --ohmyposh-theme NAME  Oh My Posh theme (default: dracula)
#   -h, --help             Display help information
#
# Requirements:
#   - Root/sudo privileges
#   - Internet connection
#   - Supported Linux distribution
#
# Author: PowerScripts
# Version: 1.0
#

set -e

# ================== CONFIGURATION ==================
SKIP_DOCKER=false
SKIP_DEVCONTAINERS=false
SKIP_GIT=false
SKIP_POWERSHELL=false
SKIP_OHMYPOSH=false
OHMYPOSH_THEME="dracula"
LOG_FILE="/tmp/vscode-install_$(date +%Y%m%d_%H%M%S).log"

# ================== COLORS ==================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ================== FUNCTIONS ==================

log_message() {
    local level=$1
    shift
    local message="$@"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

print_color() {
    local color=$1
    local emoji=$2
    shift 2
    local message="$@"
    
    log_message "INFO" "$message"
    echo -e "${color}${emoji} ${message}${NC}"
}

print_success() { print_color "$GREEN" "✅" "$@"; }
print_error() { print_color "$RED" "❌" "$@"; log_message "ERROR" "$@"; }
print_warning() { print_color "$YELLOW" "⚠️ " "$@"; log_message "WARNING" "$@"; }
print_info() { print_color "$BLUE" "ℹ️ " "$@"; }
print_section() {
    echo ""
    echo -e "${MAGENTA}$(printf '=%.0s' {1..80})${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}$(printf '=%.0s' {1..80})${NC}"
    log_message "SECTION" "$1"
}

show_help() {
    cat << EOF
📝 Visual Studio Code Development Environment Installer

Usage: $0 [OPTIONS]

Options:
    --skip-docker          Skip Docker installation
    --skip-devcontainers   Skip Dev Containers extension
    --skip-git             Skip Git installation
    --skip-powershell      Skip PowerShell 7 installation
    --skip-ohmyposh        Skip Oh My Posh installation
    --ohmyposh-theme NAME  Oh My Posh theme (default: dracula)
    -h, --help             Display this help message

Examples:
    $0                              # Full installation
    $0 --skip-docker                # Install without Docker
    $0 --ohmyposh-theme "paradox"   # Use different theme

Requirements:
    - Root/sudo privileges
    - Internet connection
    - Supported distribution (Ubuntu, Debian, Fedora, CentOS, Arch)

EOF
    exit 0
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root or with sudo"
        exit 1
    fi
    print_success "Running with root privileges"
}

detect_distribution() {
    print_section "🔍 DISTRIBUTION DETECTION"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        print_info "Detected: $NAME $VERSION"
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    case $DISTRO in
        ubuntu|debian|raspbian)
            PACKAGE_MANAGER="apt"
            ;;
        fedora|centos|rhel)
            PACKAGE_MANAGER="dnf"
            ;;
        arch|manjaro)
            PACKAGE_MANAGER="pacman"
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    print_success "Distribution supported: $NAME"
}

install_git() {
    if [ "$SKIP_GIT" = true ]; then
        print_section "⏭️  SKIPPING GIT"
        return
    fi
    
    print_section "📦 GIT INSTALLATION"
    
    if command -v git &> /dev/null; then
        local git_version=$(git --version)
        print_success "Git already installed: $git_version"
    else
        print_info "Installing Git..."
        
        case $PACKAGE_MANAGER in
            apt)
                apt-get update -qq
                apt-get install -y git
                ;;
            dnf)
                dnf install -y git
                ;;
            pacman)
                pacman -S --noconfirm git
                ;;
        esac
        
        print_success "Git installed successfully"
        git --version
    fi
}

install_powershell7() {
    if [ "$SKIP_POWERSHELL" = true ]; then
        print_section "⏭️  SKIPPING POWERSHELL 7"
        return
    fi
    
    print_section "💻 POWERSHELL 7 INSTALLATION"
    
    if command -v pwsh &> /dev/null; then
        local pwsh_version=$(pwsh --version)
        print_success "PowerShell 7 already installed: $pwsh_version"
    else
        print_info "Installing PowerShell 7..."
        
        case $PACKAGE_MANAGER in
            apt)
                # Install prerequisites
                apt-get update -qq
                apt-get install -y wget apt-transport-https software-properties-common
                
                # Download the Microsoft repository GPG keys
                wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
                dpkg -i packages-microsoft-prod.deb
                rm packages-microsoft-prod.deb
                
                # Update package list and install PowerShell
                apt-get update -qq
                apt-get install -y powershell
                ;;
            dnf)
                # Register Microsoft repository
                curl -sSL https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo
                dnf install -y powershell
                ;;
            pacman)
                # Install from AUR (requires yay or another AUR helper)
                print_warning "PowerShell on Arch requires AUR helper"
                print_info "Install manually: yay -S powershell-bin"
                return
                ;;
        esac
        
        print_success "PowerShell 7 installed successfully"
        pwsh --version
    fi
}

install_ohmyposh() {
    if [ "$SKIP_OHMYPOSH" = true ]; then
        print_section "⏭️  SKIPPING OH MY POSH"
        return
    fi
    
    print_section "🎨 OH MY POSH INSTALLATION"
    
    if command -v oh-my-posh &> /dev/null; then
        print_success "Oh My Posh already installed"
    else
        print_info "Installing Oh My Posh..."
        
        # Install Oh My Posh
        curl -s https://ohmyposh.dev/install.sh | bash -s
        
        print_success "Oh My Posh installed successfully"
    fi
    
    # Install Nerd Font
    print_info "Installing CascadiaCode Nerd Font..."
    oh-my-posh font install CascadiaCode 2>&1 || true
    print_success "Font installation attempted"
}

configure_powershell_profile() {
    if [ "$SKIP_OHMYPOSH" = true ]; then
        print_section "⏭️  SKIPPING PROFILE CONFIGURATION"
        return
    fi
    
    print_section "⚙️  POWERSHELL PROFILE CONFIGURATION"
    
    # Get real user (not root)
    REAL_USER=${SUDO_USER:-$USER}
    REAL_HOME=$(eval echo ~$REAL_USER)
    
    # PowerShell profile path
    PWSH_PROFILE_DIR="$REAL_HOME/.config/powershell"
    PWSH_PROFILE="$PWSH_PROFILE_DIR/Microsoft.PowerShell_profile.ps1"
    
    # Create directory
    mkdir -p "$PWSH_PROFILE_DIR"
    
    # Download theme
    THEME_PATH="$PWSH_PROFILE_DIR/$OHMYPOSH_THEME.omp.json"
    if [ ! -f "$THEME_PATH" ]; then
        print_info "Downloading $OHMYPOSH_THEME theme..."
        curl -sSL "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$OHMYPOSH_THEME.omp.json" -o "$THEME_PATH"
        print_success "Theme downloaded"
    fi
    
    # Create profile
    cat > "$PWSH_PROFILE" << EOF
# Oh My Posh initialization
oh-my-posh init pwsh --config "$THEME_PATH" | Invoke-Expression

# PSReadLine configuration
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Useful aliases
Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker -ErrorAction SilentlyContinue
Set-Alias -Name dc -Value docker-compose -ErrorAction SilentlyContinue

# Welcome message
Write-Host "🚀 PowerShell 7 with Oh My Posh - $OHMYPOSH_THEME theme" -ForegroundColor Cyan
EOF
    
    chown -R $REAL_USER:$REAL_USER "$PWSH_PROFILE_DIR"
    print_success "PowerShell profile configured"
    
    # Also configure for bash
    BASHRC="$REAL_HOME/.bashrc"
    if [ -f "$BASHRC" ]; then
        if ! grep -q "oh-my-posh" "$BASHRC"; then
            echo "" >> "$BASHRC"
            echo "# Oh My Posh" >> "$BASHRC"
            echo 'eval "$(oh-my-posh init bash --config '"$THEME_PATH"')"' >> "$BASHRC"
            chown $REAL_USER:$REAL_USER "$BASHRC"
            print_success "Bash profile configured"
        fi
    fi
}

install_vscode() {
    print_section "📝 VISUAL STUDIO CODE INSTALLATION"
    
    if command -v code &> /dev/null; then
        print_success "VS Code already installed"
        code --version | head -n1
    else
        print_info "Installing Visual Studio Code..."
        
        case $PACKAGE_MANAGER in
            apt)
                # Import Microsoft GPG key
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
                
                # Add VS Code repository
                echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
                
                rm -f packages.microsoft.gpg
                
                # Install
                apt-get update -qq
                apt-get install -y code
                ;;
            dnf)
                # Add repository
                rpm --import https://packages.microsoft.com/keys/microsoft.asc
                cat << EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
                dnf install -y code
                ;;
            pacman)
                # Install from AUR or snap
                print_warning "VS Code on Arch requires AUR or snap"
                print_info "Install manually: yay -S visual-studio-code-bin"
                return
                ;;
        esac
        
        print_success "VS Code installed successfully"
    fi
}

install_vscode_extensions() {
    print_section "🔌 VS CODE EXTENSIONS"
    
    if ! command -v code &> /dev/null; then
        print_warning "VS Code not found, skipping extensions"
        return
    fi
    
    # Get real user
    REAL_USER=${SUDO_USER:-$USER}
    
    # Extensions to install
    extensions=(
        "ms-vscode.powershell"
        "eamodio.gitlens"
    )
    
    if [ "$SKIP_DEVCONTAINERS" != true ]; then
        extensions+=("ms-vscode-remote.remote-containers")
    fi
    
    if [ "$SKIP_DOCKER" != true ]; then
        extensions+=("ms-azuretools.vscode-docker")
    fi
    
    for extension in "${extensions[@]}"; do
        print_info "Installing extension: $extension..."
        sudo -u $REAL_USER code --install-extension "$extension" --force 2>&1 | grep -v "WARNING" || true
        print_success "Installed: $extension"
    done
    
    print_success "Extensions installation completed"
}

install_docker() {
    if [ "$SKIP_DOCKER" = true ]; then
        print_section "⏭️  SKIPPING DOCKER"
        return
    fi
    
    print_section "🐳 DOCKER INSTALLATION"
    
    # Check if Docker install script exists
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOCKER_SCRIPT="$SCRIPT_DIR/install-docker.sh"
    
    if [ -f "$DOCKER_SCRIPT" ]; then
        print_info "Running Docker installation script..."
        bash "$DOCKER_SCRIPT"
    else
        print_warning "Docker installation script not found"
        print_info "Please run install-docker.sh separately"
    fi
}

# ================== MAIN EXECUTION ==================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --skip-devcontainers)
            SKIP_DEVCONTAINERS=true
            shift
            ;;
        --skip-git)
            SKIP_GIT=true
            shift
            ;;
        --skip-powershell)
            SKIP_POWERSHELL=true
            shift
            ;;
        --skip-ohmyposh)
            SKIP_OHMYPOSH=true
            shift
            ;;
        --ohmyposh-theme)
            OHMYPOSH_THEME="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            ;;
    esac
done

# Main installation flow
echo ""
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo -e "${BLUE}█${NC}     📝 VISUAL STUDIO CODE - DEVELOPMENT ENVIRONMENT SETUP 📝        ${BLUE}█${NC}"
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo ""

print_info "Installation started at $(date +'%Y-%m-%d %H:%M:%S')"
print_info "Log file: $LOG_FILE"

print_section "📋 COMPONENTS TO INSTALL"
print_info "Git: $([ "$SKIP_GIT" = false ] && echo "✅" || echo "❌")"
print_info "PowerShell 7: $([ "$SKIP_POWERSHELL" = false ] && echo "✅" || echo "❌")"
print_info "Oh My Posh ($OHMYPOSH_THEME): $([ "$SKIP_OHMYPOSH" = false ] && echo "✅" || echo "❌")"
print_info "Visual Studio Code: ✅"
print_info "Dev Containers: $([ "$SKIP_DEVCONTAINERS" = false ] && echo "✅" || echo "❌")"
print_info "Docker: $([ "$SKIP_DOCKER" = false ] && echo "✅" || echo "❌")"

check_root
detect_distribution
install_git
install_powershell7
install_ohmyposh
configure_powershell_profile
install_vscode
install_vscode_extensions
install_docker

print_section "📊 INSTALLATION SUMMARY"
print_success "Development environment setup completed!"
print_info "Next steps:"
print_info "  1. Restart your terminal to apply changes"
print_info "  2. Launch PowerShell 7: pwsh"
print_info "  3. Verify Oh My Posh theme"
print_info "  4. Open VS Code: code ."
print_info "  5. Configure terminal font (CascadiaCode Nerd Font)"

if [ "$SKIP_DOCKER" != true ]; then
    print_info "  6. Test Docker: docker run hello-world"
fi

print_info "Full log available at: $LOG_FILE"

echo ""
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo -e "${GREEN}  ✨ DEVELOPMENT ENVIRONMENT READY! ✨${NC}"
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo ""
