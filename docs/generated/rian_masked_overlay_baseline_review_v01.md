# Rian Masked Overlay Baseline Review V01

## Scope

Reviewed the deterministic masked overlay baseline for `Rian`.

Reference record:

- [rian_masked_overlay_baseline_record_v01.md](/Volumes/AI/tactics/docs/generated/rian_masked_overlay_baseline_record_v01.md)

QA board:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime/8dir/composite_preview/rian_masked_overlay_qa_board_v01.png`

## Inputs

Official visual source of truth:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`

Masks:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/masks/rian_weapon_overlay_mask_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/masks/rian_upper_armor_overlay_mask_v01.png`

Extracted baseline layers:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v03_masked.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v04_masked.png`

## Verdict

Status:

- `baseline accepted as alignment / rollback reference`

Not status:

- not promoted runtime proof
- not final Rian layer approval
- not a replacement identity anchor

## What Passes

- official reference anchor remains the source of truth
- masks restrict edits to the intended target zones
- extracted overlays have transparent non-target regions
- eight runtime frames exist for both target overlays
- output grid remains aligned to the source `4x2` sheet
- face, hair, stance, and broader costume are not redrawn

## Cautions

The baseline is a mask extraction, not a semantic layer clean-up.

That means:

- `weapon_overlay` may retain small hand or nearby gear fragments where the mask
  protects sword alignment
- `upper_armor_overlay` may include some adjacent straps or collar material
  because they sit inside the armor safety zone
- visual polish should happen through a future masked edit, not by broad redraw

These cautions are acceptable for a rollback/alignment baseline.

## Direct Visual Check Update

A direct visual check of the QA board found that deterministic extraction is
not sufficient as a final layer cleanup.

Observed and corrected:

- one weapon direction was erased by the warm-background removal pass
- `weapon_overlay` extraction now bypasses that cleanup so all eight swords stay
  present

Still true:

- the weapon extraction may include hand/glove or small background fragments
- this remains acceptable only for alignment and rollback, not final production
  layer truth

Follow-up checkpoint:

- [rian_weapon_overlay_cleanup_checkpoint_v01.md](/Volumes/AI/tactics/docs/generated/rian_weapon_overlay_cleanup_checkpoint_v01.md)

## Next Live Proof Rule

Run live masked edit one layer at a time.

Recommended order:

1. `weapon_overlay`
2. `upper_armor_overlay`

Acceptance rule:

- the live result must beat this deterministic baseline while preserving Rian's
  identity and grid alignment

Reject rule:

- reject immediately if the result redraws the whole character, hides the face,
  changes the silhouette into a rogue/hooded read, or adds oversized FX

## Working Conclusion

The baseline is good enough to serve as a constrained comparison target. The
next productive step is a single-layer live masked edit proof for
`weapon_overlay`.
