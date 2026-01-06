#!/usr/bin/env bash

#
# Install Docker on Linux with all necessary dependencies
#
# Description:
#   This script automates the installation of Docker Engine on Linux including:
#   - Distribution detection (Ubuntu, Debian, Fedora, CentOS, Arch)
#   - Docker repository setup
#   - Docker Engine installation
#   - Docker Compose installation
#   - User group configuration
#   - Post-installation verification
#
# Usage:
#   ./install-docker.sh [OPTIONS]
#
# Options:
#   --skip-compose     Skip Docker Compose installation
#   --skip-user-group  Skip adding current user to docker group
#   -h, --help         Display help information
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
SKIP_COMPOSE=false
SKIP_USER_GROUP=false
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
🐳 Docker Installation Script for Linux

Usage: $0 [OPTIONS]

Options:
    --skip-compose      Skip Docker Compose installation
    --skip-user-group   Skip adding current user to docker group
    -h, --help          Display this help message

Examples:
    $0                          # Full installation
    $0 --skip-compose           # Install Docker without Compose
    $0 --skip-user-group        # Install without adding user to docker group

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
            print_info "Supported: Ubuntu, Debian, Fedora, CentOS, RHEL, Arch Linux"
            exit 1
            ;;
    esac
    
    print_success "Distribution supported: $NAME"
}

remove_old_docker() {
    print_section "🧹 REMOVING OLD DOCKER VERSIONS"
    
    case $PACKAGE_MANAGER in
        apt)
            apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            ;;
        dnf)
            dnf remove -y docker docker-client docker-client-latest docker-common \
                docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true
            ;;
        pacman)
            pacman -R --noconfirm docker docker-compose 2>/dev/null || true
            ;;
    esac
    
    print_success "Old Docker versions removed (if any)"
}

install_dependencies() {
    print_section "📦 INSTALLING DEPENDENCIES"
    
    case $PACKAGE_MANAGER in
        apt)
            apt-get update -qq
            apt-get install -y \
                ca-certificates \
                curl \
                gnupg \
                lsb-release \
                apt-transport-https \
                software-properties-common
            ;;
        dnf)
            dnf install -y \
                dnf-plugins-core \
                ca-certificates \
                curl
            ;;
        pacman)
            pacman -Sy --noconfirm \
                ca-certificates \
                curl
            ;;
    esac
    
    print_success "Dependencies installed"
}

setup_docker_repository() {
    print_section "🔧 SETTING UP DOCKER REPOSITORY"
    
    case $PACKAGE_MANAGER in
        apt)
            # Add Docker's official GPG key
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            chmod a+r /etc/apt/keyrings/docker.gpg
            
            # Set up repository
            echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \
                $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            apt-get update -qq
            ;;
        dnf)
            dnf config-manager --add-repo https://download.docker.com/linux/$DISTRO/docker-ce.repo
            ;;
        pacman)
            # Docker is in official Arch repositories
            print_info "Using official Arch repositories"
            ;;
    esac
    
    print_success "Docker repository configured"
}

install_docker_engine() {
    print_section "🐳 INSTALLING DOCKER ENGINE"
    
    case $PACKAGE_MANAGER in
        apt)
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        dnf)
            dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        pacman)
            pacman -S --noconfirm docker docker-compose
            ;;
    esac
    
    print_success "Docker Engine installed"
}

start_docker_service() {
    print_section "🚀 STARTING DOCKER SERVICE"
    
    systemctl start docker
    systemctl enable docker
    
    print_success "Docker service started and enabled"
}

install_docker_compose() {
    if [ "$SKIP_COMPOSE" = true ]; then
        print_section "⏭️  SKIPPING DOCKER COMPOSE"
        return
    fi
    
    print_section "🔨 INSTALLING DOCKER COMPOSE"
    
    # Check if already installed via plugin
    if docker compose version &>/dev/null; then
        print_success "Docker Compose (plugin) already installed"
        docker compose version
        return
    fi
    
    # Install standalone if needed
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$COMPOSE_VERSION" ]; then
        print_warning "Could not detect latest Compose version, using v2.24.0"
        COMPOSE_VERSION="v2.24.0"
    fi
    
    print_info "Installing Docker Compose $COMPOSE_VERSION..."
    
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    
    chmod +x /usr/local/bin/docker-compose
    
    print_success "Docker Compose installed"
    docker-compose --version
}

configure_user_group() {
    if [ "$SKIP_USER_GROUP" = true ]; then
        print_section "⏭️  SKIPPING USER GROUP CONFIGURATION"
        return
    fi
    
    print_section "👥 CONFIGURING USER GROUP"
    
    # Create docker group if it doesn't exist
    if ! getent group docker > /dev/null 2>&1; then
        groupadd docker
        print_success "Docker group created"
    fi
    
    # Add user to docker group
    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker "$SUDO_USER"
        print_success "User '$SUDO_USER' added to docker group"
        print_warning "Log out and back in for group changes to take effect"
    else
        print_info "Run manually: sudo usermod -aG docker \$USER"
    fi
}

verify_installation() {
    print_section "✅ VERIFYING INSTALLATION"
    
    if docker --version; then
        print_success "Docker installed successfully"
    else
        print_error "Docker installation verification failed"
        return 1
    fi
    
    if docker compose version &>/dev/null || docker-compose --version &>/dev/null; then
        print_success "Docker Compose available"
    fi
    
    print_info "Testing Docker with hello-world..."
    if docker run --rm hello-world &>/dev/null; then
        print_success "Docker is working correctly!"
    else
        print_warning "Docker test container failed (may need logout/login for group permissions)"
    fi
}

# ================== MAIN EXECUTION ==================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-compose)
            SKIP_COMPOSE=true
            shift
            ;;
        --skip-user-group)
            SKIP_USER_GROUP=true
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
echo -e "${BLUE}█${NC}           🐳 DOCKER ENGINE FOR LINUX - INSTALLER 🐳                ${BLUE}█${NC}"
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo -e "${BLUE}$(printf '█%.0s' {1..80})${NC}"
echo ""

print_info "Installation started at $(date +'%Y-%m-%d %H:%M:%S')"
print_info "Log file: $LOG_FILE"

check_root
detect_distribution
remove_old_docker
install_dependencies
setup_docker_repository
install_docker_engine
start_docker_service
install_docker_compose
configure_user_group
verify_installation

print_section "📊 INSTALLATION SUMMARY"
print_success "Docker installation completed successfully!"
print_info "Next steps:"
print_info "  1. Log out and back in (for group permissions)"
print_info "  2. Verify: docker --version"
print_info "  3. Test: docker run hello-world"
print_info "  4. Start using Docker!"

print_info "Full log available at: $LOG_FILE"

echo ""
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo -e "${GREEN}  ✨ DOCKER ENGINE INSTALLATION COMPLETED ✨${NC}"
echo -e "${GREEN}$(printf '═%.0s' {1..80})${NC}"
echo ""
