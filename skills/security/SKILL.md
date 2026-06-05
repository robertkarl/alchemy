---
name: security
description: Security audit across 8 dimensions. Writes SECURITY.md.
disable-model-invocation: true
allowed-tools:
  - Bash(*)
  - Read
  - Write
  - Grep
  - Glob
---

# /security

Security audit. Requires concrete attack vectors for every finding.

## Algorithm

### Step 1: Read Context

Read SECURITY.md (prior findings, accepted risks, don't re-flag accepted), CODEREVIEW.md, SPEC.md.

### Step 2: Determine Scope

- Empty = full repo. Prioritize: config files, auth code, input-handling, network-facing code, dependency manifests.
- `changes-only` = `git diff` + `git diff --cached`.
- File path(s) = those files only.

### Step 3: Review (8 dimensions)

1. Secret leaks: file contents AND `git log -p --follow -3 <file>`. Never reproduce secret values, use redacted form.
2. Input/output sanitization: SQL injection, XSS, command injection, path traversal, SSRF. Trace actual data flow.
3. Auth/authz: authentication and authorization gaps.
4. Dependency supply chain: known vulns, unpinned versions, typosquatting.
5. Infrastructure: permissions, ports, CORS, debug endpoints.
6. AI-specific: prompt injection, unvalidated LLM outputs.
7. Data exposure: sensitive data in logs, verbose stack traces.
8. PII in source: ignore git commit metadata. WARN on first detection. Skip if accepted in prior SECURITY.md.

### Step 4: Pressure Test

- Is the attack vector reachable? Verify concrete path.
- What was missed? For each clean dimension, verify it wasn't skipped due to complexity.
- Severity calibration: theoretical concern with no reachable vector is not BLOCK.
- Verify `git log -p` was run for credential-handling files.

### Step 5: Report & Write SECURITY.md

Severities: BLOCK / WARN / NOTE.

Finding format:
```
[SEVERITY] file:line description
  Attack vector: [how to exploit]
  Evidence: [redacted]
  Remediation: [concrete fix]
```

```markdown
## Security, YYYY-MM-DD (commit: abc1234)
**Scope:** full | changes-only | paths
### Findings
[list or "No security issues identified."]
### Accepted Risks
[carried forward]
---
*Prior scan (YYYY-MM-DD): [one sentence]*
<!-- SECURITY_META: {"date":"YYYY-MM-DD","commit":"<HEAD>","scope":"...","block":N,"warn":N,"note":N} -->
```

For path-scoped runs, include `"scanned_files"` in META.

Retention: current entry + one-paragraph prior summary. 80% confidence threshold. Empty report is valid.
