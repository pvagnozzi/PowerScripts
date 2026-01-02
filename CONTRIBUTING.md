# Contributing to PowerScripts

Thank you for your interest in contributing! 🎉

## 📋 Development Guidelines

### Adding New Scripts

1. **Create for All Platforms**
   - Windows: `scripts/windows/script-name.ps1`
   - Linux: `scripts/linux/script-name.sh`
   - macOS: `scripts/macos/script-name.zsh`

2. **Ensure Functional Parity**
   - All versions must provide the same functionality
   - Handle platform-specific features gracefully
   - Document any unavoidable differences

3. **Follow Style Guide**
   - Include emoji and colored output
   - Implement idempotent behavior
   - Add help/usage information (`-h` or `--help`)
   - Use English for all text
   - Include proper error handling

4. **Testing**
   - Test on the target platform
   - Verify idempotency (run twice, check results)
   - Test with invalid inputs
   - Check exit codes

5. **Documentation**
   - Update README.md with script description
   - Update CHANGELOG.md
   - Include usage examples in help output

### Code Review Checklist

Before submitting:

- [ ] Works on target platform(s)
- [ ] Idempotent behavior verified
- [ ] Consistent naming across platforms
- [ ] Colorful output with emoji
- [ ] Help/usage information included
- [ ] Error handling implemented
- [ ] English language only
- [ ] README.md updated
- [ ] CHANGELOG.md updated
- [ ] All platform versions updated

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new backup script for all platforms
fix: correct error handling in network-check script
docs: update README with new script examples
refactor: improve color helper functions
```

### Pull Request Process

1. Create a feature branch: `git checkout -b feature/script-name`
2. Make your changes
3. Test on all applicable platforms
4. Update documentation
5. Commit with conventional commit messages
6. Push and create a pull request
7. Wait for review

## 🎨 Style Guidelines

### Output Colors

Use these consistently:

- ✅ Success: Green
- ❌ Error: Red
- ⚠️ Warning: Yellow
- ℹ️ Info: Cyan/Blue
- 📝 Note: Magenta
- 🚀 Action: Bold/Bright

### Script Structure

```
# Header/Shebang
# Description
# Parameters
# Helper Functions
# Main Logic
# Error Handling
```

### Comments

- Only comment when clarification is needed
- Keep comments concise
- Use English

## 🐛 Reporting Issues

When reporting issues:

1. Specify the platform (Windows/Linux/macOS)
2. Include the script name and version
3. Provide steps to reproduce
4. Include error messages
5. Describe expected vs actual behavior

## 💡 Suggestions

Have ideas for new scripts? Open an issue with:

- Description of the script's purpose
- Expected functionality
- Use cases
- Platform considerations

## 📜 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help others learn and grow

## 📞 Questions?

Open an issue for questions or discussions!

---

Happy scripting! 🚀
