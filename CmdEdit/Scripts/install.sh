#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/build/CmdEdit.app"
ZSH_SNIPPET="source $ROOT_DIR/ShellIntegration/cmdedit.zsh"

if [[ -w "/Applications" ]]; then
  TARGET_DIR="/Applications"
else
  TARGET_DIR="$HOME/Applications"
  mkdir -p "$TARGET_DIR"
fi

TARGET_APP="$TARGET_DIR/CmdEdit.app"

echo "Building CmdEdit..."
bash "$ROOT_DIR/Scripts/build.sh"

echo "Installing app bundle to $TARGET_DIR..."
rm -rf "$TARGET_APP"
cp -R "$APP_BUNDLE" "$TARGET_APP"

if [[ -f "$HOME/.zshrc" ]]; then
  if ! grep -Fq "$ZSH_SNIPPET" "$HOME/.zshrc"; then
    {
      echo ""
      echo "# CmdEdit"
      echo "$ZSH_SNIPPET"
    } >> "$HOME/.zshrc"
    echo "Added CmdEdit to ~/.zshrc"
  else
    echo "CmdEdit is already configured in ~/.zshrc"
  fi
else
  {
    echo "# CmdEdit"
    echo "$ZSH_SNIPPET"
  } > "$HOME/.zshrc"
  echo "Created ~/.zshrc and added CmdEdit"
fi

echo ""
echo "CmdEdit installed."
echo "App location: $TARGET_APP"
echo "Next step: run 'source ~/.zshrc' or open a new terminal tab."
echo "Use Ctrl+E in zsh to edit the current command."
