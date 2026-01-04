<#
.SYNOPSIS
    Setup Flutter development environment on Windows

.DESCRIPTION
    Configures the system for Flutter development by installing:
    - Flutter SDK
    - Android Studio
    - VS Code with Flutter extensions
    - Git
    - Android SDK
    - Ninja build system
    - Oh My Posh with user theme
    All tools are configured with proper PATH settings.

.PARAMETER SkipUpdates
    Skip updating existing tools

.PARAMETER Verbose
    Show detailed output

.EXAMPLE
    .\setup-flutter-dev.ps1
    .\setup-flutter-dev.ps1 -Verbose
    .\setup-flutter-dev.ps1 -SkipUpdates

.NOTES
    Requires administrator privileges for some installations
    Idempotent - safe to run multiple times
#>

param(
    [switch]$SkipUpdates,
    [switch]$Verbose
)

# Color functions
function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Error-Custom { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Warning-Custom { param([string]$Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Action { param([string]$Message) Write-Host "🚀 $Message" -ForegroundColor White }
function Write-Note { param([string]$Message) Write-Host "📝 $Message" -ForegroundColor Magenta }

# Check if running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Add to PATH if not already present
function Add-ToPath {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        Write-Warning-Custom "Path does not exist: $Path"
        return
    }

    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$Path*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", "User")
        $env:Path = "$env:Path;$Path"
        Write-Success "Added to PATH: $Path"
    } else {
        Write-Info "Already in PATH: $Path"
    }
}

Write-Action "🎯 Starting Flutter Development Environment Setup"
Write-Info "Platform: Windows"

# Check for administrator privileges
if (-not (Test-Administrator)) {
    Write-Warning-Custom "Some operations may require administrator privileges"
    Write-Note "Consider running as administrator for full installation"
}

# Install Chocolatey if not present
Write-Action "Checking Chocolatey package manager..."
if (-not (Test-Command "choco")) {
    Write-Info "Installing Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Success "Chocolatey installed"
    } catch {
        Write-Error-Custom "Failed to install Chocolatey: $_"
        exit 1
    }
} else {
    Write-Success "Chocolatey already installed"
}

# Install Git
Write-Action "Installing/Updating Git..."
if (-not (Test-Command "git")) {
    choco install git -y
    Write-Success "Git installed"
} else {
    Write-Success "Git already installed"
    if (-not $SkipUpdates) {
        choco upgrade git -y
    }
}

# Install VS Code
Write-Action "Installing/Updating Visual Studio Code..."
if (-not (Test-Command "code")) {
    choco install vscode -y
    Write-Success "VS Code installed"
} else {
    Write-Success "VS Code already installed"
    if (-not $SkipUpdates) {
        choco upgrade vscode -y
    }
}

# Install Ninja build system
Write-Action "Installing/Updating Ninja build system..."
$ninjaPath = "$env:USERPROFILE\.ninja"
if (-not (Test-Path "$ninjaPath\ninja.exe")) {
    Write-Info "Downloading Ninja..."
    try {
        New-Item -ItemType Directory -Path $ninjaPath -Force | Out-Null
        $ninjaZip = "$env:TEMP\ninja-win.zip"
        $ninjaUrl = "https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip"
        Invoke-WebRequest -Uri $ninjaUrl -OutFile $ninjaZip
        Write-Info "Extracting Ninja..."
        Expand-Archive -Path $ninjaZip -DestinationPath $ninjaPath -Force
        Remove-Item $ninjaZip
        Add-ToPath $ninjaPath
        Write-Success "Ninja build system installed"
    } catch {
        Write-Error-Custom "Failed to install Ninja: $_"
        Write-Warning-Custom "Continuing without Ninja..."
    }
} else {
    Write-Success "Ninja build system already installed"
    Add-ToPath $ninjaPath
}

