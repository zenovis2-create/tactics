# Heavy Armor Support 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current heavy-armor support image into a reusable runtime-facing equipment asset.

## Expected Source

When a chosen heavy-armor candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean armor asset that:

- has transparent background
- preserves chest / shoulder / strap separation
- stays broad and defense-led
- can support loadout, support-card, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- broad cuirass silhouette
- readable shoulder mass
- visible strap logic
- one restrained accent only

Do not add:

- capes
- giant spikes
- parade trim

## Step 3. Tighten Value Separation

- plate must stay distinct from straps
- shoulder mass must read before the accent
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned armor should support:

- equipment sheet
- loadout support surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `heavy_armor_support_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/heavy_armor_support_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `heavy_armor_support_01_equipment_v01.png`
- `heavy_armor_support_01_icon_v01.png`
- `heavy_armor_support_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/heavy_armor_support_01/runtime/`

## Acceptance Checklist

- background fully removed
- chest, shoulder, and straps remain distinct
- silhouette survives 128px reduction
- reads as heavy armor, not shield slab or statue fragment
- sits in the same world as shield, sword, and anchor-knight support art
