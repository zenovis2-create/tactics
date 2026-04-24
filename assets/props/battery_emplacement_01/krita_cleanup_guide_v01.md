# Battery Emplacement 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current battery-emplacement image into a reusable runtime-facing chapter prop.

## Expected Source

When a chosen battery-emplacement candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean fortress landmark asset that:

- has transparent background
- preserves base / frame / firing-direction separation
- stays siege-first and mechanism-second
- can support chapter map previews, landmark cards, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- readable base mass
- visible firing frame
- clear front-facing direction
- one restrained accent only

Do not add:

- blast effects
- fantasy muzzle fire
- decorative chain clutter

## Step 3. Tighten Value Separation

- base must stay distinct from the firing frame
- firing frame must read before the accent
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned battery should support:

- chapter landmark sheet
- map integration surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `battery_emplacement_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/battery_emplacement_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `battery_emplacement_01_landmark_v01.png`
- `battery_emplacement_01_icon_v01.png`
- `battery_emplacement_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/battery_emplacement_01/runtime/`

## Acceptance Checklist

- background fully removed
- base, frame, and threat direction remain distinct
- silhouette survives 128px reduction
- reads as battery emplacement, not cart or gate device
- sits in the same world as fortress tiles and CH02 military landmarks
