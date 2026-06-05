---
name: codereview
description: Adversarial code review. Gates git push. Invokes /security and /codefix.
disable-model-invocation: true
allowed-tools:
  - Bash(*)
  - Read
  - Grep
  - Glob
  - Skill(security)
  - Skill(codefix)
---

# /codereview

Adversarial review of changes before push. No Edit or Write access, verifier only.

## Full Review Pipeline

### Step 1: Read Context

Read from project root (if they exist):
- `CODEREVIEW.md` (prior findings, accepted risks. Downgrade accepted to NOTE, re-report unresolved at original severity)
- `SECURITY.md`, `TESTING.md`, `SPEC.md` (most recent entry, metadata footer)

### Step 2: Gather Changes

Run: `git status --short`, `git log --oneline -5`, `git diff`, `git diff --cached`.

Review scope: `git diff $(codereview-marker base) -- ':!CODEREVIEW.md' ':!SECURITY.md' ':!TESTING.md' ':!SPEC.md'`

**Tier classification:**
- **Light:** Only `.md`, `.txt`, `.gitignore`, `.gitconfig` changed. Skips steps 3, 5, 5.5, 6.5, 7.
- **Full:** Any code/config file changed.

**Refresh detection** (all must hold):
1. Prior `reviewed_up_to` is ancestor of HEAD
2. Prior `block` count is 0
3. Prior `base` matches current upstream

If refresh: full-depth review on files changed since prior review, regression-risk-only on already-reviewed files.

**Empty-tree case:** New repo, no upstream → entire tree is the diff. Full review.
**Nothing to review:** Only when `codereview-marker hash` exits 2.

### Step 3: Run Tests (full only)

Detect test infrastructure. Run tests, record baseline pass/fail. No tests = finding.

### Step 4: Review (6 dimensions)

1. Correctness: bugs, off-by-one, null handling, race conditions
2. Code quality: dead code, duplication, abstraction level
3. Solution approach: right approach? simpler alternative?
4. Spaghetti detection: mixed concerns in one commit
5. Regression risk: could break existing? adequate tests?
6. Spec alignment: (only if SPEC.md exists) advances or contradicts criteria? NOTE-only.

Light review: dimensions 1 and 3 only.
Refresh review: all 6 on focus set, only 5 on already-reviewed.

### Step 4.5: Pressure Test (full only)

1. Did I verify the bug or just suspect it?
2. Is there a simpler approach I missed?
3. Regression risk: did I check callers?
4. Am I conflating style with substance?
5. Spaghetti check: is the bundling intentional?

### Step 5: Security Review (full only)

Check if SECURITY.md covers current state (SECURITY_META commit + scanned_files). If covered, skip. Otherwise:
- First push (no prior scan): invoke `/security` (full audit)
- Otherwise: invoke `/security` with changed files list

### Step 5.5: External Reviewers (full only)

If `review-external.sh` is on PATH, pipe diff to it. Capture stdout (findings) and stderr (cost log). Not on PATH = skip silently. Run once only, not during fix cycles.

### Step 6: Report

**Severities:**
- BLOCK: must fix before push. Bugs, data loss, security vulns, broken tests, spaghetti.
- WARN: should fix. Missing error handling, untested critical paths.
- NOTE: informational. Never auto-fixed.

**Finding format:**
```
[SEVERITY] file:line description
  Evidence: [specific code or pattern]
  Suggested fix: [concrete recommendation]
```

### Step 6.5: Write Preliminary CODEREVIEW.md (full only)

If BLOCK or WARN findings exist, write CODEREVIEW.md now so `/codefix` can read it.

### Step 7: Fix Loop (full only)

1. Invoke `/codefix` (reads CODEREVIEW.md as spec).
2. Re-review changed files.
3. Re-run tests. Regression = cycle fails.
4. If remaining BLOCK/WARN, update CODEREVIEW.md, invoke `/codefix` again.
5. **3-cycle cap.** After 3: "requires manual intervention."

### Step 8: Write Marker

Condition: all BLOCKs resolved AND tests stable.
Command: `codereview-marker write`
Do NOT write if BLOCKs remain or tests regressed.

### Step 9: Update CODEREVIEW.md

```markdown
## Review, YYYY-MM-DD (commit: abc1234)
**Summary:** [1-2 sentences]
**External reviewers:** [cost log or "None configured."]
### Findings
[list or "No issues found."]
### Fixes Applied
[list with provider attribution, or "None."]
### Accepted Risks
[carried forward, or "None."]
---
*Prior review (YYYY-MM-DD): [one sentence]*
<!-- REVIEW_META: {"date":"...","commit":"...","reviewed_up_to":"<HEAD>","base":"<upstream>","tier":"full|refresh|light","block":N,"warn":N,"note":N} -->
```

Retention: current entry + one-line prior summary.

## External-Only Mode

`/codereview external [range]`

1. Pre-check: `review-external.sh --check`. Fail = halt.
2. Resolve range: empty → `<upstream>..HEAD`, single ref → `ref..HEAD`, two/three-dot → verbatim.
3. Compute diff. Empty = halt.
4. Pipe to `review-external.sh --range "<range>"`.
5. Print findings grouped by severity with provider attribution.
6. **No mutations.** No CODEREVIEW.md, no marker, no codefix.
