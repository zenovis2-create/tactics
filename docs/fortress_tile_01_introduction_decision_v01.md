# Fortress Tile 01 Introduction Decision V01

## Decision

`fortress_tile_01` is approved as a `map-specific fortified-ground variant`, not as a global production swap.

## Why This Decision Is Correct

The current battle-board runtime still routes terrain through a small set of filename-based global slots.

Relevant current promoted terrain slot:

- `assets/ui/production/tile_cards/forest.png`
- `assets/ui/production/tile_icons/forest.png`

Current implication:

- the project can promote one global terrain family cleanly
- it should not replace the global forest baseline with a fortress tile just because the asset exists

There are three realistic choices:

1. replace a current global terrain slot
2. keep `fortress_tile_01` as a preview-only asset
3. treat `fortress_tile_01` as a chapter- or map-specific fortified-ground variant

Option `1` is wrong right now because:

- fortress is not a global baseline terrain family
- replacing the wrong slot would distort current board readability assumptions

Option `2` is too weak because:

- it leaves the asset without an operational purpose
- it encourages unused asset accumulation

Option `3` is the correct choice because:

- fortress terrain is naturally chapter- and location-specific
- it lets the project expand terrain breadth without destabilizing current global runtime surfaces
- it fits Hardren / Valtor / monastery-adjacent fortified maps

## Working Rule

Until the project adds a richer terrain-routing layer:

- `forest` remains the currently promoted global terrain baseline
- `fortress_tile_01` is reserved for map-specific fortified-ground usage
- it should be introduced through chapter- or map-scoped integration, not through a blind global terrain replacement

## Immediate Use Cases

Use `fortress_tile_01` for:

- fortified board mockups
- Hardren-like or Valtor-like preview surfaces
- chapter-specific map screenshot assembly
- future runtime slot tests for fortified maps

Do not use it yet as:

- a replacement for the current promoted forest slot
- a generic fallback for all stone or neutral terrain

## Best Initial Target Surfaces

Most suitable early targets:

1. `CH02` fortress-adjacent previews
2. `CH06` iron-keep / fortified-ground previews
3. battle integration tests that need a contrast lane against forest

## What This Enables Next

Once this decision is locked:

1. the project can add a second terrain family without destabilizing the global forest lane
2. future chapter-specific terrain routing can be designed around actual use cases
3. fortress-family props and objectives can be designed around a stable floor language

## Related Files

- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_clean_v01.png`
- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_tile_card_v01.png`
- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_tile_icon_v01.png`
- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_integration_v01.png`
- `/Volumes/AI/tactics/docs/environment_equipment_runtime_promotion_plan_v01.md`
- `/Volumes/AI/tactics/docs/environment_prop_tile_matrix_v01.md`

