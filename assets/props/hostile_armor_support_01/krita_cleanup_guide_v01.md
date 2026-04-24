# Hostile Armor Support 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current hostile armor-support image into a reusable runtime-facing enemy equipment asset.

## Expected Source

When a chosen hostile armor-support candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean hostile armor asset that:

- has transparent background
- preserves chest / shoulder / strap separation
- stays coercive and rigid
- can support enemy dossier, loadout, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- readable chest block
- visible shoulder mass
- clear strap logic
- one restrained hostile accent only

Do not add:

- ally heraldry
- giant spikes
- glowing effects

## Step 3. Tighten Value Separation

- chest must stay distinct from straps
- shoulder mass must read before accent
- ember accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned armor should support:

- hostile equipment sheet
- enemy support surface
- future icon extraction

## Step 5. Export Clean Output

- `hostile_armor_support_01_clean_v01.png`

## Step 6. Prepare Runtime Derivatives

- `hostile_armor_support_01_equipment_v01.png`
- `hostile_armor_support_01_icon_v01.png`
- `hostile_armor_support_01_integration_v01.png`
