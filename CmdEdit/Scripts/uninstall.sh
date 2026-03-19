#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ZSH_SNIPPET="source $ROOT_DIR/ShellIntegration/cmdedit.zsh"

remove_app() {
  local target="$1"
  if [[ -d "$target" ]]; then
    rm -rf "$target"
    echo "Removed $target"
  fi
}

remove_app "/Applications/CmdEdit.app"
remove_app "$HOME/Applications/CmdEdit.app"

if [[ -f "$HOME/.zshrc" ]]; then
  tmp_file="$(mktemp)"
  grep -Fv "$ZSH_SNIPPET" "$HOME/.zshrc" | grep -Fv "# CmdEdit" > "$tmp_file" || true
  mv "$tmp_file" "$HOME/.zshrc"
  echo "Removed CmdEdit shell integration from ~/.zshrc"
fi

echo ""
echo "CmdEdit uninstalled."
echo "If your current shell still has the widget loaded, open a new terminal tab or run: exec zsh"
