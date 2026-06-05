## Spec — 2026-06-04 — kar.env bootstrap

**Goal:** kar.env installs and uninstalls cleanly, skills are discoverable by both Claude Code and Codex, and the verification loop works end-to-end.

### Acceptance Criteria

- [x] `install.sh` symlinks all 7 skills into `~/.claude/skills/` and `~/.agents/skills/`
- [x] `install.sh` symlinks all bin scripts into `~/bin/` and they are executable
- [x] `install.sh` registers all 3 hooks in `~/.claude/settings.json` without clobbering existing settings
- [x] `install.sh` appends Codex instructions to `~/.codex/AGENTS.md` (idempotent, does not duplicate on re-run)
- [x] `uninstall.sh` removes all symlinks, hook registrations, and Codex instructions created by install
- [x] `codereview-marker hash` returns a 16-char hex hash when there are uncommitted/unpushed changes
- [x] `codereview-marker hash` exits 2 when there are no reviewable changes
- [x] `spec-backlog-apply.sh` handles delete, adopt, purge-origin, and append operations correctly
- [x] Pre-push hook blocks `git push` when no review marker exists and allows it when marker matches

### Context

First spec for kar.env. Derived from zat.env mechanics, stripped of philosophy and agent-specific coupling. Skills are plain markdown with YAML frontmatter — compatible with both Claude Code and Codex skill discovery.

<!-- SPEC_META: {"date":"2026-06-04","title":"kar.env bootstrap","criteria_total":9,"criteria_met":9} -->
