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
- ✅ Scans the environment first and asks for confirmation before uninstalling
- 📋 Prints step-by-step uninstall logs
- 🧾 Shows manual PATH and terminal profile cleanup guidance at the end when needed
- 🛡️ Keeps Hackable / Git source checkouts intact by default

## **🚀 Uninstall Scripts**

> **Use these 2 core scripts directly for cross-platform OpenClaw uninstall:**

- **💻 Windows**: `uninstall-openclaw-windows.ps1`
- **🍎 macOS / 🐧 Linux**: `uninstall-openclaw-unix.sh`

> **Default strategy: scan first, show everything that will be cleaned, ask for confirmation, try official uninstall, keep npm / pnpm / yarn cleanup, then run fallback cleanup only when traces remain.**

## **⚡ Copy and Run**

> **Want the fastest path? Copy one command and run it.**

### 🧭 Open a Terminal First

If you are not familiar with command-line tools yet, here is the quickest way to open one:

- **💻 Windows**: press `Win`, search for `PowerShell`, then open `Windows PowerShell` or `Terminal`
- **🍎 macOS**: press `Command + Space`, type `Terminal`, then press Enter
- **🐧 Linux**: usually press `Ctrl + Alt + T`, or search for `Terminal` in your app menu

Once the terminal is open, copy the command for your system below and press Enter.

### 💻 Windows

```powershell
irm https://raw.githubusercontent.com/hicoldcat/openclaw-uninstaller/main/uninstall-openclaw-windows.ps1 | iex
```

### 🍎 macOS

```bash
curl -fsSL https://raw.githubusercontent.com/hicoldcat/openclaw-uninstaller/main/uninstall-openclaw-unix.sh | bash
```

### 🐧 Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hicoldcat/openclaw-uninstaller/main/uninstall-openclaw-unix.sh | bash
```

## 🔄 Uninstall Flow

```text
1. Scan commands, processes, services, global packages, and leftover files
2. Show the full result list and ask the user to confirm
3. Try the official uninstall command first
4. If traces remain, stop related processes/services and run fallback uninstall
5. Clean leftover files, registry/system entries, and verify again
6. If PATH or shell / PowerShell profiles still contain traces, show where to edit them
```

Notes:

- ✅ npm / pnpm / yarn global uninstall still runs after official uninstall
- ⏭️ most other heavy fallback actions are skipped if official uninstall already succeeded
- 🧰 if traces remain, the scripts continue with package-manager uninstall, service stop, and path cleanup
- 📝 if environment-variable traces remain, the scripts tell users which PATH entries or profile files to edit manually

## ⚡ One-line Uninstall from GitHub

No manual download is required. The "Copy and Run" section above is the recommended entry point.

## 👀 Dry Run

Preview actions without modifying the system.

If you want to skip the confirmation prompt, you can also use `--yes` or `-Yes`.

### 💻 Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-openclaw-windows.ps1 -DryRun
```

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-openclaw-windows.ps1 -Yes
```

### 🍎 macOS

```bash
./uninstall-openclaw-unix.sh --dry-run
```

```bash
./uninstall-openclaw-unix.sh --yes
```

### 🐧 Linux

```bash
./uninstall-openclaw-unix.sh --dry-run
```

```bash
./uninstall-openclaw-unix.sh --yes
```

## 💻 Run Locally

### 💻 Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-openclaw-windows.ps1
```

### 🍎 macOS

```bash
chmod +x ./uninstall-openclaw-unix.sh
./uninstall-openclaw-unix.sh
```

### 🐧 Linux

```bash
chmod +x ./uninstall-openclaw-unix.sh
./uninstall-openclaw-unix.sh
```

## 🧹 What Gets Cleaned

- 🧩 `openclaw` binary and common install paths
- 📁 `~/.openclaw`
- ⚙️ `~/.config/openclaw`
- 🗂️ `~/.cache/openclaw`
- 🍎 macOS `~/Library/Application Support/openclaw`
- 🍎 macOS `~/Library/Caches/openclaw`
- 💻 Windows `%APPDATA%\openclaw`
- 💻 Windows `%LOCALAPPDATA%\openclaw`
- 📦 Node global package leftovers and shim files
- 🧩 some service entries, desktop launchers, startup files, or registry keys depending on platform

## 🚫 What Is Not Removed by Default

- 🧪 your local OpenClaw source repository
- 🔒 unrelated system settings
- 🚷 Git configuration

## 🔐 Security Notes

- 📖 Review scripts before running remote piped commands
- 🔑 Some actions require Administrator or `sudo`
- ⛔ Running services/processes may be stopped during fallback cleanup
- 🧯 If the scripts report remaining PATH or profile traces, edit those files/entries manually and restart the terminal

## 📄 License

MIT

---

<div align="center">

Made with care for clean OpenClaw removal.

</div>
