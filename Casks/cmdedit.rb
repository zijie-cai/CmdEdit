cask "cmdedit" do
  version "1.0.4"
  sha256 "8870d4628f74d8e36d703ad5653bcc4e5ef814cf2e973785b1ea8e58c3ced5de"

  url "https://github.com/zijie-cai/CmdEdit/releases/download/v1.0.4/CmdEdit.zip"
  name "CmdEdit"
  desc "Native macOS command editor overlay for zsh"
  homepage "https://github.com/zijie-cai/CmdEdit"

  app "CmdEdit-#{version}/CmdEdit.app"
  artifact "CmdEdit-#{version}/cmdedit.zsh", target: "#{Dir.home}/.cmdedit/cmdedit.zsh"

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
