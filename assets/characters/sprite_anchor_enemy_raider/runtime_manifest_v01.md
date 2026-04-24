# Sprite Anchor Enemy Raider Runtime Manifest V01

## Lane Mode

This lane is now tracked as:

- `layered_8dir_enemy_baseline`
- `anchor_first_required`

## Reference Status

Current pre-layered or flat `8dir` enemy-raider material should be treated as:

- legacy reference
- hostile silhouette benchmark
- not final production truth

## Frozen Anchor Source

Expected anchor path:

- `source/8dir/anchor/enemy_raider_anchor_8dir_sheet_source_v01.png`

If this file is absent, the lane remains in structural migration state rather
than frozen-production state.

## Existing State Outputs

Keep current state outputs intact:

- `runtime/idle/`
- `runtime/move/`
- `runtime/attack/`

## Layered 8Dir Targets

### Source Layers

- `source/8dir/anchor/`
- `source/8dir/base_body/`
- `source/8dir/base_outfit/`
- `source/8dir/weapon_overlay/`
- `source/8dir/shield_overlay/`
- `source/8dir/upper_armor_overlay/`
- `source/8dir/legacy_reference/`

### Clean Layers

- `clean/8dir/base_body/`
- `clean/8dir/base_outfit/`
- `clean/8dir/weapon_overlay/`
- `clean/8dir/shield_overlay/`
- `clean/8dir/upper_armor_overlay/`

### Runtime Layers

- `runtime/8dir/base_body/`
- `runtime/8dir/base_outfit/`
- `runtime/8dir/weapon_overlay/`
- `runtime/8dir/shield_overlay/`
- `runtime/8dir/upper_armor_overlay/`

### Composite Preview

- `runtime/8dir/composite_preview/`

### Support Derivatives

- `runtime/portraits/`
- `runtime/tokens/`

## Enemy Baseline Acceptance Gate

- all eight directions exist for `base_body`
- all eight directions exist for `base_outfit`
- all eight directions exist for `weapon_overlay`
- all eight directions exist for `upper_armor_overlay`
- `shield_overlay` may remain empty in the first hostile baseline pass
- composite preview must preserve hostile melee pressure
- lane must not drift toward ally warmth, noble-command read, or generic bandit slouch
- no layered output is promoted beyond reference-only until it is derived from the frozen anchor
