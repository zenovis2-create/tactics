# Sprite Anchor Enemy Skirmisher Runtime Pipeline

## Current Role

This lane is now tracked as the layered 8-direction hostile agile proof lane.

It should no longer be treated as one finished eight-direction character sheet.

It should be treated as a layered stack whose main job is to preserve:

- hostile agile threat first
- pursuit hunter second
- enemy identity distinct from `Tia`

## Anchor-First Rule

This lane is governed by:

- anchor sheet first
- all variants derived from anchor
- consistency beats speed

No layered output in this lane should be treated as final production truth
unless it is derived from the frozen lane anchor.

## Anchor Status

The official anchor path for this lane is:

- `source/8dir/anchor/enemy_skirmisher_anchor_8dir_sheet_source_v01.png`

Current status:

- layered contract migrated
- frozen anchor created
- no layered source promoted as production truth

## Legacy Reference

Any previous monolithic directional prep belongs in:

- `source/8dir/legacy_reference/`

Use that folder only for:

- old flat 8dir prep
- silhouette comparison
- prompt-era exploratory material

Do not promote legacy reference material as final layered production truth.

## Layered Pipeline

1. `source/`
   Existing state sheets and historical material.
2. `source/8dir/anchor/`
3. `source/8dir/legacy_reference/`
4. `source/8dir/base_body/`
5. `source/8dir/base_outfit/`
6. `source/8dir/weapon_overlay/`
7. `source/8dir/shield_overlay/`
8. `source/8dir/upper_armor_overlay/`
9. `clean/8dir/<layer>/`
10. `runtime/8dir/<layer>/`
11. `runtime/8dir/composite_preview/`
12. `runtime/portraits/`
13. `runtime/tokens/`

## Layer Rule

Required layers for this lane:

- `base_body`
- `base_outfit`
- `weapon_overlay`

Optional or restrained layers:

- `upper_armor_overlay`
- `shield_overlay`

Reason:

- skirmisher hostility must survive gear separation
- weapon overlay is required for ranged-threat read
- enemy skirmisher should not bulk up into defender mass
- shield logic is not a core proof case here

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

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/layered_8dir_prompt_pack_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-plan.md`
