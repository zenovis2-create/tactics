# Evac Handcart 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current evacuation-handcart image into a reusable runtime-facing chapter prop.

## Expected Source

When a chosen evacuation-handcart candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean escort prop that:

- has transparent background
- preserves cart / wheel / handle / bundle separation
- stays rescue-first and civilian-first
- can support chapter map previews, escort cards, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- readable cart body
- visible wheels
- handle direction
- one restrained accent only

Do not add:

- market clutter
- treasure contents
- military cargo

## Step 3. Tighten Value Separation

- wood body must stay distinct from bundles
- wheel read must survive before the accent
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned cart should support:

- chapter prop sheet
- map integration surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `evac_handcart_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/evac_handcart_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `evac_handcart_01_object_v01.png`
- `evac_handcart_01_icon_v01.png`
- `evac_handcart_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/evac_handcart_01/runtime/`

## Acceptance Checklist

- background fully removed
- body, wheels, handles, and bundles remain distinct
- silhouette survives 128px reduction
- reads as civilian handcart, not merchant wagon or military cart
- sits in the same world as CH01 rescue and investigation props
