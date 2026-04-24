# Minimum Integration Execution Order V01

## Purpose

This document converts the minimum asset set into a practical insertion order.

It answers:

1. what should be inserted first
2. where each asset should land
3. what each insertion step is supposed to prove

## Integration Strategy

Use this order:

1. replace the most visible and easiest-to-validate surfaces first
2. validate in Godot after each small batch
3. do not insert every new asset at once

## Phase 1. Character Proof Set

### Step 1. Insert Rian

Target surfaces:

- dev preview scenes first
- then battle unit visual stack if promoted

Source set:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime/`

What this proves:

- base frontline ally read
- sword-class readability
- sprite import and playback stability

### Step 2. Insert Serin

Target surfaces:

- dev preview scenes first
- then battle unit visual stack if promoted

Source set:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/runtime/`

What this proves:

- support-class readability
- cast-state readability
- ally class contrast beyond sword lane

### Step 3. Insert Bran

Target surfaces:

- dev preview scenes first
- then battle unit visual stack if promoted

Source set:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/runtime/`

What this proves:

- heavy-class differentiation
- shield-mass read
- class-width variation in the same ally roster

### Step 4. Insert Enemy Raider

Target surfaces:

- dev preview scenes first
- then hostile battle unit visual stack if promoted

Source set:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/runtime/`

What this proves:

- first hostile runtime lane
- ally/enemy posture separation
- battlefield team readability

## Phase 2. Terrain Proof Set

### Step 5. Insert Forest Tile 01

Target surfaces:

- integration preview
- any dev board preview using forest terrain

Source set:

- `/Volumes/AI/tactics/assets/environment/forest_tile_01/runtime/forest_tile_01_clean_v01.png`

What this proves:

- characters remain readable over a real terrain candidate
- first terrain anchor behaves as expected

### Step 6. Insert Forest Tile 02

Target surfaces:

- same preview surfaces as Forest Tile 01

Source set:

- `/Volumes/AI/tactics/assets/environment/forest_tile_02/runtime/forest_tile_02_clean_v01.png`

What this proves:

- terrain variation without style drift
- repetition relief on the board

## Phase 3. Objective Proof Set

### Step 7. Insert Altar 01

Target surfaces:

- integration preview
- object-icon trial surface if needed

Source sets:

- `/Volumes/AI/tactics/assets/props/altar_01/runtime/altar_01_clean_v01.png`
- `/Volumes/AI/tactics/assets/props/altar_01/runtime/altar_01_object_icon_v01.png`
- `/Volumes/AI/tactics/assets/props/altar_01/runtime/altar_01_integration_v01.png`

What this proves:

- objective prop readability
- sacred objective lane
- world object language before UI overlays

## Phase 4. Equipment-Support Proof Set

### Step 8. Insert Paladin Shield Support Surface

Target surfaces:

- integration preview support pass
- equipment-support reference surface
- later loadout support panel if promoted

Source sets:

- `/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_clean_v01.png`
- `/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_equipment_v01.png`
- `/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png`
- `/Volumes/AI/tactics/assets/props/paladin_shield/runtime/paladin_shield_icon_v01.png`

What this proves:

- equipment-support language belongs to the same world
- knight and heavy-class support art can share a consistent equipment baseline

## Validation After Each Phase

After each phase, check:

1. does the inserted asset improve the screen
2. does anything now feel out of family
3. is gameplay readability still stronger than decoration

## Stop Conditions

Pause the rollout if:

- a new sprite breaks class or team readability
- terrain starts overpowering sprites
- objective props need UI markers to be understood
- equipment support art feels like a different game

## Working Recommendation

Do not skip the order.

Character proof first, terrain second, objective third, equipment support last.
That is the shortest path to a believable playable slice.

