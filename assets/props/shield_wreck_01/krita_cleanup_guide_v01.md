# Shield Wreck 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current shield-wreck image into a reusable runtime-facing chapter prop.

## Expected Source

When a chosen shield-wreck candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean siege landmark asset that:

- has transparent background
- preserves slab / break / brace separation
- stays cover-first and debris-second
- can support chapter map previews, landmark cards, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- readable defensive slab
- visible break edge
- clear brace logic
- one restrained accent only

Do not add:

- trophy clutter
- spike forests
- rubble clouds

## Step 3. Tighten Value Separation

- slab must stay distinct from the braces
- break edge must read before the accent
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned wreck should support:

- chapter landmark sheet
- map integration surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `shield_wreck_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/shield_wreck_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `shield_wreck_01_landmark_v01.png`
- `shield_wreck_01_icon_v01.png`
- `shield_wreck_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/shield_wreck_01/runtime/`

## Acceptance Checklist

- background fully removed
- slab, break edge, and braces remain distinct
- silhouette survives 128px reduction
- reads as cover wreck, not generic rubble
- sits in the same world as CH06 siege pressure and fortified ground
