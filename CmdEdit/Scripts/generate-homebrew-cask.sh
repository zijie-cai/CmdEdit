#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
VERSION="${1:-}"
SHA256="${2:-}"

if [[ -z "$VERSION" || -z "$SHA256" ]]; then
  echo "Usage: bash CmdEdit/Scripts/generate-homebrew-cask.sh <version> <sha256>"
  exit 1
fi

mkdir -p "$REPO_ROOT/Casks"

cat > "$REPO_ROOT/Casks/cmdedit.rb" <<EOF
cask "cmdedit" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/zijie-cai/CmdEdit/releases/download/v$VERSION/CmdEdit.zip"
  name "CmdEdit"
  desc "Native macOS command editor overlay for zsh"
  homepage "https://github.com/zijie-cai/CmdEdit"

  app "CmdEdit.app"
  artifact "cmdedit.zsh", target: "#{Dir.home}/.cmdedit/cmdedit.zsh"

  preflight do
    FileUtils.mkdir_p(File.expand_path("~/.cmdedit"))
  end

  postflight do
    zshrc = File.expand_path("~/.zshrc")
    snippet = '[[ -f "\$HOME/.cmdedit/cmdedit.zsh" ]] && source "\$HOME/.cmdedit/cmdedit.zsh"'

    unless File.exist?(zshrc) && File.read(zshrc).include?(snippet)
      File.open(zshrc, "a") do |file|
        file.puts
        file.puts "# CmdEdit"
        file.puts snippet
      end
    end
  end

  uninstall delete: [
    "/Applications/CmdEdit.app",
    "#{Dir.home}/Applications/CmdEdit.app",
    "#{Dir.home}/.cmdedit/cmdedit.zsh",
  ]

  zap delete: [
    "#{Dir.home}/.cmdedit",
  ]

  caveats <<~EOS
    CmdEdit was added to ~/.zshrc.

    Reload your shell:

      source ~/.zshrc

    Then use Ctrl+E in zsh to open CmdEdit.
  EOS
end
EOF

echo "Generated Homebrew cask:"
echo "  $REPO_ROOT/Casks/cmdedit.rb"
