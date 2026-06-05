---
name: spec
description: Write and evolve acceptance criteria in SPEC.md. Turn-based development loop.
disable-model-invocation: true
allowed-tools:
  - Bash(*)
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# /spec

Write verifiable acceptance criteria to SPEC.md. One unit of work per entry.

## Step 1: Read Context

Read from project root (if they exist):
- `SPEC.md` (current entry only)
- `README.md`, `CLAUDE.md`, `AGENTS.md`
- `CODEREVIEW.md` (most recent entry)
- `TESTING.md` (most recent entry)
- `BACKLOG.md` (skim)
- Directory structure 1-2 levels deep via `ls`

## Step 2: Mode Routing

First match wins:

| Priority | Condition | Mode |
|----------|-----------|------|
| 1 | `plan` or `plan <slug>` | Plan adoption (3e) |
| 2 | `propose` | Propose (3d) |
| 3 | `backlog <desc>` or `backlog clear` | Backlog (3f) |
| 4 | `new` or no SPEC.md | Interview (3a) |
| 5 | Args describe a feature | Direct (3b) |
| 6 | No args, SPEC.md has `### Proposal` section | Consume proposal (3g). If 5+ commits since proposal date, ask user to confirm first |
| 7 | No args, SPEC.md exists | Evolve (3c) |

## Step 3a: Interview Mode

1. Ask 3-5 focused questions: goal (one sentence), done criteria, constraints.
2. Pre-fill from README if available.
3. If BACKLOG.md exists, note overlapping entries.
4. After user responds, write SPEC.md (Step 4).

## Step 3b: Direct Mode

1. Read codebase to understand current state.
2. Draft acceptance criteria from description.
3. Note BACKLOG.md overlaps if any.
4. **Escape hatch:** If brief is too vague for 2+ testable checkboxes, STOP. Tell user to explore in plan mode first, then `/spec plan`.
5. Pressure test (Step 3.5).
6. Write SPEC.md (Step 4).

## Step 3c: Evolve Mode

1. Read SPEC.md. Assess which criteria are met by reading code/tests.
2. Update SPEC.md: check off met criteria (`- [ ]` -> `- [x]`), update `criteria_met` in SPEC_META.
3. If criteria remain: report progress.
4. If ALL criteria met (turn boundary):
   1. Run BACKLOG sweep (Step 3c.5) if BACKLOG.md exists.
   2. Generate proposal (Step 3d logic).
   3. Write proposal under `### Proposal (YYYY-MM-DD)` in SPEC.md.
   4. Ask user: retrospective additions? Deferred ideas for BACKLOG?
   5. End with: "Run `/spec` to start the next turn."

### Step 3c.5: BACKLOG Sweep (turn close only)

Classify each BACKLOG.md entry:
- **keep** (default, bias toward this)
- **revisit-candidate** (criteria now plausibly hold)
- **recommend-delete** (shipped, supplanted, or problem gone)

Include recommend-delete in proposal as `### Backlog Sweep`. Do NOT delete yet.

## Step 3d: Propose Mode

1. Read SPEC.md (goal, criteria, SPEC_META date). No SPEC.md -> route to interview.
2. `git log --oneline` since SPEC_META date.
3. If `### Proposal` already exists, ask user before replacing.
4. Generate proposal (under 40 lines):
   - What happened (grounded in git history)
   - Questions and directions
   - Revisit candidates (optional, from sweep, cap 3)
   - Backlog Sweep (optional)
5. Write under `### Proposal (YYYY-MM-DD)` in SPEC.md.

## Step 3e: Plan Adoption Mode

1. Locate plan file:
   - With slug: `~/.claude/plans/<slug>.md`
   - Without: most recent plan file
2. Read plan file as authoritative brief.
3. Read codebase. Note drift in Context section. Check BACKLOG.md overlap.
4. Draft acceptance criteria from plan prose. Convert aspirational prose to testable checkboxes or drop.
5. Pressure test (Step 3.5).
6. Write SPEC.md (Step 4). Note plan source in Context. Leave plan file in place.

## Step 3f: Backlog Mode

### Append (`/spec backlog <description>`)

1. Read SPEC.md and BACKLOG.md. Check for duplicates.
2. Pressure test (3 gates, stop on any failure):
   - Is description specific? (names a what and where)
   - Can a revisit criterion be derived?
   - Is why-deferred concrete?
3. Generate: short name (kebab-case), one-line description, why deferred, revisit criteria, origin.
4. Append to BACKLOG.md. Create file if absent.

### Clear (`/spec backlog clear`)

1. Count entries, `rm BACKLOG.md`. Report count.

## Step 3g: Proposal Consume Mode

1. Read `### Proposal` section.
2. Apply BACKLOG manifest via `spec-backlog-apply.sh`:
   ```bash
   spec-backlog-apply.sh <<'MANIFEST'
   delete: <heading>
   adopt: <heading> | YYYY-MM-DD
   MANIFEST
   ```
3. Read codebase.
4. Draft acceptance criteria from proposal + revived candidates.
5. Pressure test (Step 3.5).
6. Write SPEC.md (Step 4). Remove consumed `### Proposal` section.
7. Report BACKLOG mutations verbatim from script output.

## Step 3.5: Pressure Test

Applied when writing NEW criteria only. 5 questions:

1. What input or state would break this?
2. What did I assume but not state?
3. What happens on failure?
4. What would an adversarial reviewer flag as untested?
5. Am I over-specifying?

Only add/revise criteria if a question reveals a genuine gap.

## Step 4: SPEC.md Format

```markdown
## Spec, YYYY-MM-DD, [short title]

**Goal:** [1-2 sentences]

### Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

### Context

[Optional: constraints, prior art, dependencies]

---
*Prior spec (YYYY-MM-DD): [one sentence summary]*

### Proposal (YYYY-MM-DD)
[Only when generated. Consumed when next spec written.]

<!-- SPEC_META: {"date":"YYYY-MM-DD","title":"...","criteria_total":N,"criteria_met":0} -->
```

Criteria rules:
- Checkbox format, each independently verifiable
- Ordered most to least important
- No overlap, no implementation steps disguised as criteria

## Step 5: Output

| Mode | Output |
|------|--------|
| New spec | "Spec written: [title] with N acceptance criteria." |
| Plan adopted | "Spec adopted from plan `<slug>` with N acceptance criteria." |
| Evolve (in progress) | "Spec updated: N/M criteria met." |
| Evolve (complete) | Proposal + retrospective question + BACKLOG template |
| Proposal | "Proposal written. Run `/spec` to start next turn." |
| Backlog append | "Added `<name>` to BACKLOG.md." |
| Backlog clear | "Cleared N entries from BACKLOG.md." |
| Escape | No spec written; suggest plan mode |

If BACKLOG.md has entries, append: `BACKLOG.md: N entries.`
If N > 15, also: `Staleness check: consider /spec backlog clear.`
