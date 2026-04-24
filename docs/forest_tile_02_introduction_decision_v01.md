# Forest Tile 02 Introduction Decision V01

## Decision

`forest_tile_02` is approved as a `map-specific visual variant`, not as a global production swap.

## Why This Decision Is Correct

The current runtime loader for battle board terrain is filename-based.

Relevant runtime path:

- `assets/ui/production/tile_cards/forest.png`
- `assets/ui/production/tile_icons/forest.png`

Current implication:

- the project has one global promoted `forest` production slot
- there is not yet a built-in multi-variant forest runtime routing layer

Because of that, there are only three realistic options:

1. replace the current promoted forest slot globally
2. keep `forest_tile_02` as a second board candidate only
3. treat `forest_tile_02` as a map-specific visual variant for future selective use

Option `1` is wrong right now because:

- `forest_tile_01` is already the promoted forest baseline
- replacing it globally would erase the current stable reference instead of expanding the family

Option `2` is acceptable but too weak because:

- it leaves the asset without a planned runtime purpose
- it encourages drift into unused concept inventory

Option `3` is the best current choice because:

- it preserves `forest_tile_01` as the stable global baseline
- it gives `forest_tile_02` a real future runtime purpose
- it avoids premature code changes for multi-variant terrain routing

## Working Rule

Until a multi-variant terrain routing system exists:

- `forest_tile_01` remains the global promoted forest slot
- `forest_tile_02` is reserved for selective map-side usage, visual comparison, and future chapter-specific terrain upgrades

## Immediate Use Cases

Use `forest_tile_02` for:

- battle integration preview comparison
- chapter-specific board mockups
- visual variation tests for Greenwood-heavy surfaces
- future chapter-specific production replacement decisions

Do not use it yet as:

- the new global `forest.png`
- a random swap-in replacement without review

## What This Enables Next

With this decision locked, the next environment tasks become cleaner:

1. create one more forest-family variant only if it serves map composition
2. define how chapter-specific terrain overrides should work
3. postpone global terrain-routing code changes until multiple families actually need them

## Related Files

- `/Volumes/AI/tactics/assets/environment/forest_tile_01/runtime/forest_tile_01_clean_v01.png`
- `/Volumes/AI/tactics/assets/environment/forest_tile_02/runtime/forest_tile_02_clean_v01.png`
- `/Volumes/AI/tactics/assets/ui/production/tile_cards/forest.png`
- `/Volumes/AI/tactics/assets/ui/production/tile_icons/forest.png`
- `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`
- `/Volumes/AI/tactics/docs/environment_equipment_runtime_promotion_plan_v01.md`

