# Runtime Promotion Candidate List V01

## Purpose

This document defines which art assets should be promoted from preview/candidate status
into the actual runtime surfaces first.

Promotion here means:

- the asset is no longer treated as a pure experiment
- it becomes the preferred in-game surface for the current slice
- future polish builds on it instead of replacing the entire direction

## Promotion Criteria

Promote an asset first if it is:

1. already validated enough to load in the current pipeline
2. highly visible during normal play
3. important for gameplay readability
4. low-risk to swap into runtime

## Promote Now

### 1. Forest Tile Card + Icon

Current runtime surfaces:

- [forest.png](/Volumes/AI/tactics/assets/ui/production/tile_cards/forest.png)
- [forest.png](/Volumes/AI/tactics/assets/ui/production/tile_icons/forest.png)

Why promote now:

- forest terrain is common and highly visible
- it directly affects board readability
- it is already wired into the production slot path

Promotion note:

- treat this as the current forest baseline for the slice
- continue improving through variants rather than replacing the whole direction

### 2. Altar Object Icon

Current runtime surface:

- [altar.png](/Volumes/AI/tactics/assets/ui/production/object_icons/altar.png)

Why promote now:

- objective props must read before UI
- altar is a strong test case for sacred/interactable language
- it is already wired into the production slot path

Promotion note:

- use it as the current objective-prop baseline
- future altar polish should preserve silhouette and sacred focal hierarchy

### 3. Forest Tile 01 Clean Candidate

Current clean source:

- [forest_tile_01_clean_v01.png](/Volumes/AI/tactics/assets/environment/forest_tile_01/runtime/forest_tile_01_clean_v01.png)

Why promote now:

- this is the best current terrain anchor for integration review
- it should remain the source asset behind the production forest slot

Promotion note:

- this is the source-of-truth terrain visual, even though the production runtime surface may later be resized/derived from it

### 4. Altar 01 Clean / Integration Candidate

Current clean sources:

- [altar_01_clean_v01.png](/Volumes/AI/tactics/assets/props/altar_01/runtime/altar_01_clean_v01.png)
- [altar_01_integration_v01.png](/Volumes/AI/tactics/assets/props/altar_01/runtime/altar_01_integration_v01.png)

Why promote now:

- this is the current best sacred objective baseline
- integration preview already depends on it

Promotion note:

- keep both clean and integration variants
- the clean variant remains the base art asset
- the integration variant is the board-facing support version

## Promote Soon

### 5. Forest Tile 02

Current candidate:

- [forest_tile_02_clean_v01.png](/Volumes/AI/tactics/assets/environment/forest_tile_02/runtime/forest_tile_02_clean_v01.png)

Why not immediate:

- valuable for repetition relief
- not strictly required for the first forest insertion

Promotion note:

- should be promoted once the first forest slot is visually stable

### 6. Paladin Shield Runtime Support Set

Current candidates:

- [paladin_shield_clean_v01.png](/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_clean_v01.png)
- [paladin_shield_equipment_v01.png](/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_equipment_v01.png)
- [paladin_shield_integration_v01.png](/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png)
- [paladin_shield_icon_v01.png](/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_icon_v01.png)

Why not immediate:

- shield support matters, but it is not yet connected to a core gameplay runtime slot the way forest and altar are

Promotion note:

- promote once equipment-support or loadout-facing runtime surfaces are ready

### 7. Memory Well Runtime Object Icon

Current candidates:

- [memory_well_01_clean_v01.png](/Volumes/AI/tactics/assets/props/memory_well_01/clean/memory_well_01_clean_v01.png)
- [memory_well_01_icon_v01.png](/Volumes/AI/tactics/assets/props/memory_well_01/runtime/memory_well_01_icon_v01.png)
- [memory_well.png](/Volumes/AI/tactics/assets/ui/production/object_icons/memory_well.png)

Why promote now:

- it is the strongest chapter-local investigation landmark in the current lane
- the silhouette remains readable at object-icon scale
- it adds a non-sacred, non-mechanical chapter object family to the runtime icon surface

Promotion note:

- treat it as the first chapter-local landmark promoted into the production `object_icons` slot path
- keep the chapter-local meaning tied to investigation and memory disturbance, not generic sacred-object use

### 8. Battery Emplacement Runtime Object Icon

Current candidates:

