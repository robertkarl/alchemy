#!/usr/bin/env bash
set -euo pipefail

# alchemy uninstaller -- removes symlinks.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/bin"

echo "Uninstalling alchemy"

# -- Skills ----------------------------------------------------------------
for dir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    target="$dir/$skill_name"
    if [[ -L "$target" ]]; then
      rm "$target"
      echo "  removed: $target"
    fi
  done
done

# -- Bin scripts -----------------------------------------------------------
for script in "$SCRIPT_DIR"/bin/*; do
  name="$(basename "$script")"
  target="$BIN_DIR/$name"
  if [[ -L "$target" ]]; then
    rm "$target"
    echo "  removed: $target"
  fi
done

echo ""
echo "alchemy uninstalled."
