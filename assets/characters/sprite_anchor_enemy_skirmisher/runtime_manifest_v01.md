# Sprite Anchor Enemy Skirmisher Runtime Manifest V01

## Lane Mode

This lane is now tracked as:

- `layered_8dir_enemy_agile`
- `anchor_first_required`

## Anchor Status

Required anchor:

- `source/8dir/anchor/enemy_skirmisher_anchor_8dir_sheet_source_v01.png`

Current status:

- layered folders migrated
- frozen anchor created
- no layered outputs promoted as final

## Legacy Reference Sources

Use `source/8dir/legacy_reference/` for:

- previous monolithic eight-direction prep
- silhouette comparison
- prompt-era exploratory material

These remain reference-only.

## Existing State Outputs

Keep current state outputs intact:

- `runtime/idle/`
- `runtime/move/`
- `runtime/attack/`

These are now the promoted `runtime_v02_layered_candidate` battle-state frames.
The candidate folders remain available as the review source and rollback
reference.

## Layered 8Dir Targets

### Source Layers

- `source/8dir/base_body/`
- `source/8dir/base_outfit/`
- `source/8dir/weapon_overlay/`
- `source/8dir/shield_overlay/`
- `source/8dir/upper_armor_overlay/`

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

## Enemy Lane Acceptance Gate

- all eight directions exist for `base_body`
- all eight directions exist for `base_outfit`
- all eight directions exist for `weapon_overlay`
- `upper_armor_overlay` may remain empty until enemy upper gear is justified
- `shield_overlay` may remain empty unless a specific proof case requires it
- hostile agile threat survives the layered split
- lane identity stays distinct from `Tia`
- no layer set is promoted past reference-only unless future derivation is anchored to the frozen lane anchor

## Battle-State Runtime Promotion

Promotion record:

- `/Volumes/AI/tactics/docs/generated/character_state_runtime_promotion_record_v01.md`

Promoted states:

- `idle`
- `move`
- `attack`
