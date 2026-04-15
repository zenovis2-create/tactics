# Core Game Loop Design

## Scope

Implement and harden the first playable battle loop inside the current Godot 4 architecture.

In scope:

- battle phase flow
- per-unit turn ownership
- movement legality
- deterministic enemy action choice
- interactive object resolution
- gameplay correctness verification

Out of scope:

- campaign meta systems
- progression, equipment, or loot layers
- broader AI role expansion beyond deterministic baseline legality

## Existing Architecture

The repo already has the correct top-level split:

- `BattleController` orchestrates battle phases and scene actors.
- `TurnManager` owns unit action states.
- `PathService` and `RangeService` answer movement/range queries.
- `CombatService` resolves deterministic damage.
- `AIService` chooses enemy actions.
- `InteractiveObjectActor` owns object-local interaction state.

This design keeps that split intact. The goal is to make the current loop more explicit and more testable, not replace it.

## Chosen Approach

Use strict orchestration in `BattleController`, with legality and state ownership delegated to the existing services. Strengthen the loop by codifying runtime invariants in headless Godot scripts and then making only the minimum code changes needed to satisfy those invariants.

Why this approach:

- it preserves the current vertical-slice architecture
- it keeps the project runnable after each step
- it avoids adding new subsystems for a solved scene topology
- it gives gameplay correctness evidence instead of relying on manual inspection

## Core Loop Contract

### Battle flow

- Battle starts in `BATTLE_INIT` and immediately enters player phase.
- Only player-select and player-preview phases accept player input.
- Player phase ends when all living allies are exhausted or when the player ends the turn manually.
- Enemy phase resolves in roster order and returns to the next player phase unless victory or defeat triggers first.
- Victory and defeat must be evaluated after each resolved action and before any further phase work.

### Turn logic

- A living unit gets one action package per round.
- Valid player packages remain:
  - move then attack
  - move then interact
  - move then wait
  - attack in place
  - interact in place
  - wait in place
- `TurnManager` remains the authority for `READY`, `MOVED`, `ACTED`, `EXHAUSTED`, and `DOWNED`.
- Cancelling a moved unit restores its origin tile and state only if that tile is still legally available.

### Movement

- Movement is orthogonal and bounded by `PathService`.
- Units cannot end on blocked terrain, another unit, or a blocking object.
- AI movement uses the same occupancy and terrain legality as player movement.
- Object state changes must be reflected in dynamic blocking immediately.

### AI

- Enemy AI stays deterministic.
- Priority remains:
  - attack if already in range
  - move to a legal attack tile if one exists
  - otherwise move toward the best legal approach tile
  - otherwise wait
- AI must never commit an illegal move target or attack target.

### Interactive objects

- Objects can be targeted only when `can_interact()` is true.
- One-time objects become non-interactable after resolution.
- If an object changes blocking behavior when resolved, the battle loop must reflect that on the same turn.
- Interaction consumes the unit’s action package.

## Verification Strategy

Use headless Godot runtime scripts for contract coverage.

Checks to enforce:

- battle boot and phase progression
- cancel and wait flow
- one action package per unit per round
- early end-turn forfeits remaining ally actions
- object interaction is one-time and stateful
- AI-generated actions stay legal against terrain/unit/object occupancy
- deterministic victory path remains intact

## Files Expected To Change

- `scripts/battle/battle_controller.gd`
- `scripts/battle/ai_service.gd`
- `scripts/battle/interactive_object_actor.gd`
- `scripts/dev/m1_playtest_runner.gd`
- new headless contract runner under `scripts/dev/`

## Risks

- The battle loop already passes the current smoke runner, so new failures are likely to expose subtle rule drift rather than obvious crashes.
- The campaign layer exists in the main scene, so runtime tests should target the battle loop without accidentally expanding chapter-flow scope.

## Acceptance Criteria

- Core loop invariants are covered by headless runners.
- Player and enemy turns remain deterministic.
- AI and player movement obey the same legality rules.
- Interaction state changes are immediately reflected in battle behavior.
- Gate 0 and headless runtime verification both pass after changes.
