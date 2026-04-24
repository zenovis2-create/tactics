# Sprite Anchor Rian Runtime Manifest V01

## Lane Mode

This lane is now tracked as:

- `layered_8dir_pilot`
- `anchor_first_required`

## Legacy Reference Sources

- `source/8dir/legacy_reference/rian_8dir_sheet_source_v01.png`
- `source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`
- `source/8dir/legacy_reference/rian_4dir_sheet_source_v01_legacy.png`

These remain reference-only.

## Frozen Anchor Source

- `source/8dir/anchor/rian_anchor_8dir_sheet_source_v01.png`

## Official Visual Reference Anchor

- `source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`

This is the reviewed visual source of truth for `Rian`.

Generated anchors that fail the quality bar are not allowed to replace this
reference.

## Reference-Only Derived Exploration

Current generated layered source files are not yet final production truth.

Even after the anchor is frozen, treat these as:

- reference-only derived exploration
- usable for silhouette and alignment review
- not yet the final locked layer set until they are re-derived from the frozen anchor

## Constrained Edit Pack

Approved next constrained edit pack:

- `source/8dir/masked_edit_v01/`

Approved target layers:

- `weapon_overlay`
- `upper_armor_overlay`

Use the official visual reference anchor and the pack masks. Do not promote
unconstrained generated anchors or full-character redraws as layer truth.

Current deterministic baseline outputs:

- `source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v03_masked.png`
- `source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v04_masked.png`
- `runtime/8dir/weapon_overlay/rian_weapon_overlay_00.png` through `rian_weapon_overlay_07.png`
- `runtime/8dir/upper_armor_overlay/rian_upper_armor_overlay_00.png` through `rian_upper_armor_overlay_07.png`

These are alpha-isolated baseline layers derived from the official visual
reference. They are safe as alignment and rollback references, but they do not
promote `Rian` out of candidate status.

Baseline review board:

- `runtime/8dir/composite_preview/rian_masked_overlay_qa_board_v01.png`

Baseline review:

- `/Volumes/AI/tactics/docs/generated/rian_masked_overlay_baseline_review_v01.md`

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

## Pilot Acceptance Gate

- all eight directions exist for `base_body`
- all eight directions exist for `base_outfit`
- all eight directions exist for `weapon_overlay`
- all eight directions exist for `upper_armor_overlay`
- `shield_overlay` may remain empty in the pilot
- composite preview can be assembled without losing Rian's command read
- the lane anchor is now frozen
- no layer set is promoted past reference-only until it is re-derived from that frozen anchor
