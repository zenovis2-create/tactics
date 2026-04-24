# Layered Character Composite Preview Rules v01

## Purpose

`composite_preview` is a review-only assembled image for the new layered character system.

It exists to:

- confirm that `base_body`, `base_outfit`, and required equipment overlays align correctly
- confirm that the lane keeps the intended gameplay read in `8dir`
- give art/runtime review a quick visual check before runtime outputs are finalized

Location:

- `runtime/8dir/composite_preview/`

## Minimum Preview Set Per Lane

Minimum required previews:

- `front`
- `front_right`
- `right`
- `back_right`
- `back`
- `back_left`
- `left`
- `front_left`

Minimum file set:

- one composite preview per direction
- naming: `<character>_composite_<view>_preview_v01.png`

## Required Visible Layers

Every composite preview must show:

- `base_body`
- `base_outfit`

Plus lane-required gear layers:

- `weapon_overlay` when the lane has a weapon-facing read
- `shield_overlay` when the lane is shield-bearing or shield-proof
- `upper_armor_overlay` when upper-body gear is part of the current reviewed build

The preview should only include layers that are part of the intended reviewed build.

## What The Preview Is For

Use composite preview for:

- layer alignment review
- silhouette/readability review
- early runtime planning
- quick handoff checks between art and runtime work

## What The Preview Is Not For

Do not use composite preview as:

- final gameplay sprite output
- proof that all runtime slicing is complete
- proof that all equipment combinations are supported
- a replacement for per-layer source, clean, or runtime outputs
- a generic beauty render or promo image
