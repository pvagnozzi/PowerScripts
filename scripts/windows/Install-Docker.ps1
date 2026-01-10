<#
.SYNOPSIS
    Install Docker Desktop on Windows with all necessary prerequisites.

.DESCRIPTION
    This script automates the installation of Docker Desktop for Windows including:
    - WSL2 installation and configuration
    - WSL2 updates to latest version
    - Ubuntu installation and system updates
    - Hyper-V enablement verification
    - Docker Desktop installation via Winget
    - Post-installation configuration
    All operations are idempotent and can be run multiple times safely.

.PARAMETER SkipWSL
    Skip WSL2 installation and configuration

.PARAMETER SkipHyperV
    Skip Hyper-V verification and enablement

.PARAMETER SkipDocker
    Skip Docker Desktop installation (useful for testing prerequisites only)

.PARAMETER Help
    Display help information

.NOTES
    Author: PowerScripts
    Version: 1.0
    Requires: PowerShell 5.1 or higher, Administrator privileges, Windows 10/11 Pro/Enterprise
    
.EXAMPLE
    .\Install-Docker.ps1
    Installs Docker Desktop with all prerequisites.

.EXAMPLE
    .\Install-Docker.ps1 -SkipWSL
    Installs Docker Desktop without WSL2 configuration.

.EXAMPLE
    .\Install-Docker.ps1 -Help
    Displays help information.

.LINK
    https://docs.docker.com/desktop/install/windows-install/
    https://docs.microsoft.com/en-us/windows/wsl/install
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Skip WSL2 installation and configuration")]
    [switch]$SkipWSL,
    
    [Parameter(HelpMessage="Skip Hyper-V verification and enablement")]
    [switch]$SkipHyperV,
    
    [Parameter(HelpMessage="Skip Docker Desktop installation")]
    [switch]$SkipDocker,
    
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
$Script:LogPath = "$env:TEMP\DockerInstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Script:NeedsReboot = $false

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

function Test-WindowsVersion {
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $build = [System.Environment]::OSVersion.Version.Build
    
    Write-ColorOutput "Windows Version: $($osInfo.Caption) (Build $build)" "Info" "ℹ️"
    
    if ($build -lt 19041) {
        Write-ColorOutput "Docker Desktop requires Windows 10 version 2004 or higher (Build 19041+)" "Error" "❌"
        return $false
    }
    
    return $true
}

function Test-WindowsEdition {
    $osInfo = Get-CimInstance Win32_OperatingSystem
    
    if ($osInfo.Caption -match "Home") {
        Write-ColorOutput "Windows Home edition detected. WSL2 backend will be used." "Warning" "⚠️"
        return "Home"
    }
    
    return "ProOrEnterprise"
}

function Enable-HyperV {
    Write-SectionHeader "🖥️ HYPER-V VERIFICATION"
    
    if ($SkipHyperV) {
        Write-ColorOutput "Hyper-V check skipped (--SkipHyperV flag)" "Info" "⏭️"
        return
    }
    
    $edition = Test-WindowsEdition
    if ($edition -eq "Home") {
        Write-ColorOutput "Hyper-V not available on Windows Home edition" "Info" "ℹ️"
        return
    }
    
    $hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
    
    if ($hyperv.State -eq "Enabled") {
        Write-ColorOutput "Hyper-V is already enabled" "Success" "✅"
    }
    else {
        Write-ColorOutput "Enabling Hyper-V..." "Info" "🔧"
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart -ErrorAction Stop | Out-Null
            Write-ColorOutput "Hyper-V enabled successfully" "Success" "✅"
            $Script:NeedsReboot = $true
        }
        catch {
            Write-ColorOutput "Failed to enable Hyper-V: $($_.Exception.Message)" "Error" "❌"
            Write-ColorOutput "You may need to enable it manually in BIOS/UEFI" "Warning" "⚠️"
        }
    }
    
    $containers = Get-WindowsOptionalFeature -FeatureName Containers -Online
    if ($containers.State -ne "Enabled") {
        Write-ColorOutput "Enabling Windows Containers feature..." "Info" "🔧"
        Enable-WindowsOptionalFeature -Online -FeatureName Containers -NoRestart -ErrorAction SilentlyContinue | Out-Null
    }
}

