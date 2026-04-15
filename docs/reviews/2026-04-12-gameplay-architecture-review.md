# Gameplay Architecture Review (2026-04-12)

## Scope

Review target was the battle skeleton and implementation standards for the Godot 4 tactics RPG prototype.

## Findings

### 1. Core boundaries are correctly separated

- Battle orchestration is centralized in `BattleController`.
- Rules are split into focused services (`turn`, `path`, `range`, `combat`, `ai`, `input`).
- Runtime actor state is isolated in `UnitActor`.
- Data contracts are resource-driven (`UnitData`, `SkillData`, `StageData`).
- M1 deterministic combat core now has an explicit battle-phase transition map and per-unit action-state authority.

### 2. Data-driving requirement is satisfied at baseline

- Unit stats, skill values, and stage placements are in `data/*.tres`.
- Scene nodes are not used to store balance values.
- Stage-level battle setup can be swapped by replacing `StageData`.

### 3. Runnability risk notes

- Godot runtime is not available in the current shell environment, so runtime boot was not executed here.
- Tile visuals are still placeholder; map tileset metadata integration remains a Phase 2 task.
- Current AI is nearest-target baseline only, consistent with MVP spec.
- Deterministic transition logic is implemented, but replay-grade validation still depends on headless Godot execution in a Godot-installed environment.

## Architecture Decisions to Keep

- `BattleController` owns phase progression and gate checks.
- Service scripts stay stateless or minimally stateful.
- Resource files remain single source for gameplay values.
- No plugin dependency introduced.

## Recommended Next Implementation Order

1. Integrate tile metadata into `PathService` and combat modifiers.
2. Add explicit move/attack range overlays in battle scene rendering.
3. Expand enemy AI evaluation with threat/risk scoring.
4. Add automated smoke checks in CI once Godot is available.

## Exit Criteria for This Review

- Scene/script baseline established.
- Ownership matrix documented.
- Runnable gates documented per milestone.
- Architecture gaps and follow-up priorities recorded.
