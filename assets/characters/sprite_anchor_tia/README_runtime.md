# Sprite Anchor Tia Runtime Pipeline

## Current Role

This lane is now tracked as a layered 8-direction ranged hunter lane.

It should no longer be treated as one finished 8-direction character sheet.

It should be treated as a layered stack with a bow-first gameplay read.

## Layered Pipeline

1. `source/`
   Existing state sheets and historical material.
2. `source/8dir/base_body/`
3. `source/8dir/base_outfit/`
4. `source/8dir/weapon_overlay/`
5. `source/8dir/shield_overlay/`
6. `source/8dir/upper_armor_overlay/`
7. `source/8dir/legacy_reference/`
8. `clean/8dir/<layer>/`
9. `runtime/8dir/<layer>/`
10. `runtime/8dir/composite_preview/`
11. `runtime/portraits/`
12. `runtime/tokens/`

## Layer Rule

Required layers for this lane:

- `base_body`
- `base_outfit`
- `weapon_overlay`

Optional or situational:

- `upper_armor_overlay`
- `shield_overlay`

Reason:

- Tia must read as ranged hunter first
- bow overlay is required
- shield logic is not a core proof case here
- upper-body gear can swap, but it must not erase her hunter asymmetry

## Direction Rule

All layered assets use:

- `front`
- `front_right`
- `right`
- `back_right`
- `back`
- `back_left`
- `left`
- `front_left`

## Tia-Specific Rules

- ranged hunter first, forest skirmisher second
- bow overlay is required in any combat-ready composite
- shield overlay is optional and likely unused
- `upper_armor_overlay` is only for swappable upper hunter gear
- asymmetry that defines Tia's hunter read should stay in `base_outfit`, not in swappable armor

## Companion Docs

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/layered_8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-design.md`
