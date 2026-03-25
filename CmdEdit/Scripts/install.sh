#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SUPPORT_DIR="$HOME/.cmdedit"
INSTALLED_ZSH="$SUPPORT_DIR/cmdedit.zsh"
ZSH_SNIPPET='[[ -f "$HOME/.cmdedit/cmdedit.zsh" ]] && source "$HOME/.cmdedit/cmdedit.zsh"'

find_app_bundle() {
  if [[ -d "$ROOT_DIR/build/CmdEdit.app" ]]; then
    printf '%s\n' "$ROOT_DIR/build/CmdEdit.app"
    return 0
  fi

  if [[ -d "$ROOT_DIR/CmdEdit.app" ]]; then
    printf '%s\n' "$ROOT_DIR/CmdEdit.app"
    return 0
  fi

  return 1
}

find_zsh_source() {
  if [[ -f "$ROOT_DIR/ShellIntegration/cmdedit.zsh" ]]; then
    printf '%s\n' "$ROOT_DIR/ShellIntegration/cmdedit.zsh"
    return 0
  fi

  if [[ -f "$ROOT_DIR/cmdedit.zsh" ]]; then
    printf '%s\n' "$ROOT_DIR/cmdedit.zsh"
    return 0
  fi

  return 1
}

if [[ -w "/Applications" ]]; then
  TARGET_DIR="/Applications"
else
  TARGET_DIR="$HOME/Applications"
  mkdir -p "$TARGET_DIR"
fi

TARGET_APP="$TARGET_DIR/CmdEdit.app"
APP_BUNDLE="$(find_app_bundle || true)"
ZSH_SOURCE="$(find_zsh_source || true)"

if [[ -z "$APP_BUNDLE" ]]; then
  if [[ -f "$ROOT_DIR/Scripts/build.sh" && -d "$ROOT_DIR/App" ]]; then
    echo "Building CmdEdit..."
    bash "$ROOT_DIR/Scripts/build.sh"
    APP_BUNDLE="$(find_app_bundle || true)"
  else
    echo "CmdEdit.app not found in $ROOT_DIR."
    exit 1
  fi
fi

if [[ -z "$APP_BUNDLE" ]]; then
  echo "Build completed but CmdEdit.app was not created in $ROOT_DIR."
  exit 1
fi

if [[ -z "$ZSH_SOURCE" ]]; then
  echo "cmdedit.zsh not found in $ROOT_DIR."
  exit 1
fi

echo "Installing app bundle to $TARGET_DIR..."
rm -rf "$TARGET_APP"
cp -R "$APP_BUNDLE" "$TARGET_APP"

mkdir -p "$SUPPORT_DIR"
cp "$ZSH_SOURCE" "$INSTALLED_ZSH"

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
echo "Shell integration: $INSTALLED_ZSH"
echo "Next step: run 'source ~/.zshrc' or open a new terminal tab."
echo "Use Ctrl+E in zsh to edit the current command."
