# Systems Fit Review (2026-04-13)

## Scope

Reviewed against:

- `docs/production/ch1/ch1_encounter_pacing_variety_spec.md`
- `docs/plans/2026-04-12-systems-combat-progression-design.md`
- `docs/plans/2026-04-12-systems-chapter-rule-cards.md`
- `scripts/campaign/campaign_controller.gd`
- `scripts/data/stage_data.gd`
- `scripts/battle/battle_controller.gd`
- Chapter 1 stage resources under `data/stages/`

Verified with runtime checks:

- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/ch01_05_boss_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`

## Verdict

The M2 Chapter 1 shell is operational, but the current data/contracts flatten too much of the chapter's intended rule identity.

- The campaign shell, camp routing, and boss telegraph path all run.
- The current implementation is strong enough for flow validation.
- It is not yet a trustworthy expression of chapter-by-chapter mechanical teaching.

## What Is Working

- Chapter 1 battle-to-cutscene-to-camp flow passes end to end.
- The CH01 boss fight already exposes a real mark -> buff -> charge telegraph cycle.
- Camp/UI surfaces can render progression summaries, records, and loadout-facing snapshots without crashing.

## Findings

### 1. Chapter 1 mission identity is flattened in stage data

Source-of-truth pacing expects distinct lesson types:

- `CH01_02` is an escort chase with timed evacuation pressure, not a wipe map.
- `CH01_04` is a lever puzzle that pivots into a one-turn hold, not just a two-switch clear.
- `CH01_05` is a telegraph boss exam with an optional tempo test, not only a generic defeat condition.

Current battle data does not carry those lesson contracts.

- `docs/production/ch1/ch1_encounter_pacing_variety_spec.md:45-49`
- `data/stages/ch01_02_stage.tres:33-38`
- `data/stages/ch01_04_stage.tres:34-39`
- `scripts/data/stage_data.gd:7-25`
- `scripts/battle/battle_controller.gd:591-620`

Impact:

- The automated M2 shell validates routing, but not the chapter's intended mastery curve.
- Escort, hold, rescue, timer, and optional-objective teaching cannot currently be expressed as first-class battle rules.

### 2. `CampaignController` is carrying too much authored campaign and equipment authority

The current controller owns all of the following in one file:

- Chapter flow tables from `CH01` through `CH10`
- reward logs, memory/evidence/letter unlock payloads
- recruit timing
- equipment unlock timing
- loadout cycling and inventory presentation

Evidence:

- `scripts/campaign/campaign_controller.gd:69-166`
- `scripts/campaign/campaign_controller.gd:1121-1173`
- `scripts/campaign/campaign_controller.gd:2038-2113`

Impact:

- The integration layer is drifting toward the junk-drawer risk already called out in the M2 gate review.
- Later chapter rule rollout will be harder to reason about because authored content, progression state, and equipment meta are coupled in one authority surface.

### 3. The thematic state model exists in design docs, but not in runtime contracts yet

The systems design expects:

- `Oblivion`, `Clarity`, `Guard`, `Mark`, `Seal`
- canonical battle fields such as `objective_state`, `hazard_state`, `oblivion_global_pressure`, and `rescue_state`
- campaign meta states such as `Burden` and `Trust`

Evidence:

- `docs/plans/2026-04-12-systems-combat-progression-design.md:124-193`
- `docs/plans/2026-04-12-systems-combat-progression-design.md:243-295`

Current runtime only expresses a narrow subset:

- mark-style boss telegraph
- standard guard/damage resolution
- generic win conditions and reward logs

Evidence:

- `scripts/battle/battle_controller.gd:453-499`
- `scripts/battle/battle_controller.gd:991-1025`

Impact:

- This is acceptable for M2 if treated as explicit deferment.
- It becomes dangerous if later tickets assume the shell already represents the chapter rule ladder.

## Recommendations

### For the gameplay/content lane

- Add a battle-local mission objective contract that can express escort, hold, rescue, and timer states without pushing camp logic into `StageData`.
- Keep Chapter 1 maps distinct in failure pattern and optional reward logic, especially `CH01_02` and `CH01_04`.

### For the integration lane

- Keep a single session-state owner, but move authored chapter content tables out of `CampaignController` into content registries or chapter-specific data payloads.
- Do not let M2 equipment/loadout scaffolding become the long-term source of campaign progression truth.

### For future systems milestones

- Treat `Oblivion`, `Clarity`, `Seal`, `Burden`, and `Trust` as named deferred contracts until their milestone lands.
- When they do land, add them as explicit runtime state and telemetry surfaces, not as hidden one-off script exceptions.

## Release Framing

If the team needs to ship M2 as-is, frame it honestly:

- validated Chapter 1 campaign shell
- validated boss telegraph readability
- placeholder mission-rule fidelity outside the boss encounter

Do not treat the current shell as proof that Chapter 1's full rule-teaching sequence is already represented in playable data.
