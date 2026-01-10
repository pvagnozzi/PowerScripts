<#
.SYNOPSIS
    Setup ESP32 development environment on Windows

.DESCRIPTION
    Configures the system for ESP32 development by installing and configuring:
    - Git version control
    - PowerShell 7 (latest version)
    - Visual Studio Code with ESP32/PlatformIO/C++ extensions
    - ESP-IDF (ESP32 SDK)
    - CMake, GCC, Clang
    - PlatformIO
    - C/C++ build tools
    - Python (required for ESP-IDF)
    - Oh My Posh with automatic initialization and user theme
    
    All tools are configured with proper PATH settings and integrations.

.PARAMETER SkipUpdates
    Skip updating existing tools

.PARAMETER Verbose
    Show detailed output

.EXAMPLE
    .\setup-esp32-dev.ps1
    
.EXAMPLE
    .\setup-esp32-dev.ps1 -SkipUpdates
    
.EXAMPLE
    .\setup-esp32-dev.ps1 -Verbose

.NOTES
    Requires administrator privileges
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

Write-Action "🎯 Starting ESP32 Development Environment Setup"
Write-Info "Platform: Windows"

# Check for administrator privileges
if (-not (Test-Administrator)) {
    Write-Error-Custom "This script requires administrator privileges"
    Write-Note "Please run PowerShell as Administrator and try again"
    exit 1
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
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
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
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "Git already installed"
    if (-not $SkipUpdates) {
        choco upgrade git -y
    }
}

# Install PowerShell 7
Write-Action "Installing/Updating PowerShell 7..."
if (-not (Test-Path "$env:ProgramFiles\PowerShell\7")) {
    Write-Info "Installing PowerShell 7..."
    choco install powershell-core -y
    Write-Success "PowerShell 7 installed"
} else {
    Write-Success "PowerShell 7 already installed"
    if (-not $SkipUpdates) {
        choco upgrade powershell-core -y
    }
}

# Install Python (required for ESP-IDF)
Write-Action "Installing/Updating Python..."
if (-not (Test-Command "python")) {
    choco install python -y
    Write-Success "Python installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "Python already installed"
    if (-not $SkipUpdates) {
        choco upgrade python -y
    }
}

# Install VS Code
Write-Action "Installing/Updating Visual Studio Code..."
if (-not (Test-Command "code")) {
    choco install vscode -y
    Write-Success "VS Code installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "VS Code already installed"
    if (-not $SkipUpdates) {
        choco upgrade vscode -y
    }
}

# Install VS Code extensions for ESP32 development
Write-Action "Installing VS Code extensions..."
if (Test-Command "code") {
    $extensions = @(
        "ms-vscode.cpptools",
        "ms-vscode.cpptools-extension-pack",
        "ms-vscode.cmake-tools",
        "twxs.cmake",
        "platformio.platformio-ide",
        "espressif.esp-idf-extension",
        "ms-python.python",
        "ms-python.vscode-pylance",
        "eamodio.gitlens",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "usernamehw.errorlens",
        "jeff-hykin.better-cpp-syntax",
        "llvm-vs-code-extensions.vscode-clangd"
    )
    foreach ($ext in $extensions) {
        Write-Info "Installing extension: $ext"
        code --install-extension $ext --force 2>$null
    }
    Write-Success "VS Code extensions installed"
}

# Install CMake
Write-Action "Installing/Updating CMake..."
if (-not (Test-Command "cmake")) {
    choco install cmake -y --installargs 'ADD_CMAKE_TO_PATH=System'
    Write-Success "CMake installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "CMake already installed"
    if (-not $SkipUpdates) {
        choco upgrade cmake -y
    }
}

# Install Ninja build system
Write-Action "Installing/Updating Ninja..."
if (-not (Test-Command "ninja")) {
    choco install ninja -y
    Write-Success "Ninja installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "Ninja already installed"
}

# Install GCC
Write-Action "Installing/Updating GCC (MinGW)..."
if (-not (Test-Command "gcc")) {
    choco install mingw -y
    Write-Success "GCC (MinGW) installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "GCC already installed"
    if (-not $SkipUpdates) {
        choco upgrade mingw -y
    }
}

# Install Clang
Write-Action "Installing/Updating Clang (LLVM)..."
if (-not (Test-Command "clang")) {
    choco install llvm -y
    Write-Success "Clang (LLVM) installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "Clang already installed"
    if (-not $SkipUpdates) {
        choco upgrade llvm -y
    }
}

# Install ESP-IDF
Write-Action "Installing ESP-IDF (ESP32 SDK)..."
$espIdfPath = "C:\tools\esp-idf"
$espToolsPath = "C:\tools\.espressif"

if (-not (Test-Path $espIdfPath)) {
    Write-Info "Cloning ESP-IDF repository to C:\tools..."
    New-Item -ItemType Directory -Path "C:\tools" -Force | Out-Null
    git clone --recursive https://github.com/espressif/esp-idf.git $espIdfPath
    
    Write-Info "Installing ESP-IDF tools to C:\tools\.espressif..."
    Set-Location $espIdfPath
    
    # Set tools path before running install
    $env:IDF_TOOLS_PATH = $espToolsPath
    [Environment]::SetEnvironmentVariable("IDF_TOOLS_PATH", $espToolsPath, "User")
    
    & .\install.bat all
    
    Write-Success "ESP-IDF installed to C:\tools"
    
    # Set environment variables
    [Environment]::SetEnvironmentVariable("IDF_PATH", $espIdfPath, "User")
    $env:IDF_PATH = $espIdfPath
    
    Write-Info "ESP-IDF location: $espIdfPath"
    Write-Info "ESP-IDF tools location: $espToolsPath"
} else {
    Write-Success "ESP-IDF already installed at C:\tools"
    if (-not $SkipUpdates) {
        Write-Info "Updating ESP-IDF..."
        Set-Location $espIdfPath
        
        # Ensure tools path is set
        $env:IDF_TOOLS_PATH = $espToolsPath
        [Environment]::SetEnvironmentVariable("IDF_TOOLS_PATH", $espToolsPath, "User")
        
        git pull
        & .\install.bat all
    }
}

