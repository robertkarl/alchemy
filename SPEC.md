## Spec, 2026-06-04, alchemy

**Goal:** Rename kar.env to alchemy and rebuild around two user entry points (mkspec, alchemize) that enforce builder/verifier separation structurally, not aspirationally.

### Acceptance Criteria

- [ ] Repo renamed to alchemy: directory, README, install/uninstall scripts, all internal references
- [ ] `/mkspec` skill exists: interviews the user one question at a time, reads codebase for context, produces SPEC.md with concrete criteria (bash-verifiable where possible, judgment-based when needed)
- [ ] `/alchemize` skill exists and runs the full loop autonomously: spawn builder, spawn verifier, write TESTLOG.md on failure, loop up to 20 times, stop on success or exhaustion
- [ ] Builder agent: reads SPEC.md + TESTLOG.md, implements criteria, checks boxes as it goes, commits along the way, deletes TESTLOG.md after reading it
- [ ] Verifier agent: unchecks all boxes first, reads only SPEC.md and the codebase, executes bash-verifiable specs, judges subjective specs, re-checks only what actually passes
- [ ] Verifier never sees TESTLOG.md (builder deletes it before verifier runs)
- [ ] Alchemize orchestrator never reads source code — only SPEC.md and verifier output
- [ ] Alchemize orchestrator never uses Edit or Write on source files — only SPEC.md and TESTLOG.md
- [ ] Old skills (codereview, codefix, security, architect, tester, pr, implement) removed from skills/ and install/uninstall
- [ ] `install.sh` writes valid Claude Code hook schema (no bare `command` or `if` fields)
- [ ] Running `/alchemize` on a trivial SPEC.md in a fresh tmux session completes the loop without the orchestrator touching source code — verifiable by reading the session log

### Context

Alchemy is a ground-up rethink of kar.env (itself derived from zat.env). The core insight: the builder lies. Every agentic loop where the same context builds and verifies has structural bias (zat.env philosophy principle #5). Alchemy enforces separation through context boundaries: the builder dies, the verifier is born cold, TESTLOG.md is ephemeral so the verifier can't develop sympathy for prior attempts.

SPEC.md is the only durable file. It's the clipboard passed between builder and verifier. TESTLOG.md exists only between verifier death and builder birth.

---
*Prior spec (2026-06-04): kar.env bootstrap + settings fix + implement skill. Superseded by alchemy redesign.*

<!-- SPEC_META: {"date":"2026-06-04","title":"alchemy","criteria_total":11,"criteria_met":0} -->
