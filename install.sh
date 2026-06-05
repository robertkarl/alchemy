#!/usr/bin/env bash
set -euo pipefail

# alchemy installer -- symlinks skills and bin scripts into place.
# Supports: Claude Code, Codex CLI.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing alchemy from $SCRIPT_DIR"

# -- Skills ----------------------------------------------------------------
# Claude Code: ~/.claude/skills/
CLAUDE_SKILLS="$HOME/.claude/skills"
mkdir -p "$CLAUDE_SKILLS"

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$CLAUDE_SKILLS/$skill_name"
  if [[ -L "$target" ]]; then
    rm "$target"
  fi
  ln -s "$skill_dir" "$target"
  echo "  claude skill: $skill_name -> $target"
done

# Codex: ~/.agents/skills/
CODEX_SKILLS="$HOME/.agents/skills"
mkdir -p "$CODEX_SKILLS"

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$CODEX_SKILLS/$skill_name"
  if [[ -L "$target" ]]; then
    rm "$target"
  fi
  ln -s "$skill_dir" "$target"
  echo "  codex skill: $skill_name -> $target"
done


echo ""
echo "alchemy installed. Make sure ~/bin is on your PATH."
echo "  Uninstall: $SCRIPT_DIR/uninstall.sh"
