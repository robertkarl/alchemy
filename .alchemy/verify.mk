SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.PHONY: alchemy-verify criterion-1 criterion-2 criterion-3 criterion-4 criterion-5 criterion-6 criterion-7

SKILLS_DIR := skills

# Criterion 1: /alchemize orchestrates two loops with a codereview pass between them:
#   inner loop (fulfill/verify until pass), then codereview (once), then final loop (fulfill/verify until pass)
criterion-1:
	@echo "Checking: /alchemize orchestrates two loops with codereview pass between them"
	@grep -qi 'codereview\|code.review\|code_review' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not reference codereview phase"; exit 1; }
	@grep -qi 'inner.*loop\|first.*loop\|phase 3\|loop.*1\|initial.*loop' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not describe the inner (first) loop"; exit 1; }
	@grep -qi 'final.*loop\|second.*loop\|phase 5\|loop.*2\|post.*review.*loop' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not describe the final (second) loop"; exit 1; }
	@python3 -c "import re,sys; text=open('$(SKILLS_DIR)/alchemize/SKILL.md').read(); cr=[m.start() for m in re.finditer(r'codereview|code.review',text,re.I)]; lp=[m.start() for m in re.finditer(r'fulfill.*verify|verify.*fulfill|loop',text,re.I)]; sys.exit(1) if not cr else None; before=[p for p in lp if p<cr[0]]; after=[p for p in lp if p>cr[0]]; sys.exit('FAIL: no loop before codereview') if not before else None; sys.exit('FAIL: no loop after codereview') if not after else None"
	@echo "PASS: criterion-1"

# Criterion 2: /codereview writes its report to CODE_REVIEW.md in the project root
#   (in addition to or instead of /tmp/codereview-*.md)
criterion-2:
	@echo "Checking: /codereview writes report to CODE_REVIEW.md in project root"
	@grep -q 'CODE_REVIEW\.md' $(SKILLS_DIR)/codereview/SKILL.md || { echo "FAIL: codereview SKILL.md does not mention CODE_REVIEW.md"; exit 1; }
	@echo "PASS: criterion-2"

# Criterion 3: /fulfill reads CODE_REVIEW.md if it exists and addresses review findings alongside SPEC.md criteria
criterion-3:
	@echo "Checking: /fulfill reads CODE_REVIEW.md if it exists"
	@grep -q 'CODE_REVIEW\.md' $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill SKILL.md does not mention CODE_REVIEW.md"; exit 1; }
	@grep -qi 'read.*CODE_REVIEW\|CODE_REVIEW.*read\|review.*finding\|address.*review\|code review' $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill does not describe reading or addressing code review findings"; exit 1; }
	@echo "PASS: criterion-3"

# Criterion 4: The code review pass runs at most once per alchemize invocation;
#   alchemize does not re-enter codereview after the final loop
criterion-4:
	@echo "Checking: code review runs at most once per alchemize invocation"
	@grep -qi 'once\|at most once\|single.*review\|one.*review\|no.*re-enter\|does not.*re-enter\|exactly once' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not state codereview runs at most once"; exit 1; }
	@echo "PASS: criterion-4"

# Criterion 5: CODE_REVIEW.md lives in the project root, next to SPEC.md
criterion-5:
	@echo "Checking: CODE_REVIEW.md lives in project root next to SPEC.md"
	@grep -q 'CODE_REVIEW\.md' $(SKILLS_DIR)/alchemize/SKILL.md || grep -q 'CODE_REVIEW\.md' $(SKILLS_DIR)/codereview/SKILL.md || { echo "FAIL: neither alchemize nor codereview mention CODE_REVIEW.md"; exit 1; }
	@echo "PASS: criterion-5"

# Criterion 6: /shipit does NOT invoke /alchemize; it is a separate human-triggered step
criterion-6:
	@echo "Checking: /shipit does NOT invoke /alchemize"
	@if grep -qi '/alchemize\|run.*alchemize\|spawn.*alchemize\|invoke.*alchemize' $(SKILLS_DIR)/shipit/SKILL.md; then echo "FAIL: shipit still invokes or references /alchemize"; exit 1; fi
	@echo "PASS: criterion-6"

# Criterion 7: README.md documents all 8 skills: mkspec, encode, fulfill, verify, alchemize, codereview, shipit, alchemy-worker
criterion-7:
	@echo "Checking: README.md documents all 8 skills"
	@test -f README.md || { echo "FAIL: README.md does not exist"; exit 1; }
	@for skill in mkspec encode fulfill verify alchemize codereview shipit alchemy-worker; do grep -qi "$$skill" README.md || { echo "FAIL: README.md does not mention $$skill"; exit 1; }; done
	@echo "PASS: criterion-7"

alchemy-verify: criterion-1 criterion-2 criterion-3 criterion-4 criterion-5 criterion-6 criterion-7
	@echo "All criteria passed."
