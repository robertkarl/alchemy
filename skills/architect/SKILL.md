---
name: architect
description: Architecture review across 10 dimensions. Read-only, no persistent output.
disable-model-invocation: true
allowed-tools:
  - Bash(*)
  - Read
  - Grep
  - Glob
---

# /architect

Architecture review. Terminal node, produces no persistent file.

## Algorithm

### Step 1: Read Context

Read CODEREVIEW.md, SECURITY.md, TESTING.md, SPEC.md (most recent entry, metadata).

### Step 2: Understand the System

- README, CLAUDE.md, AGENTS.md, design docs
- Directory structure 2-3 levels deep
- Languages, frameworks, dependency management
- Entry points and config files
- Dependency manifests (tree size, pinning, freshness)
- CI/CD, deployment, observability
- If args name a topic, focus there. `deps` = dimension 4 deep-dive. `ops` = dimension 9.

### Step 3: Evaluate (10 dimensions, 2 groups)

If focused review requested, evaluate only relevant dimensions; one-line note for rest.

**Design Quality:**
1. Structural clarity: navigability, separation of responsibilities
2. Appropriate complexity: proportional to problem
3. Scale alignment: architecture fits current/near-term scale
4. Dependency health: justified, maintained, pinned, license risks, bloat
5. Extensibility: probable evolution paths, not hypothetical

**Strategic Fitness:**
6. Consistency: uniform patterns across codebase
7. Business goal alignment: architecture serves stated goals
8. Technology selection: evidence of friction (build failures, missing ecosystem, abandonment)
9. Operational fitness: build pipeline, deployment, observability, config management
10. Developer experience: clone-to-running time, local dev complexity, feedback loops

### Step 4: Pressure Test

1. Judging for wrong scale?
2. Is complexity proportional? Name concrete cost.
3. Extensibility against likely vs hypothetical changes?
4. Consistency vs intentional evolution (check git history)?
5. Technology changes without evidence of friction?
6. Operational fitness for right deployment model?

### Step 5: Report

Per dimension: assessment (2-4 sentences), recommendation, priority (HIGH/MEDIUM/LOW/N/A).

Strategic summary: 2-3 sentences, board recommendation (HEALTHY/WATCH/ACT), top 3 recommendations.

Console output only. No file written.
