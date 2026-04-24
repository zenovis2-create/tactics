# Sprite Anchor Serin Runtime Manifest V01

## Lane Mode

This lane is now tracked as:

- `layered_8dir_support_proof`

## Legacy Reference Sources

- `source/8dir/legacy_reference/`

Use this folder for any previous monolithic eight-direction prep.

## Existing State Outputs

Keep current state outputs intact:

- `runtime/idle/`
- `runtime/cast/`
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

## Support/Caster Acceptance Gate

- all eight directions exist for `base_body`
- all eight directions exist for `base_outfit`
- all eight directions exist for `weapon_overlay`
- `weapon_overlay` reads as compact staff support gear
- `shield_overlay` may remain empty
- `upper_armor_overlay` may remain empty until a swappable support-gear case is justified
- the robe or support identity must not collapse into upper armor
- identity must stay support/healer first and caster second

## Battle-State Runtime Promotion

Promotion record:

- `/Volumes/AI/tactics/docs/generated/character_state_runtime_promotion_record_v01.md`

Promoted states:

- `idle`
- `cast`
- `attack`
