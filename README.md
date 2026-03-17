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
- ✅ 正式卸载前会先扫描环境并列出待清理内容，让用户确认后再执行
- 📋 输出分步骤日志，便于用户理解当前执行进度
- 🧾 最后会补充 PATH 和终端配置中的手动清理指引
- 🛡️ 对 Hackable / Git 源码方式保持保守处理，默认不删除源码仓库

## **🚀 卸载脚本**

> **直接使用这 2 个核心脚本即可完成跨平台卸载：**

- **💻 Windows**: `uninstall-openclaw-windows.ps1`
- **🍎 macOS / 🐧 Linux**: `uninstall-openclaw-unix.sh`

> **如果你不想手动打开命令行，也可以下载右键运行这些启动文件：**

- **💻 Windows**: `run-uninstall-windows.bat`
- **🍎 macOS**: `run-uninstall-unix.command`
- **🐧 Linux**: `run-uninstall-linux.sh`

> **脚本默认策略：先扫描并展示待卸载内容，确认后优先尝试官方卸载，再执行 npm / pnpm / yarn 卸载，最后按残留情况做兜底清理。**

## **⚡ 复制即用**

> **想直接执行？复制下面的命令即可。**

### 📦 下载 ZIP 后直接运行

如果你完全不想碰命令行，最简单的方式是下载 Release 里的 ZIP 压缩包：

1. 打开 GitHub 项目的 `Releases`
2. 下载 `openclaw-uninstaller-release.zip`
3. 解压到任意目录
4. 直接双击或右键运行下面的启动文件：

- **💻 Windows**: `run-uninstall-windows.bat`
- **🍎 macOS**: `run-uninstall-unix.command`
- **🐧 Linux**: `run-uninstall-linux.sh`

这样用户不需要自己输入命令，只需要下载、解压、运行即可。

### 🧭 先打开命令行工具

如果你还不熟悉怎么打开终端，可以按下面的方式进入：

- **💻 Windows**: 按 `Win` 键，搜索 `PowerShell`，打开 `Windows PowerShell` 或 `终端`
- **🍎 macOS**: 按 `Command + Space`，输入 `Terminal`，回车打开 `终端`
- **🐧 Linux**: 一般可按 `Ctrl + Alt + T`，或在应用菜单里搜索 `Terminal` / `终端`

打开后，把下面对应系统的命令复制进去，按回车即可运行。

### 🖱️ 不会用命令行？也可以右键运行文件

如果你不想手动输入命令，也可以直接下载仓库里的启动文件，然后双击或右键运行：

- **💻 Windows**: 下载 `run-uninstall-windows.bat`，双击即可运行
- **🍎 macOS**: 下载 `run-uninstall-unix.command`，右键或双击运行；如果系统拦截，可先在“系统设置 -> 隐私与安全性”里允许
- **🐧 Linux**: 下载 `run-uninstall-linux.sh`，右键选择 `Run as Program` / `作为程序运行`

提示：启动文件本质上只是帮你自动调用仓库里的卸载脚本，本身不会绕过确认流程。

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

## 🔄 卸载流程

```text
1. 扫描命令、进程、服务、全局包和残留文件
2. 把扫描结果完整列出来，让用户确认是否继续
3. 优先尝试官方卸载命令
4. 如仍有残留，再停止相关进程/服务并执行兜底卸载
5. 清理残留文件、注册表或系统级入口并重新校验
6. 如果 PATH 或 shell / PowerShell 配置仍有残留，告诉用户去哪里删除
```

额外说明：

- ✅ 如果官方卸载成功，脚本仍会继续执行 npm / pnpm / yarn 的全局包卸载
- ⏭️ 其他大多数重型兜底动作会被跳过
- 🧰 如果官方卸载后仍有残留，脚本会继续尝试包管理器卸载、服务停止、路径删除等动作
- 📝 如果环境变量里还有残留，脚本会明确提示去哪个 PATH 条目、哪个 shell 配置文件或 PowerShell 配置文件里删除

## ⚡ 远程一键卸载

无需先下载脚本，可直接从 GitHub 执行。上面的“复制即用”区块就是推荐入口。

## 👀 预览模式

如果你想先看脚本会做什么，而不真正修改系统，可以使用 dry-run。

如果你想跳过确认提示，也可以使用 `--yes` 或 `-Yes` 自动继续。

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

## 💻 本地运行

### 💻 Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-openclaw-windows.ps1
```

或直接双击：`run-uninstall-windows.bat`

### 🍎 macOS

```bash
chmod +x ./uninstall-openclaw-unix.sh
./uninstall-openclaw-unix.sh
```

或直接运行：`run-uninstall-unix.command`

### 🐧 Linux

```bash
chmod +x ./uninstall-openclaw-unix.sh
./uninstall-openclaw-unix.sh
```

或右键运行：`run-uninstall-linux.sh`

## 🧹 会清理什么

脚本会根据平台尽量清理这些内容：

- 🧩 `openclaw` 可执行命令及常见安装路径
- 📁 `~/.openclaw`
- ⚙️ `~/.config/openclaw`
- 🗂️ `~/.cache/openclaw`
- 🍎 macOS 下的 `~/Library/Application Support/openclaw`
- 🍎 macOS 下的 `~/Library/Caches/openclaw`
- 💻 Windows 下的 `%APPDATA%\openclaw`
- 💻 Windows 下的 `%LOCALAPPDATA%\openclaw`
- 📦 Node 全局安装留下的命令、模块与 shim 文件
- 🧩 部分系统级服务、桌面入口、启动项或注册表项（按平台差异处理）

## 🚫 不会默认做什么

- 🧪 不会强制删除你本地的 OpenClaw 源码仓库
- 🔒 不会修改 Git 配置
- 🚷 不会自动推送或执行与卸载无关的系统操作

## 🔐 安全提示

- 📖 建议在执行远程命令前先阅读脚本内容
- 🔑 某些清理动作需要管理员权限或 `sudo`
- ⛔ 对正在运行中的 OpenClaw，脚本可能会在兜底阶段停止相关服务和进程
- 🧯 如果脚本最后提示 PATH 或配置文件还有残留，请按提示手动修改后重新打开终端

## 📄 License

MIT

---

<div align="center">

Made with care for clean OpenClaw removal.

</div>
