# CmdEdit

CmdEdit is a native macOS command editor overlay for `zsh`. Type a command in your normal terminal, press `Ctrl+E`, edit it in a focused floating window, and send it back to your prompt without running it.

## Why

Editing shell commands in a terminal is still awkward:

- long flags and paths are tedious to fix
- multiline commands are annoying to restructure
- selection and copy/paste are clumsy
- command recall is useful, but editing recalled commands is still painful

CmdEdit keeps your existing shell and terminal, but swaps the editing step for a native macOS editor.

## What It Does

- captures the current `zsh` command buffer
- opens a native floating editor window
- lets you edit with normal text editing behavior
- writes the edited command back to your prompt
- includes recent command history inside the editor
- supports starring favorite commands so they stay at the top

CmdEdit does not replace your terminal and does not auto-run commands on save.

## Demo Flow

1. Type a command in `zsh`
2. Press `Ctrl+E`
3. Edit in CmdEdit
4. Press `Cmd+S`
5. Your terminal prompt is updated with the edited command

`Esc` cancels.

## Requirements

- macOS 14+
- `zsh`
- Xcode Command Line Tools or a local Swift toolchain

Install CLT if needed:

```bash
xcode-select --install
```

## Install

One-line install from GitHub:

```bash
git clone --depth 1 https://github.com/zijie-cai/CmdEdit.git && bash CmdEdit/CmdEdit/Scripts/install.sh && source ~/.zshrc
```

What that does:

- builds the native app
- installs `CmdEdit.app` into `/Applications` or `~/Applications`
- adds the `zsh` integration to `~/.zshrc`

After install:

- type a command in `zsh`
- press `Ctrl+E`

## Uninstall

If you installed from this repo checkout:

```bash
bash /absolute/path/to/CmdEdit/CmdEdit/Scripts/uninstall.sh
```

Example:

```bash
bash ~/CmdEdit/CmdEdit/Scripts/uninstall.sh
```

The uninstall script:

- removes `CmdEdit.app` from `/Applications` and `~/Applications`
- removes the CmdEdit source line from `~/.zshrc`

## Manual Setup

Build:

```bash
cd CmdEdit/CmdEdit
bash Scripts/build.sh
```

Install app bundle:

```bash
cp -R build/CmdEdit.app /Applications/
```

Wire into `zsh`:

```zsh
source /absolute/path/to/CmdEdit/CmdEdit/ShellIntegration/cmdedit.zsh
```

Reload shell:

```bash
source ~/.zshrc
```

## Usage

- `Ctrl+E`: open CmdEdit from the terminal
- `Cmd+S`: save back to the prompt
- `Cmd+Shift+H`: open command history
- `Esc`: cancel or go back

## How It Works

CmdEdit uses a simple local roundtrip:

1. a `zle` widget captures the current `BUFFER`
2. the shell writes the current command and recent history to temp files
3. the native app edits the command
4. the app writes back the edited text and status
5. the widget restores the edited text into the terminal prompt

No clipboard hacks are used.

## Project Structure

The shipped native app lives under [`/Users/zai28/dev/CmdEdit/CmdEdit`](/Users/zai28/dev/CmdEdit/CmdEdit):

```text
CmdEdit/
├── CmdEdit/
│   ├── App/
│   ├── Scripts/
│   ├── ShellIntegration/
│   └── build/
├── README.md
└── LICENSE
```

Important paths:

- native app source: [`/Users/zai28/dev/CmdEdit/CmdEdit/App`](/Users/zai28/dev/CmdEdit/CmdEdit/App)
- shell integration: [`/Users/zai28/dev/CmdEdit/CmdEdit/ShellIntegration/cmdedit.zsh`](/Users/zai28/dev/CmdEdit/CmdEdit/ShellIntegration/cmdedit.zsh)
- install script: [`/Users/zai28/dev/CmdEdit/CmdEdit/Scripts/install.sh`](/Users/zai28/dev/CmdEdit/CmdEdit/Scripts/install.sh)
- uninstall script: [`/Users/zai28/dev/CmdEdit/CmdEdit/Scripts/uninstall.sh`](/Users/zai28/dev/CmdEdit/CmdEdit/Scripts/uninstall.sh)

## Current Scope

Current MVP scope:

- macOS
- `zsh`
- save-back editing
- recent command history
- starred command recall

## Known Limitations

- `zsh` only
- local source build/install, not notarized distribution
- history UI is tuned for the current MVP and may evolve

## Launch Readiness

CmdEdit is usable and shareable as a source-install GitHub project.

What is ready:

- end-to-end shell integration
- native editor overlay
- one-command install
- one-command uninstall
- documented setup and usage

What is not done yet:

- signed/notarized release build
- Homebrew formula / packaged distribution
- support for shells beyond `zsh`

## License

[MIT](/Users/zai28/dev/CmdEdit/LICENSE)
