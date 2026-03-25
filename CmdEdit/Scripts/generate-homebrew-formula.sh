#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
VERSION="${1:-}"
SHA256="${2:-}"

if [[ -z "$VERSION" || -z "$SHA256" ]]; then
  echo "Usage: bash CmdEdit/Scripts/generate-homebrew-formula.sh <version> <sha256>"
  exit 1
fi

mkdir -p "$REPO_ROOT/Formula"

cat > "$REPO_ROOT/Formula/cmdedit.rb" <<EOF
class Cmdedit < Formula
  desc "Native macOS command editor overlay for zsh"
  homepage "https://github.com/zijie-cai/CmdEdit"
  url "https://github.com/zijie-cai/CmdEdit/releases/download/v$VERSION/CmdEdit-$VERSION.zip"
  sha256 "$SHA256"
  version "$VERSION"

  def install
    package_root = Dir["CmdEdit-*"].find { |path| File.directory?(path) } || "."
    prefix.install "#{package_root}/CmdEdit.app"
    prefix.install "#{package_root}/cmdedit.zsh"
  end

  def caveats
    <<~EOS
      Add CmdEdit to zsh by placing this in ~/.zshrc:

        [[ -f "#{opt_prefix}/cmdedit.zsh" ]] && source "#{opt_prefix}/cmdedit.zsh"

      CmdEdit.app is installed at:

        #{opt_prefix}/CmdEdit.app

      The shell integration will look there automatically.
    EOS
  end

  test do
    assert_predicate prefix/"CmdEdit.app", :exist?
    assert_predicate prefix/"cmdedit.zsh", :exist?
  end
end
EOF

echo "Generated Homebrew formula:"
echo "  $REPO_ROOT/Formula/cmdedit.rb"
