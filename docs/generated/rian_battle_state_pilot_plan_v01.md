# Rian Battle-State Pilot Plan V01

## Objective

Turn the current locked `Rian` layered baseline into the first gameplay-facing
battle-state pilot.

## Execution Order

1. lock the pilot contract
2. build `idle`
3. build `move`
4. build `attack`
5. compare against existing `v01` legacy sheets
6. decide whether to promote `v02_layered`

## Inputs

Layered baseline:

- `rian_composite_8dir_preview_v03_lighter_armor`

Legacy state references:

- `rian_idle_sheet_source_v01`
- `rian_move_sheet_source_v01`
- `rian_attack_sheet_source_v01`

## Output Targets

Source:

- `source/rian_idle_sheet_source_v02_layered.png`
- `source/rian_move_sheet_source_v02_layered.png`
- `source/rian_attack_sheet_source_v02_layered.png`

Clean:

- `clean/rian_idle_clean_v02_layered.png`
- `clean/rian_move_clean_v02_layered.png`
- `clean/rian_attack_clean_v02_layered.png`

## Pilot Rule

Do not try to solve:

- all characters
- all states
- runtime slicing promotion

in the same slice.

This pilot is only about proving that the locked layered baseline can produce
usable state sheets.

## Next Step After This Plan

If this pilot passes:

1. `Serin` support/cast state pilot
2. `Tia` ranged state pilot
3. `Bran` heavy/shield state pilot
4. enemy state rollout

## Current Status

Completed source-sheet pilot outputs:

- `source/rian_idle_sheet_source_v02_layered.png`
- `source/rian_move_sheet_source_v02_layered.png`
- `source/rian_attack_sheet_source_v02_layered.png`

Current note:

- one intermediate `move` output was rejected for size mismatch
- one intermediate `attack` output was rejected for numbering artifacts
- the retained `v02_layered` sheets now satisfy the intended `1536x1024` pilot
  format
