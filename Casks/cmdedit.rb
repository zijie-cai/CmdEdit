cask "cmdedit" do
  version "1.0.0"
  sha256 "a815edf57cf65dbc29a67ccdfc0547690b4fc8feb47ff34828dd66bfe1b9a6b2"

  url "https://github.com/zijie-cai/CmdEdit/releases/download/v1.0.0/CmdEdit-1.0.0.zip"
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
    snippet = '[[ -f "$HOME/.cmdedit/cmdedit.zsh" ]] && source "$HOME/.cmdedit/cmdedit.zsh"'

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
