# Kar.env

Inspired by [zat.env](https://github.com/peterzat/zat.env).

Kar.env is a minimal harness for verification-first coding. Works with Claude Code, Codex, and any coding agent that reads markdown.

## Install

```bash
git clone <repo-url> ~/Code/kar.env
cd ~/Code/kar.env
./install.sh
```

Symlinks skills into `~/.claude/skills/` and `~/.agents/skills/`, helper scripts into `~/bin/`, and registers hooks in Claude Code settings.

Uninstall with `./uninstall.sh`.

## Workflow

1. `/spec` to define what done looks like
2. Build it
3. `/spec` again to check off criteria
4. `/codereview` before pushing (the pre-push hook enforces this)
5. `/pr` to ship

`/security`, `/architect`, and `/tester` are available any time but not required by the loop.

## Skills

- `/spec` writes and evolves acceptance criteria in SPEC.md
- `/codereview` adversarial code review, gates git push
- `/codefix` fixes review findings (called by /codereview)
- `/security` security audit
- `/architect` architecture review (read-only, no output file)
- `/tester` test strategy review and test architecture design
- `/pr` PR workflow via gh CLI

## Files written to disk

- SPEC.md by /spec
- CODEREVIEW.md by /codereview
- SECURITY.md by /security
- TESTING.md by /tester
- BACKLOG.md by /spec and /tester

## Helper scripts (~/bin/)

- `codereview-marker` push marker management
- `codereview-skip` one-time bypass for the pre-push gate
- `spec-backlog-apply.sh` deterministic BACKLOG.md mutator

## Hooks

- `pre-push-codereview.sh` blocks git push without passing review
- `allow-venv-source.sh` auto-approves venv activation
- `post-tool-exit-plan-mode.sh` reminds about /spec plan after exiting plan mode
