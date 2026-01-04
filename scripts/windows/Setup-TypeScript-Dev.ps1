<#
.SYNOPSIS
    Setup TypeScript development environment on Windows

.DESCRIPTION
    Configures the system for TypeScript/JavaScript development by installing and configuring:
    - Git version control
    - PowerShell 7 (latest version)
    - Oh My Posh with automatic initialization and user theme
    - Visual Studio Code with TypeScript, React, Angular, and Vue extensions
    - NVM for Windows (Node Version Manager)
    - Node.js LTS version via NVM
    - TypeScript compiler (global)
    - React development tools
    - Angular CLI (global)
    - Vue CLI (global)
    - Yarn package manager (global)
    - PNPM package manager (global)
    - GitHub Copilot CLI
    - WebStorm IDE (optional, default: no)

    All tools are configured with proper PATH settings and integrations.

.PARAMETER InstallWebStorm
    Install JetBrains WebStorm (default: no)

.PARAMETER SkipUpdates
    Skip updating existing tools

.PARAMETER SkipAngular
    Skip Angular CLI installation

.PARAMETER SkipVue
    Skip Vue CLI installation

.PARAMETER Verbose
    Show detailed output

.EXAMPLE
    .\Setup-TypeScript-Dev.ps1

.EXAMPLE
    .\Setup-TypeScript-Dev.ps1 -InstallWebStorm

.EXAMPLE
    .\Setup-TypeScript-Dev.ps1 -SkipAngular -SkipVue

.NOTES
    Requires administrator privileges
    Idempotent - safe to run multiple times
#>

