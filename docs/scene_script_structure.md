# Scene and Script Structure Baseline

## Purpose

This document is the source of truth for project shape owned by the Godot Lead Engineer.
Use it to keep new work aligned with the battle architecture and avoid hidden dependencies.

## Canonical Tree

```text
project.godot
icon.svg
scenes/
  Main.tscn
  battle/
    BattleScene.tscn
    Unit.tscn
    GridCursor.tscn
    BattleHUD.tscn
  campaign/
    CampaignPanel.tscn
scripts/
  main.gd
  campaign/
    campaign_controller.gd
    campaign_panel.gd
    campaign_state.gd
  battle/
    battle_controller.gd
    turn_manager.gd
    path_service.gd
    range_service.gd
    combat_service.gd
    ai_service.gd
    input_controller.gd
    unit_actor.gd
    grid_cursor.gd
    battle_hud.gd
  data/
    unit_data.gd
    skill_data.gd
    stage_data.gd
  dev/
    m1_playtest_runner.gd
    m2_campaign_flow_runner.gd
data/
  units/
    ally_vanguard.tres
    ally_scout.tres
    enemy_raider.tres
    enemy_skirmisher.tres
  skills/
    basic_attack.tres
  stages/
    tutorial_stage.tres
docs/
  game_spec.md
  engineering_rules.md
  codex_workflow.md
  scene_script_structure.md
  milestone_runnable_gates.md
  reviews/
    2026-04-12-gameplay-architecture-review.md
```

## M2 Extension Baseline

When the Chapter 1 loop expands beyond a single battle scene, extend the tree in this direction:

```text
scenes/
  ui/
    camp/
      CampHub.tscn
scripts/
  main.gd
  campaign/
    chapter_session.gd
    stage_registry.gd
    chapter_flow_controller.gd
  ui/
    camp/
      camp_hub.gd
data/
  text/
    cutscenes/
    memory_fragments/
    letters/
    evidence/
```

Rules for this extension:

- `main.gd` owns top-level handoff from boot into the campaign shell once M2 wiring exists.
- `scripts/campaign/` owns in-memory chapter progression and scene routing only.
- `scripts/campaign/stage_registry.gd` owns the authored stage-chain lookup and next-step mapping for the active chapter.
- `scripts/ui/camp/` owns presentation only; it must not calculate progression or rewards.
- `data/text/` remains authored content, not runtime state.
- Save/load remains out of scope for the current vertical slice unless a later milestone explicitly adds it.

## Ownership Matrix

- `BattleController`: battle state machine orchestration and win/loss transitions.
- `CampaignController`: Chapter-level flow orchestration between battle, cutscene placeholder, and camp placeholder states.
- `CampaignPanel`: lightweight overlay for non-battle handoff text and continue actions.
- `TurnManager`: per-phase action lock state.
- `TurnManager`: authoritative per-unit action state machine (`READY`, `MOVED`, `ACTED`, `EXHAUSTED`, `DOWNED`).
- `PathService`: AStarGrid2D-backed walkable/reachable/path queries.
- `RangeService`: range-cell calculations independent from scene nodes.
- `CombatService`: attack resolution and HP result payloads.
- `AIService`: enemy target and action decisions.
- `InputController`: touch/mouse to grid-cell routing.
- `UnitActor`: unit runtime state bound to `UnitData`.
- `BattleHUD`: phase/result UI and player action signals.
- `StageData`, `UnitData`, `SkillData`: all gameplay-critical values and placement data.
- `ChapterSession`: volatile Chapter 1 progression state, recruit state, and unlocked memory/evidence/letter ids.
- `StageRegistry`: chapter stage order, stage identifiers, and transition targets for the active slice.
- `ChapterFlowController`: main-scene campaign shell wiring plus battle clear to cutscene to camp routing above `BattleController`.
- `CampHub`: read-only presentation of party summary and record views for the active session.

## Implementation Standards

- Keep gameplay values in `.tres` resources under `data/`.
- Keep scene files focused on composition and references.
- Keep campaign progression in `Main`/`campaign_controller.gd`, not in `battle_controller.gd`.
- Do not let UI nodes own game rules.
- Do not hardcode stage-specific placement in services.
- Make phase transitions explicit in `battle_controller.gd`.
- Emit battle transition reasons to both HUD and logs.
- Keep service APIs deterministic and side-effect light.
- Keep chapter progression state out of battle services and out of UI scripts.
- Keep camp UI read-only over authored data plus active session state.

## Change Policy

- New systems should extend this tree, not bypass it.
- Any new battle subsystem must declare owner script and API boundary.
- Any new campaign/camp subsystem must declare whether it is authored data, volatile session state, or presentation.
- Any milestone PR should update this file if shape or ownership changed.
