<#
.SYNOPSIS
    Comprehensive Windows system update and maintenance script with full automation.

.DESCRIPTION
    This script performs a complete system update cycle including:
    - Windows Updates installation
    - System health checks (DISM, SFC)
    - Winget package updates
    - Chocolatey package updates (if installed)
    - Scoop package updates (if installed)
    - Microsoft Store app updates
    All operations run unattended without user prompts.

.PARAMETER WindowsUpdate
    Enable/disable Windows Updates (default: $true)

.PARAMETER SystemHealth
    Enable/disable system health checks (DISM, SFC) (default: $true)

.PARAMETER Winget
    Enable/disable Winget package updates (default: $true)

.PARAMETER Chocolatey
    Enable/disable Chocolatey package updates (default: $true)

.PARAMETER Scoop
    Enable/disable Scoop package updates (default: $true)

.PARAMETER MicrosoftStore
    Enable/disable Microsoft Store app updates (default: $true)

.PARAMETER Help
    Display help information

.NOTES
    Author: System Administrator
    Version: 2.0
    Requires: PowerShell 5.1 or higher, Administrator privileges
    
.EXAMPLE
    .\Windows-Check-Health.ps1
    Executes all update and maintenance tasks automatically.

.EXAMPLE
    .\Windows-Check-Health.ps1 -WindowsUpdate:$false -SystemHealth:$false
    Runs only package manager updates (Winget, Chocolatey, Scoop, Store)

.EXAMPLE
    .\Windows-Check-Health.ps1 -Winget -Chocolatey:$false -Scoop:$false
    Runs only Windows Updates, System Health checks, Winget and Microsoft Store updates

.EXAMPLE
    .\Windows-Check-Health.ps1 -Help
    Displays help information

.LINK
    https://github.com/microsoft/winget-cli
    https://chocolatey.org
    https://scoop.sh
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Enable/disable Windows Updates")]
    [switch]$WindowsUpdate = $true,
    
    [Parameter(HelpMessage="Enable/disable system health checks (DISM, SFC)")]
    [switch]$SystemHealth = $true,
    
    [Parameter(HelpMessage="Enable/disable Winget package updates")]
    [switch]$Winget = $true,
    
    [Parameter(HelpMessage="Enable/disable Chocolatey package updates")]
    [switch]$Chocolatey = $true,
    
    [Parameter(HelpMessage="Enable/disable Scoop package updates")]
    [switch]$Scoop = $true,
    
    [Parameter(HelpMessage="Enable/disable Microsoft Store app updates")]
    [switch]$MicrosoftStore = $true,
    
    [Parameter(HelpMessage="Display help information")]
    [Alias('h', '?')]
    [switch]$Help
)

#Requires -RunAsAdministrator

# Show help if requested
if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# ================== CONFIGURATION ==================
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$Script:LogPath = "$env:TEMP\SystemUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

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

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-PSWindowsUpdate {
    Write-ColorOutput "🔍 Checking for PSWindowsUpdate module..." "Info" "📦"
    
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-ColorOutput "Installing PSWindowsUpdate module..." "Info" "⬇️"
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false | Out-Null
            Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -SkipPublisherCheck
            Write-ColorOutput "PSWindowsUpdate module installed successfully" "Success" "✅"
        }
        catch {
            Write-ColorOutput "Failed to install PSWindowsUpdate: $($_.Exception.Message)" "Error" "❌"
            return $false
        }
    }
    
    Import-Module PSWindowsUpdate -Force
    return $true
}

function Update-WindowsSystem {
    Write-SectionHeader "🪟 WINDOWS UPDATES"
    
    if (-not (Install-PSWindowsUpdate)) {
        Write-ColorOutput "Skipping Windows Updates due to module installation failure" "Warning" "⚠️"
        return
    }
    
    try {
        Write-ColorOutput "Scanning for available Windows updates..." "Info" "🔎"
        $updates = Get-WindowsUpdate -MicrosoftUpdate -Verbose:$false
        
        if ($updates.Count -eq 0) {
            Write-ColorOutput "No Windows updates available" "Success" "✅"
        }
        else {
            Write-ColorOutput "Found $($updates.Count) update(s). Installing..." "Info" "📥"
            Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -Confirm:$false -Verbose:$false | 
                ForEach-Object {
                    Write-ColorOutput "Installed: $($_.Title)" "Success" "✅"
                }
            Write-ColorOutput "Windows updates completed successfully" "Success" "🎉"
        }
    }
    catch {
        Write-ColorOutput "Windows Update error: $($_.Exception.Message)" "Error" "❌"
    }
}

