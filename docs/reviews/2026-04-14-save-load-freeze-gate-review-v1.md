# Save/Load Freeze Gate Review v1 (2026-04-14)

## Scope

- current runtime lane under `scenes/`, `scripts/`, and `docs/`
- build stability and session-flow verification surface
- save/load readiness for future tranche planning

## Verdict

Keep save/load frozen.

- Runtime stability is green for the current in-session battle, campaign, UI, sortie, and equipment surfaces.
- Persistence readiness is red because the project still lacks restore-grade state boundaries, save schema ownership, and resume validation.
- Export readiness is also red, so reopening persistence now would expand release risk before the shipping surface is even defined.

## Evidence

Validated locally on 2026-04-14:

- `godot4 --version` -> `4.6.2.stable.official.71f334935`
- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --quit`
- `godot4 --headless --path . --script res://scripts/dev/m1_core_loop_contract_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/sortie_assignment_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/equipment_slot_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/accessory_equipment_runner.gd`

All commands above passed in the current workspace.

## Findings

### 1. The project is stable inside one live session

The current runners prove that the game can:

- boot cleanly
- finish battle flow
- advance through the campaign shell
- expose mobile-oriented UI snapshots
- carry sortie assignments forward
- carry equipment and accessory choices from camp into battle

This is the right baseline for the active production lane.

### 2. The project still has no persistence implementation or persistence seam

There is no gameplay save/load path in runtime code today.

- No `user://`, `ConfigFile`, `store_var`, `get_var`, `to_json`, or equivalent save API is used in gameplay/runtime scripts.
- The only `FileAccess` usage found is asset-preview loading in UI/visual helpers, not state persistence.

This means reopening save/load would start from zero on the actual file/schema side.

### 3. The current state surface is snapshot-grade, not restore-grade

`Main` hard-boots directly into a fresh Chapter 1 session on startup (`scripts/main.gd`), which means there is no resume entrypoint yet.

`CampaignController` currently owns volatile progression and loadout/session state directly:

- active mode, chapter, and stage index
- reward, memory, evidence, and letter unlock arrays
- deployed party ids
- unlocked weapon, armor, and accessory ids
- equipped gear dictionaries by unit id

That state is live in one controller (`scripts/campaign/campaign_controller.gd`), which is now 3,014 lines long.

`BattleController` owns additional mutable combat state directly:

- live ally and enemy actors
- interactive object resolution
- selected unit and reachable cells
- pending move state
- round and phase progression
- boss telegraph and buff state
- reward log and transition history

The exposed read APIs are still inspection-oriented:

- `main.get_campaign_state_snapshot()`
- `campaign_controller.get_state_snapshot()`
- `battle_controller.get_player_interface_snapshot()`
- `battle_controller.get_objective_state_snapshot()`

These are useful for UI and runners, but they do not define a full capture/restore contract for either between-battle resume or mid-battle resume.

### 4. Current validation proves carry-over, not save/resume correctness

The runner surface validates in-memory carry-over in one process, not persistence across shutdown and restart.

Missing today:

- cold boot -> load existing campaign state
- quit/relaunch -> resume same chapter and camp state
- round-trip save serialization/deserialization validation
- corruption handling or schema-version rejection
- any mid-battle restore contract

Without those checks, save/load would ship on assumption instead of evidence.

### 5. Export readiness is still below the bar for persistence work

There is still no committed `export_presets.cfg` in the workspace and no target-platform validation artifact.

That matters for save/load because persistence bugs become a shipping/support liability only after platform lifecycle, filesystem behavior, and resume behavior are known.

### 6. There is one encouraging signal: content ids already exist

The project already uses stable ids on core data resources such as:

- `stage_id`
- `unit_id`
- `weapon_id`
- `armor_id`
- `accessory_id`

That makes a future between-battle save tranche feasible, but only after state ownership is decomposed and restore APIs are defined.

## Recommendation

Do not reopen save/load in the current lane.

If the team wants persistence soon, reopen only a narrow **between-battle campaign resume** tranche first. Do **not** reopen mid-battle save/checkpointing in the same tranche.

## Unlock Criteria

Save/load can reopen only when all of the following are true:

1. Session state ownership is decomposed out of the monolithic campaign controller into explicit modules for:
   - authored chapter content/registry
   - volatile campaign session state
   - loadout/equipment session state
2. Startup flow no longer hard-resets to a new Chapter 1 run and instead supports an explicit boot decision:
   - new session
   - resume session
3. A versioned save schema is written down before implementation starts.
   - At minimum define schema version, chapter/stage pointer, unlocked records, deployed roster, and equipped gear.
   - Decide explicitly whether battle state is out of scope for v1.
4. Runtime owners expose capture/restore APIs instead of UI-only snapshots.
   - `capture_state()`
   - `restore_state(payload)`
   - validation failure path
5. Persistence runners exist and pass for the reopened scope:
   - boot -> save -> quit -> relaunch -> load same camp state
   - equipment/accessory/sortie round-trip restore
   - chapter progression round-trip restore
   - invalid or old schema rejection path
6. `docs/scene_script_structure.md` and ownership docs are updated to match the live architecture before the persistence tranche starts.
7. Export configuration exists for the first target platform, with validation notes recorded in-repo.

## Deferred Scope

Keep these frozen after the future v1 reopen:

- mid-battle save
- battle checkpoint rewind
- rollback/replay systems
- cross-platform cloud sync
- migration from multiple historical save schemas

## Primary Risks If Reopened Now

1. A save schema would couple directly to the current monolithic controller and turn ordinary chapter-content edits into persistence regressions.
2. Session-only runner coverage would hide restart bugs until late manual testing.
3. `Main` would need boot-flow surgery while campaign shell responsibilities are still shifting.
4. Export/platform uncertainty would make persistence bugs harder to reproduce and support.

## Technical Position

The build is stable enough to keep shipping the current save-free production lane.
It is not stable enough to justify opening save/load yet.
