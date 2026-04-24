# Tia Battle-State Pilot Design V01

## Scope

Pilot target:

- `Tia`

States in scope:

- `idle`
- `move`
- `attack`

## Why `Tia` Goes Next

`Tia` is the correct third pilot because:

- the lane already has a stable ranged-hunter layered baseline
- it proves bow-led readability after frontline and support pilots
- it tests asymmetry and ranged posture without heavy FX dependence

## Hard Rule

This pilot remains subordinate to the layered contract:

1. anchor sheet first
2. all variants derived from anchor
3. consistency beats speed

## Current Upstream Baseline

Use this layered best set:

- `base_body v01`
- `base_outfit v01`
- `weapon_overlay v01`
- `upper_armor_overlay v01`

Default state composite reference:

- `tia_composite_8dir_preview_v02_bgfix`

## Legacy Runtime Reference

- `source/tia_idle_sheet_source_v02.png`
- `source/tia_move_sheet_source_v01.png`
- `source/tia_attack_sheet_source_v02.png`

Observed size:

- `1536x1024`

Pilot compatibility target:

- 8 frames
- `4 x 2`
- `1536x1024`

## State Contract

### `idle`

- wary ranged hunter
- bow readable
- asymmetry visible without noise

### `move`

- agile but grounded
- not rogue acrobatics
- bow and hood break remain readable

### `attack`

- bow-led ranged attack
- projectile implied by weapon posture, not FX
- clearly ranged and lighter than `Rian`

## Output Targets

Source:

- `source/tia_idle_sheet_source_v02_layered.png`
- `source/tia_move_sheet_source_v02_layered.png`
- `source/tia_attack_sheet_source_v03_layered.png`

Clean:

- `clean/tia_idle_clean_v02_layered.png`
- `clean/tia_move_clean_v02_layered.png`
- `clean/tia_attack_clean_v03_layered.png`
