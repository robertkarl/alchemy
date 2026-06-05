#!/usr/bin/env bash
set -euo pipefail

# kar.env uninstaller — removes symlinks and hook registrations.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/bin"

echo "Uninstalling kar.env"

# ── Skills ──────────────────────────────────────────────────────────
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

# ── Bin scripts ─────────────────────────────────────────────────────
for script in "$SCRIPT_DIR"/bin/*; do
  name="$(basename "$script")"
  target="$BIN_DIR/$name"
  if [[ -L "$target" ]]; then
    rm "$target"
    echo "  removed: $target"
  fi
done

# ── Claude Code hooks ──────────────────────────────────────────────
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$CLAUDE_SETTINGS" ]]; then
  python3 << PYEOF
import json

settings_path = "$CLAUDE_SETTINGS"
hooks_dir = "$SCRIPT_DIR/hooks"

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})

for key in ["PreToolUse", "PostToolUse"]:
    if key in hooks:
        hooks[key] = [h for h in hooks[key] if hooks_dir not in h.get("command", "")]
        if not hooks[key]:
            del hooks[key]

if hooks:
    settings["hooks"] = hooks
elif "hooks" in settings:
    del settings["hooks"]

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("  hooks: removed from", settings_path)
PYEOF
fi

# ── Codex instructions ─────────────────────────────────────────────
CODEX_AGENTS="$HOME/.codex/AGENTS.md"
if [[ -f "$CODEX_AGENTS" ]]; then
  # Remove the kar.env block
  sed -i '' '/<!-- kar\.env -->/,/<!-- \/kar\.env -->/d' "$CODEX_AGENTS" 2>/dev/null || true
  echo "  codex: removed instructions from $CODEX_AGENTS"
fi

echo ""
echo "kar.env uninstalled. Reviewer config left at ~/.config/claude-reviewers/.env"
