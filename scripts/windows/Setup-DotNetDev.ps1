<#
.SYNOPSIS
    Setup .NET development environment on Windows

.DESCRIPTION
    Configures the system for .NET development by installing and configuring:
    - Git version control
    - PowerShell 7 (latest version)
    - Oh My Posh with automatic initialization and user theme
    - Visual Studio Code with C# extensions
    - Hyper-V (verification and enablement)
    - WSL2 with default Ubuntu distribution
    - Docker Desktop
    - .NET SDK (latest version: .NET 10, plus .NET 8 LTS)
    - Visual Studio (optional, default: yes)
    - JetBrains Rider (optional, default: no)
    
    All tools are configured with proper PATH settings and integrations.

.PARAMETER SkipVisualStudio
    Skip Visual Studio installation (default: install)

.PARAMETER InstallRider
    Install JetBrains Rider (default: no)

.PARAMETER SkipUpdates
    Skip updating existing tools

.PARAMETER SkipDocker
    Skip Docker Desktop installation

.PARAMETER Verbose
    Show detailed output

.EXAMPLE
    .\Setup-DotNetDev.ps1
    
.EXAMPLE
    .\Setup-DotNetDev.ps1 -SkipVisualStudio
    
.EXAMPLE
    .\Setup-DotNetDev.ps1 -InstallRider
    
.EXAMPLE
    .\Setup-DotNetDev.ps1 -SkipVisualStudio -InstallRider -SkipDocker

.NOTES
    Requires administrator privileges
    Idempotent - safe to run multiple times
    Reboot may be required for Hyper-V/WSL features
#>

param(
    [switch]$SkipVisualStudio,
    [switch]$InstallRider,
    [switch]$SkipUpdates,
    [switch]$SkipDocker,
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

# Check if Windows feature is enabled
function Test-WindowsFeature {
    param([string]$FeatureName)
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction SilentlyContinue
    return $feature -and $feature.State -eq "Enabled"
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

Write-Action "🎯 Starting .NET Development Environment Setup"
Write-Info "Platform: Windows"

# Check for administrator privileges
if (-not (Test-Administrator)) {
    Write-Error-Custom "This script requires administrator privileges"
    Write-Note "Please run PowerShell as Administrator and try again"
    exit 1
}

$rebootRequired = $false

# Install Chocolatey if not present
Write-Action "Checking Chocolatey package manager..."
if (-not (Test-Command "choco")) {
    Write-Info "Installing Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Success "Chocolatey installed"
        
        # Refresh environment
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

# Install VS Code extensions
Write-Action "Installing VS Code extensions..."
if (Test-Command "code") {
    $extensions = @(
        "ms-dotnettools.csharp",
        "ms-dotnettools.csdevkit",
        "ms-dotnettools.vscode-dotnet-runtime",
        "ms-vscode.powershell",
        "eamodio.gitlens",
        "ms-vscode-remote.remote-containers",
        "ms-azuretools.vscode-docker",
        "GitHub.copilot",
        "GitHub.copilot-chat"
    )
    foreach ($ext in $extensions) {
        Write-Info "Installing extension: $ext"
        code --install-extension $ext --force 2>$null
    }
    Write-Success "VS Code extensions installed"
}

# Check and enable Hyper-V
Write-Action "Checking Hyper-V..."
$hyperVFeatures = @("Microsoft-Hyper-V-All", "Microsoft-Hyper-V", "Microsoft-Hyper-V-Management-PowerShell")
$hyperVEnabled = $true

foreach ($feature in $hyperVFeatures) {
    if (-not (Test-WindowsFeature $feature)) {
        $hyperVEnabled = $false
        break
    }
}

if (-not $hyperVEnabled) {
    Write-Info "Enabling Hyper-V..."
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
        Write-Success "Hyper-V enabled"
        $rebootRequired = $true
    } catch {
        Write-Warning-Custom "Failed to enable Hyper-V: $_"
        Write-Note "You may need to enable it manually or your system may not support it"
    }
} else {
    Write-Success "Hyper-V is already enabled"
}

# Check and enable WSL
Write-Action "Checking WSL..."
if (-not (Test-WindowsFeature "Microsoft-Windows-Subsystem-Linux")) {
    Write-Info "Enabling WSL..."
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        Write-Success "WSL enabled"
        $rebootRequired = $true
    } catch {
        Write-Error-Custom "Failed to enable WSL: $_"
    }
} else {
    Write-Success "WSL is already enabled"
}

# Check and enable Virtual Machine Platform for WSL2
Write-Action "Checking Virtual Machine Platform..."
if (-not (Test-WindowsFeature "VirtualMachinePlatform")) {
    Write-Info "Enabling Virtual Machine Platform..."
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        Write-Success "Virtual Machine Platform enabled"
        $rebootRequired = $true
    } catch {
        Write-Error-Custom "Failed to enable Virtual Machine Platform: $_"
    }
} else {
    Write-Success "Virtual Machine Platform is already enabled"
}

