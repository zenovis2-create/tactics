# Rian Asset Engine + ComfyUI Verification V01

## Scope

Verify what the `Rian` Asset Engine + ComfyUI pass actually proved.

Reviewed local imported outputs:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/anchor/rian_anchor_8dir_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/base_body/rian_base_body_8dir_sheet_source_v02_anchor_derived.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/base_outfit/rian_base_outfit_8dir_sheet_source_v02_anchor_derived.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v02_anchor_derived.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/shield_overlay/rian_shield_overlay_8dir_sheet_source_v02_anchor_derived.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v02_anchor_derived.png`

Reference:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`

Temporary visual verification board:

- `/tmp/rian_asset_engine_comfy_verification_board_v01.png`

## Environment Note

The original external runtime paths referenced by earlier reviews are not
available in the current session:

- `/Volumes/AI2/asset/`
- `/Volumes/AI2/ComfyUI/`

Therefore this verification is limited to local imported outputs and existing
project documentation.

## File Contract Check

All reviewed imported layer outputs are:

- `1536x1024`
- `RGB`
- no alpha channel

This matters because `RGB` sheets are flattened images. They are not directly
runtime-composable transparent layers.

## What The Pass Proved

The pass did prove:

- the pipeline can produce `4x2` 8-direction sheets
- the pipeline can produce separate layer-intent concepts:
  - base body
  - base outfit
  - weapon
  - shield
  - upper armor
- the generated equipment sheets are visually coherent as standalone concept
  sheets
- the generated body/outfit sheets are cleaner than the earlier failed
  full-character duplicate-layer behavior

## What The Pass Did Not Prove

The pass did not prove:

- runtime-ready alpha-separated layers
- final Rian identity match to the official visual reference
- compositing correctness over the current official reference
- that generated anchor outputs can replace the official legacy reference
- that layer outputs can be promoted into production without cleanup

## Visual Findings

### Official Reference

The official reference has:

- visible face
- sword-led frontline read
- light armor and command-cloth silhouette
- stronger tactical commander identity

### Generated Anchor

The generated anchor is usable as a simplified directional character sheet, but:

- it is not the same visual source of truth
- it loses the sword-led command read
- it is less armored and less specific than the official reference

Verdict:

- reference-only
- not official anchor

### Base Body

The generated base body is a plausible body concept sheet.

Verdict:

- useful concept input
- not runtime-ready because it is flattened RGB

### Base Outfit

The generated base outfit is a plausible outfit concept sheet.

Verdict:

- useful concept input
- not runtime-ready because it is flattened RGB

### Weapon Overlay

The generated weapon sheet is the strongest layer-intent output.

It is weapon-only as a concept sheet, but it remains:

- flattened RGB
- not aligned as an alpha overlay to the official body/reference

Verdict:

- useful source candidate
- requires alpha cleanup and alignment validation before runtime use

### Upper Armor Overlay

The generated armor sheet is visually coherent, but:

- it is a standalone armor concept sheet
- it is flattened RGB
- it does not prove exact compositing over the official reference

Verdict:

- useful source candidate
- requires alpha cleanup and alignment validation before runtime use

## Verification Conclusion

Asset Engine + ComfyUI succeeded as a concept/layer-intent generator.

Asset Engine + ComfyUI did not yet succeed as a runtime layer production system.

The correct next step is not more masked extraction from the full reference.

The correct next step is:

1. choose the best existing generated layer source candidates
2. convert those candidates into transparent alpha layers
3. validate alignment by recompositing over the accepted Rian base/reference
4. only then decide whether any layer is production-ready

## Production Rule

Do not promote any current `*_anchor_derived.png` source as runtime truth
without:

- alpha separation
- compositing test
- visual review against the official Rian reference
- manifest update marking it as reviewed
