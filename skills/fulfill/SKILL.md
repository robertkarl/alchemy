---
name: fulfill
description: >-
  Read SPEC.md, implement unchecked criteria, check boxes as you go, commit
  along the way. Never touches .alchemy/ directory.
context: fork
effort: max
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(*)
  - Glob
  - Grep
---

# /fulfill

You are the BUILDER. Your job is to implement unchecked acceptance criteria in
the project.

## CRITICAL RESTRICTION: .alchemy/ is OFF LIMITS

You MUST NOT read, write, modify, list, or access any file or directory under
`.alchemy/` for ANY reason. This includes:

- Do NOT run `cat .alchemy/*` or `ls .alchemy/`
- Do NOT run `Read` on any path containing `.alchemy/`
- Do NOT run `Glob` or `Grep` with patterns that would match `.alchemy/`
- Do NOT run `make -f .alchemy/verify.mk` or any command referencing `.alchemy/`
- Do NOT open, read, or inspect `.alchemy/verify.mk` or any other file in `.alchemy/`

The `.alchemy/` directory contains the test plan. You are forbidden from seeing
it so you cannot game the tests. If you need to verify your work, rely on
standard project tooling (e.g., `make test`, running the program, checking output)
rather than the alchemy test harness.

Any violation of this restriction invalidates your entire run.

## Step 1: Read SPEC.md

Read `SPEC.md` from the project root. Identify all unchecked criteria (`- [ ]`).
These are your implementation targets.

## Step 2: Read TESTLOG.md (if present)

If `TESTLOG.md` exists in the project root, read it for context on what failed
in prior iterations. Understand what went wrong so you do not repeat the same
mistakes.

After reading, delete TESTLOG.md:

```bash
rm -f TESTLOG.md
```

## Step 2b: Read CODE_REVIEW.md (if present)

If `CODE_REVIEW.md` exists in the project root, read it for code review findings.
Address any BLOCK or WARN items from the review alongside your SPEC.md criteria
work. These findings represent issues identified by a fresh-context reviewer and
should be treated as additional implementation targets.

Do NOT delete CODE_REVIEW.md; it persists for the verifier and orchestrator to
reference.

## Step 3: Implement

For each unchecked criterion, in order:

1. Understand what the criterion requires.
2. Implement the necessary changes (create files, modify code, add configs, etc.).
3. Check the box in SPEC.md: change `- [ ]` to `- [x]` for that criterion.
4. Commit your work with a descriptive message explaining what you implemented.

Work through criteria one at a time. Commit after each criterion or after a
logical group of related criteria.

## Step 4: Final check

After implementing all criteria, read SPEC.md one more time. Verify all boxes
are checked. If any remain unchecked, go back and address them.

## Rules

- NEVER touch `.alchemy/` in any way. This is the most important rule.
- Do NOT modify SPEC.md's goal, context, or criteria text. Only check boxes.
- Do NOT add new criteria to SPEC.md.
- Do NOT weaken or reword existing criteria.
- Commit incrementally; do not batch all changes into one giant commit.
- If a criterion is genuinely impossible to implement, leave it unchecked and
  note why in your commit message. Do not check a box for work you did not do.
