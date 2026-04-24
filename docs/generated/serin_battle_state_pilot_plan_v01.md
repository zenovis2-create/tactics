# Serin Battle-State Pilot Plan V01

## Objective

Turn the current locked `Serin` layered baseline into the second gameplay-facing
battle-state pilot.

## Execution Order

1. lock the pilot contract
2. build `idle`
3. build `cast`
4. build `attack`
5. compare against existing legacy sheets
6. decide whether to promote the layered candidate set

## Inputs

Layered baseline:

- `serin_composite_8dir_preview_v01`

Legacy state references:

- `serin_idle_sheet_source_v02`
- `serin_cast_sheet_source_v03`
- `serin_attack_sheet_source_v03`

## Output Targets

Source:

- `source/serin_idle_sheet_source_v02_layered.png`
- `source/serin_cast_sheet_source_v03_layered.png`
- `source/serin_attack_sheet_source_v03_layered.png`

Clean:

- `clean/serin_idle_clean_v02_layered.png`
- `clean/serin_cast_clean_v03_layered.png`
- `clean/serin_attack_clean_v03_layered.png`

## Pilot Rule

Do not try to solve:

- full FX layering
- all support units
- runtime promotion into the main folders

in the same slice.

This pilot is only about proving that the locked layered baseline can produce
usable support/caster state sheets.

## Next Step After This Plan

If this pilot passes:

1. `Tia` ranged state pilot
2. `Bran` heavy/shield state pilot
3. enemy state rollout
