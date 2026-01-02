<#
.SYNOPSIS
    Install Visual Studio Code with development tools and extensions.

.DESCRIPTION
    This script automates the installation of a complete development environment:
    - Visual Studio Code
    - Git version control
    - PowerShell 7 (latest)
    - Oh My Posh with Dracula theme
    - Docker (optional)
    - VS Code extensions (Dev Containers, Docker)
    All operations are idempotent and can be run multiple times safely.

.PARAMETER SkipDocker
    Skip Docker installation

.PARAMETER SkipDevContainers
    Skip Dev Containers extension installation

.PARAMETER SkipGit
    Skip Git installation

.PARAMETER SkipPowerShell
    Skip PowerShell 7 installation

.PARAMETER SkipOhMyPosh
    Skip Oh My Posh installation and configuration

.PARAMETER OhMyPoshTheme
    Oh My Posh theme to use (default: dracula)

.PARAMETER Help
    Display help information

.NOTES
    Author: PowerScripts
    Version: 1.0
    Requires: PowerShell 5.1 or higher, Administrator privileges
    
.EXAMPLE
    .\Install-VSCode.ps1
    Full installation with all components.

.EXAMPLE
    .\Install-VSCode.ps1 -SkipDocker
    Install without Docker.

.EXAMPLE
    .\Install-VSCode.ps1 -OhMyPoshTheme "paradox"
    Install with a different Oh My Posh theme.

.EXAMPLE
    .\Install-VSCode.ps1 -Help
    Displays help information.

.LINK
    https://code.visualstudio.com/
    https://git-scm.com/
    https://ohmyposh.dev/
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Skip Docker installation")]
    [switch]$SkipDocker,
    
    [Parameter(HelpMessage="Skip Dev Containers extension")]
    [switch]$SkipDevContainers,
    
    [Parameter(HelpMessage="Skip Git installation")]
    [switch]$SkipGit,
    
    [Parameter(HelpMessage="Skip PowerShell 7 installation")]
    [switch]$SkipPowerShell,
    
    [Parameter(HelpMessage="Skip Oh My Posh installation")]
    [switch]$SkipOhMyPosh,
    
    [Parameter(HelpMessage="Oh My Posh theme name")]
    [string]$OhMyPoshTheme = "dracula",
    
    [Parameter(HelpMessage="Display help information")]
    [Alias('h', '?')]
    [switch]$Help
)

#Requires -RunAsAdministrator

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# ================== CONFIGURATION ==================
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$Script:LogPath = "$env:TEMP\VSCodeInstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# VS Code Extensions
$Script:VSCodeExtensions = @(
    "ms-vscode-remote.remote-containers"  # Dev Containers
    "ms-azuretools.vscode-docker"         # Docker
    "ms-vscode.powershell"                # PowerShell
    "eamodio.gitlens"                     # GitLens
    "GitHub.copilot"                      # GitHub Copilot
    "GitHub.copilot-chat"                 # GitHub Copilot Chat
)

# ================== FUNCTIONS ==================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = "Info",
        [string]$Emoji = ""
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Add-Content -Path $Script:LogPath -Value $logMessage
    
    $color = switch ($Type) {
        "Success" { "Green" }
        "Error" { "Red" }
        "Warning" { "Yellow" }
        "Info" { "Cyan" }
        "Section" { "Magenta" }
        default { "White" }
    }
    
    Write-Host "$Emoji $Message" -ForegroundColor $color
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n" -NoNewline
    Write-Host ("=" * 80) -ForegroundColor Magenta
    Write-Host "  $Title" -ForegroundColor Magenta
    Write-Host ("=" * 80) -ForegroundColor Magenta
}

function Test-WingetAvailable {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Winget not found. Please install App Installer from Microsoft Store." "Error" "❌"
        return $false
    }
    return $true
}

