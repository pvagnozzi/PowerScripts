#!/usr/bin/env zsh

#
# Install Visual Studio Code with development tools on macOS
#
# Description:
#   This script automates the installation of a complete development environment:
#   - Visual Studio Code
#   - Git version control  
#   - PowerShell 7 (latest)
#   - Oh My Posh with Dracula theme
#   - Docker Desktop (optional)
#   - VS Code extensions (Dev Containers, Docker)
#
# Usage:
#   ./install-vscode.zsh [OPTIONS]
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
#   - macOS 11.0 (Big Sur) or later
#   - Internet connection
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
📝 Visual Studio Code Development Environment Installer for macOS

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
    - macOS 11.0 (Big Sur) or later
    - Internet connection

EOF
    exit 0
}

check_homebrew() {
    print_section "🍺 HOMEBREW VERIFICATION"
    
    if command -v brew &> /dev/null; then
        print_success "Homebrew is already installed"
        print_info "Updating Homebrew..."
        brew update
        print_success "Homebrew updated"
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        if [ "$(uname -m)" = "arm64" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed successfully"
    fi
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
        brew install git
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
        
        print_info "Checking for updates..."
        brew upgrade powershell 2>/dev/null || true
    else
        print_info "Installing PowerShell 7..."
        brew install --cask powershell
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
        
        print_info "Updating Oh My Posh..."
        brew upgrade oh-my-posh 2>/dev/null || true
    else
        print_info "Installing Oh My Posh..."
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
        print_success "Oh My Posh installed successfully"
    fi
    
    # Install Nerd Font
    print_info "Installing CascadiaCode Nerd Font..."
    brew tap homebrew/cask-fonts 2>/dev/null || true
    brew install --cask font-caskaydia-cove-nerd-font 2>/dev/null || true
    print_success "Font installation completed"
}

configure_powershell_profile() {
    if [ "$SKIP_OHMYPOSH" = true ]; then
        print_section "⏭️  SKIPPING PROFILE CONFIGURATION"
        return
    fi
    
    print_section "⚙️  POWERSHELL PROFILE CONFIGURATION"
    
    # PowerShell profile path
    PWSH_PROFILE_DIR="$HOME/.config/powershell"
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
    
    # Create PowerShell profile
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
    
    print_success "PowerShell profile configured"
    
    # Also configure for zsh
    ZSHRC="$HOME/.zshrc"
    if [ -f "$ZSHRC" ]; then
        if ! grep -q "oh-my-posh" "$ZSHRC"; then
            echo "" >> "$ZSHRC"
            echo "# Oh My Posh" >> "$ZSHRC"
            echo 'eval "$(oh-my-posh init zsh --config '"$THEME_PATH"')"' >> "$ZSHRC"
            print_success "Zsh profile configured"
        else
            print_success "Zsh already configured with Oh My Posh"
        fi
    fi
}

install_vscode() {
    print_section "📝 VISUAL STUDIO CODE INSTALLATION"
    
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        print_success "VS Code already installed"
        
        print_info "Checking for updates..."
        brew upgrade --cask visual-studio-code 2>/dev/null || true
    else
        print_info "Installing Visual Studio Code..."
        brew install --cask visual-studio-code
        print_success "VS Code installed successfully"
    fi
}

install_vscode_extensions() {
    print_section "🔌 VS CODE EXTENSIONS"
    
    if ! command -v code &> /dev/null; then
        print_warning "VS Code command not found, skipping extensions"
        print_info "You may need to install 'code' command from VS Code"
        print_info "Open VS Code > Command Palette > Shell Command: Install 'code' command in PATH"
        return
    fi
    
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
        code --install-extension "$extension" --force 2>&1 | grep -v "WARNING" || true
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
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
    DOCKER_SCRIPT="$SCRIPT_DIR/install-docker.zsh"
    
    if [ -f "$DOCKER_SCRIPT" ]; then
        print_info "Running Docker installation script..."
        zsh "$DOCKER_SCRIPT"
    else
        print_warning "Docker installation script not found"
        
        if [ -d "/Applications/Docker.app" ]; then
            print_success "Docker Desktop already installed"
        else
            print_info "Installing Docker Desktop..."
            brew install --cask docker
            print_success "Docker Desktop installed"
        fi
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

check_homebrew
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
print_info "  4. Open VS Code and install 'code' command if needed:"
print_info "     Command Palette > Shell Command: Install 'code' command in PATH"
print_info "  5. Configure terminal font (CaskaydiaCove Nerd Font)"

if [ "$SKIP_DOCKER" != true ]; then
    print_info "  6. Start Docker Desktop from Applications"
    print_info "  7. Test Docker: docker run hello-world"
fi

print_info "Full log available at: $LOG_FILE"

echo ""
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo -e "${GREEN}  ✨ DEVELOPMENT ENVIRONMENT READY! ✨${NC}"
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo ""
