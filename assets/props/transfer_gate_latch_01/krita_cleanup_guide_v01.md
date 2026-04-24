# Transfer Gate Latch 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current transfer-gate-latch image into a reusable runtime-facing chapter prop.

## Expected Source

When a chosen transfer-gate-latch candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean pursuit-landmark asset that:

- has transparent background
- preserves latch / release arm / bracket separation
- stays route-release-first and clutter-second
- can support chapter map previews, landmark cards, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- readable latch body
- visible release arm
- clear support bracket
- one restrained accent only

Do not add:

- gate-frame clutter
- shrine decoration
- gear nests

## Step 3. Tighten Value Separation

- latch body must stay distinct from the arm
- release arm must read before the accent
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned latch should support:

- chapter landmark sheet
- map integration surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `transfer_gate_latch_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/transfer_gate_latch_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `transfer_gate_latch_01_landmark_v01.png`
- `transfer_gate_latch_01_icon_v01.png`
- `transfer_gate_latch_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/transfer_gate_latch_01/runtime/`

## Acceptance Checklist

- background fully removed
- latch, arm, and bracket remain distinct
- silhouette survives 128px reduction
- reads as route latch, not gate-control recolor or clutter
- sits in the same world as CH08 pursuit pressure and split-line landmarks
