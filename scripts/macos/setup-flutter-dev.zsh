#!/usr/bin/env zsh

#
# Setup Flutter development environment on macOS
#
# Configures the system for Flutter development by installing:
# - Flutter SDK
# - Android Studio
# - VS Code with Flutter extensions
# - Git
# - Android SDK
# - iOS SDK (Xcode)
# - CocoaPods
# - Oh My Posh with user theme
# All tools are configured with proper PATH settings.
#
# Usage:
#   ./setup-flutter-dev.zsh
#   ./setup-flutter-dev.zsh -v
#   ./setup-flutter-dev.zsh --skip-updates
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
ANDROID_HOME="$HOME/Library/Android/sdk"

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
        export PATH="$PATH:$path"
        success "Added to PATH: $path"
    else
        info "Already in PATH: $path"
    fi
}

action "🎯 Starting Flutter Development Environment Setup"
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

# Install Flutter SDK
action "Installing/Updating Flutter SDK..."
if [[ ! -d "$FLUTTER_DIR" ]]; then
    info "Downloading Flutter SDK..."
    cd "$HOME"
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_stable.zip -o flutter.zip
    info "Extracting Flutter SDK..."
    unzip -q flutter.zip
    rm flutter.zip
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

# Install Xcode Command Line Tools
action "Installing Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode CLI tools..."
    xcode-select --install
    warning "Please complete Xcode CLI tools installation and run this script again"
    success "Xcode CLI tools installation started"
else
    success "Xcode CLI tools already installed"
fi

# Check for Xcode
action "Checking Xcode..."
if [[ -d "/Applications/Xcode.app" ]]; then
    success "Xcode is installed"
    
    # Accept Xcode license
    if ! sudo xcodebuild -license check &>/dev/null; then
        warning "Xcode license not accepted"
        info "Please run: sudo xcodebuild -license accept"
    fi
    
    # Configure Xcode
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    success "Xcode configured"
else
    warning "Xcode not found. Install from App Store for iOS development"
    note "Download: https://apps.apple.com/app/xcode/id497799835"
fi

# Install CocoaPods
action "Installing/Updating CocoaPods..."
if ! command_exists pod; then
    info "Installing CocoaPods..."
    sudo gem install cocoapods
    success "CocoaPods installed"
else
    success "CocoaPods already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        sudo gem update cocoapods 2>/dev/null || true
    fi
fi

# Install Android Studio
action "Installing/Updating Android Studio..."
if [[ ! -d "/Applications/Android Studio.app" ]]; then
    brew install --cask android-studio
    success "Android Studio installed"
else
    success "Android Studio already installed"
    if [[ "$SKIP_UPDATES" != true ]]; then
        brew upgrade --cask android-studio 2>/dev/null || true
    fi
fi

# Configure Android SDK
action "Configuring Android SDK..."
mkdir -p "$ANDROID_HOME"

SHELL_RC="$HOME/.zshrc"

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
    curl -L https://dl.google.com/android/repository/commandlinetools-mac-9477386_latest.zip -o commandlinetools.zip
    unzip -q commandlinetools.zip
    mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
    mv cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/"
    rm -rf cmdline-tools commandlinetools.zip
    success "Android SDK command-line tools installed"
fi

# Install Android SDK components for emulator
if [[ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]]; then
    action "Installing Android SDK components for emulator..."
    
    # Accept licenses first
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses 2>/dev/null || true
    
    # Install essential components (use arm64 for Apple Silicon)
    if [[ $(uname -m) == 'arm64' ]]; then
        "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator" "system-images;android-34;google_apis_playstore;arm64-v8a" 2>/dev/null
    else
        "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator" "system-images;android-34;google_apis_playstore;x86_64" 2>/dev/null
    fi
    
    success "Android SDK components installed"
    
    # Create default AVD if it doesn't exist
    if [[ -f "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" ]]; then
        info "Checking for Android Virtual Device..."
        avd_list=$("$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" list avd 2>/dev/null || echo "")
        if [[ ! "$avd_list" =~ "flutter_emulator" ]]; then
            info "Creating default Android emulator..."
            if [[ $(uname -m) == 'arm64' ]]; then
                echo "no" | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd -n flutter_emulator -k "system-images;android-34;google_apis_playstore;arm64-v8a" -d "pixel_5" 2>/dev/null
            else
                echo "no" | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd -n flutter_emulator -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_5" 2>/dev/null
            fi
            success "Android emulator created: flutter_emulator"
        else
            info "Android emulator already exists"
        fi
    fi
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
command_exists pod && success "CocoaPods is ready" || warning "CocoaPods needs attention"
command_exists oh-my-posh && success "Oh My Posh is ready" || warning "Oh My Posh needs attention"
[[ -d "/Applications/Xcode.app" ]] && success "Xcode is ready" || warning "Xcode needs to be installed from App Store"

action ""
action "✨ Setup Complete!"
note "Next steps:"
info "1. Restart your terminal to apply all PATH changes"
info "2. Run 'flutter doctor' to verify installation"
info "3. Open Android Studio and complete first-run setup"
info "4. Accept Android licenses: flutter doctor --android-licenses"
info "5. Open Xcode at least once to complete installation"
info "6. Accept Xcode license: sudo xcodebuild -license accept"
info "7. Test Android emulator: flutter emulators --launch flutter_emulator"
info "8. Test iOS simulator: open -a Simulator"
info "9. VS Code: Sign in with GitHub for Copilot activation"
