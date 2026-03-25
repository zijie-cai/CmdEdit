# CmdEdit

CmdEdit is a native macOS command editor overlay for `zsh`.

It lets you press `Ctrl+E`, edit the current shell command in a focused floating window, browse command history, star reusable commands, and save the result back to your prompt.

[Download for macOS](https://github.com/zijie-cai/CmdEdit/releases/latest)

## What It Does

CmdEdit makes shell command editing less painful without replacing your terminal.

- Opens from `zsh` with `Ctrl+E`
- Edits commands like normal text
- Searches recent command history
- Supports starred commands
- Saves back to the prompt without running automatically

## Install

1. Download the latest release zip
2. Unzip the file
3. Double-click `install.command`
4. Run `source ~/.zshrc`

Or install from source:

```bash
git clone --depth 1 https://github.com/zijie-cai/CmdEdit.git && bash CmdEdit/CmdEdit/Scripts/install.sh && source ~/.zshrc
```

Or install with Homebrew:

```bash
brew install --cask zijie-cai/cmdedit/cmdedit && source ~/.zshrc
```

## Requirements

- macOS 14+
- `zsh`
- Xcode Command Line Tools or a local Swift toolchain

If needed:

```bash
xcode-select --install
```

## Usage

- `Ctrl+E` opens CmdEdit
- `Cmd+S` saves back to the prompt
- `Cmd+Shift+H` opens command history
- `Esc` cancels or goes back

## Download

- [Latest Release](https://github.com/zijie-cai/CmdEdit/releases/latest)
- [Release Notes](https://github.com/zijie-cai/CmdEdit/releases)

## For Developers

Build and install from the repo:

```bash
bash CmdEdit/Scripts/install.sh
```

Create a release tag:

```bash
bash CmdEdit/Scripts/release.sh 1.0.0
```

Build a release zip locally:

```bash
bash CmdEdit/Scripts/package-release.sh 1.0.0
```

Generate a Homebrew cask:

```bash
bash CmdEdit/Scripts/generate-homebrew-cask.sh 1.0.0 <sha256>
```

## License

[MIT](LICENSE)
