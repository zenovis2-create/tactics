# M0-M1 Technical Gate Review (2026-04-12)

## Scope

Review target:

- `production_backlog.md`
- `docs/game_spec.md`
- `docs/engineering_rules.md`
- `docs/milestone_runnable_gates.md`
- current Godot repo baseline under `scenes/`, `scripts/`, and `data/`

## Verdict

Current repository state is aligned to the intended `M0-M1` slice.

- Gate 0 static integrity passes via `scripts/dev/check_runnable_gate0.sh`.
- Runtime code is still centered on a single battle slice.
- The present scene and script split matches the documented service boundaries.
- No early implementation of save/load, equipment meta, loot, crafting, or multiplayer was found in runtime code.

## Evidence

### Runnable baseline

- `project.godot` points to `res://scenes/Main.tscn`.
- Core battle scenes exist: `BattleScene`, `BattleHUD`, `GridCursor`, `Unit`.
- Core services exist: `battle_controller`, `turn_manager`, `path_service`, `range_service`, `combat_service`, `ai_service`, `input_controller`.
- Resource-driven sample data exists for stage, units, and skills.

### Scope compliance

Allowed and already represented:

- single battle scene
- grid movement
- player/enemy phase flow
- attack-or-wait loop
- nearest-target enemy AI
- victory/defeat HUD path

Explicitly still out of scope for `M0-M1`:

- save/load
- equipment systems
- random drops / loot meta
- crafting / forge / sigil systems
- campaign progression systems beyond minimum handoff planning
- multiplayer / network features

## Implementation Guardrails

`ASH-18` and `ASH-19` should stay inside these limits:

1. Only ship the first playable battle loop, not broader campaign infrastructure.
2. Keep gameplay values in `Resource` data, not in scene inspector tuning.
3. Keep `BattleController` as orchestration only; do not fold service logic back into it.
4. Do not let HUD work introduce nested menu complexity or meta progression UI.
5. Keep the project statically runnable after each change, with Gate 0 passing.

## Risks And Gaps

### Runtime validation gap

- Godot runtime is not installed in the current shell environment.
- Gate 1 manual runtime validation is therefore still unverified here.

### Export-readiness gap

- Android export templates and export preset validation are not yet present.
- This is acceptable for `M0-M1` so long as no one claims deployment readiness.

### Task coordination gap

- `ASH-1` is still open even though the repo already contains the described foundation skeleton.
- PMO or engineering leadership should either close it against the existing baseline or re-scope it to any remaining foundation deltas only.

## Next Gates

Before `M1` can be called complete, require all of the following:

1. One full battle runs from selection to victory/defeat without script errors.
2. `ASH-18` runtime flow stays limited to battle-loop logic only.
3. `ASH-19` HUD stays mobile-readable and only surfaces battle-state feedback.
4. Gate 0 script remains passing after each implementation handoff.
5. A Godot-available environment runs the manual Gate 1 validation path.
