---
name: alchemy-worker
description: >-
  Spawn a worker agent in an isolated git worktree. The worker executes
  immediately with no proposal/approval ceremony. .alchemy/ is deleted
  from the worktree before launch.
context: conversation
effort: max
allowed-tools:
  - Agent
  - Read
---

# /alchemy-worker

Spawn a worker in an isolated git worktree. The worker cannot see `.alchemy/`.
It executes immediately; no proposal gates, no "commit/land?" prompts.

## Input

The caller provides:
- **task**: what the worker should do (passed as the prompt)
- **slug**: short identifier for the worktree/branch (default: `alchemy-work`)
- **context_files**: files the worker should read first (optional)

## How to spawn the worker

Use the **Agent** tool with `isolation: "worktree"`. This is the only correct way.

Do NOT use `claude -p`, Bash, iTerm2, osascript, or any other shell-based approach.

### Step 1: Read context files

Read any files the worker will need (SPEC.md, context_files) so you can include
their content in the prompt.

### Step 2: Call the Agent tool

```
Agent(
  description: "<slug>: <short task description>",
  prompt: "<full task prompt, including rules below>",
  isolation: "worktree",
  mode: "bypassPermissions"
)
```

Include these rules in the prompt you pass to the Agent:

1. Execute immediately. No proposals, no approval gates.
2. Read the files listed for context, then do the work.
3. Commit your work with descriptive messages as you go.
4. Everything is local. NEVER `git push`.
5. Delete the `.alchemy/` directory from your worktree before starting work.

### Step 3: Report

The Agent tool returns results when the worker finishes. Report the outcome
to the caller. If the worker made changes, the worktree path and branch are
included in the result.
