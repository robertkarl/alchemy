#!/usr/bin/env bash
set -euo pipefail

# pre-push-codereview.sh — Claude Code PreToolUse hook.
# Blocks git push unless codereview has passed for the current diff.
# Input: JSON on stdin with tool_input.command
# Exit 0 = allow, Exit 2 = block

# Read the command from stdin
INPUT="$(cat)"
COMMAND="$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")"

[[ -n "$COMMAND" ]] || exit 0

# Check if this is a git push command
is_git_push() {
  local cmd="$1"
  # Handle compound commands — check each part
  local IFS='&;|'
  for part in $cmd; do
    part="$(echo "$part" | sed 's/^ *//' | sed 's/ *$//')"
    # Tokenize
    local tokens=()
    read -ra tokens <<< "$part"
    local i=0
    local found_git=0
    local found_push=0

    while [[ $i -lt ${#tokens[@]} ]]; do
      local t="${tokens[$i]}"
      case "$t" in
        git)
          found_git=1
          ;;
        -C|-c|--git-dir|--work-tree)
          # These take an argument; skip next token
          ((i++))
          ;;
        push)
          if [[ $found_git -eq 1 ]]; then
            found_push=1
            break
          fi
          ;;
        -*)
          # Other git-level flags
          ;;
      esac
      ((i++))
    done

    if [[ $found_push -eq 1 ]]; then
      return 0
    fi
  done
  return 1
}

is_git_push "$COMMAND" || exit 0

# Check for tag-only push
if echo "$COMMAND" | grep -qE '(--tags|refs/tags/|v[0-9])'; then
  exit 0
fi

# Check for skip marker
SKIP_FILE="$(codereview-marker skip-path 2>/dev/null)" || {
  echo "codereview-marker not found on PATH. Push blocked." >&2
  exit 2
}

if [[ -f "$SKIP_FILE" ]]; then
  rm "$SKIP_FILE"
  echo "Skip marker consumed. Push allowed." >&2
  exit 0
fi

# Verify review marker matches current diff
CURRENT_HASH="$(codereview-marker hash 2>/dev/null)" || {
  rc=$?
  if [[ $rc -eq 2 ]]; then
    # No reviewable changes
    exit 0
  fi
  echo "codereview-marker hash failed. Push blocked." >&2
  exit 2
}

MARKER_FILE="$(codereview-marker path)"
if [[ -f "$MARKER_FILE" ]]; then
  STORED_HASH="$(cat "$MARKER_FILE")"
  if [[ "$STORED_HASH" == "$CURRENT_HASH" ]]; then
    exit 0
  fi
fi

echo "Push blocked: no passing code review for current changes." >&2
echo "Run /codereview to review, or: codereview-skip && git push" >&2
exit 2
