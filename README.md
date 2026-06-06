Alchemy enforces builder/verifier separation for agentic coding loops.

Works with Claude and Codex.

## Install

```bash
git clone <repo-url> ~/Code/alchemy
cd ~/Code/alchemy
./install.sh
```

Symlinks skills into `~/.claude/skills/` and `~/.agents/skills/`, helper scripts into `~/bin/`.

Uninstall with `./uninstall.sh`.

## Skills

- `/mkspec`: Interview the user to produce SPEC.md with concrete acceptance criteria.
- `/encode`: Read SPEC.md and produce `.alchemy/verify.mk` with an alchemy-verify target that exits 0 on pass, non-zero on fail.
- `/fulfill`: Read SPEC.md, implement unchecked criteria, check boxes as you go, commit along the way. Never touches `.alchemy/`. Also reads `CODE_REVIEW.md` if present.
- `/verify`: Fresh-context verifier. Unchecks all boxes, runs the test plan, re-checks only criteria that actually pass, commits updated SPEC.md.
- `/alchemize`: Autonomous build-verify-learn loop. Orchestrates mkspec, encode, then two fulfill/verify loops with a codereview pass between them.
- `/codereview`: Fresh-context code review of diff from main. Precision over recall. 80% confidence threshold. Severity tiers BLOCK/WARN/NOTE. Writes report to `CODE_REVIEW.md`.
- `/shipit`: Ship pipeline: assert clean, test, codereview, rebase, push. Human-triggered; does not invoke `/alchemize`.
- `/alchemy-worker`: Spawn a fulfill agent in an isolated git worktree where `.alchemy/` does not exist, enforcing builder/verifier separation.

## Files

- `SPEC.md`: the clipboard (acceptance criteria with checkboxes)
- `TESTLOG.md`: ephemeral failure feed (deleted after each fulfill reads it)
- `CODE_REVIEW.md`: code review findings (written by codereview, read by fulfill)
