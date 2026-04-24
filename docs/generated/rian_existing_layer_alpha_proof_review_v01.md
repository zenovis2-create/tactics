# Rian Existing Layer Alpha Proof Review V01

## Scope

Test whether existing Asset Engine + ComfyUI layer-intent sheets can become
runtime overlays through alpha cleanup alone.

Reviewed sources:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v02_anchor_derived.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v03_lighter.png`

Proof pack:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/existing_layer_alpha_proof_v01/`

QA board:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime/8dir/composite_preview/rian_existing_layer_alpha_proof_board_v01.png`

## Method

Generated alpha proof sheets by:

- removing the flat background from the existing layer-intent sheets
- preserving visible equipment pixels
- recompositing the alpha sheets over the official Rian reference

Builder:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/existing_layer_alpha_proof_v01/build_existing_layer_alpha_proof.py`

## What Worked

Alpha cleanup is technically possible:

- weapon sheet can become an RGBA weapon-only proof sheet
- upper armor sheet can become an RGBA armor-only proof sheet
- both preserve all eight directions as standalone equipment sheets

## What Failed

Alpha cleanup alone does not make these sheets runtime-ready overlays.

Observed in recomposite:

- upper armor is too large and sits over the head/body instead of fitting the
  current Rian silhouette
- weapon positions do not align with Rian's hands
- recomposite changes Rian's read into a bulky armored character rather than
  preserving the official command silhouette

## Verdict

Status:

- `useful standalone equipment concept sources`

Not status:

- not aligned runtime overlays
- not production-ready layer outputs
- not safe to promote into `runtime/8dir/<layer>/`

## Pipeline Conclusion

Asset Engine + ComfyUI produced usable equipment concepts, but not placement
locked overlays for the accepted Rian body/reference.

The missing step is not just alpha separation.

The missing step is:

- per-direction transform/placement alignment, or
- regenerate/edit overlays against the actual accepted Rian body grid, or
- manually paint/fit the equipment onto the existing body alignment

## Next Correct Step

Do not continue broad extraction.

Choose one of these production paths:

1. alignment pass: scale/translate each equipment direction onto the accepted
   Rian body/reference and review recomposite
2. constrained generation pass: use the accepted Rian body/reference as the
   control image and generate equipment in-place
3. manual cleanup pass: use the existing equipment concepts as paint reference
   and produce hand-aligned transparent overlays

For the current pipeline, the most practical next proof is:

- `weapon_overlay` per-direction alignment pass first

Reason:

- weapon shape is already clean
- only placement relative to hands needs proof
- armor alignment has larger silhouette risk and should wait
