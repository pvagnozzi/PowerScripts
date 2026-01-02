# Windows-Check-Health

## 📋 Overview

Comprehensive Windows system update and maintenance script with full automation support. This script performs a complete system update cycle with granular control over each operation.

## ✨ Features

- 🪟 **Windows Updates** - Automatic installation of Windows updates via PSWindowsUpdate module
- 🏥 **System Health Checks** - DISM and SFC integrity verification and repair
- 📦 **Winget Updates** - Windows Package Manager updates for all installed packages
- 🍫 **Chocolatey Updates** - Chocolatey package manager updates (if installed)
- 🥄 **Scoop Updates** - Scoop package manager updates (if installed)
- 🏪 **Microsoft Store Updates** - Automatic Microsoft Store app updates
- 📝 **Detailed Logging** - Complete log file with timestamp for troubleshooting
- 🎨 **Rich Visual Output** - Color-coded output with emoji for better readability

## 🚀 Usage

### Basic Usage (All Operations Enabled)

```powershell
.\scripts\windows\Windows-Check-Health.ps1
```

### Selective Operations

#### Disable Specific Operations

```powershell
# Skip Windows Updates and health checks
.\scripts\windows\Windows-Check-Health.ps1 -WindowsUpdate:$false -SystemHealth:$false

# Only run package managers
.\scripts\windows\Windows-Check-Health.ps1 -WindowsUpdate:$false -SystemHealth:$false

# Only Winget updates
.\scripts\windows\Windows-Check-Health.ps1 -SystemHealth:$false -Chocolatey:$false -Scoop:$false -MicrosoftStore:$false -WindowsUpdate:$false
```

#### Enable Only Specific Operations

```powershell
# Only Windows Updates
.\scripts\windows\Windows-Check-Health.ps1 -SystemHealth:$false -Winget:$false -Chocolatey:$false -Scoop:$false -MicrosoftStore:$false

# Only system health checks
.\scripts\windows\Windows-Check-Health.ps1 -WindowsUpdate:$false -Winget:$false -Chocolatey:$false -Scoop:$false -MicrosoftStore:$false
```

### Help

```powershell
# Display detailed help
.\scripts\windows\Windows-Check-Health.ps1 -Help

# Or use standard PowerShell help
Get-Help .\scripts\windows\Windows-Check-Health.ps1 -Full
```

## 📝 Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-WindowsUpdate` | Switch | `$true` | Enable/disable Windows Updates installation |
| `-SystemHealth` | Switch | `$true` | Enable/disable system health checks (DISM, SFC) |
| `-Winget` | Switch | `$true` | Enable/disable Winget package updates |
| `-Chocolatey` | Switch | `$true` | Enable/disable Chocolatey package updates |
| `-Scoop` | Switch | `$true` | Enable/disable Scoop package updates |
| `-MicrosoftStore` | Switch | `$true` | Enable/disable Microsoft Store app updates |
| `-Help` | Switch | `$false` | Display help information (aliases: `-h`, `-?`) |

## 📋 Requirements

- **Operating System**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: Version 5.1 or higher (PowerShell 7+ recommended)
- **Privileges**: Administrator rights required
- **Optional**: Chocolatey and/or Scoop (script detects and skips if not installed)

## 🔄 Idempotency

This script is designed to be **idempotent** - it can be run multiple times safely without causing issues:

- Windows Updates: Only installs updates that aren't already installed
- System Health: DISM/SFC only repairs if issues are found
- Package Managers: Only update packages with newer versions available
- All operations check current state before making changes

## 📊 Output

The script provides:

- **Real-time console output** with color-coded messages and emoji
- **Comprehensive logging** to `$env:TEMP\SystemUpdate_YYYYMMDD_HHMMSS.log`
- **Progress indicators** for each operation
- **Summary report** at the end of execution

### Output Color Scheme

