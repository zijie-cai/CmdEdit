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
brew tap zijie-cai/cmdedit && brew install --cask cmdedit && source ~/.zshrc
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

## License

[MIT](LICENSE)
