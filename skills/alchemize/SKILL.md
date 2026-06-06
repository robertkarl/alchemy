---
name: alchemize
description: >-
  Autonomous build-verify-learn loop. Spawn builder, spawn verifier, learn from
  failures, repeat until gold or you run out of mass.
context: conversation
effort: max
allowed-tools:
  - Agent
  - Skill
  - Read
  - Write
  - Edit
  - Bash(*)
---

# /alchemize

You are the orchestrator. You NEVER read source code. You NEVER use Edit or Write
on source files. You only read SPEC.md, TESTLOG.md, and agent output. You NEVER
read `.alchemy/verify.mk` or any file in `.alchemy/`.

## Step 0: Load deferred tools

The Agent and Skill tools may be deferred. Fetch them before starting:

```
ToolSearch(query: "select:Agent,Skill", max_results: 2)
```

Do this FIRST, before anything else.

## Phase 1: mkspec (once)

Read `SPEC.md` from the project root. If it does not exist or is empty, spawn a
mkspec agent:

```
Agent(
  prompt: "You are the spec writer. Run /mkspec in autonomous mode: read the codebase and any existing context, then produce SPEC.md with concrete acceptance criteria. Do not interview the user; work autonomously.",
  description: "mkspec agent",
  mode: "auto"
)
```

If SPEC.md already exists with criteria, skip this phase.

## Phase 2: encode (once)

Check if `.alchemy/verify.mk` exists:

```bash
test -f .alchemy/verify.mk && echo "EXISTS" || echo "MISSING"
```

If it does not exist, spawn an encode agent:

```
Agent(
  prompt: "You are the test-plan encoder. Run /encode in autonomous mode: read SPEC.md, read the codebase for context, and produce .alchemy/verify.mk with an alchemy-verify target that exits 0 on pass and non-zero on fail. Work autonomously; do not interview the user.",
  description: "encode agent",
  mode: "auto"
)
```

If `.alchemy/verify.mk` already exists, skip this phase.

## Phase 3: fulfill <-> verify loop (max 20 iterations)

### Step 1: Read SPEC.md

Read `SPEC.md` from the project root. If every criterion is checked (`- [x]`),
stop and report success. If unchecked criteria remain, continue.

### Step 2: Spawn FULFILL agent via /alchemy-worker

The fulfill agent MUST run in an isolated worktree so it cannot access `.alchemy/`.
Use the `/alchemy-worker` skill to spawn it.

Invoke `/alchemy-worker` with:

> slug: fulfill
>
> Task: implement the unchecked acceptance criteria in SPEC.md.
>
> 1. Read SPEC.md as your brief.
> 2. If TESTLOG.md exists, read it for context on prior failures, then delete it.
> 3. Implement unchecked criteria. Check each box (`- [x]`) as you complete it.
> 4. Commit your work along the way with descriptive messages.
> 5. Do NOT modify SPEC.md's goal, context, or criteria text. Only check boxes.
>
> The .alchemy/ directory does not exist in your worktree. Do not look for it.

The worker runs in a worktree where `.alchemy/` has been deleted, providing
structural enforcement that the builder cannot see the test plan. It executes
immediately with no proposal/approval ceremony.

Wait for the worker to land its changes back to the main branch.

### Step 3: Spawn VERIFY agent

The verifier runs in the main worktree (where `.alchemy/verify.mk` lives).

```
Agent(
  prompt: "<the prompt below>",
  description: "Verify agent",
  mode: "auto"
)
```

Spawn with this prompt:

> You are the VERIFIER. You have ZERO knowledge of prior attempts. You have never
> seen TESTLOG.md. Judge purely on what you find in the codebase right now.
>
> 1. Read SPEC.md. Uncheck ALL boxes (`- [ ]`) first.
> 2. Run `make -f .alchemy/verify.mk alchemy-verify` to execute the test plan.
> 3. If the overall target fails, run each criterion target individually to
>    determine which pass and which fail.
> 4. For each criterion, also read the relevant code to confirm the result.
> 5. Check only criteria that actually pass. Leave failures unchecked.
> 6. Commit the updated SPEC.md with message: "Verify spec criteria".

Wait for the verifier to finish.

### Step 4: Evaluate

Read SPEC.md. If all criteria are checked, stop and report success with a summary
of iterations taken.

If unchecked criteria remain, write TESTLOG.md with:
- Which criteria failed
- The verifier's reasoning or error output for each failure
- Iteration number

Then go to Step 1.

### Step 5: Exhaustion

If you reach 20 iterations without full success, stop and report which criteria
still fail and why. Do not loop forever.

## Rules

- You are the orchestrator. You NEVER read source code. Only SPEC.md and TESTLOG.md.
- You NEVER read `.alchemy/verify.mk` or any file in `.alchemy/`.
- You NEVER use Edit or Write on source files. Only SPEC.md and TESTLOG.md.
- The fulfill agent runs in an alchemy-worker worktree where `.alchemy/` does not exist.
- The verifier runs in the main worktree where `.alchemy/verify.mk` is available.
- The verifier NEVER sees TESTLOG.md. The builder deletes it after reading.
- The builder checks boxes as progress markers. The verifier unchecks everything
  and re-verifies from scratch.
- Each agent is born with zero shared state. Communication flows only through
  SPEC.md (criteria status) and TESTLOG.md (failure context).
- The spec and test plan (.alchemy/verify.mk) are NEVER modified during the
  fulfill/verify loop. They are written once in phases 1 and 2.
