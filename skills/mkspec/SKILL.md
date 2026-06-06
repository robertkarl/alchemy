---
name: mkspec
description: Interview the user to produce SPEC.md with concrete acceptance criteria
context: fork
effort: max
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(*)
  - AskUserQuestion
---

# /mkspec

Produce SPEC.md with concrete, verifiable acceptance criteria. Supports two modes:

- **Interactive mode** (default): Interview the user one question at a time.
- **Autonomous mode**: Read the codebase and any provided prompt context, then
  generate the spec without user interaction. Activated when the prompt that
  launched you contains "autonomous" or you are running inside an Agent call.

## Step 1: Orient

Read from the project root (skip missing files silently):
- `README.md`, `CLAUDE.md`, `AGENTS.md`
- `SPEC.md` (check if one already exists)
- Directory structure 1-2 levels deep via `ls`
- Skim key source files to understand what the project does

Hold this context. Do not dump it back to the user.

## Step 2: Gather requirements

### Interactive mode

Ask these questions sequentially. Wait for the user's answer before asking the next. Never batch questions.

1. **What are you building?** Get a one-sentence goal. If the answer is vague, push back and ask them to be specific.
2. **What does done look like?** Ask for concrete outcomes: what works, what a user can do, what output looks like.
3. **What should I verify?** Ask how you would confirm each outcome. Push for bash-verifiable checks where possible (e.g., `make test passes`, `curl localhost:8080 returns 200`, `file X exists with Y content`). Judgment-based criteria are fine when mechanical verification is not practical (e.g., "UI matches mockup").
4. **Anything out of scope?** Identify boundaries so criteria stay focused.

After question 4, move to Step 3. You may ask a fifth follow-up if earlier answers left a gap, but do not exceed five questions total.

### Autonomous mode

Skip the interview. Instead:

1. Read the codebase thoroughly (directory structure, READMEs, config files, key source files).
2. Read any context provided in the prompt that spawned you.
3. Infer the goal, outcomes, and verification methods from the codebase and prompt.
4. Proceed directly to Step 3.

## Step 3: Pressure-test

Review the criteria you have gathered. For each criterion, silently ask yourself:

1. Is this independently verifiable, or does it depend on another criterion?
2. Would an adversarial reviewer say this is too vague to check off?
3. Am I missing an error/edge case the user implied but did not state?

If any criterion fails, propose a revision or addition to the user. Ask them to confirm or reject. One round only. Do not loop.

## Step 4: Write SPEC.md

Write the file to the project root using Bash (e.g., `cat <<'EOF' > SPEC.md`).

Format:

```markdown
## Spec, YYYY-MM-DD, [short title]

**Goal:** [1-2 sentences from the interview]

### Acceptance Criteria

- [ ] Criterion 1 (bash-verifiable preferred)
- [ ] Criterion 2
```

Rules:
- EVERY criterion MUST use markdown checkbox format: `- [ ]` (unchecked). No exceptions. Do not use plain `- ` bullets.
- Each criterion independently verifiable
- Ordered most to least important
- Bash-verifiable criteria include the exact command or check in parentheses where practical
- No implementation steps disguised as criteria
- No overlap between criteria

## Step 5: Confirm

Tell the user: "Spec written: [title] with N acceptance criteria."
Show the full SPEC.md content so they can review it.