# Install WSL2 and default distribution
Write-Action "Configuring WSL2..."
if (Test-Command "wsl") {
    # Set WSL2 as default
    try {
        wsl --set-default-version 2 2>$null
        Write-Success "WSL2 set as default version"
    } catch {
        Write-Info "WSL2 default version already set"
    }
    
    # Check if Ubuntu is installed
    $wslList = wsl --list --quiet 2>$null
    if ($wslList -notmatch "Ubuntu") {
        Write-Info "Installing Ubuntu distribution..."
        try {
            wsl --install -d Ubuntu --no-launch
            Write-Success "Ubuntu distribution installed"
        } catch {
            Write-Warning-Custom "Failed to install Ubuntu. You may need to install it manually from Microsoft Store"
        }
    } else {
        Write-Success "Ubuntu distribution already installed"
        
        # Update WSL distribution
        if (-not $SkipUpdates) {
            Write-Info "Updating WSL distribution..."
            wsl -d Ubuntu -e sudo apt-get update 2>$null
            wsl -d Ubuntu -e sudo apt-get upgrade -y 2>$null
            Write-Success "WSL distribution updated"
        }
    }
} else {
    Write-Warning-Custom "WSL command not available. A reboot may be required."
    $rebootRequired = $true
}

# Install .NET SDK
Write-Action "Installing/Updating .NET SDK..."

# Install latest .NET SDK using winget (more up-to-date than chocolatey)
if (-not (Test-Command "dotnet")) {
    Write-Info "Installing latest .NET SDK via winget..."
    if (Test-Command "winget") {
        winget install Microsoft.DotNet.SDK.10 --silent --accept-source-agreements --accept-package-agreements
        Write-Success ".NET SDK installed"
    } else {
        Write-Info "Winget not available, using Chocolatey..."
        choco install dotnet-sdk -y
        Write-Success ".NET SDK installed"
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success ".NET SDK already installed"
    
    if (-not $SkipUpdates) {
        Write-Info "Updating .NET SDK to latest version..."
        if (Test-Command "winget") {
            # Upgrade to latest .NET SDK
            winget upgrade Microsoft.DotNet.SDK.10 --silent --accept-source-agreements --accept-package-agreements 2>$null
            Write-Success ".NET SDK updated"
        } else {
            choco upgrade dotnet-sdk -y
        }
    }
}

# Install .NET 8 LTS (if not present)
Write-Action "Checking .NET 8 LTS..."
$dotnetSdks = ""
if (Test-Command "dotnet") {
    $dotnetSdks = dotnet --list-sdks 2>$null | Out-String
}

if ($dotnetSdks -notmatch "8\.0\.") {
    Write-Info "Installing .NET 8 LTS..."
    if (Test-Command "winget") {
        winget install Microsoft.DotNet.SDK.8 --silent --accept-source-agreements --accept-package-agreements 2>$null
        Write-Success ".NET 8 LTS installed"
    } else {
        choco install dotnet-8.0-sdk -y 2>$null
        Write-Success ".NET 8 LTS installed"
    }
} else {
    Write-Success ".NET 8 LTS already installed"
}

# Install .NET 10 (latest) if available
Write-Action "Checking .NET 10 (latest)..."
if ($dotnetSdks -notmatch "10\.0\.") {
    Write-Info "Installing .NET 10 (latest)..."
    if (Test-Command "winget") {
        $result = winget install Microsoft.DotNet.SDK.10 --silent --accept-source-agreements --accept-package-agreements 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success ".NET 10 installed"
        } else {
            Write-Info ".NET 10 not yet available or already installed"
        }
    }
} else {
    Write-Success ".NET 10 already installed"
}

