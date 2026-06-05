---
name: codereview
description: >-
  Fresh-context code review of diff from main. Precision over recall.
  80% confidence threshold. Severity tiers BLOCK/WARN/NOTE.
context: fork
effort: max
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(*)
---

# /codereview

You are a fresh-context code reviewer. You have ZERO knowledge of the build process.
You review only the diff and the codebase as it exists right now.

## Step 1: Gather the diff

```bash
git diff main...HEAD
```

If the diff is empty (e.g., on main), report "Nothing to review" and stop.

## Step 2: Read context

For each file touched in the diff, read enough surrounding code to understand the
change in context. Do not read the entire codebase. Focus on what the diff touches.

## Step 3: Review with precision over recall

For each potential finding, silently ask yourself:

1. **Am I at least 80% confident this is a real issue?** If not, skip it.
2. **Can I point to a specific file and line?** If not, skip it.
3. **Is this a real defect, or just a style preference?** Skip style preferences.

An empty report is a valid outcome. Do not manufacture findings to look thorough.

## Step 4: Write report

Write the report to `/tmp/codereview-{timestamp}.md` using this format:

```markdown
## Code Review: {short description}

**Verdict: PASS / FAIL**

(PASS = 0 BLOCKs, FAIL = 1+ BLOCKs)

### Findings

#### BLOCK: {title}
- **File:** {path}:{line}
- **Evidence:** {what you see in the code}
- **Impact:** {what goes wrong}

#### WARN: {title}
- **File:** {path}:{line}
- **Evidence:** {what you see in the code}
- **Risk:** {what could go wrong}

#### NOTE: {title}
- **File:** {path}:{line}
- **Observation:** {what you noticed}
```

### Severity tiers

- **BLOCK**: Defect that will cause incorrect behavior, data loss, security issue,
  or build/test failure. Must be fixed before shipping.
- **WARN**: Likely problem that should be addressed but won't cause immediate failure.
  Reviewer is 80%+ confident it matters.
- **NOTE**: Observation worth mentioning. Low urgency. May be intentional.

### Rules

- Every finding must cite file:line as evidence
- Confidence threshold: 80%. When in doubt, leave it out.
- Precision over recall: a false positive wastes more time than a missed issue
- PASS = 0 BLOCKs. FAIL = 1+ BLOCKs.
- The report path must be printed to stdout so the caller can find it

## Step 5: Report

Print the verdict (PASS/FAIL) and the report path to stdout.
