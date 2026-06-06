## Spec, 2026-06-05, alchemy v2: four-phase loop

**Goal:** Rearchitect alchemy's core loop into four discrete phases (mkspec, encode, fulfill, verify) where the spec and executable test plan are written once and locked, the builder never sees the tests, and failures loop only between fulfill and verify.

### Acceptance Criteria

- [ ] `/mkspec` skill produces SPEC.md with `- [ ]` checkbox criteria; supports both interactive (interview) and autonomous (agent reads codebase + prompt) modes
- [ ] `/encode` skill exists: reads SPEC.md, produces `.alchemy/verify.mk` with an `alchemy-verify` target that exits 0 on pass and non-zero on fail; supports both interactive and autonomous modes
- [ ] `.alchemy/` directory is structurally separated from source code; the fulfill agent is explicitly forbidden from reading or modifying anything in `.alchemy/`
- [ ] `/fulfill` skill exists: reads SPEC.md and TESTLOG.md (if present), implements unchecked criteria, checks boxes as it goes, commits along the way, deletes TESTLOG.md after reading; never touches `.alchemy/`
- [ ] `/verify` skill exists: fresh-context agent unchecks all boxes, runs `make -f .alchemy/verify.mk alchemy-verify`, re-checks only criteria that actually pass, commits updated SPEC.md
- [ ] `/alchemize` orchestrator runs the full pipeline: mkspec (once) -> encode (once) -> [fulfill <-> verify] loop (max 20 iterations); orchestrator never reads source code or `.alchemy/verify.mk`
- [ ] On verify failure, orchestrator writes TESTLOG.md with failure details and iteration number, then loops back to fulfill; spec and test plan are never modified during the loop
- [ ] The fulfill agent is spawned via a custom `/alchemy-worker` skill into an isolated git worktree where `.alchemy/` is deleted before launch; the worker has no proposal/approval ceremony and just executes
- [ ] `/codereview` and `/shipit` skills are updated to work with the new four-phase structure
- [ ] `install.sh` and `uninstall.sh` handle all skills (mkspec, encode, fulfill, verify, alchemize, alchemy-worker, codereview, shipit)

### Context

This is alchemy v2. The core insight from v1 remains: the builder lies. But v1 conflated spec-writing with test-writing, and the verifier had to both design and execute verification. V2 splits these concerns: the spec says *what*, the encoded test plan says *how to check*, and neither is modified once the build loop starts. The fulfill agent never sees the test plan (`.alchemy/` is off-limits), so it cannot learn to game the tests. Failures only result in more implementation attempts, never in weakened specs or tests.

The loop: mkspec (once) -> encode (once) -> [fulfill <-> verify] until gold or exhaustion (20 rounds).

---
*Prior spec (2026-06-04): alchemy v1 with builder/verifier separation. Superseded by four-phase rearchitecture.*

<!-- SPEC_META: {"date":"2026-06-05","title":"alchemy v2: four-phase loop","criteria_total":10,"criteria_met":0} -->
