# Copilot Instructions - PowerScripts

## Project Overview
PowerScripts is a cross-platform collection of utility scripts for Windows (PowerShell), Linux (Bash), and macOS (Zsh). All scripts are idempotent, feature-rich with emoji and colorful CLI output inspired by GitHub CLI.

## Core Principles

### 1. Cross-Platform Synchronization
- Scripts MUST have the same base name across platforms (respecting platform-specific naming conventions)
- Scripts MUST provide identical functionality across all platforms
- When modifying a script, update ALL platform versions simultaneously
- Document platform-specific differences when unavoidable

### 2. Code Quality Standards
- **Idempotency**: Scripts can be run multiple times safely without side effects
- **Modularity**: Prefer well-structured, reusable code with functions
- **Error Handling**: Always include proper error handling and validation
- **Documentation**: Include inline comments only when necessary for clarity
- **Language**: All documentation, help messages, and user-facing text MUST be in English

### 3. User Experience
- **Visual Design**: Use emoji and colors (inspired by GitHub CLI aesthetic)
- **Feedback**: Provide clear, colored output for success ✅, warnings ⚠️, errors ❌, info ℹ️
- **Help**: Include `-h` or `--help` flag with comprehensive usage information
- **Verbosity**: Support `-v` or `--verbose` flag when applicable

### 4. Naming Conventions
- **Directory Names**: Always lowercase (`scripts/windows/`, `scripts/linux/`, `scripts/macos/`)
- **Windows Scripts**: PascalCase with hyphens - capitalize first letter and after each hyphen (e.g., `Backup-Files.ps1`, `Create-User.ps1`)
- **Linux/macOS Scripts**: lowercase with hyphens (e.g., `backup-files.sh`, `create-user.zsh`)
- **Consistency**: Respect platform-specific naming conventions while maintaining functional parity across all platforms

## Platform-Specific Guidelines

### Windows (PowerShell)
- File extension: `.ps1`
- Location: `scripts/windows/`
- Use `Write-Host` with `-ForegroundColor` for colored output
- Include execution policy notes in documentation
- Use `param()` blocks for parameters
- Follow PowerShell approved verbs (Get, Set, New, Remove, etc.)

### Linux (Bash)
- File extension: `.sh`
- Location: `scripts/linux/`
- Shebang: `#!/usr/bin/env bash`
- Use ANSI color codes for output
- Make executable: `chmod +x`
- Follow POSIX standards when possible

### macOS (Zsh)
- File extension: `.zsh`
- Location: `scripts/macos/`
- Shebang: `#!/usr/bin/env zsh`
- Use ANSI color codes for output
- Consider macOS-specific tools (e.g., `pbcopy`, `osascript`)
- Make executable: `chmod +x`

## Color Scheme (Consistent Across Platforms)

```
✅ Success: Green
❌ Error: Red
⚠️  Warning: Yellow
ℹ️  Info: Cyan/Blue
📝 Note: Magenta
🚀 Action: Bright White/Bold
```

## Script Template Structure

Each script should follow this structure:

1. **Header**: Shebang (Unix) / Comment block (Windows)
2. **Description**: Brief purpose of the script
3. **Parameters/Arguments**: Documented parameters
4. **Functions**: Reusable helper functions (colors, logging, validation)
5. **Main Logic**: Core functionality
6. **Error Handling**: Proper exit codes and cleanup

## File Naming Conventions

### Script Files
- **Windows (PowerShell)**: PascalCase with hyphens - capitalize first letter and after each hyphen
  - Examples: `Backup-Files.ps1`, `Create-User.ps1`, `Get-SystemInfo.ps1`
- **Linux (Bash)**: lowercase with hyphens
  - Examples: `backup-files.sh`, `create-user.sh`, `get-system-info.sh`
- **macOS (Zsh)**: lowercase with hyphens
  - Examples: `backup-files.zsh`, `create-user.zsh`, `get-system-info.zsh`
- Use descriptive, action-oriented names
- Keep names concise but clear

### Directory Structure
- All directory names MUST use lowercase
- Use platform names as-is: `windows`, `linux`, `macos`
- Follow the established structure: `scripts/{platform}/`
- Do NOT use camelCase, PascalCase, or UPPERCASE for directories

## Testing & Validation

- Test scripts on their target platform before committing
- Verify idempotency (run twice, same result)
- Check error handling with invalid inputs
- Validate cross-platform consistency

## Git Workflow

- Create feature branches for new scripts: `feature/new-script-name`
- Update all platform versions in the same commit
- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`
- Update README.md when adding new scripts

## Documentation Requirements

- README.md: Maintain list of all scripts with brief descriptions
- Each script: Include usage examples in help output
- CHANGELOG.md: Document changes for each version

## When Creating New Scripts

1. Create the script for all three platforms simultaneously
2. Ensure functional parity across platforms
3. Add color output and emoji consistently
4. Include help functionality
5. Test idempotency
6. Update main README.md
7. Add examples to documentation

## Code Review Checklist

- [ ] Works on target platform(s)
- [ ] Idempotent behavior verified
- [ ] Consistent naming across platforms
- [ ] Colorful output with emoji
- [ ] Help/usage information included
- [ ] Error handling implemented
- [ ] English language only
- [ ] README.md updated
- [ ] All platform versions updated (if applicable)
