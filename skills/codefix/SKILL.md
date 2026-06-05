---
name: codefix
description: Fix code review findings. Reads CODEREVIEW.md as spec. Minimal targeted fixes.
disable-model-invocation: true
allowed-tools:
  - Bash(*)
  - Read
  - Edit
  - Grep
  - Glob
---

# /codefix

Read CODEREVIEW.md findings. Apply minimal targeted fixes. No self-evaluation.

Called by `/codereview`, not directly by users.

## Algorithm

1. **Read findings.** Parse CODEREVIEW.md. Extract BLOCK and WARN findings (ignore NOTE). For each: severity, file:line, description, suggested fix. No findings = "Nothing to fix." and stop.

2. **Read context.** For each finding, read the referenced file with surrounding context. If finding references callers or dependencies, read those too.

3. **Fix.** Process BLOCKs first, then WARNs. For each:
   - Locate the issue.
   - Determine minimal change.
   - If fix requires >20 lines changed: skip with "Fix too large, requires manual intervention."
   - Apply the fix.
   - Run syntax check if available (`bash -n`, `python3 -m py_compile`, etc.). If check fails, revert and skip.

4. **Report.** Print fixed and skipped findings.

## Constraints

- One fix at a time. Verify each compiles/parses before moving on.
- No refactoring or style cleanup.
- Never delete or weaken tests.
- Never add new dependencies.
- Never modify CODEREVIEW.md, SECURITY.md, TESTING.md, or SPEC.md.
- Never invoke other skills or evaluate own work.
