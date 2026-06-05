## Spec, 2026-06-04, alchemy

**Goal:** Alchemy enforces builder/verifier separation for agentic coding loops via two user entry points (mkspec, alchemize) plus a ship pipeline (shipit) that gates on code review with fresh context.

### Acceptance Criteria

- [x] `/mkspec` skill exists: interviews the user one question at a time, reads codebase for context, produces SPEC.md with concrete criteria (bash-verifiable where possible, judgment-based when needed)
- [x] `/alchemize` skill exists and runs the build/verify loop: spawn builder, spawn verifier, write TESTLOG.md on failure, loop up to 20 rounds, stop on success or exhaustion
- [x] Builder agent: reads SPEC.md + TESTLOG.md, implements criteria, checks boxes as it goes, commits along the way, deletes TESTLOG.md after reading it
- [x] Verifier agent: unchecks all boxes first, reads only SPEC.md and the codebase, executes bash-verifiable specs, judges subjective specs, re-checks only what actually passes
- [x] Verifier never sees TESTLOG.md (builder deletes it before verifier runs)
- [x] Alchemize orchestrator never reads source code; only SPEC.md and verifier output
- [x] Alchemize orchestrator never uses Edit or Write on source files; only SPEC.md and TESTLOG.md
- [x] `/codereview` skill exists: fresh-context agent reviews diff from main, writes report to /tmp/, uses precision-over-recall criteria (80% confidence threshold, empty report is valid, evidence grounded with file:line), severity tiers BLOCK/WARN/NOTE, pass = 0 BLOCKs
- [x] `/shipit` skill exists and runs the full pipeline: assert git clean, run `make test`, run `/alchemize`, run `/codereview`, if codereview fails feed findings back through `/alchemize` and re-review (shared 20-round cap), rebase onto remote main, push
- [x] `install.sh` and `uninstall.sh` handle all skills (mkspec, alchemize, codereview, shipit)

### Context

Alchemy is a ground-up rethink of kar.env (itself derived from zat.env). The core insight: the builder lies. Every agentic loop where the same context builds and verifies has structural bias. Alchemy enforces separation through context boundaries: the builder dies, the verifier is born cold, TESTLOG.md is ephemeral so the verifier can't develop sympathy for prior attempts.

Code review follows the same principle. A fresh-context agent reviews the code with no knowledge of the build process. Codereview criteria are borrowed from zat.env: precision over recall, confidence thresholds, evidence grounding.

SPEC.md is the only durable file. TESTLOG.md exists only between verifier death and builder birth.

---
*Prior spec (2026-06-04): kar.env bootstrap + settings fix + implement skill. Superseded by alchemy redesign.*

<!-- SPEC_META: {"date":"2026-06-04","title":"alchemy","criteria_total":10,"criteria_met":10} -->
