---
name: alchemy-worker
description: >-
  Spawn a worker agent in an isolated git worktree. The worker executes
  immediately with no proposal/approval ceremony. .alchemy/ is deleted
  from the worktree before launch.
context: conversation
effort: max
allowed-tools:
  - Read
  - Write
  - Bash(*)
---

# /alchemy-worker

Spawn a worker in an isolated git worktree. The worker cannot see `.alchemy/`.
It executes immediately; no proposal gates, no "commit/land?" prompts.

## Input

The caller provides:
- **task**: what the worker should do (passed as the prompt)
- **slug**: short identifier for the worktree/branch (default: `alchemy-work`)
- **context_files**: files the worker should read first (optional)

## Procedure

### 1. Write the prompt file

Write `/tmp/alchemy-worker-<slug>.prompt.md` with the caller's task.
Structure:

```markdown
# Alchemy Worker Task

<task from caller>

## Rules

1. Execute immediately. No proposals, no approval gates, no "commit/land?" prompts.
2. Read the files listed below for context, then do the work.
3. Commit your work with descriptive messages as you go.
4. Everything is local. NEVER `git push`.
5. When done, land your changes:
   - `git rebase <base-branch>`
   - `git -C ../.. merge --ff-only alchemy/<slug>`
   - Stop. Do NOT push.
6. Write a summary to `/tmp/alchemy-worker-<slug>_summary.md` (2-4 sentences).

## Read these files first

<context_files list>
```

### 2. Create worktree, delete .alchemy/, launch

Run this as a single bash command (substitute SLUG and BASE_BRANCH):

```bash
set -euo pipefail
SLUG="<slug>"
PROMPT_FILE="/tmp/alchemy-worker-<slug>.prompt.md"

REPO_DIR="$(git rev-parse --show-toplevel)"
WORKTREE="${REPO_DIR}/.worktrees/${SLUG}"
BRANCH="alchemy/${SLUG}"
BASE_BRANCH="$(git branch --show-current)"

# Prune stale worktrees
git worktree prune 2>/dev/null

# Clean up if this slug was used before
if git worktree list --porcelain | grep -q "worktree ${WORKTREE}$"; then
    git worktree remove --force "${WORKTREE}" 2>/dev/null || true
fi
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
    git branch -D "${BRANCH}" 2>/dev/null || true
fi

# Create worktree
mkdir -p "${REPO_DIR}/.worktrees"
git worktree add "${WORKTREE}" -b "${BRANCH}" HEAD

# Delete .alchemy/ so the worker cannot see the test plan
rm -rf "${WORKTREE}/.alchemy"

# Launch in new iTerm2 window without stealing focus
CMD="cd $(printf '%q' "${WORKTREE}") && claude -p 'Read ${PROMPT_FILE} for your task instructions.'"

osascript \
    -e 'tell application "iTerm2"' \
    -e '  create window with default profile' \
    -e '  tell current session of current window' \
    -e "    write text \"${CMD}\"" \
    -e '  end tell' \
    -e 'end tell' \
    -e 'tell application "System Events" to set frontmost of process "iTerm2" to false'

echo "Worker '${SLUG}' launched (branch: ${BRANCH}, base: ${BASE_BRANCH})"
```

### 3. Report

Tell the caller: the worker is running. It will write a summary to
`/tmp/alchemy-worker-<slug>_summary.md` when done. The caller should
wait for the summary file to appear, then read SPEC.md to check progress.
