#!/usr/bin/env bash

#
# Setup Flutter development environment on Linux
#
# Configures the system for Flutter development by installing:
# - Flutter SDK
# - Android Studio
# - VS Code with Flutter extensions
# - Git
# - Android SDK
# - Oh My Posh with user theme
# All tools are configured with proper PATH settings.
#
# Usage:
#   ./setup-flutter-dev.sh
#   ./setup-flutter-dev.sh -v
#   ./setup-flutter-dev.sh --skip-updates
#
# Options:
#   -v, --verbose      Show detailed output
#   --skip-updates     Skip updating existing tools
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
FLUTTER_DIR="$HOME/flutter"
ANDROID_HOME="$HOME/Android/Sdk"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --skip-updates)
            SKIP_UPDATES=true
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
            sudo apt-get update -qq && sudo apt-get install -y "$pkg"
            ;;
        dnf)
            sudo dnf install -y "$pkg"
            ;;
        yum)
            sudo yum install -y "$pkg"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg"
            ;;
        zypper)
            sudo zypper install -y "$pkg"
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
    local shell_rc="$HOME/.bashrc"
    
    if [[ ! -d "$path" ]]; then
        warning "Path does not exist: $path"
        return
    fi
    
    # Detect shell
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="$HOME/.zshrc"
    fi
    
    if ! grep -q "$path" "$shell_rc" 2>/dev/null; then
        echo "export PATH=\"\$PATH:$path\"" >> "$shell_rc"
        export PATH="$PATH:$path"
        success "Added to PATH: $path"
    else
        info "Already in PATH: $path"
    fi
}

action "🎯 Starting Flutter Development Environment Setup"
info "Platform: Linux"

# Install dependencies
action "Installing system dependencies..."
PM=$(detect_package_manager)
info "Detected package manager: $PM"

case $PM in
    apt)
        sudo apt-get update -qq
        sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa wget
        ;;
    dnf|yum)
        sudo $PM install -y curl git unzip xz zip mesa-libGLU wget
        ;;
    pacman)
        sudo pacman -S --noconfirm curl git unzip xz zip mesa wget
        ;;
    zypper)
        sudo zypper install -y curl git unzip xz zip Mesa-libGLU1 wget
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

# Install Flutter SDK
action "Installing/Updating Flutter SDK..."
if [[ ! -d "$FLUTTER_DIR" ]]; then
    info "Downloading Flutter SDK..."
    cd "$HOME"
    wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_stable.tar.xz
    info "Extracting Flutter SDK..."
    tar xf flutter_linux_stable.tar.xz
    rm flutter_linux_stable.tar.xz
    add_to_path "$FLUTTER_DIR/bin"
    success "Flutter SDK installed"
else
    success "Flutter SDK already installed"
    add_to_path "$FLUTTER_DIR/bin"
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating Flutter SDK..."
        "$FLUTTER_DIR/bin/flutter" upgrade
    fi
fi

# Install Android Studio
action "Installing/Updating Android Studio..."
if [[ ! -d "/opt/android-studio" ]] && [[ ! -d "$HOME/android-studio" ]]; then
    info "Downloading Android Studio..."
    cd /tmp
    wget -q --show-progress https://redirector.gvt1.com/edgedl/android/studio/ide-zips/latest/android-studio-linux.tar.gz
    info "Extracting Android Studio..."
    sudo tar xzf android-studio-linux.tar.gz -C /opt/ 2>/dev/null || tar xzf android-studio-linux.tar.gz -C "$HOME/"
    rm android-studio-linux.tar.gz
    
    if [[ -d "/opt/android-studio" ]]; then
        sudo ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio 2>/dev/null || true
    else
        ln -sf "$HOME/android-studio/bin/studio.sh" "$HOME/.local/bin/android-studio" 2>/dev/null || true
    fi
    success "Android Studio installed"
else
    success "Android Studio already installed"
fi

# Configure Android SDK
action "Configuring Android SDK..."
mkdir -p "$ANDROID_HOME"

# Set environment variables
SHELL_RC="$HOME/.bashrc"
[[ -n "$ZSH_VERSION" ]] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "ANDROID_HOME" "$SHELL_RC" 2>/dev/null; then
    {
        echo ""
        echo "# Android SDK"
        echo "export ANDROID_HOME=\"$ANDROID_HOME\""
        echo "export ANDROID_SDK_ROOT=\"$ANDROID_HOME\""
    } >> "$SHELL_RC"
fi

export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

add_to_path "$ANDROID_HOME/platform-tools"
add_to_path "$ANDROID_HOME/tools"
add_to_path "$ANDROID_HOME/tools/bin"
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/cmdline-tools/latest/bin"
success "Android SDK configured"

