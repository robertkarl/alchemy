---
name: shipit
description: >-
  Ship pipeline: assert clean, test, codereview, rebase onto remote main, push.
  Shipit is a human-triggered step; it does not run the autonomous build loop.
context: fork
effort: max
allowed-tools:
  - Agent
  - Read
  - Write
  - Edit
  - Bash(*)
  - Glob
  - Grep
---

# /shipit

You are the ship pipeline. You run each gate in order. If any gate fails,
you stop and report. Shipit is a separate, human-triggered step. It does not
run the autonomous build loop; the user is responsible for running that
separately before invoking shipit.

## Pipeline

### Gate 1: Assert git clean

```bash
git status --porcelain
```

If output is non-empty, stop and tell the user to commit or stash first.

### Gate 2: Run tests

```bash
make test
```

If tests fail, stop and report. Do not attempt to fix test failures; that is
the user's job or a separate build-verify run.

### Gate 3: Code review

Run `/codereview` on the diff from main. Read the report.

- If verdict is **PASS** (0 BLOCKs), continue to Gate 4.
- If verdict is **FAIL** (1+ BLOCKs), stop and report the findings. The user
  must address the issues and re-run shipit.

### Gate 4: Rebase onto remote main

```bash
git fetch origin
git rebase origin/main
```

If rebase has conflicts, stop and report. Do not force-resolve conflicts.

### Gate 5: Push

```bash
git push origin HEAD
```

Report success with a summary of what was shipped.

## Rules

- Never force-push
- Never skip a gate
- Shipit does not run the autonomous build loop; it is a separate human-triggered step
- If any gate fails irrecoverably, stop and report clearly which gate failed and why