# Display .NET info
if (Test-Command "dotnet") {
    Write-Info "Installed .NET SDKs:"
    dotnet --list-sdks
    Write-Info "`nInstalled .NET Runtimes:"
    dotnet --list-runtimes
}

# Install Docker Desktop
if (-not $SkipDocker) {
    Write-Action "Installing/Updating Docker Desktop..."
    if (-not (Test-Path "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe")) {
        choco install docker-desktop -y
        Write-Success "Docker Desktop installed"
        Write-Note "Docker Desktop will start automatically. Complete the setup wizard."
    } else {
        Write-Success "Docker Desktop already installed"
        if (-not $SkipUpdates) {
            choco upgrade docker-desktop -y
        }
    }
} else {
    Write-Info "Skipping Docker Desktop installation"
}

# Install Visual Studio
if (-not $SkipVisualStudio) {
    Write-Action "Installing/Updating Visual Studio..."
    
    $vsInstalled = $false
    $vsPaths = @(
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community"
    )
    
    foreach ($path in $vsPaths) {
        if (Test-Path $path) {
            $vsInstalled = $true
            break
        }
    }
    
    if (-not $vsInstalled) {
        Write-Info "Installing Visual Studio 2022 Community..."
        choco install visualstudio2022community -y --package-parameters "--allWorkloads --includeRecommended --passive"
        Write-Success "Visual Studio 2022 installed"
        Write-Note "Visual Studio workloads: .NET desktop, ASP.NET, Azure, etc."
    } else {
        Write-Success "Visual Studio already installed"
        if (-not $SkipUpdates) {
            Write-Info "Note: Visual Studio updates should be done through Visual Studio Installer"
        }
    }
} else {
    Write-Info "Skipping Visual Studio installation"
}

# Install JetBrains Rider
if ($InstallRider) {
    Write-Action "Installing/Updating JetBrains Rider..."
    if (-not (Test-Path "$env:ProgramFiles\JetBrains\Rider*")) {
        choco install jetbrainstoolbox -y
        Write-Success "JetBrains Toolbox installed"
        Write-Note "Use JetBrains Toolbox to install and manage Rider"
    } else {
        Write-Success "JetBrains Rider path found"
        if (-not $SkipUpdates) {
            choco upgrade jetbrainstoolbox -y
        }
    }
} else {
    Write-Info "Skipping JetBrains Rider installation"
}

# Install additional useful tools
Write-Action "Installing additional development tools..."

# NuGet CLI
if (-not (Test-Command "nuget")) {
    choco install nuget.commandline -y
    Write-Success "NuGet CLI installed"
} else {
    Write-Success "NuGet CLI already installed"
}

# Azure CLI
if (-not (Test-Command "az")) {
    choco install azure-cli -y
    Write-Success "Azure CLI installed"
} else {
    Write-Success "Azure CLI already installed"
}

# Install Node.js for GitHub Copilot CLI
Write-Action "Installing Node.js for GitHub Copilot CLI..."
if (-not (Test-Command "node")) {
    choco install nodejs -y
    Write-Success "Node.js installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "Node.js already installed"
}