function Install-Git {
    Write-SectionHeader "📦 GIT INSTALLATION"
    
    if ($SkipGit) {
        Write-ColorOutput "Git installation skipped" "Info" "⏭️"
        return
    }
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitVersion = git --version
        Write-ColorOutput "Git already installed: $gitVersion" "Success" "✅"
    }
    else {
        Write-ColorOutput "Installing Git..." "Info" "📥"
        winget install --id Git.Git --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Git installed successfully" "Success" "🎉"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }
        else {
            Write-ColorOutput "Git installation failed" "Error" "❌"
        }
    }
}

function Install-PowerShell7 {
    Write-SectionHeader "💻 POWERSHELL 7 INSTALLATION"
    
    if ($SkipPowerShell) {
        Write-ColorOutput "PowerShell 7 installation skipped" "Info" "⏭️"
        return
    }
    
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        $pwshVersion = pwsh --version
        Write-ColorOutput "PowerShell 7 already installed: $pwshVersion" "Success" "✅"
        
        Write-ColorOutput "Checking for updates..." "Info" "🔍"
        winget upgrade Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
    }
    else {
        Write-ColorOutput "Installing PowerShell 7..." "Info" "📥"
        winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "PowerShell 7 installed successfully" "Success" "🎉"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }
        else {
            Write-ColorOutput "PowerShell 7 installation failed" "Error" "❌"
        }
    }
}

function Install-OhMyPosh {
    Write-SectionHeader "🎨 OH MY POSH INSTALLATION"
    
    if ($SkipOhMyPosh) {
        Write-ColorOutput "Oh My Posh installation skipped" "Info" "⏭️"
        return
    }
    
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Write-ColorOutput "Oh My Posh already installed" "Success" "✅"
        
        Write-ColorOutput "Updating Oh My Posh..." "Info" "📥"
        winget upgrade JanDeDobbeleer.OhMyPosh --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
    }
    else {
        Write-ColorOutput "Installing Oh My Posh..." "Info" "📥"
        winget install JanDeDobbeleer.OhMyPosh --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Oh My Posh installed successfully" "Success" "🎉"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }
        else {
            Write-ColorOutput "Oh My Posh installation failed" "Error" "❌"
            return
        }
    }
    
    # Install Nerd Font
    Write-ColorOutput "Installing Cascadia Code Nerd Font..." "Info" "🔤"
    oh-my-posh font install CascadiaCode --user 2>&1 | Out-Null
    Write-ColorOutput "Font installed (may require terminal restart)" "Success" "✅"
}

