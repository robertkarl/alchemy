# Alchemy

Alchemy enforces builder/verifier separation for agentic coding loops. The builder lies -- alchemy makes that structurally impossible.

## Install

```bash
git clone <repo-url> ~/Code/kar.env
cd ~/Code/kar.env
./install.sh
```

Symlinks skills into `~/.claude/skills/` and `~/.agents/skills/`, helper scripts into `~/bin/`.

Uninstall with `./uninstall.sh`.

## Commands

- `/mkspec` -- interview to produce SPEC.md
- `/alchemize` -- autonomous build-verify-learn loop. Until gold or you run out of mass.

## Files

- `SPEC.md` -- the clipboard
- `TESTLOG.md` -- ephemeral failure feed