- ✅ **Green** - Success messages
- ❌ **Red** - Error messages
- ⚠️ **Yellow** - Warning messages
- ℹ️ **Cyan** - Informational messages
- 📝 **Magenta** - Section headers and notes

## 🛠️ Operations Details

### Windows Updates
- Installs PSWindowsUpdate module if not present
- Scans for available Windows updates (Microsoft Update catalog)
- Installs all applicable updates
- Does not require reboot during execution

### System Health Checks
- **DISM**: Scans and repairs Windows component store
- **SFC**: Verifies and repairs system file integrity
- Both tools run with full repair capability

### Winget Updates
- Updates all packages installed via Windows Package Manager
- Runs silently with automatic agreement acceptance
- Skips if winget is not installed

### Chocolatey Updates
- Updates all Chocolatey packages
- Runs with `-y` flag for unattended operation
- Gracefully skips if Chocolatey is not installed

### Scoop Updates
- Updates Scoop itself first
- Updates all installed Scoop apps
- Cleans up old versions to save disk space
- Gracefully skips if Scoop is not installed

### Microsoft Store Updates
- Triggers Microsoft Store update scan via WMI
- Updates happen in background
- Works on Windows 10/11

## 💡 Examples

### Example 1: Full System Maintenance (Default)
```powershell
.\scripts\windows\Windows-Check-Health.ps1
```
Runs all operations: Windows Updates, health checks, and all package managers.

### Example 2: Quick Package Updates Only
```powershell
.\scripts\windows\Windows-Check-Health.ps1 -WindowsUpdate:$false -SystemHealth:$false
```
Skips time-consuming Windows Updates and health checks, only updates packages.

### Example 3: Health Check Only
```powershell
.\scripts\windows\Windows-Check-Health.ps1 -WindowsUpdate:$false -Winget:$false -Chocolatey:$false -Scoop:$false -MicrosoftStore:$false
```
Performs only DISM and SFC system health verification.

### Example 4: Custom Combination
```powershell
.\scripts\windows\Windows-Check-Health.ps1 -Chocolatey:$false -Scoop:$false
```
Runs Windows Updates, system health, Winget, and Microsoft Store updates (skips Chocolatey and Scoop).

## 🔒 Security Considerations

- Script requires administrator privileges
- All package managers run with automatic acceptance flags
- PSWindowsUpdate module installed from PowerShell Gallery
- Log files stored in user's temp directory
- No credentials or sensitive data logged

## ⚠️ Known Limitations

- Windows Updates may require a system reboot (not performed by script)
- DISM and SFC can take significant time on first run
- Microsoft Store updates may not complete immediately
- Requires active internet connection for most operations

## 🐛 Troubleshooting

### Script won't run
- Ensure you're running PowerShell as Administrator
- Check execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### PSWindowsUpdate module fails to install
- Check internet connectivity
- Ensure PowerShell Gallery is accessible: `Register-PSRepository -Default`
- Try manual installation: `Install-Module PSWindowsUpdate -Force`

### Package manager updates fail
- Verify package manager is installed and in PATH
- Run the package manager manually to check for issues
- Check log file for detailed error messages

### View detailed logs
```powershell
# Logs are stored in temp directory
Get-ChildItem $env:TEMP\SystemUpdate_*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

## 📚 Related Resources

- [PSWindowsUpdate Module](https://www.powershellgallery.com/packages/PSWindowsUpdate)
- [Winget Documentation](https://docs.microsoft.com/en-us/windows/package-manager/)
- [Chocolatey](https://chocolatey.org/)
- [Scoop](https://scoop.sh/)
- [DISM Documentation](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism---deployment-image-servicing-and-management-technical-reference-for-windows)

## 📄 Version History

- **v2.0** - Added configurable parameters for each operation
- **v1.0** - Initial release with all operations enabled

---

**Author**: System Administrator  
**License**: MIT  
**Repository**: [PowerScripts](https://github.com/yourusername/PowerScripts)
