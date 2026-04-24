# Resin Shrine 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current resin-shrine image into a reusable runtime-facing chapter prop.

## Expected Source

When a chosen resin-shrine candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean forest landmark asset that:

- has transparent background
- preserves shrine / focal plane / marker separation
- stays hidden-landmark-first and altar-second
- can support chapter map previews, landmark cards, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- readable shrine base
- visible focal plane
- clear upright marker
- one restrained accent only

Do not add:

- crystal masses
- chain clutter
- cathedral trim

## Step 3. Tighten Value Separation

- base must stay distinct from the marker
- focal plane must read before the accent
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned shrine should support:

- chapter landmark sheet
- map integration surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `resin_shrine_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/resin_shrine_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `resin_shrine_01_landmark_v01.png`
- `resin_shrine_01_icon_v01.png`
- `resin_shrine_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/resin_shrine_01/runtime/`

## Acceptance Checklist

- background fully removed
- base, focal plane, and marker remain distinct
- silhouette survives 128px reduction
- reads as forest shrine, not altar or stump clutter
- sits in the same world as Greenwood tiles and CH03 trap-language landmarks
