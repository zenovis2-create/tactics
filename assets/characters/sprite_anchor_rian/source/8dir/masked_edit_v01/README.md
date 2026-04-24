# Rian Masked Edit Pack V01

## Source Of Truth

Use only this official visual reference anchor:

- `../legacy_reference/rian_8dir_sheet_source_v02.png`

Do not use generated bridge-proof anchors as production truth.

## Purpose

This pack constrains the next Rian regeneration pass to two layers:

- `weapon_overlay`
- `upper_armor_overlay`

It exists to avoid the previous failure mode where prompt-only generation
produced repeated full-character images instead of isolated layers.

## Masks

Generated masks:

- `masks/rian_weapon_overlay_mask_v01.png`
- `masks/rian_upper_armor_overlay_mask_v01.png`

Mask contract:

- white: editable region
- black: protected reference-anchor region

## Generation Rule

The next live proof must:

- use `../legacy_reference/rian_8dir_sheet_source_v02.png` as the image source
- use the relevant mask for the target layer
- preserve all black/protected regions
- avoid full-character redraw
- output one layer at a time

## Output Targets

Write successful constrained outputs to:

- `../weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v03_masked.png`
- `../upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v04_masked.png`

Do not overwrite earlier source outputs.

## Deterministic Baseline

Before live masked AI edit, this pack can build a deterministic extraction
baseline from the official visual reference:

- `build_deterministic_overlay_baseline.py`

Generated baseline outputs:

- `../weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v03_masked.png`
- `../upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v04_masked.png`
- `../../../clean/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_clean_v03_masked.png`
- `../../../clean/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_clean_v04_masked.png`
- `../../../runtime/8dir/weapon_overlay/rian_weapon_overlay_00.png` through `07.png`
- `../../../runtime/8dir/upper_armor_overlay/rian_upper_armor_overlay_00.png` through `07.png`

Use this baseline as an alignment and rollback reference. It is not a new
identity anchor and does not promote Rian out of candidate status.

## QA Board

Build the visual QA board with:

- `build_overlay_qa_board.py`

Generated board:

- `../../../runtime/8dir/composite_preview/rian_masked_overlay_qa_board_v01.png`

Use it to compare:

- official reference anchor
- baseline recomposite
- weapon mask
- weapon overlay extraction
- upper armor mask
- upper armor overlay extraction

## Current Weapon Baseline Caution

The deterministic `weapon_overlay` baseline preserves all eight sword
directions, but it is not a final clean weapon-only layer.

Known remaining issues:

- hand or glove fragments may remain near the hilt
- small background wedges may remain inside the broad sword safety mask

Use the current weapon baseline for alignment and rollback only. The next
production-quality step is a single-layer masked cleanup/edit.
