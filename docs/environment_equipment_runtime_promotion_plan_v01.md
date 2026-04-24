# Environment And Equipment Runtime Promotion Plan V01

## Purpose

This document defines the next promotion phase for non-character art surfaces.

The character lane is now mature enough that environment and equipment surfaces are the primary bottleneck for screen quality.

This plan focuses on:

- terrain promotion
- interactable prop promotion
- equipment-support promotion

## Current Runtime Reality

### Already Promoted

- forest production tile card baseline
- forest production tile icon baseline
- altar production object icon baseline

### Runtime-Ready Candidates

- Forest Tile 01 clean / integration / tile-card / tile-icon
- Forest Tile 02 clean / integration / tile-card / tile-icon
- Altar 01 clean / integration / object icon
- Paladin Shield clean / integration / equipment / icon

## Promotion Philosophy

Promote non-character assets in this order:

1. surfaces that directly affect gameplay readability
2. surfaces that appear frequently
3. surfaces that support class identity

Do not promote based on visual novelty alone.

## Tier 1: Promote First

### Forest Terrain Family

Why:

- terrain appears constantly
- terrain directly changes whether characters remain readable
- one forest tile is never enough for a believable board

Immediate actions:

1. keep `forest` production tile card and icon active
2. prepare `forest_tile_02` as the second usable forest family variant
3. choose how the project will rotate or swap between forest variants on board surfaces

### Sacred Objective Family

Why:

- objective props must read before markers
- altar language is now good enough to define the sacred/objective lane

Immediate actions:

1. keep `altar` object icon active
2. preserve `altar_01_clean_v01` and `altar_01_integration_v01` as the source baseline
3. use altar as the reference for future sacred objective props

### Mechanical Objective Family

Why:

- altar alone is not enough to define interaction language
- the game needs a second objective family that reads as machinery, not ritual

Immediate actions:

1. preserve `lever_01_clean_v01` as the baseline mechanical interaction prop
2. use `lever_01_object_icon_v01` and the active production `lever.png` surface as the first mechanical object-icon support baseline
3. validate altar vs lever contrast in fortress-like previews
4. use `gate_control_01` as the next route/system-control machinery family
5. validate altar / lever / gate-control coexistence in sacred-machinery mixed previews

## Tier 2: Promote Next

### Equipment-Support Family

Why:

- the shield now supports knight/heavy identity
- equipment is visible in UI and support surfaces even if not yet a direct gameplay prop

Immediate actions:

1. preserve `paladin_shield_clean_v01` as source baseline
2. use the camp/interlude presentation card as the first live destination for `paladin_shield_integration_v01`
3. use `paladin_shield_icon_v01` only when an actual equipment-support icon surface is ready

## Tier 3: Expand After Tier 1 Is Stable

### Terrain Variety

Needed:

- one more terrain family beyond forest

Best candidates:

- plain-family reinforcement
- stone/fortress-family reinforcement
- sacred-floor family

Current active next-step candidate:

- `fortress_tile_01`

Current family status:

- `fortress_tile_01`
- `fortress_tile_02`
- `fortress_edge_01`

### Objective Variety

Needed:

- one second objective family beyond altar

Best candidates:

- lever family
- gate-control family
- evidence-table family

Current active baseline split:

- `altar_01`: sacred objective
- `lever_01`: mechanical interaction
- `gate_control_01`: route/system-control machinery

### Equipment Variety

Needed:

- sword-family support surface
- secondary shield variant

Current active support expansion:

- `field_sword_01`

## Recommended Next Actions

### Action 1

Decide how `forest_tile_02` should be introduced:

- as a production swap
- as a second board candidate only
- as a map-specific visual variant

### Action 2

Expand the mechanical objective lane:

- keep `lever_01` as the baseline
- next likely addition: `gate_control_01`
- keep `gate_control.png` as the first real production object-slot destination for route/system-control machinery

### Action 3

Create one more equipment-support prop:

- recommended: `field_sword_01`

## What Not To Do Yet

- large environmental overhauls
- cinematic background scenes
- late-game monumental environment families
- store art pass

Those should wait until the Tier 1 surfaces are fully trusted in runtime.

## Working Conclusion

The current best environment/equipment strategy is:

- stabilize forest
- stabilize altar
- stabilize lever
- keep fortress as a map-specific terrain family, now with more than one tile
- choose the first real equipment-support destination
- only then expand breadth
