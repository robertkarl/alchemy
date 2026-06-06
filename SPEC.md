# Spec: Code Review Loop in Alchemize

## Goal

Add a code review pass to the alchemize pipeline. After the inner fulfill/verify
loop converges, alchemize spawns a code review agent that writes findings to
`CODE_REVIEW.md`. Then alchemize re-enters the fulfill/verify loop so the builder
can address the review findings. The review pass happens at most once.

## Architecture

```
/mkspec -> /encode -> [ /fulfill <-> /verify ] -> /codereview -> [ /fulfill <-> /verify ] -> DONE
                       ~~~~ inner loop ~~~~                       ~~~~ final loop ~~~~
```

The inner loop runs until all SPEC.md criteria pass. Then `/codereview` runs once
and writes `CODE_REVIEW.md` to the project root. Then the final loop runs: fulfill
reads CODE_REVIEW.md alongside SPEC.md and TESTLOG.md, and verify confirms all
criteria still pass. The final loop converges when verify passes.

## Acceptance Criteria

- [x] `/alchemize` orchestrates two loops with a codereview pass between them: inner loop (fulfill/verify until pass), then codereview (once), then final loop (fulfill/verify until pass)
- [x] `/codereview` writes its report to `CODE_REVIEW.md` in the project root (in addition to or instead of `/tmp/codereview-*.md`)
- [x] `/fulfill` reads `CODE_REVIEW.md` if it exists and addresses review findings alongside SPEC.md criteria
- [x] The code review pass runs at most once per alchemize invocation; alchemize does not re-enter codereview after the final loop
- [x] `CODE_REVIEW.md` lives in the project root, next to SPEC.md
- [ ] `/shipit` does NOT invoke `/alchemize`; it is a separate human-triggered step
- [x] `README.md` documents all 8 skills: mkspec, encode, fulfill, verify, alchemize, codereview, shipit, alchemy-worker
