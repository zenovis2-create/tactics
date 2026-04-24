# Missing Image Cleanup Queue V01

## Purpose

This document splits the current image backlog into `clean-first` work after source generation has been handled.

Use with:

- `/Volumes/AI/tactics/docs/generated/missing_image_generation_backlog_v01.md`
- `/Volumes/AI/tactics/docs/clean_pass_production_guide_v01.md`

## Current Rule

Do not regenerate source by default for these lanes.

They already have usable `source/` images and should move through:

1. source selection
2. clean pass
3. runtime derivation

## Current Clean Queue

### Character Sprite Lanes

- `sprite_anchor_serin`
- `sprite_anchor_rian`
- `sprite_anchor_tia`
- `sprite_anchor_bran`
- `sprite_anchor_enemy_raider`
- `sprite_anchor_enemy_skirmisher`

### Environment Lanes

- `forest_tile_01`
- `forest_tile_02`
- `fortress_tile_01`
- `fortress_tile_02`
- `fortress_edge_01`

### Prop Lanes

- `altar_01`
- `lever_01`
- `gate_control_01`
- `paladin_shield`

## Queue Order

Recommended order:

1. character sprite anchors
2. environment baseline tiles
3. interaction props
4. optional equipment support cleanup beyond current blockers

## Immediate Character Cleanup Order

Recommended order:

1. `sprite_anchor_serin`
2. `sprite_anchor_rian`
3. `sprite_anchor_tia`
4. `sprite_anchor_bran`
5. `sprite_anchor_enemy_raider`
6. `sprite_anchor_enemy_skirmisher`

Reason:

- Serin already has the strongest existing slicing guide and can act as the cleanup benchmark
- ally anchors should lock class distance before enemy cleanup is finalized
- enemy lanes should be cleaned only after ally class spacing is stable

## Immediate Environment Cleanup Order

Recommended order:

1. `forest_tile_01`
2. `forest_tile_02`
3. `fortress_tile_01`
4. `fortress_tile_02`
5. `fortress_edge_01`

Reason:

- forest and fortress lanes are the clearest reusable tile families
- edge and family polish should follow after the baseline tiles are locked

## Immediate Prop Cleanup Order

Recommended order:

1. `paladin_shield`
2. `altar_01`
3. `lever_01`
4. `gate_control_01`

Reason:

- shield is the clearest gear-side anchor
- altar and machinery props should follow the terrain cleanup once shared rendering rules are stable

## Completed Source Generation

Current generated source lane:

- `character_anchor_knight`

Next default action for that lane:

1. create `clean/character_anchor_knight_sheet_clean_v01.png`
2. review it against the style bible and Rhino use case

## Notes

- `field_sword_01` already has a cleanup guide and is not part of the current missing-clean backlog summary provided in this pass.
- new family expansion work should start only after the current clean queue has a stable baseline.
