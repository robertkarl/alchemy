## Spec, 2026-06-05, Structural enforcement for alchemize orchestrator

**Goal:** Add structural enforcement so the alchemize orchestrator thread physically cannot modify files beyond SPEC.md, TESTLOG.md, and CODE_REVIEW.md, replacing the current honor-system LLM instructions with tool-level restrictions.

### Acceptance Criteria

- [x] The alchemize SKILL.md `allowed-tools` list does NOT include `Edit` or `Write` (verify by parsing the YAML frontmatter of `skills/alchemize/SKILL.md`)
- [x] The alchemize SKILL.md `allowed-tools` list replaces `Bash(*)` with a restricted set of bash commands that cannot modify source files; specifically `Bash(cat SPEC.md)`, `Bash(cat TESTLOG.md)`, `Bash(cat CODE_REVIEW.md)`, `Bash(test *)`, `Bash(cat /tmp/alchemy-worker-*)`, and `Bash(cat <<*TESTLOG.md)` or equivalent write-to-TESTLOG pattern
- [x] The alchemize SKILL.md retains `Agent`, `Skill`, `Read`, and `ToolSearch` in its allowed-tools so it can still spawn sub-agents and read files
- [x] The alchemize SKILL.md instructions for writing TESTLOG.md use a mechanism compatible with the restricted bash patterns (e.g., a specific bash glob pattern for writing TESTLOG.md rather than using Write or Edit)
- [x] The alchemize SKILL.md prose rules still state the orchestrator must not read source code or .alchemy/ files; the structural enforcement supplements but does not replace the prose rules
- [x] Existing orchestrator functionality is preserved: the alchemize skill can still spawn mkspec, encode, fulfill (via alchemy-worker), verify, and codereview agents, read SPEC.md, write TESTLOG.md, and check .alchemy/verify.mk existence
