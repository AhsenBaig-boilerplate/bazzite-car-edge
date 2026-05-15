# Contributing to Bazzite Car Edge

Thank you for your interest in contributing to Bazzite Car Edge! This document provides guidelines for contributing to the project.

---

## 🎯 Project Goals

**Primary Goal:** Create a production-ready car entertainment system that non-technical users can install and use with **zero terminal commands required**.

**Target Audience:**
- Car enthusiasts wanting entertainment systems
- Users new to Linux/Bazzite
- People who prefer GUI over CLI
- Mobile/edge computing users

**Design Principles:**
1. **GUI-first:** Everything should be possible through graphical interfaces
2. **Error-tolerant:** Handle failures gracefully with clear messages
3. **Self-documenting:** UI should guide users without external docs
4. **Minimal base:** Keep image small, install apps post-boot
5. **Immutable-friendly:** Respect rpm-ostree and bootc conventions

---

## 🛠️ Development Setup

### Prerequisites
- Linux system (Fedora, Ubuntu, or similar)
- Git
- Podman or Docker
- Text editor / IDE
- GitHub account

### Clone Repository
```bash
git clone https://github.com/AhsenBaig-boilerplate/bazzite-car-edge.git
cd bazzite-car-edge
```

### Local Testing
```bash
# Build image locally
podman build -t bazzite-car-edge:test .

# Test scripts locally (without building image)
bash build_files/files/car-edge-setup-wizard-v2.sh --force
bash build_files/files/car-edge-install-apps.sh
bash test-system.sh
```

---

## 📁 Project Structure

```
bazzite-car-edge/
├── Containerfile              # Image build definition
├── build_files/
│   ├── build.sh              # System configuration script
│   └── files/                # Scripts installed to /usr/bin
│       ├── car-edge-setup-wizard-v2.sh
│       ├── car-edge-install-apps.sh
│       ├── car-edge-backup.sh
│       ├── car-edge-upgrade.sh
│       ├── car-edge-network-mounts.sh
│       └── enable-setup-wizard.sh
├── docs/                      # User documentation
│   ├── QUICK-START.md        # 1-page getting started
│   ├── INSTALLATION.md       # Install methods
│   ├── NETWORK-STORAGE.md    # SMB/NFS guide
│   ├── VM-TESTING.md         # Testing in VMs
│   └── ... (other guides)
├── TESTING.md                 # Test checklist
├── TEST-EXECUTION-PLAN.md    # Detailed test plan
├── ROADMAP.md                # Development timeline
├── STATUS.md                 # Current status
└── README.md                 # Project overview
```

---

## 🐛 Reporting Bugs

### Before Reporting
1. Check existing issues: https://github.com/AhsenBaig-boilerplate/bazzite-car-edge/issues
2. Verify you're on latest build
3. Check TROUBLESHOOTING.md for known issues
4. Collect logs: `~/.cache/car-edge-setup.log`

### Bug Report Template
```markdown
**Description:**
Clear description of the bug

**Steps to Reproduce:**
1. Step one
2. Step two
3. Step three

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happened

**Environment:**
- Build: [commit SHA or ISO name]
- Hardware: [Beelink Mini S13 / VM / Other]
- Storage: [External drive connected: Yes/No]
- Network: [Connected: Yes/No]

**Logs:**
```
[Paste relevant logs from ~/.cache/car-edge-setup.log]
```

**Screenshots:**
[If applicable]
```

---

## ✨ Feature Requests

We welcome feature requests! Please:

1. **Check ROADMAP.md** to see if already planned
2. **Open an issue** with label "enhancement"
3. **Describe the use case** (not just the feature)
4. **Consider the target audience** (non-technical users)

### Feature Request Template
```markdown
**Feature Description:**
What feature do you want to see?

**Use Case:**
Why is this feature useful? Who would use it?

**Proposed Solution:**
How do you envision this working?

**Alternatives Considered:**
Other ways to solve this problem?

**Impact:**
- Beginner users: [Helpful / Neutral / Confusing]
- Advanced users: [Helpful / Neutral / Unnecessary]
- Maintenance burden: [Low / Medium / High]
```

---

## 🔧 Contributing Code

### Before You Start
1. **Check existing issues** - Avoid duplicate work
2. **Open an issue first** - Discuss approach before coding
3. **Keep PRs focused** - One feature/fix per PR
4. **Follow conventions** - Match existing code style

### Coding Guidelines

#### Bash Scripts
- Use `set -euo pipefail` at script start
- Add comments for non-obvious code
- Use functions for reusable code
- Include error handling
- Test with ShellCheck: `shellcheck script.sh`

```bash
#!/usr/bin/env bash
# Brief description of script purpose

set -euo pipefail

# Function names: lowercase_with_underscores
do_something() {
    local param="$1"
    
    # Always quote variables
    if [ -n "$param" ]; then
        echo "Parameter: $param"
    fi
}

# Main execution
main() {
    do_something "test"
}

main "$@"
```

#### Containerfile
- Comment each section
- Use multi-stage builds when beneficial
- Minimize layers
- Clean up temp files
- Pin base image to `:stable` not `:latest`