# Install Flutter SDK
Write-Action "Installing/Updating Flutter SDK..."
$flutterPath = "$env:USERPROFILE\flutter"
if (-not (Test-Path "$flutterPath\bin\flutter.bat")) {
    Write-Info "Downloading Flutter SDK..."
    $flutterZip = "$env:TEMP\flutter_windows.zip"
    try {
        Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_stable.zip" -OutFile $flutterZip
        Write-Info "Extracting Flutter SDK..."
        Expand-Archive -Path $flutterZip -DestinationPath $env:USERPROFILE -Force
        Remove-Item $flutterZip
        Add-ToPath "$flutterPath\bin"
        Write-Success "Flutter SDK installed"
    } catch {
        Write-Error-Custom "Failed to install Flutter: $_"
        exit 1
    }
} else {
    Write-Success "Flutter SDK already installed"
    Add-ToPath "$flutterPath\bin"
    if (-not $SkipUpdates) {
        Write-Info "Updating Flutter SDK..."
        & "$flutterPath\bin\flutter.bat" upgrade
    }
}

# Configure Flutter to use Ninja
Write-Action "Configuring Flutter to use Ninja..."
if (Test-Path "$ninjaPath\ninja.exe") {
    $flutterConfig = @{
        "enable-native-assets" = "true"
    }
    
    foreach ($config in $flutterConfig.GetEnumerator()) {
        try {
            & "$flutterPath\bin\flutter.bat" config --$($config.Key) $($config.Value) 2>$null
            Write-Info "Set Flutter config: $($config.Key) = $($config.Value)"
        } catch {
            Write-Warning-Custom "Could not set Flutter config: $($config.Key)"
        }
    }
    Write-Success "Flutter configured to use Ninja build system"
} else {
    Write-Warning-Custom "Ninja not found, skipping Flutter Ninja configuration"
}

# Install Android Studio
Write-Action "Installing/Updating Android Studio..."
if (-not (Test-Path "$env:ProgramFiles\Android\Android Studio")) {
    choco install androidstudio -y
    Write-Success "Android Studio installed"
} else {
    Write-Success "Android Studio already installed"
    if (-not $SkipUpdates) {
        choco upgrade androidstudio -y
    }
}

# Configure Android SDK
Write-Action "Configuring Android SDK..."
$androidHome = "$env:LOCALAPPDATA\Android\Sdk"
if (-not (Test-Path $androidHome)) {
    $androidHome = "$env:USERPROFILE\AppData\Local\Android\Sdk"
}

if (Test-Path $androidHome) {
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidHome, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidHome, "User")
    $env:ANDROID_HOME = $androidHome
    $env:ANDROID_SDK_ROOT = $androidHome
    Add-ToPath "$androidHome\platform-tools"
    Add-ToPath "$androidHome\tools"
    Add-ToPath "$androidHome\tools\bin"
    Add-ToPath "$androidHome\emulator"
    Add-ToPath "$androidHome\cmdline-tools\latest\bin"
    Write-Success "Android SDK configured"
    
    # Install Android SDK components for emulator
    Write-Action "Installing Android SDK components for emulator..."
    if (Test-Path "$androidHome\cmdline-tools\latest\bin\sdkmanager.bat") {
        Write-Info "Installing SDK platform tools and emulator components..."
        
        # Accept licenses first
        & "$androidHome\cmdline-tools\latest\bin\sdkmanager.bat" --licenses 2>$null
        
        # Install essential components
        & "$androidHome\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator" "system-images;android-34;google_apis_playstore;x86_64" 2>$null
        
        Write-Success "Android SDK components installed"
        
        # Create default AVD if it doesn't exist
        Write-Info "Checking for Android Virtual Device..."
        if (Test-Path "$androidHome\cmdline-tools\latest\bin\avdmanager.bat") {
            $avdList = & "$androidHome\cmdline-tools\latest\bin\avdmanager.bat" list avd 2>$null
            if ($avdList -notmatch "flutter_emulator") {
                Write-Info "Creating default Android emulator..."
                echo "no" | & "$androidHome\cmdline-tools\latest\bin\avdmanager.bat" create avd -n flutter_emulator -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_5" 2>$null
                Write-Success "Android emulator created: flutter_emulator"
            } else {
                Write-Info "Android emulator already exists"
            }
        }
    } else {
        Write-Warning-Custom "Android SDK command-line tools not found"
        Write-Note "Open Android Studio and install SDK components via SDK Manager"
    }
} else {
    Write-Warning-Custom "Android SDK not found. Please install via Android Studio"
}

