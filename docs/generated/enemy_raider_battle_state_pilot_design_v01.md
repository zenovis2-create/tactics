# Enemy Raider Battle-State Pilot Design V01

## Scope

Pilot target:

- `Enemy Raider`

States in scope:

- `idle`
- `move`
- `attack`

## Intent

This pilot proves the hostile melee infantry state lane on top of the locked
layered baseline.

## Hard Rule

1. anchor sheet first
2. all variants derived from anchor
3. consistency beats speed

## Current Upstream Baseline

Use this best set:

- `base_body v01`
- `base_outfit v01`
- `weapon_overlay v03_sword_led`
- `upper_armor_overlay v02_compact`

Default state composite reference:

- `enemy_raider_composite_8dir_preview_v03_sword_led`

## Legacy Runtime Reference

- `source/enemy_raider_idle_sheet_source_v01.png`
- `source/enemy_raider_move_sheet_source_v01.png`
- `source/enemy_raider_attack_sheet_source_v01.png`

Observed size:

- `1536x1024`

Pilot compatibility target:

- 8 frames
- `4 x 2`
- `1536x1024`

## State Contract

### `idle`

- hostile melee pressure first
- rigid authority infantry second
- no machinery-wall read

### `move`

- compact infantry advance
- heavier than `Rian`
- not a sprint or dash

### `attack`

- sword-led hostile melee action
- no ranged-machine read
- no giant FX

## Output Targets

Source:

- `source/enemy_raider_idle_sheet_source_v02_layered.png`
- `source/enemy_raider_move_sheet_source_v02_layered.png`
- `source/enemy_raider_attack_sheet_source_v02_layered.png`

Clean:

- `clean/enemy_raider_idle_clean_v02_layered.png`
- `clean/enemy_raider_move_clean_v02_layered.png`
- `clean/enemy_raider_attack_clean_v02_layered.png`
