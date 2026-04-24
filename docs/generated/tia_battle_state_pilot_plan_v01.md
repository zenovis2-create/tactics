# Tia Battle-State Pilot Plan V01

## Objective

Turn the current locked `Tia` layered baseline into the third gameplay-facing
battle-state pilot.

## Execution Order

1. build `idle`
2. build `move`
3. build `attack`
4. compare against legacy sheets
5. export runtime candidate frames

## Inputs

- `tia_composite_8dir_preview_v02_bgfix`
- `tia_idle_sheet_source_v02`
- `tia_move_sheet_source_v01`
- `tia_attack_sheet_source_v02`

## Output Targets

- `source/tia_idle_sheet_source_v02_layered.png`
- `source/tia_move_sheet_source_v02_layered.png`
- `source/tia_attack_sheet_source_v03_layered.png`

- `clean/tia_idle_clean_v02_layered.png`
- `clean/tia_move_clean_v02_layered.png`
- `clean/tia_attack_clean_v03_layered.png`