function Configure-PowerShellProfile {
    Write-SectionHeader "⚙️ POWERSHELL PROFILE CONFIGURATION"
    
    if ($SkipOhMyPosh) {
        Write-ColorOutput "Profile configuration skipped" "Info" "⏭️"
        return
    }
    
    # Configure for PowerShell 7
    $pwshProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    
    # Create PowerShell directory if it doesn't exist
    $pwshDir = Split-Path $pwshProfilePath -Parent
    if (-not (Test-Path $pwshDir)) {
        New-Item -ItemType Directory -Path $pwshDir -Force | Out-Null
        Write-ColorOutput "Created PowerShell profile directory" "Success" "✅"
    }
    
    # Download theme configuration
    $themeConfigPath = "$pwshDir\$OhMyPoshTheme.omp.json"
    
    if (-not (Test-Path $themeConfigPath)) {
        Write-ColorOutput "Downloading $OhMyPoshTheme theme..." "Info" "📥"
        try {
            $themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$OhMyPoshTheme.omp.json"
            Invoke-WebRequest -Uri $themeUrl -OutFile $themeConfigPath -ErrorAction Stop
            Write-ColorOutput "Theme downloaded successfully" "Success" "✅"
        }
        catch {
            Write-ColorOutput "Failed to download theme, using built-in" "Warning" "⚠️"
            $themeConfigPath = "$OhMyPoshTheme"
        }
    }
    
    # Configure profile
    $profileContent = @"
# Oh My Posh initialization
oh-my-posh init pwsh --config "$themeConfigPath" | Invoke-Expression

# PSReadLine configuration for better command line editing
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Useful aliases
Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value docker-compose
Set-Alias -Name code -Value code-insiders -ErrorAction SilentlyContinue

# Welcome message
Write-Host "🚀 PowerShell 7 with Oh My Posh - $OhMyPoshTheme theme" -ForegroundColor Cyan
"@

    if (Test-Path $pwshProfilePath) {
        $existingContent = Get-Content $pwshProfilePath -Raw
        if ($existingContent -notmatch "oh-my-posh init") {
            Write-ColorOutput "Backing up existing profile..." "Info" "💾"
            Copy-Item $pwshProfilePath "$pwshProfilePath.backup" -Force
            
            Write-ColorOutput "Adding Oh My Posh to profile..." "Info" "✏️"
            Add-Content -Path $pwshProfilePath -Value "`n# Added by Install-VSCode script`n$profileContent"
            Write-ColorOutput "Profile updated" "Success" "✅"
        }
        else {
            Write-ColorOutput "Oh My Posh already configured in profile" "Success" "✅"
        }
    }
    else {
        Write-ColorOutput "Creating PowerShell profile..." "Info" "✏️"
        Set-Content -Path $pwshProfilePath -Value $profileContent
        Write-ColorOutput "Profile created" "Success" "✅"
    }
    
    # Also configure for Windows PowerShell
    $winPSProfilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    $winPSDir = Split-Path $winPSProfilePath -Parent
    
    if (-not (Test-Path $winPSDir)) {
        New-Item -ItemType Directory -Path $winPSDir -Force | Out-Null
    }
    
    if (-not (Test-Path $winPSProfilePath)) {
        Copy-Item $pwshProfilePath $winPSProfilePath -Force
        Write-ColorOutput "Windows PowerShell profile configured" "Success" "✅"
    }
}

function Install-VSCode {
    Write-SectionHeader "📝 VISUAL STUDIO CODE INSTALLATION"
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $codeVersion = code --version 2>$null | Select-Object -First 1
        Write-ColorOutput "VS Code already installed: $codeVersion" "Success" "✅"
        
        Write-ColorOutput "Checking for updates..." "Info" "🔍"
        winget upgrade Microsoft.VisualStudioCode --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
    }
    else {
        Write-ColorOutput "Installing Visual Studio Code..." "Info" "📥"
        winget install --id Microsoft.VisualStudioCode --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "VS Code installed successfully" "Success" "🎉"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            # Wait for VS Code to be available
            Start-Sleep -Seconds 5
        }
        else {
            Write-ColorOutput "VS Code installation failed" "Error" "❌"
            return
        }
    }
}

function Install-VSCodeExtensions {
    Write-SectionHeader "🔌 VS CODE EXTENSIONS"
    
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "VS Code not found, skipping extensions" "Warning" "⚠️"
        return
    }
    
    $extensionsToInstall = @()
    
    # Always install PowerShell and GitLens
    $extensionsToInstall += "ms-vscode.powershell"
    $extensionsToInstall += "eamodio.gitlens"
    
    # Add Dev Containers if not skipped
    if (-not $SkipDevContainers) {
        $extensionsToInstall += "ms-vscode-remote.remote-containers"
    }
    
    # Add Docker extension if Docker is being installed
    if (-not $SkipDocker) {
        $extensionsToInstall += "ms-azuretools.vscode-docker"
    }
    
    # Optional: GitHub Copilot (may require license)
    # $extensionsToInstall += "GitHub.copilot"
    # $extensionsToInstall += "GitHub.copilot-chat"
    
    foreach ($extension in $extensionsToInstall) {
        Write-ColorOutput "Installing extension: $extension..." "Info" "🔌"
        code --install-extension $extension --force 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Installed: $extension" "Success" "✅"
        }
        else {
            Write-ColorOutput "Failed to install: $extension" "Warning" "⚠️"
        }
    }
    
    Write-ColorOutput "Extensions installation completed" "Success" "🎉"
}