# Install GitHub Copilot CLI
Write-Action "Installing GitHub Copilot CLI..."
if (-not (Test-Command "github-copilot-cli")) {
    Write-Info "Installing GitHub Copilot CLI via npm..."
    npm install -g @githubnext/github-copilot-cli
    Write-Success "GitHub Copilot CLI installed"
    Write-Note "Run 'github-copilot-cli auth' to authenticate with GitHub"
} else {
    Write-Success "GitHub Copilot CLI already installed"
}

# Final summary
Write-Action "`n📊 Installation Summary"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

$tools = @{
    "Git" = (Test-Command "git")
    "PowerShell 7" = (Test-Path "$env:ProgramFiles\PowerShell\7")
    "Oh My Posh" = (Test-Command "oh-my-posh")
    "VS Code" = (Test-Command "code")
    ".NET SDK" = (Test-Command "dotnet")
    "Node.js" = (Test-Command "node")
    "GitHub Copilot CLI" = (Test-Command "github-copilot-cli")
    "Hyper-V" = (Test-WindowsFeature "Microsoft-Hyper-V-All")
    "WSL" = (Test-WindowsFeature "Microsoft-Windows-Subsystem-Linux")
    "Docker Desktop" = (Test-Path "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe")
}

foreach ($tool in $tools.GetEnumerator()) {
    if ($tool.Value) {
        Write-Success "$($tool.Key) is ready"
    } else {
        Write-Warning-Custom "$($tool.Key) needs attention"
    }
}

# Check Visual Studio
if (-not $SkipVisualStudio) {
    $vsFound = $false
    foreach ($path in $vsPaths) {
        if (Test-Path $path) {
            $vsFound = $true
            break
        }
    }
    if ($vsFound) {
        Write-Success "Visual Studio is ready"
    } else {
        Write-Warning-Custom "Visual Studio needs attention"
    }
}

# Display versions
Write-Action "`n📋 Installed Versions"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if (Test-Command "git") {
    $gitVersion = git --version
    Write-Info "Git: $gitVersion"
}

if (Test-Path "$env:ProgramFiles\PowerShell\7") {
    $pwshVersion = & "$env:ProgramFiles\PowerShell\7\pwsh.exe" -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
    Write-Info "PowerShell: $pwshVersion"
}

if (Test-Command "dotnet") {
    $dotnetVersion = dotnet --version
    Write-Info ".NET SDK: $dotnetVersion"
}

if (Test-Command "code") {
    $codeVersion = code --version | Select-Object -First 1
    Write-Info "VS Code: $codeVersion"
}

if (Test-Command "node") {
    $nodeVersion = node --version
    Write-Info "Node.js: $nodeVersion"
}

# Reboot notification
if ($rebootRequired) {
    Write-Action "`n⚠️  REBOOT REQUIRED"
    Write-Warning-Custom "Some features (Hyper-V, WSL) require a system reboot to complete installation"
    Write-Note "Please save your work and reboot your computer"
    
    $response = Read-Host "`nWould you like to reboot now? (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Action "Rebooting system in 10 seconds..."
        Write-Note "Press Ctrl+C to cancel"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

Write-Action "`n✨ Setup Complete!"
Write-Note "Next steps:"
Write-Info "1. Restart your terminal to apply PATH changes"
Write-Info "2. Run 'dotnet --info' to verify .NET installation"
Write-Info "3. Configure Oh My Posh theme: oh-my-posh config export"
Write-Info "4. Open Docker Desktop and complete initial setup"
Write-Info "5. Run 'wsl' to complete Ubuntu setup (username/password)"
Write-Info "6. Authenticate GitHub Copilot CLI: github-copilot-cli auth"
Write-Info "7. VS Code: Sign in with GitHub for Copilot activation"
if (-not $SkipVisualStudio) {
    Write-Info "8. Open Visual Studio and sign in with your Microsoft account"
}
if ($InstallRider) {
    Write-Info "9. Open JetBrains Toolbox and install Rider"
}
Write-Success "`nHappy coding! 🚀"
