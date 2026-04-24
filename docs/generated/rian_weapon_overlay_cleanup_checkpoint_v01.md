# Rian Weapon Overlay Cleanup Checkpoint V01

## Scope

Checked the deterministic `weapon_overlay` baseline after direct visual review
of:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime/8dir/composite_preview/rian_masked_overlay_qa_board_v01.png`

## Finding

The first baseline extraction was not good enough.

Problems observed:

- one weapon direction was fully erased by background-removal cleanup
- the initial alpha extraction could also carry unwanted background or hand
  fragments depending on cleanup settings

## Fix Applied

Updated:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/masked_edit_v01/build_deterministic_overlay_baseline.py`

Change:

- `weapon_overlay` no longer uses the warm-background removal pass
- `upper_armor_overlay` still uses warm-background removal

Reason:

- the sword blade is bright and low-saturation, so the same rule that removes
  the sheet background can incorrectly remove the blade itself

## Verification

After regeneration:

- all 8 `weapon_overlay` runtime frames have non-empty alpha bounds
- all 8 `upper_armor_overlay` runtime frames remain present
- QA board regenerated

## Current Verdict

Status:

- `weapon_overlay` deterministic baseline is valid as an alignment / rollback
  reference

Not status:

- not final clean weapon layer
- not ready to promote as semantic weapon-only production truth

## Remaining Issue

The current deterministic weapon extraction still includes some non-weapon
material:

- hand or glove fragments near hilts
- small background wedges inside the broad sword safety mask

This is expected for a deterministic mask extraction from a flattened reference
sheet. It cannot fully solve semantic separation without either:

- a tighter hand-authored mask, or
- live masked edit / paint cleanup

## Next Step

The correct next proof is still:

1. run `weapon_overlay` as a single-layer masked cleanup/edit
2. compare the result against this deterministic baseline
3. reject if any direction loses the sword, redraws the full character, or adds
   oversized slash FX
