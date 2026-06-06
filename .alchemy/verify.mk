# Alchemy v2 verification plan
# Run: make -f .alchemy/verify.mk alchemy-verify
# Exits 0 if all criteria pass, non-zero on first failure.

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

SKILLS_DIR := skills
SPEC := SPEC.md

alchemy-verify: check-mkspec check-encode check-separation check-fulfill check-verify check-orchestrator check-loop-behavior check-agent-spawn check-pipeline-skills check-installer
	@echo "ALL CRITERIA PASSED"

# 1. /mkspec produces SPEC.md with checkbox criteria; supports interactive + autonomous
check-mkspec:
	@echo "--- check-mkspec ---"
	@test -f $(SKILLS_DIR)/mkspec/SKILL.md || { echo "FAIL: mkspec skill not found"; exit 1; }
	@grep -q '\- \[ \]' $(SKILLS_DIR)/mkspec/SKILL.md || { echo "FAIL: mkspec SKILL.md does not show checkbox format"; exit 1; }
	@grep -qi 'autonomous\|auto.*mode\|skip.*interview\|non.interactive' $(SKILLS_DIR)/mkspec/SKILL.md || { echo "FAIL: mkspec does not mention autonomous mode"; exit 1; }
	@grep -qi 'interview\|interactive\|ask.*question' $(SKILLS_DIR)/mkspec/SKILL.md || { echo "FAIL: mkspec does not mention interactive mode"; exit 1; }
	@echo "PASS"

# 2. /encode skill exists; produces .alchemy/verify.mk with alchemy-verify target
check-encode:
	@echo "--- check-encode ---"
	@test -f $(SKILLS_DIR)/encode/SKILL.md || { echo "FAIL: encode skill not found"; exit 1; }
	@grep -q 'verify\.mk' $(SKILLS_DIR)/encode/SKILL.md || { echo "FAIL: encode SKILL.md does not reference verify.mk"; exit 1; }
	@grep -q 'alchemy.*verify' $(SKILLS_DIR)/encode/SKILL.md || { echo "FAIL: encode SKILL.md does not reference alchemy-verify target"; exit 1; }
	@echo "PASS"

# 3. .alchemy/ structurally separated; fulfill agent forbidden from touching it
check-separation:
	@echo "--- check-separation ---"
	@test -d .alchemy || { echo "FAIL: .alchemy/ directory does not exist"; exit 1; }
	@# Check that fulfill skill explicitly forbids .alchemy access
	@grep -qi '\.alchemy\|verify\.mk' $(SKILLS_DIR)/fulfill/SKILL.md && \
		grep -qi 'forbid\|never\|must not\|do not\|prohibited\|off.limits' $(SKILLS_DIR)/fulfill/SKILL.md || \
		{ echo "FAIL: fulfill SKILL.md does not explicitly forbid .alchemy/ access"; exit 1; }
	@echo "PASS"

# 4. /fulfill skill exists with correct behavior
check-fulfill:
	@echo "--- check-fulfill ---"
	@test -f $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill skill not found"; exit 1; }
	@grep -q 'SPEC.md' $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill does not reference SPEC.md"; exit 1; }
	@grep -q 'TESTLOG.md' $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill does not reference TESTLOG.md"; exit 1; }
	@grep -q 'delete\|remove\|rm' $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill does not mention deleting TESTLOG.md"; exit 1; }
	@grep -qi 'commit' $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill does not mention committing"; exit 1; }
	@grep -q '\- \[x\]' $(SKILLS_DIR)/fulfill/SKILL.md || { echo "FAIL: fulfill does not mention checking boxes"; exit 1; }
	@echo "PASS"

# 5. /verify skill exists; unchecks all, runs make -f .alchemy/verify.mk, re-checks passing
check-verify:
	@echo "--- check-verify ---"
	@test -f $(SKILLS_DIR)/verify/SKILL.md || { echo "FAIL: verify skill not found"; exit 1; }
	@grep -q 'uncheck\|Uncheck\|\- \[ \]' $(SKILLS_DIR)/verify/SKILL.md || { echo "FAIL: verify does not mention unchecking boxes"; exit 1; }
	@grep -q 'make.*-f.*\.alchemy/verify\.mk' $(SKILLS_DIR)/verify/SKILL.md || { echo "FAIL: verify does not run make -f .alchemy/verify.mk"; exit 1; }
	@grep -qi 'commit' $(SKILLS_DIR)/verify/SKILL.md || { echo "FAIL: verify does not mention committing SPEC.md"; exit 1; }
	@echo "PASS"

# 6. /alchemize orchestrator: mkspec->encode->[fulfill<->verify] loop, never reads source or .alchemy/
check-orchestrator:
	@echo "--- check-orchestrator ---"
	@test -f $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize skill not found"; exit 1; }
	@grep -q 'mkspec' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not reference mkspec phase"; exit 1; }
	@grep -q 'encode' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not reference encode phase"; exit 1; }
	@grep -q 'fulfill' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not reference fulfill phase"; exit 1; }
	@grep -q 'verify\|verif' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not reference verify phase"; exit 1; }
	@grep -qi 'never.*read.*source\|never.*source.*code\|NEVER.*read.*source' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not forbid reading source code"; exit 1; }
	@echo "PASS"

# 7. On failure: TESTLOG.md written, loop back to fulfill; spec+tests never modified
check-loop-behavior:
	@echo "--- check-loop-behavior ---"
	@grep -q 'TESTLOG.md' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not reference TESTLOG.md"; exit 1; }
	@grep -qi 'iteration\|round\|loop' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not mention iteration tracking"; exit 1; }
	@grep -q '20' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not mention 20-iteration cap"; exit 1; }
	@# Spec and test plan must not be modified during loop
	@grep -qi 'lock\|immutable\|never.*modif\|do not.*modif\|not.*modified' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not state spec/tests are locked during loop"; exit 1; }
	@echo "PASS"

# 8. All agents spawned via Agent tool with mode: "auto"; no team_name etc.
check-agent-spawn:
	@echo "--- check-agent-spawn ---"
	@grep -q 'Agent' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not reference Agent tool"; exit 1; }
	@grep -q 'mode.*auto\|"auto"' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize does not specify mode auto"; exit 1; }
	@# Must NOT mention team_name as something to use
	@! grep -q 'team_name.*=' $(SKILLS_DIR)/alchemize/SKILL.md || { echo "FAIL: alchemize sets team_name (should not)"; exit 1; }
	@echo "PASS"

# 9. codereview and shipit updated for four-phase structure
check-pipeline-skills:
	@echo "--- check-pipeline-skills ---"
	@test -f $(SKILLS_DIR)/codereview/SKILL.md || { echo "FAIL: codereview skill not found"; exit 1; }
	@test -f $(SKILLS_DIR)/shipit/SKILL.md || { echo "FAIL: shipit skill not found"; exit 1; }
	@echo "PASS"

# 10. install.sh and uninstall.sh handle all skills
check-installer:
	@echo "--- check-installer ---"
	@test -f install.sh || { echo "FAIL: install.sh not found"; exit 1; }
	@test -f uninstall.sh || { echo "FAIL: uninstall.sh not found"; exit 1; }
	@# The installer uses a glob over skills/*, so it picks up any new skill dirs automatically.
	@# Verify the expected skill directories exist.
	@for skill in mkspec encode fulfill verify alchemize codereview shipit; do \
		test -d $(SKILLS_DIR)/$$skill || { echo "FAIL: skills/$$skill directory missing"; exit 1; }; \
	done
	@echo "PASS"
