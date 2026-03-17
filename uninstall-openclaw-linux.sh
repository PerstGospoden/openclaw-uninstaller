#!/usr/bin/env bash
set -u

TARGET="openclaw"
FOUND=0
OFFICIAL_OK=0
DRY_RUN=0
PATTERN='openclaw|openclaw-gateway|claw-gateway|openclawd'

usage() {
  cat <<'EOF'
Usage: ./uninstall-openclaw-linux.sh [--dry-run|-n] [--help|-h]
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --help|-h) usage; exit 0 ;;
  esac
done

step() { printf "\n==> [%s] %s\n" "$1" "$2"; }
info() { printf " - %s\n" "$1"; }
cmd_exists() { command -v "$1" >/dev/null 2>&1; }
run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    info "[dry-run] $*"
    return 0
  fi
  "$@" >/dev/null 2>&1 || true
}

remove_if_exists() {
  local p="$1"
  if [ -e "$p" ] || [ -L "$p" ]; then
    info "removing $p"
    run_cmd rm -rf "$p"
    FOUND=1
  fi
}

is_installed() {
  local p
  cmd_exists "$TARGET" && return 0
  pgrep -f "$PATTERN" >/dev/null 2>&1 && return 0
  for p in \
    "$HOME/.openclaw" \
    "$HOME/.config/openclaw" \
    "$HOME/.cache/openclaw" \
    "$HOME/.local/bin/openclaw" \
    "/usr/local/bin/openclaw" \
    "/usr/bin/openclaw"
  do
    [ -e "$p" ] && return 0
  done
  npm list -g --depth=0 openclaw >/dev/null 2>&1 && return 0
  npm list -g --depth=0 @openclaw/cli >/dev/null 2>&1 && return 0
  return 1
}

is_remaining() {
  cmd_exists "$TARGET" && return 0
  pgrep -f "$PATTERN" >/dev/null 2>&1 && return 0
  return 1
}

step "0/5" "流程说明"
info "1) 检测 openclaw 是否安装"
info "2) 优先尝试官方卸载命令"
info "3) 如仍残留，再停止 openclaw 相关进程/服务（含 gateway）并执行兜底卸载"
info "4) 清理残留文件与配置"
info "5) 最终验证卸载结果"
[ "$DRY_RUN" -eq 1 ] && info "当前为预览模式，不会真正修改系统"

step "1/5" "检测安装状态"
if is_installed; then
  FOUND=1
  info "检测到 openclaw 或相关运行痕迹，继续卸载。"
else
  info "未检测到 openclaw，已跳过卸载。"
  exit 0
fi

step "2/5" "优先尝试官方卸载命令"
if cmd_exists "$TARGET"; then
  info "running official uninstall command"
  run_cmd "$TARGET" uninstall --all --yes
  if [ "$DRY_RUN" -eq 0 ] && ! is_remaining; then
    OFFICIAL_OK=1
    info "official uninstall completed successfully"
  fi
else
  info "official cli not found, skip direct uninstall"
fi

step "3/5" "停止相关进程/服务并执行兜底卸载"
if [ "$OFFICIAL_OK" -eq 1 ]; then
  info "official uninstall succeeded; skipping most fallback actions"
elif is_remaining; then
  if pgrep -f "$PATTERN" >/dev/null 2>&1; then
    info "stopping processes by pattern: $PATTERN"
    run_cmd pkill -f "$PATTERN"
    run_cmd sudo pkill -f "$PATTERN"
  else
    info "no running openclaw process found"
  fi

  if cmd_exists systemctl; then
    for svc in openclaw openclaw-gateway claw-gateway openclawd; do
      run_cmd sudo systemctl stop "$svc"
      run_cmd sudo systemctl disable "$svc"
    done
    info "systemd services stop/disable attempted"
  fi
else
  info "official uninstall appears successful; fallback cleanup continues"
fi

for pkg in openclaw @openclaw/cli @openclaw/openclaw; do
  cmd_exists npm && run_cmd npm uninstall -g "$pkg"
  cmd_exists pnpm && run_cmd pnpm remove -g "$pkg"
  cmd_exists yarn && run_cmd yarn global remove "$pkg"
done
info "node package uninstall attempted"

if [ "$OFFICIAL_OK" -ne 1 ]; then
  cmd_exists apt-get && run_cmd sudo apt-get remove -y openclaw
  cmd_exists dnf && run_cmd sudo dnf remove -y openclaw
  cmd_exists yum && run_cmd sudo yum remove -y openclaw
  cmd_exists pacman && run_cmd sudo pacman -Rns --noconfirm openclaw
  cmd_exists zypper && run_cmd sudo zypper -n rm openclaw
  cmd_exists snap && run_cmd sudo snap remove openclaw
  cmd_exists flatpak && run_cmd flatpak uninstall -y openclaw
  cmd_exists brew && run_cmd brew uninstall openclaw
  info "os package manager uninstall attempted"

  for p in \
    "/usr/local/bin/openclaw" \
    "/usr/bin/openclaw" \
    "$HOME/.local/bin/openclaw" \
    "$HOME/bin/openclaw" \
    "$HOME/.openclaw/bin/openclaw"
  do
    if [ -e "$p" ] || [ -L "$p" ]; then
      if [ -w "$p" ]; then
        remove_if_exists "$p"
      else
        info "need sudo to remove $p"
        run_cmd sudo rm -f "$p"
        FOUND=1
      fi
    fi
  done
fi

step "4/5" "清理残留文件"
remove_if_exists "$HOME/.openclaw"
remove_if_exists "$HOME/.config/openclaw"
remove_if_exists "$HOME/.cache/openclaw"
remove_if_exists "$HOME/.local/share/openclaw"

if [ -d "$HOME/openclaw/.git" ] || [ -d "$HOME/src/openclaw/.git" ]; then
  info "detected possible git-based OpenClaw source checkout; repository is kept as-is"
fi

step "5/5" "最终检查"
if cmd_exists "$TARGET" || pgrep -f "$PATTERN" >/dev/null 2>&1; then
  info "openclaw 仍有残留，请手动排查 PATH 或服务。"
  cmd_exists "$TARGET" && info "command path: $(command -v "$TARGET")"
  exit 1
fi

echo "卸载完成: openclaw 已清理。"
