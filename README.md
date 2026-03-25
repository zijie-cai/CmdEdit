# CmdEdit

CmdEdit is a native macOS command editor overlay for `zsh`.

Press `Ctrl+E`, edit the current shell command in a focused floating window, then save it back to your prompt.

## Requirements

- macOS 14+
- `zsh`
- Xcode Command Line Tools or a local Swift toolchain

```bash
xcode-select --install
```

## Install From Source

```bash
git clone --depth 1 https://github.com/zijie-cai/CmdEdit.git && bash CmdEdit/CmdEdit/Scripts/install.sh && source ~/.zshrc
```

## Install From Release Zip

1. Download a release zip from GitHub Releases
2. Extract it
3. Run:

```bash
bash install.sh
source ~/.zshrc
```

## Homebrew

CmdEdit can be packaged for a Homebrew tap from a release zip.

Release packaging:

```bash
bash CmdEdit/Scripts/package-release.sh 1.0.0
```

Generate formula from the release zip checksum:

```bash
bash CmdEdit/Scripts/generate-homebrew-formula.sh 1.0.0 <sha256>
```

The generated formula is written to:

`Formula/cmdedit.rb`

Upload the matching zip to a GitHub release tagged `v1.0.0` before using the formula.

## Usage

- `Ctrl+E` opens CmdEdit from `zsh`
- `Cmd+S` saves back to the prompt
- `Cmd+Shift+H` opens command history
- `Esc` cancels or goes back

## Uninstall

```bash
bash /absolute/path/to/CmdEdit/CmdEdit/Scripts/uninstall.sh
```

## Project Structure

```text
CmdEdit/
├── CmdEdit/
├── cmdedit-landing-page/
├── Formula/
├── README.md
└── LICENSE
```

## Scope

Current MVP:

- macOS
- `zsh`
- save-back editing
- command history
- starred commands

CmdEdit is source-installable today. Signed and notarized release distribution is not done yet.

## License

[MIT](LICENSE)
