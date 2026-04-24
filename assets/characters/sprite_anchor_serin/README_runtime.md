# Sprite Anchor Serin Runtime Pipeline

## Current Role

This lane is now tracked as the layered 8-direction support/caster proof lane.

It should not be treated as one finished eight-direction character sheet.

It should be treated as a layered stack whose main job is to preserve:

- support/healer first
- caster second

## Legacy Reference

Any previous monolithic directional prep is reference-only.

Use `source/8dir/legacy_reference/` for:

- old monolithic sheets
- silhouette comparisons
- prompt-era exploratory material

Do not promote legacy reference material as final layered production truth.

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

Optional or restrained layers:

- `shield_overlay`
- `upper_armor_overlay`

Reason:

- staff overlay is required for Serin's support/caster read
- shield overlay is optional and likely unused
- upper armor must stay swappable and must not become the whole robe identity

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

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/layered_8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-plan.md`
