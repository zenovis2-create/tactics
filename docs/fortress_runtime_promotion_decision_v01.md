# Fortress Runtime Promotion Decision V01

## Decision

`fortress_tile_01` is **not** promoted to a global runtime baseline at this time.

It is approved as:

- a validated `map-specific fortified-ground family`
- a runtime-ready preview and chapter-surface candidate
- a reusable source for Hardren / Valtor / fortified map variants

It is **not** approved as:

- a global replacement for any current production terrain slot

## Why This Decision Is Correct

The project now has enough evidence to decide this without guessing.

Evidence already exists in:

- `/Volumes/AI/tactics/docs/fortress_tile_01_introduction_decision_v01.md`
- `/Volumes/AI/tactics/docs/ch02_fortress_screenshot_assembly_v01.md`
- `/Volumes/AI/tactics/docs/ch04_sacred_machinery_preview_v01.md`
- `/Volumes/AI/tactics/docs/ch02_fortress_screenshot_review_v01.md`
- `/Volumes/AI/tactics/docs/ch06_iron_keep_preview_v01.md`
- `/Volumes/AI/tactics/scripts/dev/ch02_fortress_art_preview_runner.gd`
- `/Volumes/AI/tactics/scripts/dev/ch04_sacred_machinery_preview_runner.gd`
- `/Volumes/AI/tactics/scripts/dev/ch06_iron_keep_preview_runner.gd`

The critical findings are:

1. `fortress_tile_01` reads clearly as engineered fortified ground.
2. It supports character readability in preview space.
3. It works well as a contextual terrain family.
4. `fortress_tile_02` now gives the family internal variation.
5. The family now survives more than one fortified context.
6. It is still not broad enough to represent all non-forest terrain globally.

## Promotion Judgment

### Approved

- use in chapter-specific previews
- use in fortress-family screenshot assembly
- use as a basis for future fortified-floor derivatives
- use in map-specific production work for CH02 / CH06-style spaces
- use as a validated family for sacred-machinery mixed spaces where fortified stone still underlies the scene

### Not Approved

- replacing a global terrain slot in `assets/ui/production/tile_cards/`
- replacing a global terrain slot in `assets/ui/production/tile_icons/`
- acting as a generic fallback for all stone or engineered floors

## Current Runtime Role

Treat `fortress_tile_01` as:

- `runtime-ready candidate`
- `chapter-specific terrain family`
- `preview-approved`

Do not treat it as:

- `global baseline`

## What Is Missing Before Broader Promotion

Before the project could justify promoting fortress more aggressively, it would need at least one of:

1. a dedicated runtime routing rule for chapter-specific terrain families
2. stronger proof that fortress-like floors are common enough to deserve a broader baseline role
3. evidence that the current `tile_01 / tile_02 / edge_01` family still lacks breadth in real chapter compositions

## Working Rule

For now:

- `forest` remains the promoted global terrain baseline
- `fortress_tile_01` remains the promoted fortified-map candidate family
- `fortress_edge_01` is accepted as the first structural support surface within that family

This is not a demotion.
It is the correct level of promotion for the current code and asset-routing structure.

## Immediate Follow-On Recommendation

The next best terrain task is:

- decide whether a third fortress-supporting surface is needed before broader runtime routing

Reason:

- the fortress family is now validated across multiple fortified contexts
- the next decision is no longer “does fortress work”
- it is “is the family broad enough to justify stronger runtime routing”

## Related Files

- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_clean_v01.png`
- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_tile_card_v01.png`
- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_tile_icon_v01.png`
- `/Volumes/AI/tactics/assets/environment/fortress_tile_01/runtime/fortress_tile_01_integration_v01.png`
- `/Volumes/AI/tactics/docs/environment_equipment_runtime_promotion_plan_v01.md`
- `/Volumes/AI/tactics/docs/runtime_promotion_record_v01.md`