function Install-WSL2 {
    Write-SectionHeader "🐧 WSL2 INSTALLATION"
    
    if ($SkipWSL) {
        Write-ColorOutput "WSL2 installation skipped (--SkipWSL flag)" "Info" "⏭️"
        return
    }
    
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    
    if ($wslFeature.State -ne "Enabled") {
        Write-ColorOutput "Enabling WSL feature..." "Info" "🔧"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
        Write-ColorOutput "WSL feature enabled" "Success" "✅"
        $Script:NeedsReboot = $true
    }
    else {
        Write-ColorOutput "WSL feature is already enabled" "Success" "✅"
    }
    
    $vmPlatform = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    
    if ($vmPlatform.State -ne "Enabled") {
        Write-ColorOutput "Enabling Virtual Machine Platform..." "Info" "🔧"
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
        Write-ColorOutput "Virtual Machine Platform enabled" "Success" "✅"
        $Script:NeedsReboot = $true
    }
    else {
        Write-ColorOutput "Virtual Machine Platform is already enabled" "Success" "✅"
    }
    
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        Write-ColorOutput "Checking WSL version..." "Info" "🔍"
        $wslVersion = wsl --status 2>&1 | Select-String "Default Version" | Out-String
        
        if ($wslVersion -match "2") {
            Write-ColorOutput "WSL2 is already the default version" "Success" "✅"
        }
        else {
            Write-ColorOutput "Setting WSL2 as default version..." "Info" "🔧"
            wsl --set-default-version 2 2>&1 | Out-Null
            Write-ColorOutput "WSL2 set as default version" "Success" "✅"
        }
        
        Write-ColorOutput "Updating WSL kernel and components..." "Info" "📥"
        try {
            wsl --update 2>&1 | Out-Null
            Write-ColorOutput "WSL updated successfully" "Success" "✅"
        }
        catch {
            Write-ColorOutput "WSL update completed with warnings" "Warning" "⚠️"
        }
    }
    else {
        Write-ColorOutput "Installing WSL..." "Info" "📥"
        try {
            wsl --install --no-distribution 2>&1 | Out-Null
            Write-ColorOutput "WSL installed successfully" "Success" "✅"
            $Script:NeedsReboot = $true
        }
        catch {
            Write-ColorOutput "WSL installation requires a reboot to complete" "Warning" "⚠️"
            $Script:NeedsReboot = $true
        }
    }
}

function Install-Ubuntu {
    Write-SectionHeader "🐧 UBUNTU INSTALLATION"
    
    if ($SkipWSL) {
        Write-ColorOutput "Ubuntu installation skipped (WSL disabled)" "Info" "⏭️"
        return
    }
    
    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "WSL not available. Ubuntu installation will be completed after reboot." "Warning" "⚠️"
        return
    }
    
    Write-ColorOutput "Checking for installed WSL distributions..." "Info" "🔍"
    $wslList = wsl --list --quiet 2>&1 | Where-Object { $_ -match '\S' }
    
    $hasUbuntu = $false
    if ($wslList) {
        foreach ($distro in $wslList) {
            if ($distro -match "Ubuntu") {
                $hasUbuntu = $true
                Write-ColorOutput "Ubuntu is already installed: $distro" "Success" "✅"
                break
            }
        }
    }
    
    if (-not $hasUbuntu) {
        Write-ColorOutput "Ubuntu not found. Installing Ubuntu..." "Info" "📥"
        try {
            wsl --install -d Ubuntu 2>&1 | Out-Null
            Write-ColorOutput "Ubuntu installation initiated" "Success" "✅"
            Write-ColorOutput "You will need to create a user account on first Ubuntu launch" "Info" "ℹ️"
        }
        catch {
            Write-ColorOutput "Error installing Ubuntu: $($_.Exception.Message)" "Error" "❌"
            Write-ColorOutput "You can install it manually after reboot with: wsl --install -d Ubuntu" "Info" "💡"
        }
    }
    
    if ($hasUbuntu) {
        Write-ColorOutput "Updating Ubuntu system packages..." "Info" "📦"
        try {
            wsl -d Ubuntu -e bash -c "sudo apt-get update -qq && sudo apt-get upgrade -y -qq" 2>&1 | Out-Null
            Write-ColorOutput "Ubuntu packages updated successfully" "Success" "✅"
        }
        catch {
            Write-ColorOutput "Ubuntu update requires manual completion" "Warning" "⚠️"
            Write-ColorOutput "Run: wsl -d Ubuntu -e bash -c 'sudo apt-get update && sudo apt-get upgrade -y'" "Info" "💡"
        }
    }
}

function Install-DockerDesktop {
    Write-SectionHeader "🐳 DOCKER DESKTOP INSTALLATION"
    
    if ($SkipDocker) {
        Write-ColorOutput "Docker Desktop installation skipped (--SkipDocker flag)" "Info" "⏭️"
        return
    }
    
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-ColorOutput "Docker is already installed: $dockerVersion" "Success" "✅"
            Write-ColorOutput "Checking for updates..." "Info" "🔍"
        }
    }
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Winget not found. Installing Docker Desktop manually is required." "Error" "❌"
        Write-ColorOutput "Please download from: https://docs.docker.com/desktop/install/windows-install/" "Info" "🔗"
        return
    }
    
    Write-ColorOutput "Installing Docker Desktop via Winget..." "Info" "📥"
    try {
        $result = winget install Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements 2>&1
        
        if ($LASTEXITCODE -eq 0 -or $result -match "successfully") {
            Write-ColorOutput "Docker Desktop installed successfully" "Success" "🎉"
            Write-ColorOutput "Docker Desktop will start automatically after reboot" "Info" "ℹ️"
        }
        elseif ($result -match "already installed") {
            Write-ColorOutput "Docker Desktop is already installed" "Success" "✅"
            
            Write-ColorOutput "Checking for Docker Desktop updates..." "Info" "🔍"
            winget upgrade Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "Docker Desktop updated successfully" "Success" "✅"
            }
        }
        else {
            Write-ColorOutput "Docker Desktop installation completed with warnings" "Warning" "⚠️"
        }
    }
    catch {
        Write-ColorOutput "Error during Docker Desktop installation: $($_.Exception.Message)" "Error" "❌"
    }
}

