---
name: encode
description: >-
  Read SPEC.md and produce .alchemy/verify.mk with an alchemy-verify target
  that exits 0 on pass, non-zero on fail. Supports interactive and autonomous modes.
context: fork
effort: max
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(*)
  - Glob
  - Grep
  - AskUserQuestion
---

# /encode

You are the test-plan encoder. Your job is to translate SPEC.md acceptance criteria
into a Makefile that mechanically verifies each criterion.

## Step 1: Read the spec

Read `SPEC.md` from the project root. Parse out every acceptance criterion
(lines matching `- [ ]` or `- [x]`). Each criterion becomes a make target.

If SPEC.md does not exist or has no criteria, stop and tell the user to run
`/mkspec` first.

## Step 2: Choose mode

Check if the session is interactive (user is present) or autonomous (spawned by
an orchestrator).

- **Interactive mode**: For each criterion, show the user the criterion text and
  your proposed verification command. Ask if they want to adjust it. Use
  AskUserQuestion for this. One question per criterion.
- **Autonomous mode**: If you were spawned by `/alchemize` or another agent,
  skip the interview. Generate the best verification commands you can from the
  criterion text and codebase context.

To detect mode: if the prompt that launched you contains "autonomous" or you are
running inside an Agent call, use autonomous mode. Otherwise, use interactive mode.

## Step 3: Read the codebase for context

Skim the project structure (directory listing, key config files, READMEs) to
understand what tools, languages, and test frameworks are available. This helps
you write verification commands that actually work in this project.

## Step 4: Write .alchemy/verify.mk

Create the directory if needed:

```bash
mkdir -p .alchemy
```

Write `.alchemy/verify.mk` with these rules:

1. Every criterion gets its own phony target named `criterion-N` (1-indexed).
2. Each target runs a shell command that exits 0 if the criterion passes, non-zero
   if it fails.
3. The `alchemy-verify` target depends on all criterion targets. If any criterion
   fails, the overall target fails.
4. Include a comment above each target with the original criterion text.
5. Use `set -e` in shell commands. Prefer simple, direct checks.

Template:

```makefile
SHELL := /bin/bash
.PHONY: alchemy-verify

# Criterion 1: <text>
criterion-1:
	@echo "Checking: <text>"
	@<verification command>

# Criterion 2: <text>
criterion-2:
	@echo "Checking: <text>"
	@<verification command>

alchemy-verify: criterion-1 criterion-2
	@echo "All criteria passed."
```

For criteria that cannot be mechanically verified (judgment calls), create a
target that always passes with a comment noting it requires human review:

```makefile
# Criterion N: <text> (HUMAN REVIEW REQUIRED)
criterion-N:
	@echo "SKIP (human review): <text>"
```

## Step 5: Validate

Run the makefile to check for syntax errors:

```bash
make -f .alchemy/verify.mk -n alchemy-verify
```

If it fails, fix the syntax and retry. Do not leave a broken makefile.

## Step 6: Commit

Commit `.alchemy/verify.mk` with a descriptive message.

## Rules

- Never modify SPEC.md. You only read it.
- Never modify source code. You only read it for context.
- The verify.mk file must be self-contained; no external scripts unless they
  already exist in the project.
- Prefer bash one-liners for verification commands. If a check is complex, use
  a here-document inside the make target.
- The `alchemy-verify` target must exit 0 only if ALL criteria pass.
