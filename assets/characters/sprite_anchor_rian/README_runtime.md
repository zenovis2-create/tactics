# Sprite Anchor Rian Runtime Pipeline

## Current Role

This lane is the pilot lane for the layered 8-direction character contract.

It should no longer be treated as a single finished 8-direction character sheet.

It should now be treated as a layered stack.

## Anchor-First Rule

This lane is governed by:

- anchor sheet first
- all variants derived from anchor
- consistency beats speed

That means current layered source outputs are not yet final production truth.

They are only safe as:

- reference-only derived exploration
- pilot material for alignment and drift checking

## Legacy Reference

Previous monolithic directional sheets are retained only as references:

- `source/8dir/legacy_reference/rian_8dir_sheet_source_v01.png`
- `source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`
- `source/8dir/legacy_reference/rian_4dir_sheet_source_v01_legacy.png`

These are:

- silhouette benchmarks
- not the final asset contract

Current layered source outputs should also be treated the same way until the
lane anchor is explicitly frozen.

## Frozen Anchor

The current official lane anchor for the layered contract is:

- `source/8dir/anchor/rian_anchor_8dir_sheet_source_v01.png`

The current official visual reference anchor is:

- `source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`

Use the visual reference anchor as the human-reviewed source of truth for
identity checks.

Use the layered anchor path only as a contract location, not as automatic proof
that the generated image is valid.

The upstream image-to-image reference for future regeneration should be aligned
to the visual reference anchor above before trusting any new layer set:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `shield_overlay`
- `upper_armor_overlay`

Current generated layered source outputs remain reference-only until they are
re-derived against a valid reviewed anchor source.

## Constrained Edit Pack

The approved next regeneration pack is:

- `source/8dir/masked_edit_v01/`

It constrains the next pass to:

- `weapon_overlay`
- `upper_armor_overlay`

Use the masks in that pack with the official visual reference anchor. Do not
run unconstrained full-character redraws for this lane.

The current deterministic constrained baseline is generated from that pack and
populates:

- `runtime/8dir/weapon_overlay/`
- `runtime/8dir/upper_armor_overlay/`

This baseline is an alignment and rollback reference. It is not a promotion
decision for `Rian`.

The current QA board is:

- `runtime/8dir/composite_preview/rian_masked_overlay_qa_board_v01.png`

## Layered Pipeline

1. `source/`
   Existing state sheets and historical material.
2. `source/8dir/base_body/`
3. `source/8dir/base_outfit/`
4. `source/8dir/weapon_overlay/`
5. `source/8dir/shield_overlay/`
6. `source/8dir/upper_armor_overlay/`
7. `clean/8dir/<layer>/`
8. `runtime/8dir/<layer>/`
9. `runtime/8dir/composite_preview/`
10. `runtime/portraits/`
11. `runtime/tokens/`

## Layer Rule

Required layers for this lane:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `upper_armor_overlay`

Optional in the pilot:

- `shield_overlay`

Reason:

- Rian is the clearest pilot for body, outfit, weapon, and upper-armor separation
- shield logic is not the primary proof case here

## Direction Rule

All layers use:

- `front`
- `front_right`
- `right`
- `back_right`
- `back`
- `back_left`
- `left`
- `front_left`

## Companion Docs

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/layered_8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/docs/generated/rian_masked_overlay_edit_pack_v01.md`
- `/Volumes/AI/tactics/docs/generated/rian_masked_overlay_baseline_record_v01.md`
- `/Volumes/AI/tactics/docs/generated/rian_masked_overlay_baseline_review_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-design.md`
