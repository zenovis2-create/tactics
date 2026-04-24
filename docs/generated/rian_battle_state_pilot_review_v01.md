# Rian Battle-State Pilot Review V01

## Scope

Review target:

- `/Volumes/AI/tactics/docs/generated/rian_battle_state_comparison_board_v01.png`

Compared:

- legacy `v01`
- layered `v02`

States:

- `idle`
- `move`
- `attack`

## Verdict

The `Rian` battle-state pilot is good enough to keep as the current layered
candidate set.

This is not yet a fully final promotion lock, but it is strong enough to move
forward with the pilot lane.

## Findings

### 1. `idle` is stronger than legacy

The layered `idle` preserves the locked character baseline and reads more
consistent with the current portrait/token/composite identity than the older
legacy sheet.

### 2. `move` is materially stronger than legacy

The layered `move` has:

- better grounded stride
- better cloak split behavior
- stronger body-first read

It is a valid pilot-state upgrade candidate.

### 3. `attack` is mostly successful, with one remaining caution

The layered `attack` reads faster and more decisive than the legacy sheet.

Remaining caution:

- a light slash-trail style mark is still visible in part of the sheet

Current judgment:

- acceptable for pilot-candidate status
- should be watched if later runtime tests show FX dependence

## Promotion Guidance

Current pilot-candidate state set:

- `source/rian_idle_sheet_source_v02_layered.png`
- `source/rian_move_sheet_source_v02_layered.png`
- `source/rian_attack_sheet_source_v02_layered.png`

Current runtime-candidate frame export:

- `runtime_v02_layered_candidate/idle/`
- `runtime_v02_layered_candidate/move/`
- `runtime_v02_layered_candidate/attack/`

## Working Conclusion

The pilot has passed the minimum bar for:

- clean candidate generation
- candidate runtime slicing
- legacy-vs-layered comparison

Next correct move:

1. keep this as the current `Rian` state pilot candidate
2. decide whether to:
   - promote runtime candidate frames into main runtime
   - or start `Serin` state pilot first and revisit promotion after a second lane