function Test-SystemHealth {
    Write-SectionHeader "🏥 SYSTEM HEALTH CHECK"
    
    # DISM Check usando comando nativo invece di Repair-WindowsImage
    Write-ColorOutput "Running DISM health check..." "Info" "🔧"
    try {
        Write-ColorOutput "DISM: Checking component store..." "Info" "🔍"
        $dismScan = dism.exe /Online /Cleanup-Image /ScanHealth 2>&1
        
        Write-ColorOutput "DISM: Restoring system health..." "Info" "🔧"
        $dismRestore = dism.exe /Online /Cleanup-Image /RestoreHealth 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "DISM: System image is healthy" "Success" "✅"
        }
        elseif ($LASTEXITCODE -eq 3010) {
            Write-ColorOutput "DISM: Repairs completed successfully (reboot required)" "Warning" "⚠️"
        }
        else {
            Write-ColorOutput "DISM: Check completed with exit code $LASTEXITCODE" "Warning" "⚠️"
        }
    }
    catch {
        Write-ColorOutput "DISM check failed: $($_.Exception.Message)" "Error" "❌"
    }
    
    # SFC Check
    Write-ColorOutput "Running System File Checker (SFC)..." "Info" "🔧"
    try {
        $sfcOutput = sfc /scannow 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "SFC: No integrity violations found" "Success" "✅"
        }
        else {
            Write-ColorOutput "SFC: Check completed with findings (see logs)" "Warning" "⚠️"
        }
    }
    catch {
        Write-ColorOutput "SFC check failed: $($_.Exception.Message)" "Error" "❌"
    }
}


function Update-WingetPackages {
    Write-SectionHeader "📦 WINGET PACKAGE UPDATES"
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Winget is not installed" "Warning" "⚠️"
        return
    }
    
    try {
        Write-ColorOutput "Checking for Winget updates..." "Info" "🔎"
        $updateList = winget upgrade 2>&1 | Out-String
        
        if ($updateList -match "No installed package found") {
            Write-ColorOutput "No Winget packages need updating" "Success" "✅"
        }
        else {
            Write-ColorOutput "Updating all Winget packages..." "Info" "📥"
            winget upgrade --all --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | 
                ForEach-Object { 
                    if ($_ -match "Successfully") {
                        Write-ColorOutput $_ "Success" "✅"
                    }
                }
            Write-ColorOutput "Winget updates completed" "Success" "🎉"
        }
    }
    catch {
        Write-ColorOutput "Winget update error: $($_.Exception.Message)" "Error" "❌"
    }
}

function Update-ChocolateyPackages {
    Write-SectionHeader "🍫 CHOCOLATEY PACKAGE UPDATES"
    
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Chocolatey is not installed (skipping)" "Info" "ℹ️"
        return
    }
    
    try {
        Write-ColorOutput "Updating all Chocolatey packages..." "Info" "📥"
        $chocoOutput = choco upgrade all -y --no-progress 2>&1
        
        if ($chocoOutput -match "Chocolatey upgraded (\d+)/(\d+)") {
            Write-ColorOutput "Chocolatey: Updated $($Matches[1]) package(s)" "Success" "✅"
        }
        else {
            Write-ColorOutput "Chocolatey updates completed" "Success" "🎉"
        }
    }
    catch {
        Write-ColorOutput "Chocolatey update error: $($_.Exception.Message)" "Error" "❌"
    }
}

