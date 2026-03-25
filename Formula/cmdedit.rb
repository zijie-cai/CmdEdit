class Cmdedit < Formula
  desc "Native macOS command editor overlay for zsh"
  homepage "https://github.com/zijie-cai/CmdEdit"
  url "https://github.com/zijie-cai/CmdEdit/releases/download/v1.0.0/CmdEdit-1.0.0.zip"
  sha256 "02521942c300c532b5e0f9c4073eee1afdb763360e62cea977c43da8c71da32b"
  version "1.0.0"

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
