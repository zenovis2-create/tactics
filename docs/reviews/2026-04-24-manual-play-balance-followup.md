# 2026-04-24 Manual Play Balance Follow-up

## Actionable items
1. Tutorial opener should teach move/range/attack/wait before introducing Oblivion pressure.
2. Skill target selection/execution needs explicit skill+target wording on the existing telegraph card.
3. Late-boss damage spikes still merit a small ATK trim, but only if phase-bonus wiring is confirmed in the live controller.
4. Telegraph text should keep emphasizing pattern/countdown over generic warning copy.
5. Any balance touch should stay local to tutorial readability and HUD clarity; no combat-system rework.

## Applied now
### A. Tutorial enemy swap
- File: `data/stages/tutorial_stage.tres`
- Change: replaced the tutorial-only `enemy_skirmisher` spawn with a second `enemy_raider`.
- Why low risk: affects only the tutorial stage roster; does not change shared unit definitions or combat formulas.
- Expected impact: removes early Oblivion confusion while preserving enemy count and baseline melee pressure.

### B. Skill telegraph wording
- File: `scripts/battle/battle_hud.gd`
- Change: `skill_targeting_active`, `skill_telegraphed`, and `skill_insufficient_resource` now surface skill/target/cost-specific copy instead of falling back to generic reason text.
- Why low risk: HUD-only change on existing transition reasons; no turn-order, damage, or AI logic changed.
- Expected impact: faster manual parsing when picking a skill target or understanding why a skill cannot fire.

## Deferred
### Late-boss ATK spike trim
- Candidate from prior review: trim top-end phase ATK bonuses on late bosses.
- Deferred because current controller wiring for `devastation` / `final_command` / `species_resonance` is not trivially discoverable from a narrow low-risk pass, and the repo already has broad in-flight battle edits.
- Follow-up requirement: confirm the exact live phase-bonus hooks before touching shared boss tuning.

## Verification
- PASS `res://scripts/dev/tut_ch05_surface_runner.gd` in the current working tree:
  - tutorial opener now spawns two raiders
  - skill targeting telegraph names the selected skill
  - skill execution telegraph exposes the target name
- PASS `res://scripts/dev/ch06_ch10_boss_surface_runner.gd` in the current working tree:
  - CH06_05 / CH07_05 / CH08_05 / CH09A_05 / CH09B_05 / CH10_05 direct boss-stage surface is green
  - HUD, boss spawn flags, cutscene references, phase thresholds, required late-game objects, and victory handoff all validated
- PASS `res://scripts/dev/lategame_boss_pattern_runner.gd` in the current working tree:
  - CH08_05 / CH09B_05 / CH10_05 late-game boss pattern and relief-object contracts are green
- PASS `res://scripts/dev/ch06_ch10_cutscene_runner.gd` in the current working tree.
- PASS `res://scripts/dev/ch10_shell_runner.gd` in the current working tree:
  - CH10_05 intentionally passes through briefing; runner now advances briefing before battle assertion
  - CH10 intro, CH10_01~05 flow, final resolution, title return, and NG+ unlock are green
- Detailed late-game status and follow-up checklist: `docs/reviews/2026-04-24-ch06-ch10-boss-qa-balance-status.md`.
