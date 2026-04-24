# Enemy Raider Battle-State Pilot Review V01

## Scope

Review target:

- `/Volumes/AI/tactics/docs/generated/enemy_raider_battle_state_comparison_board_v01.png`

States:

- `idle`
- `move`
- `attack`

## Verdict

The `Enemy Raider` battle-state pilot is acceptable as the current hostile
melee state candidate.

## Findings

- `idle` is clearer as hostile infantry than legacy
- `move` is more compact and less shield-wall-coded than legacy
- `attack` remains sword-led, though a light arc trace is still visible

## Promotion Guidance

Current pilot-candidate source set:

- `source/enemy_raider_idle_sheet_source_v02_layered.png`
- `source/enemy_raider_move_sheet_source_v02_layered.png`
- `source/enemy_raider_attack_sheet_source_v02_layered.png`

Current runtime-candidate frame export:

- `runtime_v02_layered_candidate/idle/`
- `runtime_v02_layered_candidate/move/`
- `runtime_v02_layered_candidate/attack/`
