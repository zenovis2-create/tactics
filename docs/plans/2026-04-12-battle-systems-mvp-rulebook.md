# Battle Systems MVP Rulebook (Vertical Slice)

## 1. Purpose

Define the minimal mechanical rules required to ship a fully playable first battle loop in Godot 4.

This rulebook is constrained to MVP and is intentionally narrower than the post-slice systems package.

Primary deliverables covered:

- player phase and enemy phase rules
- action economy and unit turn ownership
- movement, attack, wait, and status rules
- terrain metadata rules
- acceptance criteria for playable start-to-finish flow

## 2. Scope Boundaries

In scope:

- one battle from load to victory or defeat
- deterministic turn flow
- one basic attack skill per unit
- terrain blocking and move-cost semantics

Out of scope for this MVP ruleset:

- character growth, equipment, class systems
- campaign meta progression
- advanced status stacks (Oblivion, Seal, etc.)
- crit, miss, reaction, counter, chain, and RNG-heavy combat layers

## 3. Core Battle Loop

## 3.1 Battle State Flow

Canonical high-level flow:

1. `BATTLE_INIT`
2. `PLAYER_PHASE_START`
3. `PLAYER_UNIT_ACTIONS`
4. `PLAYER_PHASE_END`
5. `ENEMY_PHASE_START`
6. `ENEMY_UNIT_ACTIONS`
7. `ENEMY_PHASE_END`
8. Repeat from `PLAYER_PHASE_START` until `VICTORY` or `DEFEAT`

Terminal conditions:

- `VICTORY`: all enemy units are defeated.
- `DEFEAT`: all ally units are defeated.

Transition rules:

- No hidden phase skips.
- Win/loss checks happen after every resolved action and at phase end.
- Inputs are accepted only during `PLAYER_UNIT_ACTIONS`.

## 3.2 Phase Rules

Player phase:

- Player can select only ally units.
- Each living ally can complete exactly one action package (move+attack, move+wait, attack-in-place, or wait-in-place).
- Phase ends automatically when all living allies are acted, or manually via end-turn command.

Enemy phase:

- AI iterates living enemy roster in deterministic order.
- Each living enemy performs one action package using nearest-target policy.
- After all enemy actions resolve, control returns to player phase.

## 4. Action Economy and Turn Ownership

Unit ownership rules:

- Unit faction determines phase ownership (`ally`, `enemy`).
- Non-active faction units are locked out of acting.

Per-round action budget:

- Exactly one action package per living unit per round.
- Once a unit is marked `ACTED`, it cannot act again until next round.

Manual end-turn behavior:

- If player ends phase early, all remaining unacted ally opportunities are forfeited for that round.

Determinism rules:

- Resolve order is roster order for the active faction.
- Same initial state and same player inputs must yield identical outcomes.

## 5. Unit Action Rules

## 5.1 Movement

Movement rules:

- Grid movement is orthogonal only (no diagonals).
- Reachable cells are bounded by unit movement value.
- Unit cannot end movement on blocked terrain.
- Unit cannot end movement on an occupied cell.

Path assumptions for MVP:

- Pathfinding is Manhattan-distance based.
- If terrain weights are not yet integrated, unblocked cells use cost `1` as fallback.

## 5.2 Attack

Attack eligibility:

- Unit may perform at most one attack in its action package.
- Target must be an opposing living unit in Manhattan attack range.

MVP damage formula:

- `damage = max(1, attacker.attack + skill.power_modifier - defender.defense)`

Attack resolution:

1. Validate target and range.
2. Compute and apply damage.
3. If defender HP reaches `0`, mark defender defeated and remove from active battle participation.
4. Re-evaluate victory/defeat conditions.

MVP simplifications:

- No crit/miss/evade.
- No counterattacks.
- No elemental typing.

## 5.3 Wait

Wait behavior:

- Wait consumes the unit's full action package.
- Wait performs no movement or damage.
- Wait is valid from current cell after movement decision is finalized.

## 5.4 Status Rules (MVP Minimal Set)

Required runtime statuses:

- `READY`: unit can still act this round.
- `ACTED`: unit already consumed action package this round.
- `DEFEATED`: HP is zero and unit is removed from active phase logic.

Rules:

- `READY -> ACTED` occurs on action package completion.
- `ACTED -> READY` occurs only at next round start for the unit's faction.
- `DEFEATED` is terminal for the current battle.

## 6. Terrain Metadata Rules

## 6.1 Required Keys

Each battle tile definition must support:

- `move_cost` (integer, default `1`)
- `terrain_type` (string enum)
- `blocked` (boolean)

Planned extension (not required for MVP combat math):

- `defense_bonus` (integer)

## 6.2 MVP Terrain Semantics

- `blocked=true` tiles are non-walkable and non-endable.
- `move_cost` contributes to movement budget when weighted movement is enabled.
- `terrain_type` is available for rule/UI hooks and analytics labeling.

Minimum terrain contract for first slice content:

- Plain: `move_cost=1`, `blocked=false`
- Forest: `move_cost=2`, `blocked=false`
- Wall: `blocked=true`

## 7. Acceptance Criteria: Playable Start to Finish

A battle build is accepted as MVP-playable only if all checks pass:

1. Battle boot:
- Stage loads with ally and enemy spawns from `StageData` without script errors.

2. Phase loop integrity:
- Flow cycles Player -> Enemy -> Player with no deadlock or hidden transition.

3. Action economy integrity:
- Every living unit acts at most once per round.
- End-turn forfeits remaining ally actions for that round.

4. Combat integrity:
- Adjacent or in-range attack applies deterministic damage and can defeat units.

5. Movement integrity:
- Movement respects map bounds and blocked terrain.
- Unit cannot end movement on occupied cells.

6. Terrain contract integrity:
- Stage content provides required tile metadata keys (`move_cost`, `terrain_type`, `blocked`).

7. Terminal states:
- Victory popup appears when all enemies are defeated.
- Defeat popup appears when all allies are defeated.

8. Deterministic replay sanity:
- Repeating identical input sequence from same initial stage state yields identical winner and turn count.

## 8. Implementation Ownership Map (Godot 4)

- `battle_controller.gd`: state flow, phase transitions, win/loss checks
- `turn_manager.gd`: action ownership and acted tracking
- `path_service.gd`: reachable cells and path query
- `range_service.gd`: attackable-cell queries
- `combat_service.gd`: attack resolution and HP updates
- `ai_service.gd`: enemy action selection
- `stage_data.gd`: stage-level terrain and spawn contract

## 9. Vertical Slice Guardrails

To keep implementation tight:

- Prefer deterministic readability over feature depth.
- Add no new meta systems before this loop is stable.
- If forced to choose, prioritize legible phase flow and deterministic completion over combat variety.
