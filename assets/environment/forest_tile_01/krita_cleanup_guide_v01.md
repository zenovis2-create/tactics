# Forest Tile 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current forest tile candidate into a runtime-friendly battlefield asset.

Source candidate:

- `/Volumes/AI/tactics/assets/environment/forest_tile_01/source/forest_tile_01_source_v02.png`

## Current Problem

The current image works as a visual candidate, but not yet as a clean runtime terrain asset.

Why:

- it still reads like a small diorama illustration
- the white paper-like background is still attached
- edge softness and depth treatment are stronger than a repeatable tile should be

## Cleanup Goal

Produce a cleaned terrain tile that:

- has transparent background
- keeps only the usable tile mass
- remains readable under unit sprites
- can repeat on a board without looking like pasted concept art

## Step 1. Remove Background

- delete the white paper background completely
- keep only the tile mass and any grounded local shadow that is necessary
- do not leave pale paper texture around the tile

## Step 2. Tighten The Silhouette

- keep the root and foliage clusters
- reduce any overly soft outer haze
- clean the edge so the tile reads as a deliberate runtime asset, not a painted illustration fragment

## Step 3. Reduce Depth Noise

- simplify small leaf clusters if they become visual noise
- preserve the main root arcs and central traversable ground
- keep center readability stronger than decorative edge density

## Step 4. Keep Unit Safety

The tile must not overpower character sprites.

Check:

- central path area remains readable
- roots and greenery support the edge read, not the whole tile read
- values are dark enough to differ from plain ground, but not so dark that units disappear

## Step 5. Export Runtime Candidate

Export:

- `forest_tile_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/environment/forest_tile_01/clean/`

## Step 6. Prepare Runtime Derivatives

Later exports may include:

- tile card version
- tile icon version
- integration preview version

Suggested names:

- `forest_tile_01_clean_v01.png`
- `forest_tile_01_tile_card_v01.png`
- `forest_tile_01_tile_icon_v01.png`
- `forest_tile_01_integration_v01.png`

## Acceptance Checklist

- background fully removed
- silhouette clean enough for runtime use
- central area still looks traversable
- edge clusters still imply forest cover
- unit sprites remain more important than tile detail

