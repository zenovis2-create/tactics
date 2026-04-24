# Field Lance 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current lance support image into a reusable runtime-facing equipment asset.

## Expected Source

When a chosen lance candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean lance asset that:

- has transparent background
- preserves shaft / head / grip separation
- stays disciplined and military
- can support loadout, support-card, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- long straight shaft silhouette
- readable narrow head
- visible grip-wrap zone
- one restrained accent only

Do not add:

- banners
- floating effects
- ceremonial side blades

## Step 3. Tighten Value Separation

- shaft must stay distinct from head
- head must read before the accent wrap
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned lance should support:

- equipment sheet
- loadout support surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `field_lance_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/field_lance_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `field_lance_01_equipment_v01.png`
- `field_lance_01_icon_v01.png`
- `field_lance_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/field_lance_01/runtime/`

## Acceptance Checklist

- background fully removed
- shaft, head, and grip remain distinct
- silhouette survives 128px reduction
- reads as military lance, not staff or halberd
- sits in the same world as sword, staff, bow, and shield support art
