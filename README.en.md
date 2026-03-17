<div align="center">

# 🦞 openclaw-uninstaller

[中文](README.md)

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-blue)](#)
[![Shell](https://img.shields.io/badge/scripts-PowerShell%20%2B%20Shell-1f6feb)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

**Cross-platform one-click uninstall scripts for OpenClaw**

_Clean uninstall, visible steps, official path first, compatibility fallback second._

</div>

This repository focuses on one thing: uninstall OpenClaw cleanly across common installation methods, with clear logs, remote execution support, and a safe preview mode.

## ✨ Features

- 🖥️ Supports Windows / macOS / Linux
- 🧭 Tries the official uninstall first: `openclaw uninstall --all --yes`
- 📦 Handles npm / pnpm / yarn global installs
- 🔎 Detects common one-liner install paths and leftovers
- 🧹 Still removes Node global packages even if official uninstall succeeds
- 👀 Supports dry-run mode
- 📋 Prints step-by-step uninstall logs
- 🛡️ Keeps Hackable / Git source checkouts intact by default

## **🚀 Uninstall Scripts**

> **Use these 3 scripts directly for cross-platform OpenClaw uninstall:**

- **🪟 Windows**: `uninstall-openclaw-windows.ps1`
- **🍎 macOS**: `uninstall-openclaw-macos.sh`
- **🐧 Linux**: `uninstall-openclaw-linux.sh`

> **Default strategy: try official uninstall first, keep npm / pnpm / yarn cleanup, then run fallback cleanup only when traces remain.**

## **⚡ Copy and Run**

> **Want the fastest path? Copy one command and run it.**

### 🧭 Open a Terminal First

If you are not familiar with command-line tools yet, here is the quickest way to open one:

- **🪟 Windows**: press `Win`, search for `PowerShell`, then open `Windows PowerShell` or `Terminal`
- **🍎 macOS**: press `Command + Space`, type `Terminal`, then press Enter
- **🐧 Linux**: usually press `Ctrl + Alt + T`, or search for `Terminal` in your app menu

Once the terminal is open, copy the command for your system below and press Enter.

### 🪟 Windows

```powershell
irm https://raw.githubusercontent.com/hicoldcat/openclaw-uninstaller/main/uninstall-openclaw-windows.ps1 | iex
```

### 🍎 macOS

```bash
curl -fsSL https://raw.githubusercontent.com/hicoldcat/openclaw-uninstaller/main/uninstall-openclaw-macos.sh | bash
```

### 🐧 Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hicoldcat/openclaw-uninstaller/main/uninstall-openclaw-linux.sh | bash
```

## 🔄 Uninstall Flow

```text
1. Detect whether openclaw is installed
2. Try the official uninstall command first
3. If traces remain, stop related processes/services and run fallback uninstall
4. Clean leftover files and config
5. Verify final uninstall result
```

Notes:

- ✅ npm / pnpm / yarn global uninstall still runs after official uninstall
- ⏭️ most other heavy fallback actions are skipped if official uninstall already succeeded
- 🧰 if traces remain, the scripts continue with package-manager uninstall, service stop, and path cleanup

## ⚡ One-line Uninstall from GitHub

No manual download is required. The "Copy and Run" section above is the recommended entry point.

## 👀 Dry Run

Preview actions without modifying the system.

### 🪟 Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-openclaw-windows.ps1 -DryRun
```

### 🍎 macOS

```bash
./uninstall-openclaw-macos.sh --dry-run
```

### 🐧 Linux

```bash
./uninstall-openclaw-linux.sh --dry-run
```

## 💻 Run Locally

### 🪟 Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-openclaw-windows.ps1
```

### 🍎 macOS

```bash
chmod +x ./uninstall-openclaw-macos.sh
./uninstall-openclaw-macos.sh
```

### 🐧 Linux

```bash
chmod +x ./uninstall-openclaw-linux.sh
./uninstall-openclaw-linux.sh
```

## 🧹 What Gets Cleaned

- 🧩 `openclaw` binary and common install paths
- 📁 `~/.openclaw`
- ⚙️ `~/.config/openclaw`
- 🗂️ `~/.cache/openclaw`
- 🍎 macOS `~/Library/Application Support/openclaw`
- 🍎 macOS `~/Library/Caches/openclaw`
- 🪟 Windows `%APPDATA%\openclaw`
- 🪟 Windows `%LOCALAPPDATA%\openclaw`
- 📦 Node global package leftovers and shim files

## 🚫 What Is Not Removed by Default

- 🧪 your local OpenClaw source repository
- 🔒 unrelated system settings
- 🚷 Git configuration

## 🔐 Security Notes

- 📖 Review scripts before running remote piped commands
- 🔑 Some actions require Administrator or `sudo`
- ⛔ Running services/processes may be stopped during fallback cleanup

## 📄 License

MIT

---

<div align="center">

Made with care for clean OpenClaw removal.

</div>
