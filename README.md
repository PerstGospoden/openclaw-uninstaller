<div align="center">

# 🦞 openclaw-uninstaller

[English](README.en.md)

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-blue)](#)
[![Shell](https://img.shields.io/badge/scripts-PowerShell%20%2B%20Shell-1f6feb)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

**跨平台 OpenClaw 一键卸载脚本**

_干净卸载，清晰可见；先走官方路径，再做兼容兜底。_

</div>

这个仓库专注做一件事：尽可能兼容 OpenClaw 的常见安装来源，并给用户一个清晰、可预览、可直接从 GitHub 远程执行的卸载方案。

## ✨ 特性

- 🖥️ 支持 Windows / macOS / Linux
- 🧭 优先调用官方卸载命令：`openclaw uninstall --all --yes`
- 📦 兼容 npm / pnpm / yarn 全局安装卸载
- 🔎 兼容 one-liner 安装后的常见命令路径和残留目录
- 🧹 在官方卸载后仍会继续执行 Node 全局包卸载，避免 npm 包残留
- 👀 支持 `--dry-run` / `-DryRun` 预览模式
- 📋 输出分步骤日志，便于用户理解当前执行进度
- 🛡️ 对 Hackable / Git 源码方式保持保守处理，默认不删除源码仓库

## **🚀 卸载脚本**

> **直接使用这 3 个脚本即可完成跨平台卸载：**

- **🪟 Windows**: `uninstall-openclaw-windows.ps1`
- **🍎 macOS**: `uninstall-openclaw-macos.sh`
- **🐧 Linux**: `uninstall-openclaw-linux.sh`

> **脚本默认策略：先尝试官方卸载，再执行 npm / pnpm / yarn 卸载，最后按残留情况做兜底清理。**

## **⚡ 复制即用**

> **想直接执行？复制下面的命令即可。**

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

## 🔄 卸载流程

```text
1. 检测是否安装 openclaw
2. 优先尝试官方卸载命令
3. 如仍有残留，再停止相关进程/服务并执行兜底卸载
4. 清理残留文件与配置
5. 最终校验是否仍存在命令或进程
```

额外说明：

- ✅ 如果官方卸载成功，脚本仍会继续执行 npm / pnpm / yarn 的全局包卸载
- ⏭️ 其他大多数重型兜底动作会被跳过
- 🧰 如果官方卸载后仍有残留，脚本会继续尝试包管理器卸载、服务停止、路径删除等动作

## ⚡ 远程一键卸载

无需先下载脚本，可直接从 GitHub 执行。上面的“复制即用”区块就是推荐入口。

## 👀 预览模式

如果你想先看脚本会做什么，而不真正修改系统，可以使用 dry-run。

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

## 💻 本地运行

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

## 🧹 会清理什么

脚本会根据平台尽量清理这些内容：

- 🧩 `openclaw` 可执行命令及常见安装路径
- 📁 `~/.openclaw`
- ⚙️ `~/.config/openclaw`
- 🗂️ `~/.cache/openclaw`
- 🍎 macOS 下的 `~/Library/Application Support/openclaw`
- 🍎 macOS 下的 `~/Library/Caches/openclaw`
- 🪟 Windows 下的 `%APPDATA%\openclaw`
- 🪟 Windows 下的 `%LOCALAPPDATA%\openclaw`
- 📦 Node 全局安装留下的命令、模块与 shim 文件

## 🚫 不会默认做什么

- 🧪 不会强制删除你本地的 OpenClaw 源码仓库
- 🔒 不会修改 Git 配置
- 🚷 不会自动推送或执行与卸载无关的系统操作

## 🔐 安全提示

- 📖 建议在执行远程命令前先阅读脚本内容
- 🔑 某些清理动作需要管理员权限或 `sudo`
- ⛔ 对正在运行中的 OpenClaw，脚本可能会在兜底阶段停止相关服务和进程

## 📄 License

MIT

---

<div align="center">

Made with care for clean OpenClaw removal.

</div>
