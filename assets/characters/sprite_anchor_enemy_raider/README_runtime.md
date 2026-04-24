# Sprite Anchor Enemy Raider Runtime Pipeline

## Current Role

This lane is now tracked as a layered 8-direction hostile baseline lane.

It should no longer be treated as one finished enemy sheet.

It should be treated as a layered stack that can preserve enemy identity while
allowing controlled gear variation.

## Anchor-First Rule

This lane is governed by:

- anchor sheet first
- all variants derived from anchor
- consistency beats speed

That means current or future layered outputs are not trusted as final production
truth unless they are explicitly derived from the lane anchor.

## Legacy Reference

Older flat `8dir` prep remains useful only as reference material.

Treat any pre-layered enemy-raider directional prep as:

- silhouette benchmark
- hostile-read benchmark
- not the final asset contract

## Frozen Anchor

The official lane anchor is:

- `source/8dir/anchor/enemy_raider_anchor_8dir_sheet_source_v01.png`

Future image-to-image derivation should flow from this anchor into:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `shield_overlay`
- `upper_armor_overlay`

This lane is now visually frozen at the anchor level.

## Layered Pipeline

1. `source/`
   Existing state sheets and historical material.
2. `source/8dir/anchor/`
3. `source/8dir/base_body/`
4. `source/8dir/base_outfit/`
5. `source/8dir/weapon_overlay/`
6. `source/8dir/shield_overlay/`
7. `source/8dir/upper_armor_overlay/`
8. `clean/8dir/<layer>/`
9. `runtime/8dir/<layer>/`
10. `runtime/8dir/composite_preview/`
11. `runtime/portraits/`
12. `runtime/tokens/`

Existing `runtime/idle/`, `runtime/move/`, and `runtime/attack/` folders remain
intact and are not deleted by this migration.

## Layer Rule

Required layers for this lane:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `upper_armor_overlay`

Optional in the initial hostile baseline:

- `shield_overlay`

Reason:

- Enemy Raider should prove hostile melee identity first
- shield logic may exist later, but it is not required to prove the baseline
- the lane must avoid collapsing into ally swordsman or generic bandit

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

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/layered_8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-design.md`
