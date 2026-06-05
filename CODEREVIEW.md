## Review, 2026-06-04 (commit: b6ab6d5)
**Summary:** First review of kar.env bootstrap. Shell scripts are correct. One non-critical bug in purge_origin reporting.
**External reviewers:** None configured.
### Findings
[WARN] bin/spec-backlog-apply.sh:160 purge_origin count via "grep -c PURGED /dev/stderr" is a no-op. grep cannot read stderr of a prior pipeline stage this way. Fix by capturing awk stderr to a temp file or counting purged lines in output.

[NOTE] No test infrastructure exists. No test files, config, or CI.
### Fixes Applied
None.
### Accepted Risks
None.
<!-- REVIEW_META: {"date":"2026-06-04","commit":"b6ab6d5","reviewed_up_to":"b6ab6d5","base":"empty-tree","tier":"full","block":0,"warn":1,"note":1} -->
