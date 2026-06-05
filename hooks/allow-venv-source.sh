#!/usr/bin/env bash
# allow-venv-source.sh — Claude Code PreToolUse hook.
# Auto-approves "source .venv/bin/activate" to skip the safety prompt.

INPUT="$(cat)"
COMMAND="$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")"

# Match exactly "source .venv/bin/activate" or ". .venv/bin/activate", optionally followed by " && ..."
if echo "$COMMAND" | grep -qE '^(source|\.) \.venv/bin/activate( &&|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"allow","message":"Auto-approved venv activation."}}'
fi
