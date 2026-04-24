# Rian Masked Overlay Edit Pack V01

## Decision

The next `Rian` layer pass is constrained to:

- `weapon_overlay`
- `upper_armor_overlay`

It must use the official visual reference anchor:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`

It must not use newly generated identity anchors as production truth.

## Pack Location

Working pack:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/`

Generated masks:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/masks/rian_weapon_overlay_mask_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/masks/rian_upper_armor_overlay_mask_v01.png`

Mask metadata:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/mask_layout_v01.json`

Mask builder:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/build_masks.py`

## Mask Contract

- white: editable region
- black: protected reference-anchor region

The protected region must preserve:

- face readability
- hair silhouette
- body stance
- command cloth read
- non-target gear and costume structure

## `weapon_overlay` Edit Brief

Input:

- official visual reference anchor
- `rian_weapon_overlay_mask_v01.png`

Allowed change:

- isolate and clean the compact one-handed sword read
- preserve direction-specific sword angle and hand placement
- remove slash effects or motion trails

Forbidden change:

- full body redraw
- new face, hood, cowl, or rogue silhouette
- giant fantasy blade
- glowing FX trail
- extra hands or secondary weapons

Target output:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v03_masked.png`

## `upper_armor_overlay` Edit Brief

Input:

- official visual reference anchor
- `rian_upper_armor_overlay_mask_v01.png`

Allowed change:

- isolate and clean light upper armor
- preserve chest and shoulder armor as compact tactical gear
- keep Rian lighter than `Bran`

Forbidden change:

- full body redraw
- face or hair edits
- heavy knight shell
- giant pauldrons
- cloak or hood expansion
- stealth/rogue read

Target output:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v04_masked.png`

## Acceptance Gate

Accept only if:

- the result still reads as `Rian` before reading the filename
- the face remains visible and ally-coded
- the output is layer-specific, not a repeated full-character image
- all eight directions preserve the 4x2 grid alignment
- no generated anchor replaces the official visual reference

Reject if:

- the image becomes hooded, faceless, rogue-coded, or enemy-coded
- the output redraws the whole character instead of the target layer region
- the sword or armor becomes larger than the tactical-map read needs

## Working Conclusion

This pack turns the next Rian pass from broad regeneration into constrained
layer repair. It is safe to use for one-layer-at-a-time live proofs, starting
with `weapon_overlay`, then `upper_armor_overlay`.
