# f100 Campaign Panel Skill Section QA

## Scope

Authoritative selected f100 payload:

- `scripts/dev/campaign_panel_skill_section_runner.gd`
- `scripts/dev/campaign_panel_skill_section_runner.gd.uid`
- `docs/reviews/2026-05-05-f100-campaign-panel-skill-section-qa.md`
- `tmp/validation/qa_evidence_20260505_f100_campaign_panel_skill_section/`

This is an internal runner/doc/evidence-only QA slice for existing CampaignPanel skill-section behavior.

No production CampaignPanel/CampaignController logic, scenes, battle logic, combat math, AI, reward/EXP formulas, support, memory/save/progression schema, telemetry implementation, stage data, new image assets, `.import` files, Android signing, bark payloads, package manifests, or public release changes are owned by this selected f100 payload.

## The Agency selection

The Agency agents were used before implementation:

- Project Shepherd recommended staying in a narrow non-image runner/doc/evidence lane after f99 and avoiding Main-heavy/image-backed runners.
- Implementation Auditor identified `campaign_panel_skill_section_runner.gd` as the safest direct CampaignPanel-only f100 target because it instantiates only `CampaignPanel.tscn` and avoids Main/CampaignController/stage/image paths.
- Release QA Scout produced a dialogue-history scout document, but selected f100 stays on the narrower skill-section fallback/selection hardening path.

Selected f100 does not modify production code and does not repeat f99 presentation-card meta hardening.

## Focused f100 gate

Focused command:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_skill_section_runner.gd
```

Observed PASS line:

```text
[PASS] campaign_panel_skill_section_runner validated dedicated camp skills section populated, selection, and fallback states.
```

## Hardened assertions

`campaign_panel_skill_section_runner.gd` now verifies populated skill-section behavior:

- `active_section == "skills"` is accepted.
- `SkillsButton` exists and is disabled while active.
- adjacent `PartyButton` and `SummaryButton` remain enabled.
- `SkillsSection` exists and is visible.
- `SummarySection` and `PartySection` are hidden while skills is active.
- `section_hint` includes `스킬 설명`, `자원 비용`, and `숙련도`.
- `SkillsHeading` reflects two party detail entries via `(2)`.
- selected-unit label renders Bran.
- `SkillList` renders Bran's skill name, description, cost, level, and EXP.
- no-cost fallback renders `비용: 없음`.
- max-level fallback renders `Lv 5 / MAX`.

It also verifies selected-party switching while staying in the skill section:

- `select_party_by_unit_id("ally_serin")` returns true.
- snapshot mirrors `selected_party_unit_id == "ally_serin"`.
- `active_section` remains `skills`.
- selected-unit label updates to Serin.
- fallback skill description renders for a unit with no detailed `skill_entries`.

It also verifies fallback states:

- invalid `selected_party_unit_id` falls back to the first valid party detail.
- empty party payload keeps `active_section == "skills"`.
- empty party payload keeps `SkillsSection` visible.
- empty party payload renders `선택된 부대원이 없다` and `점검할 스킬이 없다`.

## Adjacent gates

Adjacent direct CampaignPanel runner commands:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_dialogue_history_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_presentation_card_runner.gd
```

Expected status:

- Focused f100 skill-section runner failure is a selected f100 blocker.
- Adjacent direct CampaignPanel dialogue-history/presentation-card failure is a selected f100 blocker unless proven unrelated and documented.
- Main-heavy field-sword/party-support/title-load runners are intentionally excluded from selected f100 adjacency because they can emit broader workspace errors unrelated to selected f100 skill-section metadata.

## Hygiene gates

Scoped git whitespace gate:

```bash
git diff --check -- scripts/dev/campaign_panel_skill_section_runner.gd scripts/dev/campaign_panel_skill_section_runner.gd.uid docs/reviews/2026-05-05-f100-campaign-panel-skill-section-qa.md
```

Because selected f100 evidence may be untracked in this dirty workspace, also run a selected f100 no-index whitespace/final-newline scan over:

- `scripts/dev/campaign_panel_skill_section_runner.gd`
- `scripts/dev/campaign_panel_skill_section_runner.gd.uid`
- `docs/reviews/2026-05-05-f100-campaign-panel-skill-section-qa.md`
- `tmp/validation/qa_evidence_20260505_f100_campaign_panel_skill_section/`

## Gate0 separation

Current observed Gate0 result:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
[FAIL] Found 14 broken res:// references
```

Observed broken references are non-f100 artifact/object paths, including `res://artifacts/ash29`, `res://artifacts/ash30`, `res://artifacts/ash36`, `res://artifacts/ash37`, and object resources under `res://data/objects/`.

Classification rule:

- This is a non-f100 artifact/object reference blocker because it does not name selected f100 skill-section runner/doc/evidence paths.
- Do not claim Gate0 PASS unless `check_runnable_gate0.sh` exits 0.
- Do not claim package/public release readiness from this f100 slice.

## Package guard separation

Current observed package guard result:

```text
PACKAGE_GUARD_EXIT 1
cached_bark_stage_coverage=0/54
```

Classification rule:

- This is a bark package/index custody blocker, not a selected f100 skill-section blocker, because it does not name selected f100 runner/doc/evidence paths.
- Package guard output is recorded separately from selected f100 UX hardening.
- Package/public release readiness is not claimed while package guard or Gate0 is failing and the broader worktree remains dirty.

## Non-selected scout artifacts

The following scout artifact exists but is not authoritative for selected f100 delivery:

- `docs/reviews/2026-05-05-f100-campaign-panel-dialogue-history-runner-only-qa-scout.md`
- `tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/`

Reason:

- It focuses on a dialogue-history runner-only path.
- The selected f100 delivery is the direct CampaignPanel skill-section fallback/selection runner.

The following earlier scout artifacts also remain non-selected for f100:

- `docs/reviews/2026-05-05-f99-ending-criteria-ui-runner-only-qa-scout.md`
- `docs/reviews/2026-05-05-f98-m3-ui-runner-only-qa-scout.md`

## Current status

Working-tree internal QA status for selected f100 is complete only if the evidence directory records:

- Focused skill-section runner: PASS
- Adjacent direct CampaignPanel runners: PASS or separated
- Scoped hygiene: PASS
- Gate0 status classified separately
- Package guard status classified separately
- Spec Reviewer and Quality Reviewer: PASS
