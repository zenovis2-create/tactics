# Enemy Skirmisher Battle-State Pilot Design V01

## Scope

Pilot target:

- `Enemy Skirmisher`

States in scope:

- `idle`
- `move`
- `attack`

## Intent

This pilot proves the hostile agile pursuit-hunter state lane on top of the
locked layered baseline.

## Hard Rule

1. anchor sheet first
2. all variants derived from anchor
3. consistency beats speed

## Current Upstream Baseline

Use this best set:

- `base_body v01`
- `base_outfit v02_disciplined`
- `weapon_overlay v02_clean`
- `upper_armor_overlay v02_light`

Default state composite reference:

- `enemy_skirmisher_composite_8dir_preview_v02_corrected`

## Legacy Runtime Reference

- `source/enemy_skirmisher_idle_sheet_source_v01.png`
- `source/enemy_skirmisher_move_sheet_source_v01.png`
- `source/enemy_skirmisher_attack_sheet_source_v01.png`

Observed size:

- `1536x1024`

Pilot compatibility target:

- 8 frames
- `4 x 2`
- `1536x1024`

## State Contract

### `idle`

- hostile agile threat first
- pursuit hunter second
- not rogue/brawler

### `move`

- agile but disciplined
- lighter than `Raider`
- not acrobatic hero motion

### `attack`

- ranged-weapon led
- body readable without heavy FX
- distinct from `Tia`

## Output Targets

Source:

- `source/enemy_skirmisher_idle_sheet_source_v02_layered.png`
- `source/enemy_skirmisher_move_sheet_source_v02_layered.png`
- `source/enemy_skirmisher_attack_sheet_source_v02_layered.png`

Clean:

- `clean/enemy_skirmisher_idle_clean_v02_layered.png`
- `clean/enemy_skirmisher_move_clean_v02_layered.png`
- `clean/enemy_skirmisher_attack_clean_v02_layered.png`
