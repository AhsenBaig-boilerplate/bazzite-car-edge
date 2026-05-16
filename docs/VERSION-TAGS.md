# Version Tags - Quick Reference

## 🎯 Which Tag Should I Use?

### **Just use `:latest` or `:stable`** ⭐

They're the easiest to type and always give you the newest version!

---

## 📦 Available Tags

All builds automatically create multiple tags pointing to the same image:

| Tag | Example | When to Use |
|-----|---------|-------------|
| **`latest`** ⭐ | `:latest` | **Recommended** - Always newest version (6 letters!) |
| **`stable`** | `:stable` | Alias for latest (same image) |
| **`20260516`** | `:20260516` | Specific date - use if you want a pinned version |
| `20260516-636d6e7` | `:20260516-636d6e7` | Date + commit hash (for debugging/troubleshooting) |
| `latest.20260516` | `:latest.20260516` | Date-tagged latest (rarely needed) |

---

## 💡 Common Commands

### Update to Latest

```bash
# Easiest (recommended)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:stable

# Or use 'latest' (same thing)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:latest

# Reboot to apply
sudo systemctl reboot
```

### Pin to Specific Date

```bash
# Use date-only tag (no commit hash needed!)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:20260516
sudo systemctl reboot
```

### Troubleshooting - Use Full Tag

```bash
# Only needed if you want exact commit for debugging
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ahsenbaig-boilerplate/bazzite-car-edge:20260516-636d6e7
sudo systemctl reboot
```

---

## 🔍 How Tags Work

### Each Build Creates 5 Tags:

When code is pushed to `main`, GitHub Actions builds and tags the image:

```
Build on 2026-05-16 from commit 636d6e7

Creates tags:
├── latest              ← Always points to newest
├── stable              ← Same as latest
├── 20260516            ← Just the date
├── 20260516-636d6e7    ← Date + commit
└── latest.20260516     ← Date-tagged latest
```

**They're all the same image!** Pick whichever is easiest for you.

---

## ❓ FAQ

### Q: What's the difference between `latest` and `stable`?

**A:** None! They're aliases - same image, different names. Use whichever you prefer.

### Q: Should I use the commit hash tags?

**A:** **No, not usually.** Use `:latest` or `:stable` for normal updates. Only use commit hash tags (`20260516-636d6e7`) if:
- You're debugging a specific issue
- Someone asks you "what exact version are you running?"
- You need to rollback to a specific build

### Q: How do I know what version I'm on?

```bash
rpm-ostree status

# Look for the line with ●
# Example output:
# ● ostree-unverified-registry:ghcr.io/.../bazzite-car-edge:20260516-636d6e7
```

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
