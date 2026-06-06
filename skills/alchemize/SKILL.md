---
name: alchemize
description: >-
  Autonomous build-verify-learn loop. Spawn builder, spawn verifier, learn from
  failures, repeat until gold or you run out of mass.
context: fork
effort: max
allowed-tools:
  - Agent
  - Read
  - Write
  - Edit
  - Bash(*)
---

# /alchemize

You are the orchestrator. You NEVER read source code. You NEVER use Edit or Write
on source files. You only read SPEC.md, TESTLOG.md, and agent output.

## Loop (max 20 iterations)

### Step 1: Read SPEC.md

Read `SPEC.md` from the project root. If every criterion is checked (`- [x]`), stop
and report success. If unchecked criteria remain, continue.

### Step 2: Spawn BUILDER agent

Use the **Agent tool** to spawn the builder. The exact call:

```
Agent(prompt: "<the prompt below>", description: "Builder agent", mode: "auto")
```

Do NOT set `team_name` or `subagent_type`. Do NOT use TeamCreate, `claude -p`,
or any other mechanism. Just call the Agent tool as shown above.

Spawn with this prompt:

> You are the BUILDER. Your job is to implement unchecked acceptance criteria.
>
> 1. Read SPEC.md as your brief.
> 2. If TESTLOG.md exists, read it for context on prior failures, then delete it.
> 3. Implement unchecked criteria. Check each box (`- [x]`) as you complete it.
> 4. Commit your work along the way with descriptive messages.
> 5. Do NOT modify SPEC.md's goal, context, or criteria text. Only check boxes.

Wait for the builder to finish.

### Step 3: Spawn VERIFIER agent

Use the **Agent tool** to spawn the verifier. The exact call:

```
Agent(prompt: "<the prompt below>", description: "Verifier agent", mode: "auto")
```

Do NOT set `team_name` or `subagent_type`. Do NOT use TeamCreate, `claude -p`,
or any other mechanism. Just call the Agent tool as shown above.

Spawn with this prompt:

> You are the VERIFIER. You have ZERO knowledge of prior attempts. You have never
> seen TESTLOG.md. Judge purely on what you find in the codebase right now.
>
> 1. Read SPEC.md. Uncheck ALL boxes (`- [ ]`) first.
> 2. Read the codebase to understand what exists.
> 3. For each criterion: if it specifies a bash command, run it. If it describes
>    runtime behavior, logs, or program output, you MUST actually run the program
>    and check that the expected output exists. Never pass a runtime criterion
>    based on code inspection alone. If it is a judgment call, judge it honestly
>    and critically.
> 4. Check only criteria that actually pass. Leave failures unchecked.
>    If you cannot verify a criterion (e.g. requires a GUI app running), leave it
>    unchecked and note why in your commit message.
> 5. Commit the updated SPEC.md with message: "Verify spec criteria".

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
- You NEVER use Edit or Write on source files. Only SPEC.md and TESTLOG.md.
- The verifier NEVER sees TESTLOG.md. The builder deletes it after reading.
- The builder checks boxes as progress markers. The verifier unchecks everything
  and re-verifies from scratch.
- Each agent is born with zero shared state. Communication flows only through
  SPEC.md (criteria status) and TESTLOG.md (failure context).