- [battery_emplacement_01_clean_v01.png](/Volumes/AI/tactics/assets/props/battery_emplacement_01/clean/battery_emplacement_01_clean_v01.png)
- [battery_emplacement_01_icon_v01.png](/Volumes/AI/tactics/assets/props/battery_emplacement_01/runtime/battery_emplacement_01_icon_v01.png)
- [battery_emplacement.png](/Volumes/AI/tactics/assets/ui/production/object_icons/battery_emplacement.png)

Why promote now:

- it is one of the clearest chapter-defining military landmarks in the current lane
- it remains readable at object-icon scale
- it adds a siege-pressure landmark to the production object icon path without reusing altar or gate language

Promotion note:

- treat it as the first military chapter-local landmark promoted into the production `object_icons` slot path
- keep its meaning tied to siege pressure and aiming threat, not generic machine clutter

### 9. Resin Shrine Runtime Object Icon

Current candidates:

- [resin_shrine_01_clean_v01.png](/Volumes/AI/tactics/assets/props/resin_shrine_01/clean/resin_shrine_01_clean_v01.png)
- [resin_shrine_01_icon_v01.png](/Volumes/AI/tactics/assets/props/resin_shrine_01/runtime/resin_shrine_01_icon_v01.png)
- [resin_shrine.png](/Volumes/AI/tactics/assets/ui/production/object_icons/resin_shrine.png)

Why promote now:

- it is the clearest chapter-local ritual landmark that is not just altar reuse
- the silhouette still reads well at object-icon scale
- it adds a hidden-ritual / forest-pressure landmark to the production object icon path

Promotion note:

- treat it as the first chapter-local forest ritual landmark promoted into the production `object_icons` slot path
- keep its meaning tied to hidden ritual and route doubt, not generic sacred-object use

### 10. Floodgate Wheel Runtime Object Icon

Current candidates:

- [floodgate_wheel_01_clean_v01.png](/Volumes/AI/tactics/assets/props/floodgate_wheel_01/clean/floodgate_wheel_01_clean_v01.png)
- [floodgate_wheel_01_icon_v01.png](/Volumes/AI/tactics/assets/props/floodgate_wheel_01/runtime/floodgate_wheel_01_icon_v01.png)
- [floodgate_wheel.png](/Volumes/AI/tactics/assets/ui/production/object_icons/floodgate_wheel.png)

Why promote now:

- it is the clearest chapter-local water-control landmark in the current lane
- the wheel silhouette remains legible at object-icon scale
- it adds a sacred-machinery route-state landmark to the production object icon path

Promotion note:

- treat it as the first chapter-local sacred-machinery route-control landmark promoted into the production `object_icons` slot path
- keep its meaning tied to flood-state change and purification-route logic, not generic gate-control reuse

### 11. Truth Dais Runtime Object Icon

Current candidates:

- [truth_dais_01_clean_v01.png](/Volumes/AI/tactics/assets/props/truth_dais_01/clean/truth_dais_01_clean_v01.png)
- [truth_dais_01_icon_v01.png](/Volumes/AI/tactics/assets/props/truth_dais_01/runtime/truth_dais_01_icon_v01.png)
- [truth_dais.png](/Volumes/AI/tactics/assets/ui/production/object_icons/truth_dais.png)

Why promote now:

- it is the strongest chapter-local evidence anchor in the archive lane
- the top-plane silhouette remains legible at object-icon scale
- it adds a truth-bearing archive landmark to the production object icon path without depending on altar reuse

Promotion note:

- treat it as the first chapter-local archive evidence landmark promoted into the production `object_icons` slot path
- keep its meaning tied to evidence and truth priority, not generic sacred-object use

## Hold For Later

### Character Full Runtime Promotion

Current state:

- character-specific battle art preference is now active for:
  - Rian
  - Serin
  - Bran
  - Tia
  - Enemy Raider
  - Enemy Skirmisher

Why not fully complete yet:

- character-specific art is active, but the full sprite-frame runtime lane is still mostly represented in dev preview and support surfaces
- additional hostile and specialist class coverage is still pending

## Recommended Promotion Order

1. forest production slot baseline
2. altar production slot baseline
3. forest tile source baseline
4. altar clean/integration baseline
5. forest variation second slot
6. shield support runtime set
7. extend character-specific battle art coverage to additional lanes

## Working Conclusion

The first assets that should be considered genuinely promoted are:

- forest runtime tile surfaces
- altar runtime object surface
- character-specific battle art preference for the current roster anchors

These are the safest and highest-value runtime promotions right now.
