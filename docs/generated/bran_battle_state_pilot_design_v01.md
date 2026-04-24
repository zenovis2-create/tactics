# Bran Battle-State Pilot Design V01

## Scope

Pilot target:

- `Bran`

States in scope:

- `idle`
- `move`
- `attack`

## Why `Bran` Goes Next

`Bran` is the correct fourth pilot because:

- the lane already proved heavy/shield layered identity
- it stress-tests shield-led motion and heavy silhouette stability
- it gives the ally roster its heavy-class state baseline

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
- `shield_overlay v02_balanced_shield`
- `upper_armor_overlay v01`

Default state composite reference:

- `bran_composite_8dir_preview_v02_balanced_shield`

## Legacy Runtime Reference

- `source/bran_idle_sheet_source_v02.png`
- `source/bran_move_sheet_source_v02.png`
- `source/bran_attack_sheet_source_v02.png`

Observed size:

- `1536x1024`

Pilot compatibility target:

- 8 frames
- `4 x 2`
- `1536x1024`

## State Contract

### `idle`

- heavy defender first
- shield dominant
- broad planted stance

### `move`

- guarded movement
- heavy but readable
- no sprinting or flashy dash

### `attack`

- shield-led bash or compact heavy strike
- clearly heavier than `Rian`
- no boss-like overkill

## Output Targets

Source:

- `source/bran_idle_sheet_source_v03_layered.png`
- `source/bran_move_sheet_source_v03_layered.png`
- `source/bran_attack_sheet_source_v03_layered.png`

Clean:

- `clean/bran_idle_clean_v03_layered.png`
- `clean/bran_move_clean_v03_layered.png`
- `clean/bran_attack_clean_v03_layered.png`
