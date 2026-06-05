---
name: pr
description: Pull request workflow. Terminal node.
disable-model-invocation: true
allowed-tools:
  - Bash(*)
  - Read
  - Grep
  - Glob
---

# /pr

PR workflow via `gh` CLI. Read-only, no Write or Edit. Terminal node.

## Prerequisites

`gh auth status` must pass. Must have GitHub remote.

## Modes

### create

1. On `main` with branch name: `git checkout -b "$BRANCH"`. On `main` without: derive from recent commit (prefix `feat/`/`fix/`/`docs/`). On non-main: use as-is.
2. Check for existing PR. If exists, display and stop.
3. Gather: `git log --oneline main..HEAD`, `git diff --stat main...HEAD`, grep META blocks from review files.
4. Compose title (<70 chars) and body (summary bullets, spec status, review status table from META JSON, commits list).
5. `git push -u origin`, `gh pr create --title --body`. Report URL.

### status

`gh pr view --json ...`. Display details + summarize review comments.

### inspect

`gh pr view <ref> --json ...`. Display details and comments.

### merge

Three gates:
1. **Local review gate:** CODEREVIEW.md must have REVIEW_META with `block: 0`, `reviewed_up_to` ancestor of HEAD.
2. **GitHub readiness:** `mergeable: MERGEABLE`, no failed checks, no `CHANGES_REQUESTED`.
3. If pass: `gh pr merge --squash --delete-branch`, `git checkout main`, `git pull`.

### list

`gh pr list` with template formatting.

## Constraints

- Idempotent: create when PR exists shows existing; merge when merged reports fact.
- PR descriptions composed from existing metadata, not re-running reviews.
- No files written.
