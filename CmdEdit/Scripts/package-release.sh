#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-$(git -C "$ROOT_DIR/.." describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)}"

if [[ -z "$VERSION" ]]; then
  VERSION="0.1.0"
fi

STAGING_ROOT="$ROOT_DIR/release/CmdEdit-$VERSION"
ZIP_PATH="$ROOT_DIR/release/CmdEdit-$VERSION.zip"

echo "Packaging CmdEdit $VERSION..."
bash "$ROOT_DIR/Scripts/build.sh" "$VERSION"

rm -rf "$STAGING_ROOT" "$ZIP_PATH"
mkdir -p "$STAGING_ROOT"

cp -R "$ROOT_DIR/build/CmdEdit.app" "$STAGING_ROOT/CmdEdit.app"
cp "$ROOT_DIR/Scripts/install.sh" "$STAGING_ROOT/install.sh"
cp "$ROOT_DIR/Scripts/uninstall.sh" "$STAGING_ROOT/uninstall.sh"
cp "$ROOT_DIR/ShellIntegration/cmdedit.zsh" "$STAGING_ROOT/cmdedit.zsh"
cp "$ROOT_DIR/../LICENSE" "$STAGING_ROOT/LICENSE"

cat > "$STAGING_ROOT/README.txt" <<EOF
CmdEdit $VERSION

Install:
  bash install.sh

Uninstall:
  bash uninstall.sh

After install:
  source ~/.zshrc
EOF

chmod +x "$STAGING_ROOT/install.sh" "$STAGING_ROOT/uninstall.sh"

mkdir -p "$ROOT_DIR/release"
ditto -c -k --sequesterRsrc --keepParent "$STAGING_ROOT" "$ZIP_PATH"

SHA="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"

echo ""
echo "Release zip created:"
echo "  $ZIP_PATH"
echo "SHA256:"
echo "  $SHA"
echo ""
echo "Next step:"
echo "  bash Scripts/generate-homebrew-formula.sh $VERSION $SHA"
