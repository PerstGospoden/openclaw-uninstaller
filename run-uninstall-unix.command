#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UNINSTALL_SCRIPT="$SCRIPT_DIR/uninstall-openclaw-unix.sh"

if [ ! -f "$UNINSTALL_SCRIPT" ]; then
  printf 'Could not find uninstall-openclaw-unix.sh next to this file.\n'
  printf 'Press Enter to close...'
  read -r _
  exit 1
fi

chmod +x "$UNINSTALL_SCRIPT" >/dev/null 2>&1 || true
printf 'Launching OpenClaw uninstaller...\n'
bash "$UNINSTALL_SCRIPT"
printf '\nFinished. Press Enter to close...'
read -r _