function Set-DockerConfiguration {
    Write-SectionHeader "⚙️ DOCKER CONFIGURATION"
    
    if ($SkipDocker) {
        return
    }
    
    $dockerConfigPath = "$env:APPDATA\Docker\settings.json"
    
    if (Test-Path $dockerConfigPath) {
        Write-ColorOutput "Docker configuration file found" "Success" "✅"
        Write-ColorOutput "Location: $dockerConfigPath" "Info" "📁"
    }
    else {
        Write-ColorOutput "Docker Desktop not yet configured (first run required)" "Info" "ℹ️"
    }
    
    Write-ColorOutput "Recommended settings:" "Info" "📝"
    Write-ColorOutput "  • Enable WSL2 integration" "Info" "  →"
    Write-ColorOutput "  • Allocate sufficient memory (4GB+ recommended)" "Info" "  →"
    Write-ColorOutput "  • Enable Kubernetes (optional)" "Info" "  →"
}

# ================== MAIN EXECUTION ==================

Write-Host "`n"
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host "█" -NoNewline -ForegroundColor Cyan
Write-Host "           🐳 DOCKER DESKTOP FOR WINDOWS - INSTALLER 🐳              " -NoNewline -ForegroundColor White
Write-Host "█" -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host "`n"

Write-ColorOutput "Installation started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Info" "⏰"
Write-ColorOutput "Log file: $Script:LogPath" "Info" "📝"

Write-ColorOutput "Enabled Operations:" "Section" "📋"
Write-ColorOutput "  Hyper-V Check: $(-not $SkipHyperV)" "Info" "$(if(-not $SkipHyperV){'✅'}else{'❌'})"
Write-ColorOutput "  WSL2 Installation: $(-not $SkipWSL)" "Info" "$(if(-not $SkipWSL){'✅'}else{'❌'})"
Write-ColorOutput "  Docker Desktop: $(-not $SkipDocker)" "Info" "$(if(-not $SkipDocker){'✅'}else{'❌'})"

Write-SectionHeader "🔍 SYSTEM VERIFICATION"

if (-not (Test-WindowsVersion)) {
    Write-ColorOutput "System requirements not met. Exiting." "Error" "❌"
    exit 1
}

Write-ColorOutput "System requirements met" "Success" "✅"

Enable-HyperV
Install-WSL2
Install-Ubuntu
Install-DockerDesktop
Set-DockerConfiguration

Write-SectionHeader "📊 INSTALLATION SUMMARY"

if ($Script:NeedsReboot) {
    Write-ColorOutput "REBOOT REQUIRED to complete installation!" "Warning" "🔄"
    Write-ColorOutput "After reboot:" "Info" "📝"
    Write-ColorOutput "  1. Start Docker Desktop from Start Menu" "Info" "  →"
    Write-ColorOutput "  2. Complete initial setup wizard" "Info" "  →"
    Write-ColorOutput "  3. Verify installation: docker --version" "Info" "  →"
    
    Write-Host "`n"
    $response = Read-Host "Reboot now? (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-ColorOutput "Rebooting system in 10 seconds..." "Warning" "🔄"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}
else {
    Write-ColorOutput "Installation completed successfully!" "Success" "🎉"
    Write-ColorOutput "Next steps:" "Info" "📝"
    Write-ColorOutput "  1. Start Docker Desktop from Start Menu" "Info" "  →"
    Write-ColorOutput "  2. Wait for Docker to initialize" "Info" "  →"
    Write-ColorOutput "  3. Verify: docker --version" "Info" "  →"
    Write-ColorOutput "  4. Test: docker run hello-world" "Info" "  →"
}

Write-ColorOutput "Full log available at: $Script:LogPath" "Info" "📝"

Write-Host "`n"
Write-Host ("═" * 80) -ForegroundColor Green
Write-Host "  ✨ DOCKER DESKTOP INSTALLATION PROCESS COMPLETED ✨" -ForegroundColor Green
Write-Host ("═" * 80) -ForegroundColor Green
Write-Host "`n"
