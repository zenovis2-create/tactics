# f98 Campaign Dialogue History Fallback QA

## Scope

Authoritative selected f98 payload:

- `scripts/dev/campaign_panel_dialogue_history_runner.gd`
- `scripts/dev/campaign_panel_dialogue_history_runner.gd.uid`
- `docs/reviews/2026-05-05-f98-campaign-dialogue-history-fallback-qa.md`
- `tmp/validation/qa_evidence_20260505_f98_campaign_dialogue_history_fallback/`

This is a runner/doc/evidence-only internal QA slice for existing CampaignPanel dialogue-history populated and empty fallback states.

No production CampaignPanel/CampaignController logic, scenes, battle logic, combat math, AI, reward/EXP formulas, support, memory/save/progression schema, telemetry implementation, stage data, new image assets, `.import` files, Android signing, bark payloads, package manifests, or public release changes are owned by this selected f98 payload.

The repository has a broad dirty baseline. f98 validates against the current working-tree CampaignPanel runtime and must not be used to certify the broader worktree.

## The Agency selection

The Agency agents were used before implementation:

- Project Shepherd recommended a non-image runner path, but its first suggested defense-rate runner was not present in the current filesystem when directly checked.
- Implementation Auditor reported that image-backed field-sword/party-support options were higher risk and that some Main/CampaignController paths currently emit broader errors.
- Release QA Scout created an `m3_ui` scout artifact, but selected f98 stayed on the safer direct CampaignPanel dialogue-history runner because it passes headlessly and does not instantiate Main.

## Focused f98 gate

Focused command:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_dialogue_history_runner.gd
```

Observed PASS line:

```text
[PASS] campaign_panel_dialogue_history_runner validated the dedicated camp dialogue history section.
```

## Hardened assertions

`campaign_panel_dialogue_history_runner.gd` now verifies populated dialogue history:

- `DialogueHistoryButton` and `DialogueHistorySection` exist.
- `active_section == "dialogue_history"` is accepted.
- `DialogueHistorySection.visible == true` while selected.
- `SummarySection.visible == false` while dialogue history is selected.
- `DialogueHistoryButton.disabled == true` while active.
- `RecordsButton.disabled == false` while dialogue history is active.
- `section_hint` explains recent/support/handoff review.
- `dialogue_entries` preserve 3 entries and normalize the Korean empire line to `Empire link:`.
- `section_badges["dialogue_history"] == "신규 3"`.
- visible `DialogueHistoryButton.text` mirrors `대화 이력` and `신규 3`.
- category heading counts are exact: recent/support/handoff each `(1)`.
- Recent list renders normalized `Empire link` + `세린` text.
- Support list renders `Support B Rank` + `Bran` text.
- Handoff list renders `Handoff` + `observatory` text.
- Summary dialogue list mirrors the normalized dialogue-history entries.

It also verifies empty dialogue history fallback:

- Empty payload still keeps `active_section == "dialogue_history"`.
- Empty payload does not auto-populate a dialogue-history `신규` badge.
- Recent fallback text: `아직 기록된 최근 대화가 없다`.
- Support fallback text: `아직 해금된 지원 대화가 없다`.
- Handoff fallback text: `아직 기록된 인계 대화가 없다`.

## Adjacent gates

Executed adjacent runner-only gates:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_skill_section_runner.gd
```

Expected status:

- Focused and adjacent runner failures are selected f98 blockers unless proven unrelated and explicitly separated in the evidence log.
- Main/CampaignController-heavy runners are intentionally excluded from selected f98 adjacency because current broader workspace state can emit non-f98 compile/runtime errors.

## Hygiene gates

Scoped git whitespace gate:

```bash
git diff --check -- scripts/dev/campaign_panel_dialogue_history_runner.gd scripts/dev/campaign_panel_dialogue_history_runner.gd.uid docs/reviews/2026-05-05-f98-campaign-dialogue-history-fallback-qa.md
```

Because the selected f98 files/evidence may be untracked in this dirty workspace, also run a selected f98 no-index whitespace/final-newline scan over:

- `scripts/dev/campaign_panel_dialogue_history_runner.gd`
- `scripts/dev/campaign_panel_dialogue_history_runner.gd.uid`
- `docs/reviews/2026-05-05-f98-campaign-dialogue-history-fallback-qa.md`
- `tmp/validation/qa_evidence_20260505_f98_campaign_dialogue_history_fallback/`

## Gate0 separation

Current observed Gate0 result:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
[FAIL] Found 14 broken res:// references
```

Observed broken references include non-f98 paths under `res://artifacts/ash29`, `res://artifacts/ash30`, `res://artifacts/ash36`, `res://artifacts/ash37`, and object resources:

- `res://data/objects/ch03_04_east_ember_echo_device.tres`
- `res://data/objects/ch03_04_west_resin_shrine.tres`
- `res://data/objects/ch04_01_supply_chest.tres`
- `res://data/objects/ch04_02_belfry_cache.tres`

Classification rule:

- This is a non-f98 artifact/object reference blocker because it does not name selected f98 dialogue-history runner/doc/evidence paths.
- Do not claim Gate0 PASS unless `check_runnable_gate0.sh` exits 0.
- Do not claim package/public release readiness from this f98 slice.

## Package guard separation

Current observed package guard result:

```text
PACKAGE_GUARD_EXIT 1
cached_bark_stage_coverage=0/54
```

Classification rule:

- This is a bark package/index custody blocker, not a selected f98 dialogue-history blocker, because it does not name selected f98 runner/doc/evidence paths.
- Package guard output is recorded separately from selected f98 UX hardening.
- Package/public release readiness is not claimed while package guard or Gate0 is failing and the broader worktree remains dirty.

## Non-selected scout artifact

The following scout artifact exists from Release QA Scout exploration but is not authoritative for selected f98 delivery:

- `docs/reviews/2026-05-05-f98-m3-ui-runner-only-qa-scout.md`
- `tmp/validation/qa_evidence_20260505_f98_m3_ui_runner_only/`

Reason:

- It focuses on broad Main/BattleHUD/CampaignPanel M3 UI coverage.
- The selected f98 delivery is the narrower direct `campaign_panel_dialogue_history_runner.gd` fallback hardening.

## Current status

Working-tree internal QA status for selected f98 is complete only if the evidence directory records:

- Focused dialogue-history fallback runner: PASS
- Adjacent runner-only gate: PASS or separated
- Scoped hygiene: PASS
- Gate0 status classified separately
- Package guard status classified separately
- Spec Reviewer and Quality Reviewer: PASS
