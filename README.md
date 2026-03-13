# CmdEdit

Edit terminal commands like real text.

CmdEdit is a native macOS command editor overlay for `zsh`. Type a command in your normal terminal, press `Ctrl+E`, edit it in a focused floating window, then send it back to your prompt without running it.

## Why It Exists

Editing long shell commands in a terminal is still awkward:

- moving through long flags and paths is slow
- multiline commands are painful to restructure
- selection and copy/paste are clumsy
- complex one-liners become harder to maintain than they should be

CmdEdit keeps your existing terminal and shell workflow, but swaps the painful editing part for a native macOS editor.

## Demo Flow

1. Type a command in `zsh`
2. Press `Ctrl+E`
3. Edit it in CmdEdit
4. Press `Cmd+S`
5. Your edited command is written back to the prompt

`Esc` cancels and leaves the command unchanged.

## Features

- Native SwiftUI + AppKit macOS overlay
- `zsh` keybinding via `zle`
- Monospace multiline editor
- Save-back workflow with no auto-run
- Familiar keyboard shortcuts
- Minimal floating utility window

## One-Line Install

From the repo root:

```bash
bash CmdEdit/Scripts/install.sh
```

That script:

- builds the app
- installs `CmdEdit.app` into `/Applications` or `~/Applications`
- adds the shell integration to `~/.zshrc` if needed

Then reload your shell:

```bash
source ~/.zshrc
```

## Manual Setup

Build the app:

```bash
cd CmdEdit
bash Scripts/build.sh
```

Install the app:

```bash
cp -R build/CmdEdit.app /Applications/
```

If you prefer a user-local install:

```bash
mkdir -p ~/Applications
cp -R build/CmdEdit.app ~/Applications/
```

Wire it into `zsh`:

```zsh
source /absolute/path/to/CmdEdit/ShellIntegration/cmdedit.zsh
```

Reload your shell:

```bash
source ~/.zshrc
```

## Usage

- Type a command in `zsh`
- Press `Ctrl+E`
- Edit normally with mouse or keyboard
- Press `Cmd+S` to write it back to the prompt
- Press `Esc` to cancel

## Keyboard Shortcuts

- `Ctrl+E`: Open CmdEdit from the terminal
- `Cmd+S`: Save back to prompt
- `Esc`: Cancel

## How It Works

CmdEdit uses a simple local roundtrip:

1. A `zle` widget captures the current `BUFFER`
2. The shell passes that text to the native app through temp files
3. The app edits the command and writes back a result
4. The widget restores the edited text into the terminal buffer

This keeps the implementation predictable and avoids clipboard hacks.

## Requirements

- macOS 14+
- `zsh`
- Xcode command line tools / Swift toolchain

## Project Layout

```text
CmdEdit/
├── CmdEdit/
│   ├── App/
│   ├── Scripts/
│   └── ShellIntegration/
├── src/
└── README.md
```

The native product lives in [`/Users/zai28/dev/CmdEdit/CmdEdit`](/Users/zai28/dev/CmdEdit/CmdEdit).

## Status

Current scope is a working MVP focused on:

- macOS
- `zsh`
- save-back editing only

## Limitations

- `zsh` only for now
- currently optimized for local install from source
- no syntax highlighting yet

## Roadmap

- better shell-aware highlighting
- cursor restoration improvements
- packaging and signed distribution
- support for more shells
