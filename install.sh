#!/usr/bin/env bash
set -euo pipefail

# kar.env installer — symlinks skills, bin scripts, and hooks into place.
# Supports: Claude Code, Codex CLI.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/bin"

echo "Installing kar.env from $SCRIPT_DIR"

# ── Skills ──────────────────────────────────────────────────────────
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

# ── Bin scripts ─────────────────────────────────────────────────────
mkdir -p "$BIN_DIR"

for script in "$SCRIPT_DIR"/bin/*; do
  name="$(basename "$script")"
  target="$BIN_DIR/$name"
  if [[ -L "$target" ]]; then
    rm "$target"
  fi
  ln -s "$script" "$target"
  echo "  bin: $name -> $target"
done

# ── Claude Code hooks ──────────────────────────────────────────────
# Register hooks in ~/.claude/settings.json
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
  echo '{}' > "$CLAUDE_SETTINGS"
fi

# Use python3 to merge hook config (available on macOS by default)
python3 << PYEOF
import json, sys

settings_path = "$CLAUDE_SETTINGS"
hooks_dir = "$SCRIPT_DIR/hooks"

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})

# Pre-push codereview gate
pre_tool = hooks.get("PreToolUse", [])
# Remove any existing kar.env hooks
pre_tool = [h for h in pre_tool if "kar.env" not in h.get("command", "")]

pre_tool.append({
    "matcher": "Bash",
    "if": "Bash(git push*)",
    "command": f"{hooks_dir}/pre-push-codereview.sh"
})

pre_tool.append({
    "matcher": "Bash",
    "if": "Bash(source .venv*)",
    "command": f"{hooks_dir}/allow-venv-source.sh"
})

hooks["PreToolUse"] = pre_tool

# Post-tool exit plan mode
post_tool = hooks.get("PostToolUse", [])
post_tool = [h for h in post_tool if "kar.env" not in h.get("command", "")]

post_tool.append({
    "matcher": "ExitPlanMode",
    "command": f"{hooks_dir}/post-tool-exit-plan-mode.sh"
})

hooks["PostToolUse"] = post_tool
settings["hooks"] = hooks

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("  hooks: registered in", settings_path)
PYEOF

# ── Codex global instructions ──────────────────────────────────────
CODEX_AGENTS="$HOME/.codex/AGENTS.md"
mkdir -p "$HOME/.codex"

if [[ ! -f "$CODEX_AGENTS" ]] || ! grep -q "kar.env" "$CODEX_AGENTS" 2>/dev/null; then
  cat >> "$CODEX_AGENTS" << 'EOF'

<!-- kar.env -->
## Verification-first workflow

Before pushing, run `/codereview`. Use `/spec` to define acceptance criteria.
Available skills: /spec, /codereview, /codefix, /security, /architect, /tester, /pr.
Run `codereview-skip && git push` to bypass the review gate when needed.
<!-- /kar.env -->
EOF
  echo "  codex: appended instructions to $CODEX_AGENTS"
fi

# ── External reviewer config template ──────────────────────────────
REVIEWER_ENV="$HOME/.config/claude-reviewers/.env"
if [[ ! -f "$REVIEWER_ENV" ]]; then
  mkdir -p "$(dirname "$REVIEWER_ENV")"
  cat > "$REVIEWER_ENV" << 'EOF'
# External code reviewer configuration (optional)
# OPENAI_API_KEY=sk-...
# OPENAI_MODEL=o3
# GOOGLE_API_KEY=...
# GOOGLE_MODEL=gemini-2.5-pro
# LOCAL_MODEL=Qwen2.5-Coder-14B-Instruct-AWQ
# REVIEW_TIMEOUT=300
EOF
  echo "  config: created template at $REVIEWER_ENV"
fi

echo ""
echo "kar.env installed. Make sure ~/bin is on your PATH."
echo "  Uninstall: $SCRIPT_DIR/uninstall.sh"
