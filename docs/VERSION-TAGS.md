# Version Tags - Quick Reference

## 🎯 Which Tag Should I Use?

### **Just use `:latest` or `:stable`** ⭐

They're the easiest to type and always give you the newest version!

---

## 📦 Professional Semantic Versioning

Bazzite Car Edge uses **professional semantic versioning** like commercial software:

| Tag | Example | When to Use |
|-----|---------|-------------|
| **`latest`** ⭐ | `:latest` | **Recommended** - Always newest release |
| **`stable`** | `:stable` | Production channel (same as latest) |
| **`v1.0.0-build.123-abc1234`** | `:v1.0.0-build.123-abc1234` | Specific version with commit for debugging |
| `v1.0.0-build.123` | `:v1.0.0-build.123` | Specific version (no commit hash) |
| `build.123` | `:build.123` | Just the build number reference |

### 🔢 Version Number Breakdown

**Format:** `v{MAJOR}.{MINOR}.{PATCH}-build.{BUILD}-{COMMIT}`

**Example:** `v1.2.3-build.456-abc1234`

- **`v1`** - Major version (breaking changes)
- **`.2`** - Minor version (new features)
- **`.3`** - Patch version (bug fixes)
- **`build.456`** - Auto-incremented build number (from GitHub Actions)
- **`abc1234`** - Short git commit hash (7 characters)

**For Parents/End Users:** Just remember "Version 1.2.3 - Build 456" - that's all you need!

---

## 💡 Common Commands

### Update to Latest (Recommended)

**\ud83d\udc46 Use the GUI:** Open **Control Panel** \u2192 **System Updates** \u2192 **Check for Updates**

**Terminal way:**

```bash
# Easiest (recommended)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:stable

# Or use 'latest' (same thing)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest

# Reboot to apply
sudo systemctl reboot
```

### Pin to Specific Version

```bash
# Pin to a specific version number
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:v1.0.0-build.123
sudo systemctl reboot
```

### Troubleshooting - Use Full Version Tag

```bash
# Only needed if you want exact build for debugging
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:v1.0.0-build.123-abc1234
sudo systemctl reboot
```

---

## 🔍 How Tags Work

### Each Build Creates 5 Tags:

When code is pushed to `main`, GitHub Actions automatically builds and tags the image:

```
Build #456 from commit abc1234 (Version 1.0.0)

Creates tags:
├── latest                          ← Always points to newest
├── stable                          ← Production channel
├── v1.0.0-build.456-abc1234       ← Full version with commit hash
├── v1.0.0-build.456               ← Version without commit
└── build.456                       ← Just build number
```

**They're all the same image!** Pick whichever is easiest for you.

### 🔄 Version Bumping

**Build numbers** auto-increment with every build (no manual action needed).

**Version numbers** (v1.0.0) are bumped manually in `.github/workflows/build.yml`:

- **Major version** (v2.0.0): Breaking changes, major redesigns
- **Minor version** (v1.1.0): New features, significant updates
- **Patch version** (v1.0.1): Bug fixes, minor improvements

This follows **Semantic Versioning 2.0.0** standard (https://semver.org/).

---

## ❓ FAQ

### Q: What's the difference between `latest` and `stable`?

**A:** None! They're aliases - same image, different names. Use whichever you prefer.

### Q: Should I use the full version tags with commit hashes?

**A:** **Not usually.** Use `:latest` or `:stable` for normal updates. Only use full version tags (`v1.0.0-build.123-abc1234`) if:
- You're debugging a specific issue
- Someone asks you "what exact build are you running?"
- You need to pin to a specific version
- You're reporting a bug and need to include version details

### Q: How do I know what version I'm on?

**Easy way:** Open the **Control Panel** app from your application menu:
- Click "System Updates"
- Click "View System Version Info"
- You'll see: "Version 1.0.0 - Build 123 (abc1234)"

**Terminal way:**

```bash
rpm-ostree status

# Look for the line with ●
# Example output:
# ● ostree-unverified-registry:ghcr.io/.../bazzite-car-edge:v1.0.0-build.123-abc1234
#   Version: v1.0.0-build.123-abc1234
```

### Q: What does "Build 123" mean?

**A:** It's an auto-incrementing number from GitHub Actions. Each time code is updated and built:
- Build 122 → Build 123 → Build 124...
- Higher number = newer build
- Helps you know if you're on the latest version

### Q: Can I mix tags (upgrade from `20260515` to `latest`)?

**A:** Yes! All tags are compatible. You can switch between any tag at any time.

---

## 🎯 Pro Tips

### 1. **Bookmark the short command:**

```bash
# Save this as an alias or note
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:stable
```

### 2. **Use car-edge commands:**

The built-in commands already handle this for you!

```bash
car-edge-check-updates    # Checks for latest
car-edge-switch-version   # Shows all available versions
```

### 3. **Auto-complete the URL:**

Most terminals support tab-completion. Type the beginning and press TAB:

```bash
rpm-ostree rebase ostree-<TAB>
```

---

## 📋 Summary

**90% of users:** Just use `:stable` or `:latest`  
**10% of users:** Use date tags (`:20260516`) to pin versions  
**1% of users:** Use full commit tags for debugging

**Make it easy on yourself - use the simple tags!** 🎉