# Install Android SDK command-line tools if not present
if [[ ! -d "$ANDROID_HOME/cmdline-tools" ]]; then
    action "Installing Android SDK command-line tools..."
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    cd /tmp
    wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    unzip -q commandlinetools-linux-9477386_latest.zip
    mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
    mv cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/"
    rm -rf cmdline-tools commandlinetools-linux-9477386_latest.zip
    success "Android SDK command-line tools installed"
fi

# Install Android SDK components for emulator
if [[ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]]; then
    action "Installing Android SDK components for emulator..."
    
    # Accept licenses first
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses 2>/dev/null || true
    
    # Install essential components
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator" "system-images;android-34;google_apis_playstore;x86_64" 2>/dev/null
    
    success "Android SDK components installed"
    
    # Install KVM support for faster emulation
    action "Checking KVM support for Android emulator..."
    if [[ -e /dev/kvm ]]; then
        sudo usermod -aG kvm $USER 2>/dev/null || true
        success "KVM support configured"
    else
        warning "KVM not available. Emulator will run slower."
        note "To enable KVM: sudo apt-get install qemu-kvm libvirt-daemon-system"
    fi
    
    # Create default AVD if it doesn't exist
    if [[ -f "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" ]]; then
        info "Checking for Android Virtual Device..."
        avd_list=$("$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" list avd 2>/dev/null || echo "")
        if [[ ! "$avd_list" =~ "flutter_emulator" ]]; then
            info "Creating default Android emulator..."
            echo "no" | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd -n flutter_emulator -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_5" 2>/dev/null
            success "Android emulator created: flutter_emulator"
        else
            info "Android emulator already exists"
        fi
    fi
fi

# Install VS Code
action "Installing/Updating Visual Studio Code..."
if ! command_exists code; then
    case $PM in
        apt)
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg
            sudo apt-get update -qq
            sudo apt-get install -y code
            ;;
        dnf|yum)
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            sudo $PM check-update
            sudo $PM install -y code
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
        "Dart-Code.dart-code"
        "Dart-Code.flutter"
        "alexisvt.flutter-snippets"
        "Nash.awesome-flutter-snippets"
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

# Install Oh My Posh
action "Installing/Updating Oh My Posh..."
if ! command_exists oh-my-posh; then
    info "Downloading Oh My Posh..."
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
    success "Oh My Posh installed"
else
    success "Oh My Posh already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        info "Updating Oh My Posh..."
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    fi
fi

# Configure Oh My Posh
action "Configuring Oh My Posh..."

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
SHELL_RC="$HOME/.bashrc"

case "$CURRENT_SHELL" in
    zsh)
        SHELL_RC="$HOME/.zshrc"
        INIT_CMD='eval "$(oh-my-posh init zsh)"'
        ;;
    bash)
        SHELL_RC="$HOME/.bashrc"
        INIT_CMD='eval "$(oh-my-posh init bash)"'
        ;;
    *)
        SHELL_RC="$HOME/.bashrc"
        INIT_CMD='eval "$(oh-my-posh init bash)"'
        ;;
esac

if ! grep -q "oh-my-posh init" "$SHELL_RC" 2>/dev/null; then
    {
        echo ""
        echo "# Oh My Posh initialization"
        echo "$INIT_CMD"
    } >> "$SHELL_RC"
    success "Oh My Posh configured in $SHELL_RC"
else
    info "Oh My Posh already configured"
fi

# Accept Android licenses
action "Configuring Android licenses..."
if command_exists flutter; then
    flutter doctor --android-licenses 2>/dev/null || true
fi

# Run Flutter doctor
action "Running Flutter doctor..."
if command_exists flutter; then
    info "Flutter doctor output:"
    flutter doctor -v
else
    warning "Flutter command not found. Please restart your shell"
fi

# Final summary
action ""
action "📊 Installation Summary"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

command_exists git && success "Git is ready" || warning "Git needs attention"
command_exists flutter && success "Flutter is ready" || warning "Flutter needs attention"
command_exists code && success "VS Code is ready" || warning "VS Code needs attention"
command_exists oh-my-posh && success "Oh My Posh is ready" || warning "Oh My Posh needs attention"

action ""
action "✨ Setup Complete!"
note "Next steps:"
info "1. Restart your terminal to apply all PATH changes"
info "2. Run 'flutter doctor' to verify installation"
info "3. Open Android Studio and complete first-run setup"
info "4. Accept Android licenses: flutter doctor --android-licenses"
info "5. Log out and log back in for KVM/docker group membership"
info "6. Test emulator: flutter emulators --launch flutter_emulator"
info "7. VS Code: Sign in with GitHub for Copilot activation"