# Install PlatformIO Core
Write-Action "Installing/Updating PlatformIO Core..."
if (-not (Test-Command "pio")) {
    Write-Info "Installing PlatformIO..."
    python -m pip install --upgrade pip
    pip install --upgrade platformio
    Write-Success "PlatformIO installed"
} else {
    Write-Success "PlatformIO already installed"
    if (-not $SkipUpdates) {
        pip install --upgrade platformio
    }
}

# Configure ESP-IDF extension in VS Code
Write-Action "Configuring ESP-IDF extension..."
$vscodeSettingsDir = "$env:APPDATA\Code\User"
$vscodeSettingsFile = "$vscodeSettingsDir\settings.json"

if (-not (Test-Path $vscodeSettingsDir)) {
    New-Item -ItemType Directory -Path $vscodeSettingsDir -Force | Out-Null
}

if (Test-Path $vscodeSettingsFile) {
    $settings = Get-Content $vscodeSettingsFile -Raw | ConvertFrom-Json
} else {
    $settings = @{}
}

$settings | Add-Member -NotePropertyName "idf.espIdfPath" -NotePropertyValue $espIdfPath -Force
$settings | Add-Member -NotePropertyName "idf.toolsPath" -NotePropertyValue $espToolsPath -Force
$settings | Add-Member -NotePropertyName "idf.pythonBinPath" -NotePropertyValue (Get-Command python -ErrorAction SilentlyContinue).Source -Force

$settings | ConvertTo-Json -Depth 10 | Set-Content $vscodeSettingsFile -Force
Write-Success "ESP-IDF extension configured"
Write-Info "IDF Path: $espIdfPath"
Write-Info "Tools Path: $espToolsPath"

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

# Install USB drivers for ESP32
Write-Action "Installing USB drivers..."
Write-Info "Installing CP210x USB to UART Bridge drivers..."
choco install driver-cp210x -y --ignore-checksums 2>$null || Write-Warning-Custom "CP210x driver installation skipped (may need manual installation)"

# Final summary
Write-Action "`n📊 Installation Summary"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

$tools = @{
    "Git" = (Test-Command "git")
    "PowerShell 7" = (Test-Path "$env:ProgramFiles\PowerShell\7")
    "Python" = (Test-Command "python")
    "VS Code" = (Test-Command "code")
    "CMake" = (Test-Command "cmake")
    "Ninja" = (Test-Command "ninja")
    "GCC" = (Test-Command "gcc")
    "Clang" = (Test-Command "clang")
    "ESP-IDF" = (Test-Path $espIdfPath)
    "PlatformIO" = (Test-Command "pio")
    "Oh My Posh" = (Test-Command "oh-my-posh")
}

foreach ($tool in $tools.GetEnumerator()) {
    if ($tool.Value) {
        Write-Success "$($tool.Key) is ready"
    } else {
        Write-Warning-Custom "$($tool.Key) needs attention"
    }
}

# Display versions
Write-Action "`n📋 Installed Versions"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if (Test-Command "git") {
    $gitVersion = git --version
    Write-Info "Git: $gitVersion"
}

if (Test-Command "python") {
    $pythonVersion = python --version
    Write-Info "Python: $pythonVersion"
}

if (Test-Command "code") {
    $codeVersion = code --version | Select-Object -First 1
    Write-Info "VS Code: $codeVersion"
}

if (Test-Command "cmake") {
    $cmakeVersion = cmake --version | Select-Object -First 1
    Write-Info "CMake: $cmakeVersion"
}

if (Test-Command "gcc") {
    $gccVersion = gcc --version | Select-Object -First 1
    Write-Info "GCC: $gccVersion"
}

if (Test-Command "clang") {
    $clangVersion = clang --version | Select-Object -First 1
    Write-Info "Clang: $clangVersion"
}

if (Test-Command "pio") {
    $pioVersion = pio --version
    Write-Info "PlatformIO: $pioVersion"
}

Write-Action "`n✨ Setup Complete!"
Write-Note "Next steps:"
Write-Info "1. Restart your terminal to apply PATH changes"
Write-Info "2. VS Code: Open and let PlatformIO extension complete installation"
Write-Info "3. Test ESP-IDF: Run 'C:\tools\esp-idf\export.ps1'"
Write-Info "4. Create ESP32 project: pio project init --board esp32dev"
Write-Info "5. Configure Oh My Posh theme as desired"
Write-Info "6. VS Code: Sign in with GitHub for Copilot activation"
Write-Info "7. Connect your ESP32 board and check device in Device Manager"
Write-Note "`nInstallation Paths:"
Write-Info "ESP-IDF: C:\tools\esp-idf"
Write-Info "ESP Tools: C:\tools\.espressif"
Write-Success "`nHappy ESP32 coding! 🚀"
