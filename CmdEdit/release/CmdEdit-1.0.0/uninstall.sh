#!/bin/bash
set -euo pipefail

SUPPORT_DIR="$HOME/.cmdedit"
INSTALLED_ZSH="$SUPPORT_DIR/cmdedit.zsh"
ZSH_SNIPPET='[[ -f "$HOME/.cmdedit/cmdedit.zsh" ]] && source "$HOME/.cmdedit/cmdedit.zsh"'

remove_app() {
  local target="$1"
  if [[ -d "$target" ]]; then
    rm -rf "$target"
    echo "Removed $target"
  fi
}

remove_app "/Applications/CmdEdit.app"
remove_app "$HOME/Applications/CmdEdit.app"

if [[ -f "$INSTALLED_ZSH" ]]; then
  rm -f "$INSTALLED_ZSH"
fi

if [[ -d "$SUPPORT_DIR" ]]; then
  rmdir "$SUPPORT_DIR" 2>/dev/null || true
fi

if [[ -f "$HOME/.zshrc" ]]; then
  tmp_file="$(mktemp)"
  grep -Fv "$ZSH_SNIPPET" "$HOME/.zshrc" | grep -Fv "# CmdEdit" > "$tmp_file" || true
  mv "$tmp_file" "$HOME/.zshrc"
  echo "Removed CmdEdit shell integration from ~/.zshrc"
fi

echo ""
echo "CmdEdit uninstalled."
echo "If your current shell still has the widget loaded, open a new terminal tab or run: exec zsh"
