#!/usr/bin/env zsh

# CmdEdit Zsh Integration
# Bind Ctrl+E to open the CmdEdit overlay

function _cmdedit() {
  local input_file=$(mktemp)
  local output_file=$(mktemp)
  local status_file=$(mktemp)
  local history_file=$(mktemp)
  local script_dir="${${(%):-%N}:A:h}"
  local history_limit=120
  local count=0
  local key
  local entry
  local -A seen_history

  # Write the current buffer to the input file
  echo -n "$BUFFER" > "$input_file"

  # Export recent zsh history as NUL-delimited records so multiline commands survive transport.
  : > "$history_file"
  for key in ${(Onk)history}; do
    entry="${history[$key]}"

    if [[ -z "${entry//[$' \t\n\r']/}" ]]; then
      continue
    fi

    if [[ -n "${seen_history[$entry]}" ]]; then
      continue
    fi

    seen_history[$entry]=1
    printf '%s\0' "$entry" >> "$history_file"

    (( count++ ))
    if (( count >= history_limit )); then
      break
    fi
  done

  # Path to the CmdEdit app
  local app_path="/Applications/CmdEdit.app"
  
  if [[ ! -d "$app_path" ]]; then
    app_path="$HOME/Applications/CmdEdit.app"
  fi

  if [[ ! -d "$app_path" ]]; then
    # Fallback to local build directory if not in Applications
    app_path="$script_dir/../build/CmdEdit.app"
  fi

  if [[ ! -d "$app_path" ]]; then
    echo "\nCmdEdit.app not found at $app_path."
    echo "Please build it using Scripts/build.sh and install it."
    zle reset-prompt
    return 1
  fi

  local app_binary="$app_path/Contents/MacOS/CmdEdit"

  if [[ ! -x "$app_binary" ]]; then
    echo "\nCmdEdit executable not found at $app_binary."
    zle reset-prompt
    return 1
  fi

  # Launch the app directly so argument passing and process lifetime stay deterministic.
  "$app_binary" "$input_file" "$output_file" "$status_file" "$history_file"

  # Check the status file to see what the user chose.
  # CmdEdit only writes the edited command back to the prompt; it never executes it.
  if [[ -f "$status_file" ]]; then
    local cmdedit_status=$(cat "$status_file")
    
    if [[ "$cmdedit_status" == "RUN" || "$cmdedit_status" == "SAVE" ]]; then
      # Read the edited command
      if [[ -f "$output_file" ]]; then
        BUFFER=$(cat "$output_file")
        CURSOR=${#BUFFER}
      fi
    fi
  fi

  # Cleanup temporary files
  rm -f "$input_file" "$output_file" "$status_file" "$history_file"
  
  # Refresh the prompt
  zle reset-prompt
}

# Register the widget
zle -N _cmdedit

# Bind to Ctrl+E
bindkey '^E' _cmdedit
