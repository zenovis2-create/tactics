# 2026-04-18 Manual Play Balance Tuning v1

## Context

This pass focused on manual-play feel after the recent tutorial-through-boss smoke coverage and the CH06~CH10 boss auto-play stabilization pass.

Reference signals used:
- `scripts/dev/tut_ch05_surface_runner.gd` covers tutorial HUD, skill access, and early boss-stage entry.
- `scripts/dev/ch06_ch10_boss_surface_runner.gd` shows the intended late boss progression surface, but is currently blocked by an unrelated cutscene data regression in `cutscene_catalog.gd`.
- `scripts/dev/battle_telegraph_runtime_runner.gd` verifies the current hostile telegraph surface is alive, which made it a safe place for readability-only improvement.

## Manual-play balance read

### 1. Early game: tutorial is over-explaining danger before the player learns the baseline loop

Observed from current data:
- `tutorial_stage.tres` opened with one standard raider and one `enemy_skirmisher`.
- `enemy_skirmisher.tres` applies Oblivion stacks on hit.
- The tutorial smoke path is specifically about HUD, inventory, unit selection, and skill targeting clarity.

Interpretation:
- For a first manual session, early pressure should come from positioning and basic attack trading, not from a status rider that muddies what the player is supposed to learn first.
- The current setup risks making the first readable lesson “why did my skill/system get worse?” instead of “move, range, attack, wait.”

Tuning decision:
- Keep tutorial enemy count the same.
- Remove the tutorial-only Oblivion source by replacing the skirmisher with a second baseline raider.

### 2. Late game: stabilized boss phases are readable, but the damage spike stacks too hard on top of status/telegraph pressure

Observed from boss data and controller rules:
- Late bosses already layer telegraphs, fear/oblivion, and phase bonuses.
- `battle_controller.gd` adds extra ATK in late phases such as `devastation`, `final_command`, and `species_resonance`.
- Those phases are already high-pressure because of pattern coverage and status riders, so raw ATK spikes compound manual punishment faster than they improve readability.

Interpretation:
- Auto-play stability confirms the phase machine works.
- Manual-play pain is more likely coming from “I understood the warning but still lost too much HP to recover” than from phase logic failure.

Tuning decision:
- Leave the pattern system intact.
- Trim only the top-end ATK bonuses on the late spike phases.
- Preserve boss identity by keeping telegraph/status pressure untouched.

### 3. Skill/telegraph visibility: current cards exist, but some messages are too generic to support fast manual decisions

Observed from HUD code:
- Skill targeting and skill execution both used the same generic “A skill is being used” card.
- Boss telegraph HUD text showed warning state, but did not emphasize pattern naming/countdown as strongly as it could.

Interpretation:
- The surface is present, but the actionable information is underspecified.
- Manual-play readability improves more from concrete wording than from new widgets.

Tuning decision:
- Keep the same HUD card and runtime flow.
- Replace generic text with skill name / target / pattern / countdown-driven wording.

## Applied changes

### A. Early feel improvement
- File: `data/stages/tutorial_stage.tres`
- Change: replaced tutorial `enemy_skirmisher` with a second `enemy_raider`.
- Expected feel result: the first battle teaches movement, attack range, and turn flow before introducing status pressure.

### B. Late pressure relief
- File: `scripts/battle/battle_controller.gd`
- Change:
  - `devastation` phase ATK bonus: `+2 -> +1`
  - `final_command` phase ATK bonus: `+3 -> +2`
  - `species_resonance` phase ATK bonus: `+3 -> +2`
- Expected feel result: late bosses still punish bad spacing, but a single misread is less likely to collapse the run immediately.

### C. Skill visibility improvement
- File: `scripts/battle/battle_hud.gd`
- Change:
  - skill targeting now names the skill and tells the player to select a highlighted target
  - skill execution now names the skill and target
  - boss telegraph HUD now calls out pattern/countdown more explicitly
- Expected feel result: faster manual parsing without adding a new UI layer.

## Verification notes

Verified after tuning:
- `tut_ch05_surface_runner.gd` passes.
- `battle_telegraph_runtime_runner.gd` passes.

Known unrelated blocker encountered:
- `ch06_ch10_boss_surface_runner.gd` currently fails because `cutscene_catalog.gd` assigns a `beats` field on placeholder `CutsceneData` resources. This is outside the scope of the balance tuning pass.
