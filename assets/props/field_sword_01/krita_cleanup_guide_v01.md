# Field Sword 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current sword support image into a reusable runtime-facing equipment asset.

## Expected Source

When a chosen sword candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean sword asset that:

- has transparent background
- preserves blade / guard / grip / pommel separation
- stays practical and grounded
- can support loadout, support-card, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- straight blade silhouette
- compact crossguard
- visible grip wrap break
- distinct pommel

Do not add:

- secondary blades
- floating effects
- ceremonial tassels

## Step 3. Tighten Value Separation

- blade must stay brighter than grip
- guard must read separately from blade
- navy accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned sword should support:

- equipment sheet
- loadout support surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `field_sword_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/field_sword_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `field_sword_01_equipment_v01.png`
- `field_sword_01_icon_v01.png`
- `field_sword_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/field_sword_01/runtime/`

## Acceptance Checklist

- background fully removed
- blade, guard, grip, and pommel remain distinct
- silhouette survives 128px reduction
- reads as field equipment, not relic weapon
- sits in the same world as paladin shield and frontline unit art
