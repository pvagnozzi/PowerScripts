<#
.SYNOPSIS
    🐳 Docker Desktop VHDX Automatic Cleanup and Shrink Script

.DESCRIPTION
    Automatically cleans Docker images, containers, volumes and shrinks the VHDX file
    to reclaim disk space on Windows with WSL2 backend.

.PARAMETER SkipPrune
    Skip Docker system prune (cleanup) step

.PARAMETER SkipShrink
    Skip VHDX shrink/compact step

.PARAMETER Force
    Skip all confirmation prompts

.EXAMPLE
    .\Docker-Cleanup-Shrink.ps1
    .\Docker-Cleanup-Shrink.ps1 -Force
    .\Docker-Cleanup-Shrink.ps1 -SkipPrune

.NOTES
    Author: Fitness Management Team
    Version: 1.0.0
    Last Updated: 2026-01-01

    Requirements:
    - Windows 10/11 with WSL2
    - Docker Desktop
    - PowerShell 5.1+ (run as Administrator)
    - Hyper-V feature enabled
#>

[CmdletBinding()]
param(
    [switch]$SkipPrune,
    [switch]$SkipShrink,
    [switch]$Force
)

# Require Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "   Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Color functions
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Error-Custom { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Cyan }
function Write-Warning-Custom { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Step { Write-Host "`n🔹 $args" -ForegroundColor Magenta }

# Helper function to format bytes
function Format-Bytes {
    param([long]$bytes)
    if ($bytes -ge 1TB) { return "{0:N2} TB" -f ($bytes / 1TB) }
    if ($bytes -ge 1GB) { return "{0:N2} GB" -f ($bytes / 1GB) }
    if ($bytes -ge 1MB) { return "{0:N2} MB" -f ($bytes / 1MB) }
    if ($bytes -ge 1KB) { return "{0:N2} KB" -f ($bytes / 1KB) }
    return "$bytes Bytes"
}

# Get VHDX file paths
function Get-DockerVhdxPaths {
    $paths = @()

    # Primary Docker VHDX (ext4.vhdx)
    $dockerDataPath = "$env:LOCALAPPDATA\Docker\wsl\data\ext4.vhdx"
    if (Test-Path $dockerDataPath) {
        $paths += $dockerDataPath
    }

    # Alternative path (docker_data.vhdx)
    $dockerDataAlt = "$env:LOCALAPPDATA\Docker\wsl\disk\docker_data.vhdx"
    if (Test-Path $dockerDataAlt) {
        $paths += $dockerDataAlt
    }

    # Docker Desktop distro (if exists)
    $dockerDesktopData = "$env:LOCALAPPDATA\Docker\wsl\distro\ext4.vhdx"
    if (Test-Path $dockerDesktopData) {
        $paths += $dockerDesktopData
    }

    return $paths
}

# Main script
try {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "    🐳 Docker Desktop VHDX Cleanup & Shrink Tool" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    # Check if Docker is installed
    Write-Step "Checking Docker installation..."
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker is not installed or not in PATH"
    }
    Write-Success "Docker found"

    # Find VHDX files
    Write-Step "Locating Docker VHDX files..."
    $vhdxPaths = @(Get-DockerVhdxPaths)

    if ($vhdxPaths.Count -eq 0) {
        Write-Warning-Custom "No Docker VHDX files found. Is Docker Desktop installed?"
        exit 0
    }

    Write-Success "Found $($vhdxPaths.Count) VHDX file(s):"
    $totalSizeBefore = 0
    foreach ($path in $vhdxPaths) {
        $size = (Get-Item $path).Length
        $totalSizeBefore += $size
        Write-Host "   📁 $path" -ForegroundColor Gray
        Write-Host "      Size: $(Format-Bytes $size)" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Info "Total VHDX size before cleanup: $(Format-Bytes $totalSizeBefore)"

    # Confirmation
    if (-not $Force) {
        Write-Host ""
        Write-Warning-Custom "This script will:"
        Write-Host "   1. Remove unused Docker images, containers, and volumes" -ForegroundColor Yellow
        Write-Host "   2. Stop Docker Desktop and WSL2" -ForegroundColor Yellow
        Write-Host "   3. Compact VHDX files to reclaim disk space" -ForegroundColor Yellow
        Write-Host "   4. Restart Docker Desktop" -ForegroundColor Yellow
        Write-Host ""
        $confirm = Read-Host "Continue? (Y/N)"
        if ($confirm -ne "Y" -and $confirm -ne "y") {
            Write-Info "Operation cancelled by user"
            exit 0
        }
    }

    # Step 1: Docker System Prune
    if (-not $SkipPrune) {
        Write-Step "Step 1/4: Cleaning up Docker resources..."

        try {
            Write-Info "Removing unused images, containers, networks, and volumes..."
            Write-Warning-Custom "This may take a few minutes..."

            # Run docker system prune
            $pruneResult = docker system prune -a --volumes --force 2>&1

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Docker cleanup completed"
                Write-Host $pruneResult -ForegroundColor Gray
            } else {
                Write-Warning-Custom "Docker prune returned warnings (this is usually OK)"
            }
        } catch {
            Write-Warning-Custom "Docker cleanup had issues: $_"
            Write-Info "Continuing anyway..."
        }
    } else {
        Write-Info "Skipping Docker prune (as requested)"
    }

    # Step 2: Stop Docker Desktop
    Write-Step "Step 2/4: Stopping Docker Desktop..."

    # Try to stop Docker service gracefully
    try {
        $dockerService = Get-Service "com.docker.service" -ErrorAction SilentlyContinue
        if ($dockerService -and $dockerService.Status -eq "Running") {
            Write-Info "Stopping Docker service..."
            Stop-Service "com.docker.service" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 3
            Write-Success "Docker service stopped"
        }
    } catch {
        Write-Warning-Custom "Could not stop Docker service: $_"
    }

    # Kill Docker Desktop processes
    Write-Info "Terminating Docker Desktop processes..."
    $dockerProcesses = @("Docker Desktop", "dockerd", "com.docker.backend", "com.docker.service")
    foreach ($processName in $dockerProcesses) {
        Get-Process -Name $processName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2
    Write-Success "Docker Desktop stopped"

    # Step 3: Shutdown WSL2
    Write-Step "Step 3/4: Shutting down WSL2..."
    Write-Info "This will close all WSL2 distributions..."

    wsl --shutdown
    Start-Sleep -Seconds 5

    Write-Success "WSL2 shutdown complete"

    # Step 4: Compact VHDX files
    if (-not $SkipShrink) {
        Write-Step "Step 4/4: Compacting VHDX files..."

        $successCount = 0
        $totalSizeAfter = 0

        foreach ($vhdxPath in $vhdxPaths) {
            Write-Info "Processing: $vhdxPath"

            $sizeBefore = (Get-Item $vhdxPath).Length

            try {
                # Try Optimize-VHD first (requires Hyper-V)
                Write-Info "Running Optimize-VHD (this may take 5-15 minutes)..."
                Optimize-VHD -Path $vhdxPath -Mode Full

                $sizeAfter = (Get-Item $vhdxPath).Length
                $totalSizeAfter += $sizeAfter
                $saved = $sizeBefore - $sizeAfter

                Write-Success "VHDX compacted successfully!"
                Write-Host "   Before: $(Format-Bytes $sizeBefore)" -ForegroundColor Gray
                Write-Host "   After:  $(Format-Bytes $sizeAfter)" -ForegroundColor Gray
                Write-Host "   Saved:  $(Format-Bytes $saved)" -ForegroundColor Green

                $successCount++

            } catch {
                Write-Warning-Custom "Optimize-VHD failed, trying diskpart method..."

                # Fallback to diskpart
                try {
                    $diskpartScript = @"
select vdisk file="$vhdxPath"
compact vdisk
exit
"@
                    $diskpartScript | diskpart | Out-Null

                    $sizeAfter = (Get-Item $vhdxPath).Length
                    $totalSizeAfter += $sizeAfter
                    $saved = $sizeBefore - $sizeAfter

                    Write-Success "VHDX compacted with diskpart!"
                    Write-Host "   Before: $(Format-Bytes $sizeBefore)" -ForegroundColor Gray
                    Write-Host "   After:  $(Format-Bytes $sizeAfter)" -ForegroundColor Gray
                    Write-Host "   Saved:  $(Format-Bytes $saved)" -ForegroundColor Green

                    $successCount++

                } catch {
                    Write-Error-Custom "Failed to compact $vhdxPath : $_"
                    $totalSizeAfter += $sizeBefore
                }
            }
        }

        # Summary
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "    📊 Cleanup Summary" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   Files processed:     $successCount / $($vhdxPaths.Count)" -ForegroundColor White
        Write-Host "   Size before cleanup: $(Format-Bytes $totalSizeBefore)" -ForegroundColor White
        Write-Host "   Size after cleanup:  $(Format-Bytes $totalSizeAfter)" -ForegroundColor White

        $totalSaved = $totalSizeBefore - $totalSizeAfter
        if ($totalSaved -gt 0) {
            Write-Host "   💾 Space reclaimed:   $(Format-Bytes $totalSaved)" -ForegroundColor Green
            $percentSaved = ($totalSaved / $totalSizeBefore) * 100
            Write-Host "   📉 Reduction:         $([math]::Round($percentSaved, 2))%" -ForegroundColor Green
        } else {
            Write-Warning-Custom "No space was reclaimed (disk was already optimized)"
        }

    } else {
        Write-Info "Skipping VHDX shrink (as requested)"
    }

    # Step 5: Restart Docker Desktop
    Write-Host ""
    Write-Step "Restarting Docker Desktop..."

    $dockerDesktopPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktopPath) {
        Write-Info "Starting Docker Desktop..."
        Start-Process $dockerDesktopPath
        Write-Success "Docker Desktop is starting (may take 30-60 seconds)"
    } else {
        Write-Warning-Custom "Docker Desktop executable not found at default path"
        Write-Info "Please start Docker Desktop manually"
    }

    # Final message
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Success "Cleanup and shrink completed successfully!"
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "   1. Wait for Docker Desktop to fully start" -ForegroundColor Gray
    Write-Host "   2. Verify with: docker ps" -ForegroundColor Gray
    Write-Host "   3. Check disk space in Docker Desktop settings" -ForegroundColor Gray
    Write-Host ""

    exit 0

} catch {
    Write-Host ""
    Write-Error-Custom "Script failed: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Write-Host ""
    Write-Info "Troubleshooting:"
    Write-Host "   1. Make sure you run PowerShell as Administrator" -ForegroundColor Gray
    Write-Host "   2. Ensure Docker Desktop is installed" -ForegroundColor Gray
    Write-Host "   3. Check if Hyper-V feature is enabled" -ForegroundColor Gray
    Write-Host "   4. Try closing Docker Desktop manually first" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
