---
name: tester
description: Test strategy review (audit) and test architecture design (design). Writes TESTING.md.
disable-model-invocation: true
allowed-tools:
  - Bash(*)
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# /tester

Two modes: `audit` (review test strategy) and `design` (write test architecture contract).

## Audit Mode

### Step 1: Read Context

Read TESTING.md, SECURITY.md, CODEREVIEW.md, SPEC.md (most recent entry, metadata).

### Step 2: Discover Test Infrastructure

Scan for: test files, test config, CI/CD, coverage config, pre-commit/pre-push hooks, deployment config. Read 2-3 representative test files.

### Step 3: Assess (9 dimensions)

1. Test coverage strategy: right things tested? SPEC.md criteria with no test = finding
2. Test automation maturity: auto vs manual? single command?
3. Automatic test execution: pre-commit, CI on PR, deploy gates
4. CI/CD integration: every push/PR? branch protection?
5. Test framework choices: appropriate, current, unnecessary sprawl
6. Fixture and data management: creation, sharing, isolation
7. Flaky test patterns: sleep(), timing deps, order-dependent, shared mutable state
8. Missing test categories: only what's actually needed
9. Development loop cadence: fast inner loop <15s, documented cadence

### Step 4: Report

Classify as BLOCK / WARN / NOTE. Format: `[SEVERITY] dimension: description` with current state and recommendation.

### Step 5: Update TESTING.md

Current entry + one-paragraph prior summary. If file has `# Durable test-architecture contract` H1, preserve everything below it (audit goes above).

```
<!-- TESTING_META: {"date":"YYYY-MM-DD","commit":"abc1234","block":N,"warn":N,"note":N} -->
```

## Design Mode

### D.1: Read Context

Read TESTING.md, SPEC.md, README.md, CLAUDE.md, AGENTS.md, BACKLOG.md (scan for existing `Origin: tester design` entries + overlap detection).

### D.2: Discover Project Signals

Capture: test framework/entry point, test count/runtime, non-deterministic output signals (CUDA, LLM API, image-gen), multi-env signals, human-eval signals, drift/baseline signals.

### D.3: Pressure-test Contract Shape

- Proportional to signals?
- More proxy commitments than critic?
- Single entry point named?
- What does "pass" mean at each tier?
- What should NOT be tested?
- Survives cold-open by fresh session?

### D.4: Draft Contract

Under H1 `# Durable test-architecture contract`. Minimum sections:
1. Cold-open (1-2 commands, timing, exit code)
2. Entry point
3. Duration philosophy (greenfield: one tier; growing: short/medium; mature: tier table)
4. Proxy / drift strategy
5. Human-eval strategy
6. What not to test

Proportionality: greenfield ~50 lines, one framework. Growing: two tiers. Mature: full dimensions.

### D.5: Draft Rollout Entries

One BACKLOG.md entry per concrete step. Four fields: short name, description, why deferred, revisit criteria. Plus `Origin: tester design YYYY-MM-DD`.

### D.5.5: Pre-apply Checklist (VISIBLE, emit before any file mutation)

1. Signals fingerprint
2. Contract shape + line count
3. Rollout entry count + justification
4. Per-entry overlap scan
5. SPEC tension (flag if SPEC.md has out-of-scope clause for testing)

### D.6: Apply

1. Write contract to TESTING.md.
2. Apply BACKLOG manifest via `spec-backlog-apply.sh`:
   ```bash
   spec-backlog-apply.sh <<'MANIFEST'
   purge-origin: tester design
   append: <heading>
   ...
   end-append
   MANIFEST
   ```
3. Never write BACKLOG.md directly.

### D.7: Report

Contract shape, script output verbatim, final BACKLOG count, revert instructions.
