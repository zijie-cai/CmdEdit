# CmdEdit

CmdEdit is a native macOS command editor overlay for `zsh`.

Type a command in your normal terminal, press `Ctrl+E`, edit it in a focused floating window, then save it back to your prompt without running it.

## Install

```bash
git clone --depth 1 https://github.com/zijie-cai/CmdEdit.git && bash CmdEdit/CmdEdit/Scripts/install.sh && source ~/.zshrc
```

## Usage

- `Ctrl+E` opens CmdEdit from `zsh`
- `Cmd+S` saves the edited command back to the prompt
- `Cmd+Shift+H` opens command history
- `Esc` cancels or goes back

## Requirements

- macOS 14+
- `zsh`
- Xcode Command Line Tools or a local Swift toolchain

If needed:

```bash
xcode-select --install
```

## Uninstall

```bash
bash /absolute/path/to/CmdEdit/CmdEdit/Scripts/uninstall.sh
```

## What It Includes

- native macOS editor overlay
- `zsh` shell integration
- command history inside the editor
- starred commands

## Project Structure

```text
CmdEdit/
├── CmdEdit/
├── cmdedit-landing-page/
├── README.md
└── LICENSE
```

- native app: `CmdEdit/`
- landing page: `cmdedit-landing-page/`

## Scope

Current MVP:

- macOS
- `zsh`
- save-back editing
- command history
- starred commands

CmdEdit is source-installable today. It is not yet a signed or notarized release build.

## License

[MIT](LICENSE)
