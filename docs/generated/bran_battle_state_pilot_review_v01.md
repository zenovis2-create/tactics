# Bran Battle-State Pilot Review V01

## Scope

Review target:

- `/Volumes/AI/tactics/docs/generated/bran_battle_state_comparison_board_v01.png`

States:

- `idle`
- `move`
- `attack`

## Verdict

The `Bran` battle-state pilot is good enough to keep as the current layered
candidate set.

## Findings

### 1. `idle` preserves heavy defender read

The layered `idle` keeps shield dominance and heavy mass more clearly than
legacy while staying inside the same world grammar as the current layered
baseline.

### 2. `move` is a valid guarded heavy motion

The layered `move` stays:

- shield-led
- planted
- heavier than `Rian`

without becoming a boss sprint or dash.

### 3. `attack` is mostly successful, with one caution

The layered `attack` reads as a heavy shield-led strike.

Remaining caution:

- a light arc/impact accent is still visible

Current judgment:

- acceptable pilot-candidate attack state
- should be watched if later runtime tests show FX dependence

## Promotion Guidance

Current pilot-candidate source set:

- `source/bran_idle_sheet_source_v03_layered.png`
- `source/bran_move_sheet_source_v03_layered.png`
- `source/bran_attack_sheet_source_v03_layered.png`

Current runtime-candidate frame export:

- `runtime_v02_layered_candidate/idle/`
- `runtime_v02_layered_candidate/move/`
- `runtime_v02_layered_candidate/attack/`
