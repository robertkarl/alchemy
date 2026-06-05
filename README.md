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

## Commands

- `/mkspec`: interview to produce SPEC.md
- `/alchemize`: autonomous build-verify-learn loop. Until gold or you run out of mass.

## Files

- `SPEC.md`: the clipboard
- `TESTLOG.md`: ephemeral failure feed
