# Changelog

All notable changes to PowerScripts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- Cross-platform script directories (Windows, Linux, macOS)
- GitHub configuration files
- Copilot instructions
- README and documentation
- Windows-Check-Health script with configurable parameters
- Install-Docker scripts for all platforms (Windows, Linux, macOS)
  - Windows: WSL2 and Hyper-V prerequisite checks
  - Linux: Multi-distro support (Ubuntu, Debian, Fedora, CentOS, Arch)
  - macOS: Homebrew integration and Apple Silicon support
- Install-VSCode scripts for all platforms (Windows, Linux, macOS)
  - Complete dev environment: VS Code, Git, PowerShell 7, Oh My Posh
  - Dracula theme configuration with Nerd Fonts
  - Automatic PowerShell profile setup
  - Optional Docker installation integration
  - VS Code extensions: Dev Containers, Docker, PowerShell, GitLens

### Changed
- Windows-Check-Health: Added parameters to enable/disable individual operations
  - `-WindowsUpdate`, `-SystemHealth`, `-Winget`, `-Chocolatey`, `-Scoop`, `-MicrosoftStore`
  - All operations enabled by default
  - Added `-Help` parameter for detailed usage information

### Deprecated

### Removed

### Fixed

### Security

## [0.1.0] - 2026-01-02

### Added
- Project initialization
- Basic structure for cross-platform scripts