function Install-Docker {
    Write-SectionHeader "🐳 DOCKER INSTALLATION"
    
    if ($SkipDocker) {
        Write-ColorOutput "Docker installation skipped" "Info" "⏭️"
        return
    }
    
    # Check if Docker install script exists
    $dockerScriptPath = Join-Path $PSScriptRoot "Install-Docker.ps1"
    
    if (Test-Path $dockerScriptPath) {
        Write-ColorOutput "Running Docker installation script..." "Info" "🚀"
        & $dockerScriptPath
    }
    else {
        Write-ColorOutput "Docker installation script not found at: $dockerScriptPath" "Warning" "⚠️"
        Write-ColorOutput "Installing Docker Desktop via Winget..." "Info" "📥"
        
        if (Get-Command docker -ErrorAction SilentlyContinue) {
            Write-ColorOutput "Docker already installed" "Success" "✅"
        }
        else {
            winget install Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "Docker Desktop installed" "Success" "🎉"
            }
        }
    }
}

# ================== MAIN EXECUTION ==================

Write-Host "`n"
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host "█" -NoNewline -ForegroundColor Cyan
Write-Host "        📝 VISUAL STUDIO CODE - DEVELOPMENT ENVIRONMENT SETUP 📝       " -NoNewline -ForegroundColor White
Write-Host "█" -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host "`n"

Write-ColorOutput "Installation started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Info" "⏰"
Write-ColorOutput "Log file: $Script:LogPath" "Info" "📝"

Write-ColorOutput "Components to install:" "Section" "📋"
Write-ColorOutput "  Git: $(-not $SkipGit)" "Info" "$(if(-not $SkipGit){'✅'}else{'❌'})"
Write-ColorOutput "  PowerShell 7: $(-not $SkipPowerShell)" "Info" "$(if(-not $SkipPowerShell){'✅'}else{'❌'})"
Write-ColorOutput "  Oh My Posh ($OhMyPoshTheme): $(-not $SkipOhMyPosh)" "Info" "$(if(-not $SkipOhMyPosh){'✅'}else{'❌'})"
Write-ColorOutput "  Visual Studio Code: ✅" "Info" "✅"
Write-ColorOutput "  Dev Containers: $(-not $SkipDevContainers)" "Info" "$(if(-not $SkipDevContainers){'✅'}else{'❌'})"
Write-ColorOutput "  Docker: $(-not $SkipDocker)" "Info" "$(if(-not $SkipDocker){'✅'}else{'❌'})"

if (-not (Test-WingetAvailable)) {
    Write-ColorOutput "Installation cannot continue without Winget" "Error" "❌"
    exit 1
}

# Execute installations
Install-Git
Install-PowerShell7
Install-OhMyPosh
Configure-PowerShellProfile
Install-VSCode
Install-VSCodeExtensions
Install-Docker

Write-SectionHeader "📊 INSTALLATION SUMMARY"
Write-ColorOutput "Development environment setup completed!" "Success" "🎉"
Write-ColorOutput "Next steps:" "Info" "📝"
Write-ColorOutput "  1. Restart your terminal to apply changes" "Info" "  →"
Write-ColorOutput "  2. Launch PowerShell 7 (pwsh)" "Info" "  →"
Write-ColorOutput "  3. Verify Oh My Posh: The prompt should show the $OhMyPoshTheme theme" "Info" "  →"
Write-ColorOutput "  4. Open VS Code: code ." "Info" "  →"
Write-ColorOutput "  5. Configure font in terminal settings (Cascadia Code NF recommended)" "Info" "  →"

if (-not $SkipDocker) {
    Write-ColorOutput "  6. Start Docker Desktop and complete initial setup" "Info" "  →"
    Write-ColorOutput "  7. Test: docker run hello-world" "Info" "  →"
}

Write-ColorOutput "Full log available at: $Script:LogPath" "Info" "📝"

Write-Host "`n"
Write-Host ("═" * 80) -ForegroundColor Green
Write-Host "  ✨ DEVELOPMENT ENVIRONMENT READY! ✨" -ForegroundColor Green
Write-Host ("═" * 80) -ForegroundColor Green
Write-Host "`n"
