# Sprite Anchor Bran Runtime Pipeline

## Current Role

This lane is the heavy and shield proof lane for the layered 8-direction
character contract.

It should no longer be treated as a single finished 8-direction character sheet.

It should now be treated as a layered stack.

## Legacy Reference

Any future monolithic directional sheets for this lane should be treated as:

- silhouette benchmarks
- not the final asset contract

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
- `shield_overlay`
- `upper_armor_overlay`

Reason:

- Bran is the clearest proof lane for heavy body mass and shield-specific
  equipment change

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

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/layered_8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-design.md`