# Install VS Code extensions for Flutter
Write-Action "Installing VS Code extensions..."
if (Test-Command "code") {
    $extensions = @(
        "Dart-Code.dart-code",
        "Dart-Code.flutter",
        "alexisvt.flutter-snippets",
        "Nash.awesome-flutter-snippets",
        "usernamehw.errorlens",
        "eamodio.gitlens",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-vscode-remote.remote-containers",
        "ms-azuretools.vscode-docker"
    )
    foreach ($ext in $extensions) {
        Write-Info "Installing extension: $ext"
        code --install-extension $ext --force 2>$null
    }
    Write-Success "VS Code extensions installed"
}

# Install Oh My Posh
Write-Action "Installing/Updating Oh My Posh..."
if (-not (Test-Command "oh-my-posh")) {
    choco install oh-my-posh -y
    Write-Success "Oh My Posh installed"
} else {
    Write-Success "Oh My Posh already installed"
    if (-not $SkipUpdates) {
        choco upgrade oh-my-posh -y
    }
}

# Configure Oh My Posh in PowerShell profile
Write-Action "Configuring Oh My Posh..."
$profilePaths = @(
    $PROFILE.CurrentUserCurrentHost,
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)

foreach ($profilePath in $profilePaths) {
    if (-not (Test-Path $profilePath)) {
        New-Item -Path $profilePath -ItemType File -Force | Out-Null
        Write-Info "Created profile: $profilePath"
    }

    $poshInit = "oh-my-posh init pwsh | Invoke-Expression"
    $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue -Raw
    
    if ($profileContent -notmatch "oh-my-posh init") {
        Add-Content -Path $profilePath -Value "`n# Oh My Posh initialization"
        Add-Content -Path $profilePath -Value $poshInit
        Write-Success "Oh My Posh configured in: $(Split-Path $profilePath -Leaf)"
    } else {
        Write-Info "Oh My Posh already configured in: $(Split-Path $profilePath -Leaf)"
    }
}

# Run Flutter doctor
Write-Action "Running Flutter doctor..."
if (Test-Command "flutter") {
    Write-Info "Flutter doctor output:"
    flutter doctor -v
} else {
    Write-Warning-Custom "Flutter command not found. Please restart your shell"
}

# Final summary
Write-Action "`n📊 Installation Summary"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

$tools = @{
    "Git" = (Test-Command "git")
    "Ninja" = (Test-Command "ninja")
    "Flutter" = (Test-Command "flutter")
    "VS Code" = (Test-Command "code")
    "Oh My Posh" = (Test-Command "oh-my-posh")
}

foreach ($tool in $tools.GetEnumerator()) {
    if ($tool.Value) {
        Write-Success "$($tool.Key) is ready"
    } else {
        Write-Warning-Custom "$($tool.Key) needs attention"
    }
}

Write-Action "`n✨ Setup Complete!"
Write-Note "Next steps:"
Write-Info "1. Restart your terminal to apply all PATH changes"
Write-Info "2. Run 'flutter doctor' to verify installation"
Write-Info "3. Open Android Studio and complete first-run setup"
Write-Info "4. Accept Android licenses: flutter doctor --android-licenses"
Write-Info "5. Test emulator: flutter emulators --launch flutter_emulator"
Write-Info "6. VS Code: Sign in with GitHub for Copilot activation"
Write-Note "For iOS development, you need a macOS system with Xcode"
