# Hostile Short Bow 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current hostile short-bow image into a reusable runtime-facing enemy equipment asset.

## Expected Source

When a chosen hostile short-bow candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean hostile bow asset that:

- has transparent background
- preserves arc / grip / string separation
- stays coercive and pursuit-led
- can support enemy dossier, loadout, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- compact hostile arc
- visible grip break
- readable string line
- one restrained hostile accent only

Do not add:

- glowing arrows
- ally-style decorative wraps
- heroic longbow extensions

## Step 3. Tighten Value Separation

- bow body must stay distinct from grip
- grip must read before accent
- ember accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned bow should support:

- hostile equipment sheet
- enemy support surface
- future icon extraction

## Step 5. Export Clean Output

- `hostile_short_bow_01_clean_v01.png`

## Step 6. Prepare Runtime Derivatives

- `hostile_short_bow_01_equipment_v01.png`
- `hostile_short_bow_01_icon_v01.png`
- `hostile_short_bow_01_integration_v01.png`
