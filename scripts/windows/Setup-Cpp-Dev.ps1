<#
.SYNOPSIS
    Setup C++ development environment on Windows

.DESCRIPTION
    Configures the system for C++ development by installing:
    - Git version control
    - CMake build system
    - Ninja build system
    - vcpkg package manager
    - GCC compiler (via MinGW-w64)
    - MSVC Build Tools
    - LLVM/Clang compiler
    - Visual Studio Code with C++ extensions
    - Oh My Posh with user theme
    All tools are configured with proper PATH settings.

.PARAMETER SkipVisualStudio
    Skip Visual Studio Build Tools installation

.PARAMETER SkipUpdates
    Skip updating existing tools

.PARAMETER Verbose
    Show detailed output

.EXAMPLE
    .\Setup-Cpp-Dev.ps1
    .\Setup-Cpp-Dev.ps1 -Verbose
    .\Setup-Cpp-Dev.ps1 -SkipVisualStudio

.NOTES
    Requires administrator privileges for some installations
    Idempotent - safe to run multiple times
#>

param(
    [switch]$SkipVisualStudio,
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

Write-Action "🎯 Starting C++ Development Environment Setup"
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

# Install Ninja
Write-Action "Installing/Updating Ninja build system..."
if (-not (Test-Command "ninja")) {
    choco install ninja -y
    Write-Success "Ninja installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "Ninja already installed"
    if (-not $SkipUpdates) {
        choco upgrade ninja -y
    }
}

# Install MinGW-w64 (GCC)
Write-Action "Installing/Updating MinGW-w64 (GCC)..."
if (-not (Test-Command "g++")) {
    choco install mingw -y
    Write-Success "MinGW-w64 (GCC) installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "MinGW-w64 (GCC) already installed"
    if (-not $SkipUpdates) {
        choco upgrade mingw -y
    }
}

# Install LLVM (Clang)
Write-Action "Installing/Updating LLVM (Clang)..."
if (-not (Test-Command "clang")) {
    choco install llvm -y
    Write-Success "LLVM (Clang) installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "LLVM (Clang) already installed"
    if (-not $SkipUpdates) {
        choco upgrade llvm -y
    }
}

# Install Visual Studio Build Tools
if (-not $SkipVisualStudio) {
    Write-Action "Installing/Updating Visual Studio Build Tools..."
    
    $vsBuildToolsInstalled = $false
    $vsPaths = @(
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools"
    )
    
    foreach ($path in $vsPaths) {
        if (Test-Path $path) {
            $vsBuildToolsInstalled = $true
            break
        }
    }
    
    if (-not $vsBuildToolsInstalled) {
        Write-Info "Installing Visual Studio Build Tools 2022..."
        choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive"
        Write-Success "Visual Studio Build Tools installed"
    } else {
        Write-Success "Visual Studio Build Tools already installed"
    }
} else {
    Write-Info "Skipping Visual Studio Build Tools installation"
}

# Install vcpkg
Write-Action "Installing/Updating vcpkg..."
$vcpkgPath = "$env:USERPROFILE\vcpkg"
if (-not (Test-Path "$vcpkgPath\vcpkg.exe")) {
    Write-Info "Cloning vcpkg repository..."
    try {
        git clone https://github.com/microsoft/vcpkg.git $vcpkgPath
        Write-Info "Bootstrapping vcpkg..."
        & "$vcpkgPath\bootstrap-vcpkg.bat" -disableMetrics
        Add-ToPath $vcpkgPath
        
        # Integrate vcpkg with Visual Studio
        Write-Info "Integrating vcpkg with Visual Studio..."
        & "$vcpkgPath\vcpkg.exe" integrate install
        
        Write-Success "vcpkg installed and integrated"
    } catch {
        Write-Error-Custom "Failed to install vcpkg: $_"
        Write-Warning-Custom "Continuing without vcpkg..."
    }
} else {
    Write-Success "vcpkg already installed"
    Add-ToPath $vcpkgPath
    
    if (-not $SkipUpdates) {
        Write-Info "Updating vcpkg..."
        try {
            Push-Location $vcpkgPath
            git pull
            & "$vcpkgPath\bootstrap-vcpkg.bat" -disableMetrics
            Pop-Location
            Write-Success "vcpkg updated"
        } catch {
            Write-Warning-Custom "Failed to update vcpkg"
            Pop-Location
        }
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

# Install VS Code extensions for C++
Write-Action "Installing VS Code extensions..."
if (Test-Command "code") {
    $extensions = @(
        "ms-vscode.cpptools",
        "ms-vscode.cpptools-extension-pack",
        "ms-vscode.cmake-tools",
        "twxs.cmake",
        "llvm-vs-code-extensions.vscode-clangd",
        "vadimcn.vscode-lldb",
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

# Configure VS Code settings
Write-Action "Configuring VS Code C++ settings..."
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

# Get CMake path
$cmakePath = (Get-Command cmake -ErrorAction SilentlyContinue).Source
if ($cmakePath) {
    $settings | Add-Member -NotePropertyName "cmake.cmakePath" -NotePropertyValue $cmakePath -Force
}

# Get GCC path
$gccPath = (Get-Command gcc -ErrorAction SilentlyContinue).Source
$gppPath = (Get-Command g++ -ErrorAction SilentlyContinue).Source

# Get Clang path
$clangPath = (Get-Command clang -ErrorAction SilentlyContinue).Source
$clangppPath = (Get-Command clang++ -ErrorAction SilentlyContinue).Source

# Configure C++ IntelliSense
if ($gppPath) {
    $settings | Add-Member -NotePropertyName "C_Cpp.default.compilerPath" -NotePropertyValue $gppPath -Force
}

# Configure CMake generator
$settings | Add-Member -NotePropertyName "cmake.generator" -NotePropertyValue "Ninja" -Force
$settings | Add-Member -NotePropertyName "cmake.configureSettings" -NotePropertyValue @{
    "CMAKE_C_COMPILER" = $gccPath
    "CMAKE_CXX_COMPILER" = $gppPath
} -Force

# Configure Clangd
if ($clangPath) {
    $clangdPath = (Get-Command clangd -ErrorAction SilentlyContinue).Source
    if ($clangdPath) {
        $settings | Add-Member -NotePropertyName "clangd.path" -NotePropertyValue $clangdPath -Force
    }
}

# Configure vcpkg
if (Test-Path $vcpkgPath) {
    $settings | Add-Member -NotePropertyName "cmake.configureSettings" -NotePropertyValue @{
        "CMAKE_TOOLCHAIN_FILE" = "$vcpkgPath\scripts\buildsystems\vcpkg.cmake"
        "CMAKE_C_COMPILER" = $gccPath
        "CMAKE_CXX_COMPILER" = $gppPath
    } -Force
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $vscodeSettingsFile -Force
Write-Success "VS Code configured with C++ toolchain paths"

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

# Configure environment variables for C++ development
Write-Action "Configuring environment variables..."
if (Test-Path $vcpkgPath) {
    [Environment]::SetEnvironmentVariable("VCPKG_ROOT", $vcpkgPath, "User")
    $env:VCPKG_ROOT = $vcpkgPath
    Write-Success "VCPKG_ROOT set to: $vcpkgPath"
}

# Final summary
Write-Action "`n📊 Installation Summary"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

$tools = @{
    "Git" = (Test-Command "git")
    "CMake" = (Test-Command "cmake")
    "Ninja" = (Test-Command "ninja")
    "GCC (g++)" = (Test-Command "g++")
    "Clang" = (Test-Command "clang")
    "vcpkg" = (Test-Path "$vcpkgPath\vcpkg.exe")
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

# Display versions
Write-Action "`n📋 Installed Versions"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if (Test-Command "git") {
    $gitVersion = git --version
    Write-Info "Git: $gitVersion"
}

if (Test-Command "cmake") {
    $cmakeVersion = cmake --version | Select-Object -First 1
    Write-Info "CMake: $cmakeVersion"
}

if (Test-Command "ninja") {
    $ninjaVersion = ninja --version
    Write-Info "Ninja: $ninjaVersion"
}

if (Test-Command "g++") {
    $gccVersion = g++ --version | Select-Object -First 1
    Write-Info "GCC: $gccVersion"
}

if (Test-Command "clang") {
    $clangVersion = clang --version | Select-Object -First 1
    Write-Info "Clang: $clangVersion"
}

if (Test-Command "code") {
    $codeVersion = code --version | Select-Object -First 1
    Write-Info "VS Code: $codeVersion"
}

Write-Action "`n✨ Setup Complete!"
Write-Note "Next steps:"
Write-Info "1. Restart your terminal to apply all PATH changes"
Write-Info "2. Test CMake: cmake --version"
Write-Info "3. Test GCC: g++ --version"
Write-Info "4. Test Clang: clang --version"
Write-Info "5. Install packages with vcpkg: vcpkg install <package-name>"
Write-Info "6. Create a CMake project and configure with: cmake -B build -G Ninja"
Write-Info "7. VS Code: Sign in with GitHub for Copilot activation"
Write-Note "Sample vcpkg packages: fmt, nlohmann-json, boost, catch2, spdlog"
