#!/usr/bin/env zsh

#
# Install Docker Desktop on macOS with all necessary dependencies
#
# Description:
#   This script automates the installation of Docker Desktop on macOS including:
#   - Homebrew installation (if needed)
#   - Docker Desktop installation via Homebrew Cask
#   - Rosetta 2 installation for Apple Silicon Macs
#   - Post-installation verification
#
# Usage:
#   ./install-docker.zsh [OPTIONS]
#
# Options:
#   --skip-homebrew    Skip Homebrew installation check
#   --skip-rosetta     Skip Rosetta 2 installation (Apple Silicon only)
#   -h, --help         Display help information
#
# Requirements:
#   - macOS 11.0 (Big Sur) or later
#   - Administrator privileges
#   - Internet connection
#
# Author: PowerScripts
# Version: 1.0
#

set -e

# ================== CONFIGURATION ==================
SKIP_HOMEBREW=false
SKIP_ROSETTA=false
LOG_FILE="/tmp/docker-install_$(date +%Y%m%d_%H%M%S).log"

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
🐳 Docker Desktop Installation Script for macOS

Usage: $0 [OPTIONS]

Options:
    --skip-homebrew     Skip Homebrew installation check
    --skip-rosetta      Skip Rosetta 2 installation (Apple Silicon only)
    -h, --help          Display this help message

Examples:
    $0                      # Full installation
    $0 --skip-rosetta       # Install without Rosetta 2
    $0 --skip-homebrew      # Skip Homebrew check

Requirements:
    - macOS 11.0 (Big Sur) or later
    - Administrator privileges
    - Internet connection

EOF
    exit 0
}

check_macos_version() {
    print_section "🔍 SYSTEM VERIFICATION"
    
    local macos_version=$(sw_vers -productVersion)
    local macos_major=$(echo $macos_version | cut -d. -f1)
    
    print_info "macOS Version: $macos_version"
    
    if [ "$macos_major" -lt 11 ]; then
        print_error "Docker Desktop requires macOS 11.0 (Big Sur) or later"
        exit 1
    fi
    
    print_success "macOS version supported"
}

detect_architecture() {
    local arch=$(uname -m)
    
    if [ "$arch" = "arm64" ]; then
        print_info "Architecture: Apple Silicon (ARM64)"
        IS_APPLE_SILICON=true
    else
        print_info "Architecture: Intel (x86_64)"
        IS_APPLE_SILICON=false
    fi
}

install_rosetta() {
    if [ "$SKIP_ROSETTA" = true ] || [ "$IS_APPLE_SILICON" = false ]; then
        print_section "⏭️  SKIPPING ROSETTA 2"
        return
    fi
    
    print_section "🔧 INSTALLING ROSETTA 2"
    
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        print_success "Rosetta 2 is already installed"
    else
        print_info "Installing Rosetta 2 for x86 compatibility..."
        softwareupdate --install-rosetta --agree-to-license
        print_success "Rosetta 2 installed successfully"
    fi
}

install_homebrew() {
    if [ "$SKIP_HOMEBREW" = true ]; then
        print_section "⏭️  SKIPPING HOMEBREW CHECK"
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew is required but not installed!"
            print_info "Install from: https://brew.sh"
            exit 1
        fi
        return
    fi
    
    print_section "🍺 HOMEBREW VERIFICATION"
    
    if command -v brew &> /dev/null; then
        print_success "Homebrew is already installed"
        local brew_version=$(brew --version | head -n1)
        print_info "$brew_version"
        
        print_info "Updating Homebrew..."
        brew update
        print_success "Homebrew updated"
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        if [ "$IS_APPLE_SILICON" = true ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed successfully"
    fi
}

install_docker_desktop() {
    print_section "🐳 INSTALLING DOCKER DESKTOP"
    
    # Check if Docker is already installed
    if [ -d "/Applications/Docker.app" ]; then
        print_success "Docker Desktop is already installed"
        print_info "Checking for updates..."
        brew upgrade --cask docker 2>/dev/null || true
    else
        print_info "Installing Docker Desktop via Homebrew Cask..."
        brew install --cask docker
        print_success "Docker Desktop installed successfully"
    fi
}

configure_docker_permissions() {
    print_section "🔒 CONFIGURING PERMISSIONS"
    
    # Docker Desktop handles permissions automatically on macOS
    print_info "Docker Desktop will request necessary permissions on first launch"
    print_success "Permissions will be configured during initial setup"
}

start_docker_desktop() {
    print_section "🚀 STARTING DOCKER DESKTOP"
    
    if pgrep -x "Docker Desktop" > /dev/null; then
        print_success "Docker Desktop is already running"
    else
        print_info "Starting Docker Desktop..."
        open -a Docker
        
        print_info "Waiting for Docker to start..."
        local count=0
        local max_attempts=30
        
        while [ $count -lt $max_attempts ]; do
            if docker info &>/dev/null; then
                print_success "Docker Desktop started successfully"
                return 0
            fi
            sleep 2
            count=$((count + 1))
            echo -n "."
        done
        
        echo ""
        print_warning "Docker Desktop is starting (may take a minute)"
        print_info "Please wait for Docker Desktop to fully initialize"
    fi
}

verify_installation() {
    print_section "✅ VERIFYING INSTALLATION"
    
    # Wait a bit for Docker to be ready
    sleep 5
    
    if docker --version &>/dev/null; then
        local docker_version=$(docker --version)
        print_success "Docker installed: $docker_version"
    else
        print_warning "Docker command not available yet"
        print_info "Docker Desktop may still be initializing"
    fi
    
    if docker compose version &>/dev/null; then
        local compose_version=$(docker compose version)
        print_success "Docker Compose available: $compose_version"
    fi
    
    # Test Docker
    print_info "Testing Docker with hello-world..."
    if docker run --rm hello-world &>/dev/null; then
        print_success "Docker is working correctly!"
    else
        print_warning "Docker test may require Docker Desktop to finish initializing"
        print_info "Try running 'docker run hello-world' in a few moments"
    fi
}

# ================== MAIN EXECUTION ==================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-homebrew)
            SKIP_HOMEBREW=true
            shift
            ;;
        --skip-rosetta)
            SKIP_ROSETTA=true
            shift
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
echo -e "${BLUE}█${NC}         🐳 DOCKER DESKTOP FOR macOS - INSTALLER 🐳                  ${BLUE}█${NC}"
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo ""

print_info "Installation started at $(date +'%Y-%m-%d %H:%M:%S')"
print_info "Log file: $LOG_FILE"

check_macos_version
detect_architecture
install_rosetta
install_homebrew
install_docker_desktop
configure_docker_permissions
start_docker_desktop
verify_installation

print_section "📊 INSTALLATION SUMMARY"
print_success "Docker Desktop installation completed successfully!"
print_info "Next steps:"
print_info "  1. Wait for Docker Desktop to fully initialize"
print_info "  2. Complete the initial setup wizard if prompted"
print_info "  3. Verify: docker --version"
print_info "  4. Test: docker run hello-world"
print_info "  5. Access Docker Dashboard from menu bar"

print_info "Full log available at: $LOG_FILE"

echo ""
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo -e "${GREEN}  ✨ DOCKER DESKTOP INSTALLATION COMPLETED ✨${NC}"
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo ""
