# Sprite Anchor Bran Runtime Manifest V01

## Lane Mode

This lane is now tracked as:

- `layered_8dir_heavy_shield_proof`

## Existing State Outputs

Keep current state outputs intact:

- `runtime/idle/`
- `runtime/move/`
- `runtime/attack/`

These are not deleted by the layered migration.

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

## Proof Acceptance Gate

- all eight directions exist for `base_body`
- all eight directions exist for `base_outfit`
- all eight directions exist for `weapon_overlay`
- all eight directions exist for `shield_overlay`
- all eight directions exist for `upper_armor_overlay`
- composite preview can be assembled without losing Bran's shield-first read
