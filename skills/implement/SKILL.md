---
name: implement
description: >-
  Implement unchecked acceptance criteria from SPEC.md by spawning a fresh
  subagent per criterion. Each agent gets clean context, reads the spec as
  its brief, implements, and commits. Use when you want hands-off execution
  of a spec.
argument-hint: ''
disable-model-invocation: true
context: fork
effort: max
allowed-tools:
  - Agent
  - Read
  - Grep
  - Glob
  - Bash(*)
---

# /implement

Read SPEC.md. Spawn a fresh agent per unchecked criterion. Each agent implements
and commits independently. You are the orchestrator — you do not implement anything
yourself.

## Algorithm

### Step 1: Read SPEC.md

Read `SPEC.md` from the project root. Parse the `### Acceptance Criteria` section.
Collect all unchecked criteria (`- [ ]` lines). If there are no unchecked criteria,
report "All criteria met. Nothing to implement." and stop.

Also read `CLAUDE.md` and `README.md` if they exist — the agents will need the
project conventions.

### Step 2: Plan the work

Group criteria into logical units. Most criteria map 1:1 to an agent, but closely
related criteria that touch the same files should be grouped into a single agent
to avoid merge conflicts. Never group more than 3 criteria per agent.

Order the agents so that dependencies run first (e.g., "create the file" before
"the file handles edge case X").

### Step 3: Spawn agents

For each unit of work, spawn a fresh agent using the Agent tool. Each agent prompt
must include:

1. The full text of the criterion (or criteria) it is responsible for
2. The project root path
3. Instructions to read SPEC.md, CLAUDE.md, and README.md for context
4. Instructions to commit its work when done with a message referencing the criterion
5. Instructions to NOT modify SPEC.md — checking off criteria is `/spec`'s job

Run agents sequentially if they have dependencies. Run independent agents in
parallel where possible.

### Step 4: Report

After all agents complete, report:
- Which criteria were implemented (based on agent results)
- Which criteria failed (if any), with the error
- End with: "Run `/spec` to verify and check off criteria."

Do not run `/spec` yourself. Do not check off criteria. The spec skill is the judge.
