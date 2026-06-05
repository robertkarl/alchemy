#!/usr/bin/env bash
# post-tool-exit-plan-mode.sh — Claude Code PostToolUse hook.
# Fires after ExitPlanMode, reminds about /spec plan.

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")"

if [[ "$TOOL" == "ExitPlanMode" ]]; then
  echo "Plan mode exited. Plans are ephemeral — run /spec plan to convert into a persistent, review-gated SPEC.md."
fi
