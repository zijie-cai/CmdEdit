# CmdEdit

CmdEdit is a native macOS command editor overlay for `zsh`.

Press `Ctrl+E`, edit the current shell command in a focused floating window, browse command history, star reusable commands, and save the result back to your prompt.

## What It Does

- Opens from `zsh` with `Ctrl+E`
- Edits commands like normal text
- Searches recent command history
- Supports starred commands
- Saves back to the prompt without running automatically

## Install

```bash
git clone --depth 1 https://github.com/zijie-cai/CmdEdit.git && bash CmdEdit/CmdEdit/Scripts/install.sh && source ~/.zshrc
```

## Requirements

- macOS 14+
- `zsh`
- Xcode Command Line Tools or a local Swift toolchain

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
