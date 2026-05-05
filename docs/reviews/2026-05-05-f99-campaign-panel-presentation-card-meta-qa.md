# f99 Campaign Panel Presentation Card Meta QA

## Scope

Authoritative selected f99 payload:

- `scripts/dev/campaign_panel_presentation_card_runner.gd`
- `scripts/dev/campaign_panel_presentation_card_runner.gd.uid`
- `docs/reviews/2026-05-05-f99-campaign-panel-presentation-card-meta-qa.md`
- `tmp/validation/qa_evidence_20260505_f99_campaign_panel_presentation_card_meta/`

This is an internal runner/doc/evidence-only QA slice for existing CampaignPanel presentation-card behavior.

No production CampaignPanel/CampaignController logic, scenes, battle logic, combat math, AI, reward/EXP formulas, support, memory/save/progression schema, telemetry implementation, stage data, new image assets, `.import` files, Android signing, bark payloads, package manifests, or public release changes are owned by this selected f99 payload.

The selected runner still preserves the pre-existing image-backed smoke check for `paladin_shield_integration_v01.png`, but f99's new hardening is meta-only and verifies no `TextureRect` is created when `image_path` is omitted.

## The Agency selection

The Agency agents were used before implementation:

- Project Shepherd recommended staying direct-runner and non-Main-heavy after f98.
- Implementation Auditor identified `campaign_panel_presentation_card_runner.gd` as the safest new CampaignPanel meta slice because it instantiates only `CampaignPanel.tscn` and can validate non-image presentation-card metadata without Main/CampaignController.
- Release QA Scout explored a CH10 ending-criteria UI scout path, but that broader scout is not selected for f99.

Selected f99 is the narrower CampaignPanel presentation-card meta runner because it avoids Main-heavy, save-heavy, and image/asset-generation work while adding direct non-image metadata coverage.

## Focused f99 gate

Focused command:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_presentation_card_runner.gd
```

Observed PASS line:

```text
[PASS] campaign_panel_presentation_card_runner validated image-backed and meta-only presentation cards.
```

## Hardened assertions

`campaign_panel_presentation_card_runner.gd` now verifies:

Image-backed legacy smoke path:

- One card is created when a single presentation-card payload is supplied.
- `TextureRect` is created when `image_path` is present.
- The preview texture resolves.

New f99 meta-only path:

- Four synthetic presentation cards render exactly when four payload cards are supplied.
- Cards without `image_path` create zero `TextureRect` previews.
- The rendered label text includes all important metadata:
  - support-memory style labels
  - name-call style labels
  - ending-criteria style labels
  - generic no-image meta labels
  - eyebrow/source/memory-stamp/outcome/callout/quote text
  - badge text
  - progress-row label/value/hint text
- Node-backed visual rails/progress are present through `ColorRect` descendants, without adding assets.
- `panel.get_snapshot()["presentation_cards"]` preserves raw meta payload fields such as `style`, `memory_rail`, `quote`, and `progress_rows`.

## Adjacent gates

Adjacent runner-only commands:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_dialogue_history_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_skill_section_runner.gd
```

Expected status:

- Focused f99 presentation-card runner failure is a selected f99 blocker.
- Adjacent failure in direct CampaignPanel dialogue-history/skills runners is a selected f99 blocker unless proven unrelated and documented.
- Main-heavy field-sword/party-support/title-load runners are intentionally excluded from selected f99 adjacency because they can emit broader workspace errors unrelated to selected f99 presentation-card metadata.

## Hygiene gates

Scoped git whitespace gate:

```bash
git diff --check -- scripts/dev/campaign_panel_presentation_card_runner.gd scripts/dev/campaign_panel_presentation_card_runner.gd.uid docs/reviews/2026-05-05-f99-campaign-panel-presentation-card-meta-qa.md
```

Because selected f99 evidence may be untracked in this dirty workspace, also run a selected f99 no-index whitespace/final-newline scan over:

- `scripts/dev/campaign_panel_presentation_card_runner.gd`
- `scripts/dev/campaign_panel_presentation_card_runner.gd.uid`
- `docs/reviews/2026-05-05-f99-campaign-panel-presentation-card-meta-qa.md`
- `tmp/validation/qa_evidence_20260505_f99_campaign_panel_presentation_card_meta/`

## Gate0 separation

Current observed Gate0 result:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
[FAIL] Found 14 broken res:// references
```

Observed broken references are non-f99 artifact/object paths, including `res://artifacts/ash29`, `res://artifacts/ash30`, `res://artifacts/ash36`, `res://artifacts/ash37`, and object resources under `res://data/objects/`.

Classification rule:

- This is a non-f99 artifact/object reference blocker because it does not name selected f99 presentation-card runner/doc/evidence paths.
- Do not claim Gate0 PASS unless `check_runnable_gate0.sh` exits 0.
- Do not claim package/public release readiness from this f99 slice.

## Package guard separation

Current observed package guard result:

```text
PACKAGE_GUARD_EXIT 1
cached_bark_stage_coverage=0/54
```

Classification rule:

- This is a bark package/index custody blocker, not a selected f99 presentation-card metadata blocker, because it does not name selected f99 runner/doc/evidence paths.
- Package guard output is recorded separately from selected f99 UX hardening.
- Package/public release readiness is not claimed while package guard or Gate0 is failing and the broader worktree remains dirty.

## Non-selected scout artifacts

The following scout artifact exists but is not authoritative for selected f99 delivery:

- `docs/reviews/2026-05-05-f99-ending-criteria-ui-runner-only-qa-scout.md`
- `tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/`

Reason:

- It focuses on broader CH10 ending criteria/title/postgame surfaces.
- The selected f99 delivery is the narrower direct CampaignPanel presentation-card metadata runner.

The following f98 scout artifact also remains non-selected for f99:

- `docs/reviews/2026-05-05-f98-m3-ui-runner-only-qa-scout.md`

## Current status

Working-tree internal QA status for selected f99 is complete only if the evidence directory records:

- Focused presentation-card runner: PASS
- Adjacent direct CampaignPanel runners: PASS or separated
- Scoped hygiene: PASS
- Gate0 status classified separately
- Package guard status classified separately
- Spec Reviewer and Quality Reviewer: PASS
