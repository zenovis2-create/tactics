# Sprite Anchor Tia Runtime Manifest V01

## Lane Mode

This lane is now tracked as:

- `layered_8dir_ranged_lane`
- `bow_required`

## Existing State Outputs

Keep current state outputs intact:

- `runtime/idle/`
- `runtime/move/`
- `runtime/attack/`

These are now the promoted `runtime_v02_layered_candidate` battle-state frames.
The candidate folders remain available as the review source and rollback
reference.

## Legacy Reference Sources

Any previous monolithic 8-direction prep should be retained under:

- `source/8dir/legacy_reference/`

Treat these as reference-only if they are carried forward.

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

## Tia Acceptance Gate

- all eight directions exist for `base_body`
- all eight directions exist for `base_outfit`
- all eight directions exist for `weapon_overlay`
- bow read remains stronger than dagger or rogue read
- `shield_overlay` may remain empty
- `upper_armor_overlay` may remain empty until swappable hunter gear is needed
- composite preview must still read as ranged hunter first, forest skirmisher second

## Battle-State Runtime Promotion

Promotion record:

- `/Volumes/AI/tactics/docs/generated/character_state_runtime_promotion_record_v01.md`

Promoted states:

- `idle`
- `move`
- `attack`