param(
    [switch]$InstallWebStorm,
    [switch]$SkipUpdates,
    [switch]$SkipAngular,
    [switch]$SkipVue,
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

Write-Action "🎯 Starting TypeScript Development Environment Setup"
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
if (-not (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe")) {
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

# Configure Oh My Posh
$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$poshConfig = "oh-my-posh init pwsh --config `"`$env:POSH_THEMES_PATH\powerlevel10k_rainbow.omp.json`" | Invoke-Expression"
if (-not (Test-Path $profilePath) -or -not (Select-String -Path $profilePath -Pattern "oh-my-posh" -Quiet)) {
    Add-Content -Path $profilePath -Value "`n# Oh My Posh`n$poshConfig"
    Write-Success "Oh My Posh configured in PowerShell profile"
} else {
    Write-Info "Oh My Posh already configured"
}

# Install NVM for Windows
Write-Action "Installing/Updating NVM for Windows..."
$nvmPath = "$env:APPDATA\nvm"
if (-not (Test-Path "$nvmPath\nvm.exe")) {
    Write-Info "Installing NVM for Windows..."
    choco install nvm -y
    Write-Success "NVM for Windows installed"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Success "NVM for Windows already installed"
    if (-not $SkipUpdates) {
        choco upgrade nvm -y
    }
}

# Install Node.js LTS via NVM
Write-Action "Installing Node.js LTS via NVM..."
if (Test-Command "nvm") {
    # Get current LTS version
    $nvmList = nvm list 2>&1
    if ($nvmList -notmatch "lts") {
        Write-Info "Installing Node.js LTS..."
        nvm install lts
        nvm use lts
        Write-Success "Node.js LTS installed"
    } else {
        Write-Success "Node.js LTS already installed"
        nvm use lts 2>&1 | Out-Null
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Warning-Custom "NVM not available in PATH. You may need to restart your terminal."
}

# Verify Node.js and npm
if (Test-Command "node") {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Success "Node.js version: $nodeVersion"
    Write-Success "npm version: $npmVersion"
} else {
    Write-Warning-Custom "Node.js not found in PATH. Restart terminal and run: nvm use lts"
}

# Install global npm packages
if (Test-Command "npm") {
    Write-Action "Installing/Updating global npm packages..."

    # TypeScript
    Write-Info "Installing TypeScript..."
    npm install -g typescript
    Write-Success "TypeScript installed"

    # ts-node
    Write-Info "Installing ts-node..."
    npm install -g ts-node
    Write-Success "ts-node installed"

    # Yarn
    Write-Info "Installing Yarn..."
    npm install -g yarn
    Write-Success "Yarn installed"

    # PNPM
    Write-Info "Installing PNPM..."
    npm install -g pnpm
    Write-Success "PNPM installed"

    # Create React App
    Write-Info "Installing Create React App..."
    npm install -g create-react-app
    Write-Success "Create React App installed"

    # Vite
    Write-Info "Installing Vite..."
    npm install -g vite
    Write-Success "Vite installed"

    # Angular CLI
    if (-not $SkipAngular) {
        Write-Info "Installing Angular CLI..."
        npm install -g @angular/cli
        Write-Success "Angular CLI installed"
    }

    # Vue CLI
    if (-not $SkipVue) {
        Write-Info "Installing Vue CLI..."
        npm install -g @vue/cli
        Write-Success "Vue CLI installed"
    }

    # ESLint
    Write-Info "Installing ESLint..."
    npm install -g eslint
    Write-Success "ESLint installed"

    # Prettier
    Write-Info "Installing Prettier..."
    npm install -g prettier
    Write-Success "Prettier installed"

    # GitHub Copilot CLI
    Write-Info "Installing GitHub Copilot CLI..."
    npm install -g @githubnext/github-copilot-cli
    Write-Success "GitHub Copilot CLI installed"
}

# Install Visual Studio Code
Write-Action "Installing/Updating Visual Studio Code..."
if (-not (Test-Path "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe")) {
    choco install vscode -y
    Write-Success "Visual Studio Code installed"
} else {
    Write-Success "Visual Studio Code already installed"
    if (-not $SkipUpdates) {
        choco upgrade vscode -y
    }
}

# Install VS Code extensions
if (Test-Command "code") {
    Write-Action "Installing VS Code extensions..."

    $extensions = @(
        "ms-vscode.vscode-typescript-next",
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "dsznajder.es7-react-js-snippets",
        "Angular.ng-template",
        "Vue.volar",
        "bradlc.vscode-tailwindcss",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-vscode.js-debug",
        "orta.vscode-jest"
    )

    foreach ($ext in $extensions) {
        $installed = code --list-extensions 2>&1 | Select-String -Pattern "^$ext$"
        if (-not $installed) {
            Write-Info "Installing extension: $ext"
            code --install-extension $ext --force 2>&1 | Out-Null
        }
    }
    Write-Success "VS Code extensions installed"
}

# Install WebStorm (optional)
if ($InstallWebStorm) {
    Write-Action "Installing JetBrains WebStorm..."
    if (-not (Test-Path "$env:LOCALAPPDATA\JetBrains\WebStorm*")) {
        choco install webstorm -y
        Write-Success "WebStorm installed"
    } else {
        Write-Success "WebStorm already installed"
        if (-not $SkipUpdates) {
            choco upgrade webstorm -y
        }
    }
}

Write-Success "✨ TypeScript Development Environment Setup Complete!"
Write-Note "Installed tools:"
Write-Info "  • Git"
Write-Info "  • PowerShell 7 with Oh My Posh"
Write-Info "  • NVM for Windows"
Write-Info "  • Node.js LTS (via NVM)"
Write-Info "  • TypeScript, ts-node"
Write-Info "  • Yarn, PNPM"
Write-Info "  • Create React App, Vite"
if (-not $SkipAngular) { Write-Info "  • Angular CLI" }
if (-not $SkipVue) { Write-Info "  • Vue CLI" }
Write-Info "  • ESLint, Prettier"
Write-Info "  • Visual Studio Code with extensions"
Write-Info "  • GitHub Copilot CLI"
if ($InstallWebStorm) { Write-Info "  • JetBrains WebStorm" }

Write-Note "Next steps:"
Write-Info "  1. Restart your terminal to apply PATH changes"
Write-Info "  2. Verify installation: node --version && npm --version && tsc --version"
Write-Info "  3. Create a new project:"
Write-Info "     - React: npx create-react-app my-app"
Write-Info "     - React (Vite): npm create vite@latest my-app -- --template react-ts"
if (-not $SkipAngular) {
    Write-Info "     - Angular: ng new my-app"
}
if (-not $SkipVue) {
    Write-Info "     - Vue: vue create my-app"
}
Write-Info "  4. Configure Git: git config --global user.name 'Your Name'"
Write-Info "                   git config --global user.email 'your.email@example.com'"
