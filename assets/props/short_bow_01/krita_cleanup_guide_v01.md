# Short Bow 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current bow support image into a reusable runtime-facing equipment asset.

## Expected Source

When a chosen bow candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean bow asset that:

- has transparent background
- preserves arc / grip / string separation
- stays practical and ranger-led
- can support loadout, support-card, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- clear bow arc silhouette
- visible grip break
- readable string line
- one restrained accent only

Do not add:

- arrows
- floating effects
- excessive leaf or antler ornament

## Step 3. Tighten Value Separation

- bow body must stay distinct from grip
- grip must read separately from the arc
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned bow should support:

- equipment sheet
- loadout support surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `short_bow_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/short_bow_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `short_bow_01_equipment_v01.png`
- `short_bow_01_icon_v01.png`
- `short_bow_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/short_bow_01/runtime/`

## Acceptance Checklist

- background fully removed
- arc, grip, and string remain distinct
- silhouette survives 128px reduction
- reads as field bow, not staff or branch
- sits in the same world as field sword, sacred staff, and Tia-class art
