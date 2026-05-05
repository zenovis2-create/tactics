# f102 Stage Resolution Runner QA

## Scope

Authoritative selected f102 payload:

- `scripts/dev/stage_resolution_runner.gd`
- `scripts/dev/stage_resolution_runner.gd.uid`
- `docs/reviews/2026-05-05-f102-stage-resolution-runner-qa.md`
- `tmp/validation/qa_evidence_20260505_f102_stage_resolution_runner/`

This is an internal runner/doc/evidence-only QA slice for existing `StageResolutionService`, `ProgressionData`, and `SaveService` stage-clear persistence behavior.

No production stage-resolution service, progression schema, save service, campaign logic, battle math, UI scenes, stage data, image assets, `.import` files, Android signing, bark payloads, package manifests, or public release changes are owned by this selected f102 payload.

The runner writes and deletes `user://saves/slot_2.tres` and its JSON sidecar during verification. That is an expected non-repo side effect and is explicitly cleaned up by the selected runner.

## The Agency selection

The Agency agents were used before implementation:

- Project Shepherd selected `stage_resolution_runner.gd` as the safest f102 continuation because it is non-image, not Main-heavy, and validates downstream progression persistence after f101 battle-result summary hardening.
- Implementation Auditor inspected `s2_result_and_bond_runner.gd` and suggested bond/result-screen options, but that lane overlaps f101 result UI and was not selected for f102.
- Release QA Scout discussed a CampaignPanel dialogue-history scout lane, but selected f102 stays on the narrower stage-resolution runner path because f98/f100 already covered direct CampaignPanel dialogue/skill surfaces.

Selected f102 does not modify production code and does not claim release/package readiness.

## Focused f102 gate

Focused command:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/stage_resolution_runner.gd
```

Observed PASS line:

```text
[PASS] stage_resolution_runner: stage resolution commits progression, records, unlocks, and survives save/load.
```

## Hardened assertions

`stage_resolution_runner.gd` now verifies progression flags from a synthetic CH04_05 report:

- `cleared_stage_ids` includes `CH04_05`.
- `recovered_fragments` includes `mem_frag_ch04_test`.
- chapter flag `flag_ch04_complete` is set.
- mapped memory flag `flag_memory_ch04_ark_research_seen` is set.
- mapped evidence flag `flag_evidence_archive_transfer_obtained` is set.
- both explicit evidence IDs are persisted as flags.
- rescued NPC flag is persisted.
- optional-objective and temporary battle flags are persisted.
- mapped resonance flag `flag_resonance_serin` is emitted.
- discovered treasure IDs include `treasure:crypt_key`.

It verifies the stage clear record:

- stage record exists.
- `stage_id` and `cleared` are preserved.
- optional objective IDs persist.
- obtained memory fragment ID persists.
- both evidence IDs persist.
- rescued NPC and opened treasure IDs persist.
- battle temp counters `research_logs` and `rescued_scholars` persist.
- battle temp flags persist.
- telemetry rounds and objective completion rate persist.

It verifies unlocks:

- CH04 system unlock flag `flag_system_hunt_board_unlocked` is set.
- `unlocked_hunt_ids` includes `hunt_basil`.

It verifies save/load roundtrip:

- `save_progression()` succeeds for slot 2.
- `peek_slot()` reports the temporary save exists.
- sidecar metadata preserves `autosave_reason == "f102_stage_resolution_runner"`.
- sidecar metadata derives `chapter == "CH04"` from `CH04_05`.
- loaded progression preserves evidence, treasure, hunt unlock, and stage clear record data.
- loaded stage record telemetry matches the original record.
- the runner deletes slot 2 and verifies cleanup.

## Adjacent gates

Adjacent runner-only commands:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/battle_result_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/s2_result_and_bond_runner.gd
```

Expected status:

- Focused f102 stage-resolution runner failure is a selected f102 blocker.
- Adjacent battle-result or S2 result/bond runner failure is a selected f102 blocker unless proven unrelated and documented.
- `post_battle_handoff_runner.gd` and `post_battle_readability_runner.gd` are intentionally excluded from selected f102 adjacency because current workspace probes showed broader parse/preload/assertion failures not suitable for this narrow runner-only slice.
- Main-heavy `m3_ui_runner.gd` is excluded from selected f102 adjacency.

## Hygiene gates

Scoped git whitespace gate:

```bash
git diff --check -- scripts/dev/stage_resolution_runner.gd scripts/dev/stage_resolution_runner.gd.uid docs/reviews/2026-05-05-f102-stage-resolution-runner-qa.md
```

Because selected f102 evidence may be untracked in this dirty workspace, also run a selected f102 no-index whitespace/final-newline scan over:

- `scripts/dev/stage_resolution_runner.gd`
- `scripts/dev/stage_resolution_runner.gd.uid`
- `docs/reviews/2026-05-05-f102-stage-resolution-runner-qa.md`
- `tmp/validation/qa_evidence_20260505_f102_stage_resolution_runner/`

## Gate0 separation

Current observed Gate0 result:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
[FAIL] Found 14 broken res:// references
```

Observed broken references are non-f102 artifact/object paths, including `res://artifacts/ash29`, `res://artifacts/ash30`, `res://artifacts/ash36`, `res://artifacts/ash37`, and object resources under `res://data/objects/`.

Classification rule:

- This is a non-f102 artifact/object reference blocker because it does not name selected f102 stage-resolution runner/doc/evidence paths.
- Do not claim Gate0 PASS unless `check_runnable_gate0.sh` exits 0.
- Do not claim package/public release readiness from this f102 slice.

## Package guard separation

Current observed package guard result:

```text
PACKAGE_GUARD_EXIT 1
cached_bark_stage_coverage=0/54
```

Classification rule:

- This is a bark package/index custody blocker, not a selected f102 stage-resolution blocker, because it does not name selected f102 runner/doc/evidence paths.
- Package guard output is recorded separately from selected f102 UX hardening.
- Package/public release readiness is not claimed while package guard or Gate0 is failing and the broader worktree remains dirty.

## Non-selected scout artifacts

The following scout artifact exists but is not authoritative for selected f102 delivery:

- `docs/reviews/2026-05-05-f102-campaign-panel-dialogue-history-runner-only-qa-scout.md`

Reason:

- It focuses on a direct CampaignPanel dialogue-history runner.
- The selected f102 delivery is the existing StageResolutionService/ProgressionData/SaveService runner.

Earlier scout artifacts also remain non-selected for f102.

## Current status

Working-tree internal QA status for selected f102 is complete only if the evidence directory records:

- Focused stage-resolution runner: PASS
- Adjacent result/progression runners: PASS or separated
- Scoped hygiene: PASS
- Gate0 status classified separately
- Package guard status classified separately
- Spec Reviewer and Quality Reviewer: PASS
