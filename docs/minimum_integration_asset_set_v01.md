# Minimum Integration Asset Set V01

## Purpose

This document defines the smallest art set that should be inserted into the game first.

The goal is not to finish the whole art backlog.
The goal is to choose the smallest set of assets that will make the game stop feeling
like a prototype and start feeling like one coherent tactical RPG slice.

## Selection Principle

An asset belongs in the minimum set if it does one or more of the following:

1. appears constantly in real gameplay
2. proves the visual language of a full class lane
3. proves the objective / interaction language
4. proves terrain readability
5. upgrades a highly visible placeholder surface

## Minimum Character Set

### 1. Rian

Why:

- main protagonist line
- frontline ally read
- visible in most tests and screenshots

Current baseline:

- idle `v01`
- move `v01`
- attack `v01`

### 2. Serin

Why:

- support and cast lane baseline
- proves non-melee ally readability
- critical for party variety in screenshots

Current baseline:

- idle `v02`
- cast `v03`
- attack `v03`

### 3. Bran

Why:

- heavy class anchor
- proves shield-mass differentiation
- important for “not just one body type” validation

Current baseline:

- idle `v02`
- move `v02`
- attack `v02`

### 4. Enemy Raider

Why:

- first hostile production lane
- necessary for ally/enemy distance
- needed for a real battlefield read

Current baseline:

- idle `v01`
- move `v01`
- attack `v01`

## Minimum Environment Set

### 1. Forest Tile 01

Why:

- first true terrain anchor
- common readability test against sprites
- needed for actual board feel

Current runtime candidate:

- `forest_tile_01_clean_v01.png`

### 2. Forest Tile 02

Why:

- breaks repetition
- proves that terrain can support variation without style drift

Current runtime candidate:

- `forest_tile_02_clean_v01.png`

### 3. Altar 01

Why:

- first objective / sacred interaction read
- proves interactable prop language without UI-only dependence

Current runtime candidates:

- `altar_01_clean_v01.png`
- `altar_01_integration_v01.png`
- `altar_01_object_icon_v01.png`

## Minimum Equipment-Support Set

### 1. Paladin Shield

Why:

- first equipment-support prop anchor
- supports knight and heavy-class identity
- useful for loadout, support art, and integration previews

Current runtime candidates:

- `paladin_shield_clean_v01.png`
- `paladin_shield_integration_v01.png`
- `paladin_shield_equipment_v01.png`
- `paladin_shield_icon_v01.png`

## Not In The Minimum Set Yet

These are important, but not needed for the first integration pass:

- Tia full runtime insertion
- second hostile lane beyond Enemy Raider
- expanded map landmark packs
- final UI icon replacement sweep
- full chapter-specific terrain families
- polished spell FX sheets

## Recommended First Insertion Order

1. Rian
2. Serin
3. Bran
4. Enemy Raider
5. Forest Tile 01
6. Forest Tile 02
7. Altar 01
8. Paladin Shield support surface

## What This Set Proves

If this set is inserted successfully, the project proves:

- ally and enemy sprite lanes coexist
- melee / support / heavy class reads are stable
- terrain does not swallow the sprites
- objectives read before UI markers
- equipment support art belongs to the same world

## Working Conclusion

This is the smallest set that should enter the game first.

Anything beyond this is expansion.
This set is foundation.

