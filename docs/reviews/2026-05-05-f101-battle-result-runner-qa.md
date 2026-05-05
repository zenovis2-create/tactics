# f101 Battle Result Runner QA

## Scope

Authoritative selected f101 payload:

- `scripts/dev/battle_result_runner.gd`
- `scripts/dev/battle_result_runner.gd.uid`
- `docs/reviews/2026-05-05-f101-battle-result-runner-qa.md`
- `tmp/validation/qa_evidence_20260505_f101_battle_result_runner/`

This is an internal runner/doc/evidence-only QA slice for the existing CH01_05 battle result summary, telemetry, progression payload, and non-image result UI surfaces.

No production battle math, BattleHUD, BattleResultScreen, CampaignController/CampaignPanel logic, scenes, save/progression schema, reward formulas, telemetry implementation, stage data, new image assets, `.import` files, Android signing, bark payloads, package manifests, or public release changes are owned by this selected f101 payload.

## The Agency selection

The Agency agents were used before implementation:

- Project Shepherd selected `battle_result_runner.gd` as the safest f101 slice after f100 because it is non-image, not Main-heavy, and already passes headlessly.
- Implementation Auditor inspected the battle result runner and related result summary/UI source and recommended exact runner-only assertions.
- Release QA Scout discussed a possible CampaignPanel records-section lane, but selected f101 stays on the narrower existing battle-result runner path because the records-section runner/scout artifacts are not present in this workspace.

Selected f101 does not modify production code and does not claim release/package readiness.

## Focused f101 gate

Focused command:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/battle_result_runner.gd
```

Observed PASS line:

```text
[PASS] battle_result_runner: battle result summary exposes objective, records, EXP, telemetry, and result UI.
```

## Hardened assertions

`battle_result_runner.gd` now verifies summary shape and identity:

- summary includes stage/result/objective/progression/EXP/telemetry keys.
- `stage_id == "CH01_05"`.
- `title == "Victory"`.
- `outcome == "victory"`.
- `stars_earned == 2`.
- `turn_limit_met == true`.
- completed optional objectives include `no_ally_casualties`.
- failed optional objectives include `serin_defeats_enemy_commander` for the force-cleared scenario.

It verifies progression arrays:

- legacy `fragment_id == "ch01_fragment"`.
- legacy `command_unlocked == "tactical_shift"`.
- plural `recovered_fragment_ids` includes `ch01_fragment`.
- plural `unlocked_command_ids` includes `tactical_shift`.
- memory/evidence/letter entries are non-empty.

It verifies EXP and recommendation payloads:

- `unit_exp_results` has both allied participants.
- EXP entries contain all required keys.
- unit IDs cover `ally_vanguard` and `ally_scout`.
- `bonus_exp_pool == 8`.
- two bonus EXP entries are emitted.
- distributed bonus EXP total equals `bonus_exp_pool`.
- tactical result tags are present and include an MVP tag.
- bonus recommendation line includes `추천 보너스 대상`.

It verifies telemetry:

- telemetry `stage_id == "CH01_05"`.
- telemetry result is `victory`.
- telemetry rounds are `1`.
- optional-objective counts are `1/2`.
- `objective_completion_rate == 0.5` within tolerance.
- telemetry summary lines are present.

It verifies non-image result UI surfaces:

- legacy `result_popup` title is `Victory`.
- legacy popup text includes objective, stars, turn limit, optional objectives, rewards, EXP, result tags, telemetry, fragments, commands, status counts, memory, evidence, and letters.
- `BattleResultScreen` exists and is visible after victory.
- `BattleResultScreen` snapshot title is `Victory`.
- confirm button exists.
- result body is multi-section.
- body text includes objective, unit EXP, bonus EXP, result tags, recommendation, memory fragment, unlock, memory, evidence, letters, and telemetry sections.

## Adjacent gates

Adjacent runner-only commands:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/s2_result_and_bond_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/stage_resolution_runner.gd
```

Expected status:

- Focused f101 battle-result runner failure is a selected f101 blocker.
- Adjacent result/progression runner failure is a selected f101 blocker unless proven unrelated and documented.
- `post_battle_handoff_runner.gd` and `post_battle_readability_runner.gd` are intentionally excluded from selected f101 adjacency because current workspace probes showed broader parse/preload/assertion failures not suitable for this narrow runner-only slice.
- Main-heavy `m3_ui_runner.gd` is excluded from selected f101 adjacency.

## Hygiene gates

Scoped git whitespace gate:

```bash
git diff --check -- scripts/dev/battle_result_runner.gd scripts/dev/battle_result_runner.gd.uid docs/reviews/2026-05-05-f101-battle-result-runner-qa.md
```

Because selected f101 evidence may be untracked in this dirty workspace, also run a selected f101 no-index whitespace/final-newline scan over:

- `scripts/dev/battle_result_runner.gd`
- `scripts/dev/battle_result_runner.gd.uid`
- `docs/reviews/2026-05-05-f101-battle-result-runner-qa.md`
- `tmp/validation/qa_evidence_20260505_f101_battle_result_runner/`

## Gate0 separation

Current observed Gate0 result:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
[FAIL] Found 14 broken res:// references
```

Observed broken references are non-f101 artifact/object paths, including `res://artifacts/ash29`, `res://artifacts/ash30`, `res://artifacts/ash36`, `res://artifacts/ash37`, and object resources under `res://data/objects/`.

Classification rule:

- This is a non-f101 artifact/object reference blocker because it does not name selected f101 battle-result runner/doc/evidence paths.
- Do not claim Gate0 PASS unless `check_runnable_gate0.sh` exits 0.
- Do not claim package/public release readiness from this f101 slice.

## Package guard separation

Current observed package guard result:

```text
PACKAGE_GUARD_EXIT 1
cached_bark_stage_coverage=0/54
```

Classification rule:

- This is a bark package/index custody blocker, not a selected f101 battle-result blocker, because it does not name selected f101 runner/doc/evidence paths.
- Package guard output is recorded separately from selected f101 UX hardening.
- Package/public release readiness is not claimed while package guard or Gate0 is failing and the broader worktree remains dirty.

## Non-selected scout artifacts

The Agency QA Scout discussed a possible CampaignPanel records-section scout lane, but those records-section runner/scout artifacts are not present in this workspace and are not part of selected f101 delivery.

Reason:

- The proposed records-section runner is not present yet.
- The selected f101 delivery is the existing BattleScene-based battle result runner.

Earlier scout artifacts also remain non-selected for f101:

- `docs/reviews/2026-05-05-f100-campaign-panel-dialogue-history-runner-only-qa-scout.md`
- `docs/reviews/2026-05-05-f99-ending-criteria-ui-runner-only-qa-scout.md`
- `docs/reviews/2026-05-05-f98-m3-ui-runner-only-qa-scout.md`

## Current status

Working-tree internal QA status for selected f101 is complete only if the evidence directory records:

- Focused battle-result runner: PASS
- Adjacent result/progression runners: PASS or separated
- Scoped hygiene: PASS
- Gate0 status classified separately
- Package guard status classified separately
- Spec Reviewer and Quality Reviewer: PASS