#### Documentation
- Use Markdown formatting
- Include code examples
- Add command output examples
- Link to related docs
- Keep line length reasonable (<120 chars)
- Use headers for navigation

### Commit Message Format

```
<type>: <short summary>

<detailed description if needed>

<breaking changes if any>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Adding/updating tests
- `chore:` Maintenance tasks

**Examples:**
```
feat: Add Bluetooth controller pairing wizard

Added GUI wizard for pairing Bluetooth controllers.
Uses kdialog for user interaction, scans for devices,
and configures Steam input automatically.

fix: Handle missing external drive gracefully

Wizard now checks if drive exists before formatting.
Shows clear error message and skip option if not found.

docs: Update QUICK-START.md with network storage steps

Added section 2.5 covering SMB/NFS configuration during
first boot setup.
```

### Pull Request Process

1. **Fork the repository**
2. **Create a feature branch** from `main`
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Write clear commit messages
   - Test your changes
   - Update documentation
4. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Open Pull Request**
   - Use PR template (if provided)
   - Reference related issues
   - Describe what you changed and why
6. **Address review feedback**
7. **Squash commits if requested**
8. **Wait for merge**

---

## 🧪 Testing Requirements

### For New Features
- [ ] Add to TESTING.md checklist
- [ ] Test in VM environment
- [ ] Test error scenarios
- [ ] Update documentation
- [ ] Add to ROADMAP.md if significant

### For Bug Fixes
- [ ] Verify fix resolves issue
- [ ] Test doesn't break other features
- [ ] Add test case to prevent regression
- [ ] Update TROUBLESHOOTING.md if applicable

### Running Tests
```bash
# Automated tests
./test-system.sh

# Manual wizard test
car-edge-setup-wizard --force

# Check for ShellCheck issues
shellcheck build_files/**/*.sh

# Validate Containerfile
podman build --no-cache -t test .
```

---

## 📝 Documentation

### When to Update Documentation

**Always update docs for:**
- New features
- Changed behavior
- New commands or options
- Installation steps changes
- Configuration changes

**Which docs to update:**
- `README.md` - High-level overview
- `QUICK-START.md` - If affects first-time setup
- `docs/CONFIGURATION.md` - If new config option
- `docs/TROUBLESHOOTING.md` - If new common issue
- `TESTING.md` - If new test needed
- `ROADMAP.md` - If affects timeline

### Documentation Style

- **Use headers** for navigation
- **Use code blocks** for commands
- **Use tables** for comparisons
- **Use lists** for steps
- **Use bold** for emphasis
- **Use links** for cross-references

**Example:**
```markdown
## Feature Name

**Description:** What this feature does

**Usage:**
```bash
command --option value
```

**Example:**
```bash
# Comment explaining example
car-edge-network-mounts configure
```

**See also:** [Related Doc](link.md)
```

---

## 🎨 UI/UX Guidelines

### For kdialog Wizards

- **Keep text concise** - Users skim, don't read walls of text
- **Use positive language** - "Continue" not "Don't Stop"
- **Provide context** - Explain what will happen
- **Show progress** - Use progress bars for long operations
- **Handle errors gracefully** - Clear messages, offer retry
- **Estimate time** - "This will take ~5 minutes"
- **Confirm destructive actions** - "This will format drive X"

### Error Messages

**Bad:**
```
Error: Command failed with code 1
```

**Good:**
```
Failed to format external drive.

Possible causes:
• Drive is not connected
• Drive is read-only
• Insufficient permissions

Would you like to:
[ Retry ]  [ Skip ]  [ View Log ]
```

### Success Messages

**Bad:**
```
Done.
```

**Good:**
```
Setup Complete! 🎉

Your car entertainment system is ready.

Next steps:
• Copy media to /mnt/storage/media/
• Launch Kodi from Gaming Mode
• Check out QUICK-START.md for tips

[ Continue to Gaming Mode ]
```

---

## 🏷️ Versioning

We follow [Semantic Versioning](https://semver.org/):

- **Major** (X.0.0): Breaking changes, major rewrites
- **Minor** (0.X.0): New features, backward compatible
- **Patch** (0.0.X): Bug fixes, small improvements

**Current:** v2.0 (pre-release)

---

## 📜 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information
- Other conduct inappropriate for a professional setting

### Enforcement

Violations can be reported to project maintainers. All complaints will be reviewed and investigated.

---

## 🤝 Getting Help

### For Contributors

- **GitHub Discussions:** For questions about contributing
- **Issues:** For bugs and feature requests
- **IRC/Matrix:** (If available)

### For Users

- **Documentation:** Check docs/ first
- **TROUBLESHOOTING.md:** Common issues
- **Issues:** Report bugs
- **Quick Start:** docs/QUICK-START.md

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

See [LICENSE](LICENSE) for details.

---

## 🙏 Recognition

Contributors are recognized in:
- GitHub Contributors page
- Release notes (for significant contributions)
- README (for major features)

---

## 🗺️ Roadmap

See [ROADMAP.md](ROADMAP.md) for:
- Current phase
- Upcoming features
- Long-term goals
- How to help

---

## ❓ Questions?

Not sure about something? Open an issue with the "question" label and we'll help!

**Thank you for contributing to Bazzite Car Edge! 🚗💨**