function Update-ScoopPackages {
    Write-SectionHeader "🥄 SCOOP PACKAGE UPDATES"
    
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Scoop is not installed (skipping)" "Info" "ℹ️"
        return
    }
    
    try {
        Write-ColorOutput "Updating Scoop..." "Info" "📥"
        scoop update 2>&1 | Out-Null
        
        Write-ColorOutput "Updating all Scoop packages..." "Info" "📥"
        $scoopOutput = scoop update * 2>&1
        Write-ColorOutput "Scoop updates completed" "Success" "🎉"
        
        Write-ColorOutput "Cleaning up Scoop cache..." "Info" "🧹"
        scoop cleanup * 2>&1 | Out-Null
        Write-ColorOutput "Scoop cleanup completed" "Success" "✅"
    }
    catch {
        Write-ColorOutput "Scoop update error: $($_.Exception.Message)" "Error" "❌"
    }
}

function Update-MicrosoftStore {
    Write-SectionHeader "🏪 MICROSOFT STORE UPDATES"
    
    try {
        Write-ColorOutput "Updating Microsoft Store apps..." "Info" "📥"
        
        $namespaceName = "root\cimv2\mdm\dmmap"
        $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
        
        $wmiObj = Get-CimInstance -Namespace $namespaceName -ClassName $className
        $result = Invoke-CimMethod -CimInstance $wmiObj -MethodName UpdateScanMethod
        
        Write-ColorOutput "Microsoft Store update scan initiated" "Success" "✅"
    }
    catch {
        Write-ColorOutput "Microsoft Store update error: $($_.Exception.Message)" "Warning" "⚠️"
    }
}

# ================== MAIN EXECUTION ==================

Write-Host "`n"
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host "█" -NoNewline -ForegroundColor Cyan
Write-Host "        🚀 COMPREHENSIVE WINDOWS SYSTEM UPDATE & MAINTENANCE 🚀        " -NoNewline -ForegroundColor White
Write-Host "█" -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host ("█" * 80) -ForegroundColor Cyan
Write-Host "`n"

Write-ColorOutput "Script started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Info" "⏰"
Write-ColorOutput "Log file: $Script:LogPath" "Info" "📝"

# Administrator check
if (-not (Test-Administrator)) {
    Write-ColorOutput "This script requires Administrator privileges!" "Error" "❌"
    Write-ColorOutput "Please run PowerShell as Administrator and try again." "Error" "🔒"
    exit 1
}

Write-ColorOutput "Running with Administrator privileges" "Success" "🔓"

# Display enabled operations
Write-Host "`n"
Write-ColorOutput "Enabled Operations:" "Section" "📋"
Write-ColorOutput "  Windows Updates: $WindowsUpdate" "Info" "$(if($WindowsUpdate){'✅'}else{'❌'})"
Write-ColorOutput "  System Health Check: $SystemHealth" "Info" "$(if($SystemHealth){'✅'}else{'❌'})"
Write-ColorOutput "  Winget Updates: $Winget" "Info" "$(if($Winget){'✅'}else{'❌'})"
Write-ColorOutput "  Chocolatey Updates: $Chocolatey" "Info" "$(if($Chocolatey){'✅'}else{'❌'})"
Write-ColorOutput "  Scoop Updates: $Scoop" "Info" "$(if($Scoop){'✅'}else{'❌'})"
Write-ColorOutput "  Microsoft Store Updates: $MicrosoftStore" "Info" "$(if($MicrosoftStore){'✅'}else{'❌'})"

# Execute enabled update operations
if ($WindowsUpdate) { Update-WindowsSystem }
if ($SystemHealth) { Test-SystemHealth }
if ($Winget) { Update-WingetPackages }
if ($Chocolatey) { Update-ChocolateyPackages }
if ($Scoop) { Update-ScoopPackages }
if ($MicrosoftStore) { Update-MicrosoftStore }

# Final summary
Write-SectionHeader "📊 COMPLETION SUMMARY"
Write-ColorOutput "All update operations completed!" "Success" "🎊"
Write-ColorOutput "Script finished at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Info" "⏰"
Write-ColorOutput "Full log available at: $Script:LogPath" "Info" "📝"

Write-Host "`n"
Write-Host ("═" * 80) -ForegroundColor Green
Write-Host "  ✨ SYSTEM UPDATE PROCESS COMPLETED SUCCESSFULLY ✨" -ForegroundColor Green
Write-Host ("═" * 80) -ForegroundColor Green
Write-Host "`n"
