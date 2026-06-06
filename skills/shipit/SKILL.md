---
name: shipit
description: >-
  Full ship pipeline: assert clean, test, autonomous build loop, codereview,
  fix-and-re-review loop, rebase onto remote main, push.
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
you stop or loop as specified. You share a 20-round cap with the autonomous build loop.

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

### Gate 3: Autonomous build-verify loop

Invoke the autonomous build-verify loop to build and verify the spec. If it exhausts its rounds,
stop and report which criteria still fail.

### Gate 4: Code review

Run `/codereview` on the diff from main. Read the report.

- If verdict is **PASS** (0 BLOCKs), continue to Gate 5.
- If verdict is **FAIL** (1+ BLOCKs), go to Gate 4a.

### Gate 4a: Fix and re-review

Feed the codereview findings back as a new SPEC.md or as TESTLOG.md context,
then run the autonomous build loop again to fix the issues. After it completes,
run `/codereview` again.

This fix-and-re-review loop shares the 20-round cap with Gate 3. If the cap
is exhausted, stop and report.

### Gate 5: Rebase onto remote main

```bash
git fetch origin
git rebase origin/main
```

If rebase has conflicts, stop and report. Do not force-resolve conflicts.

### Gate 6: Push

```bash
git push origin HEAD
```

Report success with a summary of what was shipped.

## Rules

- Never force-push
- Never skip a gate
- The 20-round cap is shared across all build-verify invocations in a single shipit run
- If any gate fails irrecoverably, stop and report clearly which gate failed and why
