# Enemy Skirmisher Battle-State Pilot Review V01

## Scope

Review target:

- `/Volumes/AI/tactics/docs/generated/enemy_skirmisher_battle_state_comparison_board_v01.png`

States:

- `idle`
- `move`
- `attack`

## Verdict

The `Enemy Skirmisher` battle-state pilot is acceptable as the current hostile
agile state candidate.

## Findings

- `idle` keeps hostile agile threat without collapsing into rogue/brawler read
- `move` is lighter than `Raider` but still disciplined
- `attack` stays ranged-weapon led and distinct from `Tia`

## Promotion Guidance

Current pilot-candidate source set:

- `source/enemy_skirmisher_idle_sheet_source_v02_layered.png`
- `source/enemy_skirmisher_move_sheet_source_v02_layered.png`
- `source/enemy_skirmisher_attack_sheet_source_v02_layered.png`

Current runtime-candidate frame export:

- `runtime_v02_layered_candidate/idle/`
- `runtime_v02_layered_candidate/move/`
- `runtime_v02_layered_candidate/attack/`
