# Split Marker Post 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current split-marker-post image into a reusable runtime-facing chapter prop.

## Expected Source

When a chosen split-marker-post candidate is placed in:

- `source/`

use this guide to produce the clean and runtime outputs.

## Cleanup Goal

Produce a clean pursuit-landmark asset that:

- has transparent background
- preserves post / marker arm / accent separation
- stays route-guidance-first and clutter-second
- can support chapter map previews, landmark cards, and icon surfaces

## Step 1. Remove Background

- keep full transparency
- remove all paper, glow, and framing
- do not keep drop-shadow haze beyond a minimal contact-softening edge

## Step 2. Preserve Major Structure

Keep:

- readable vertical post
- visible directional arm
- clear base footing
- one restrained accent only

Do not add:

- banner clusters
- shrine clutter
- branch noise fields

## Step 3. Tighten Value Separation

- post must stay distinct from the marker arm
- marker arm must read before the accent
- accent must stay tertiary

## Step 4. Prepare Reusable Output

The cleaned route marker should support:

- chapter landmark sheet
- map integration surface
- future icon extraction

That means the silhouette must remain clean and centered.

## Step 5. Export Clean Output

Export:

- `split_marker_post_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/split_marker_post_01/clean/`

## Step 6. Prepare Runtime Derivatives

Current derivatives:

- `split_marker_post_01_landmark_v01.png`
- `split_marker_post_01_icon_v01.png`
- `split_marker_post_01_integration_v01.png`

Store these under:

- `/Volumes/AI/tactics/assets/props/split_marker_post_01/runtime/`

## Acceptance Checklist

- background fully removed
- post, marker arm, and accent remain distinct
- silhouette survives 128px reduction
- reads as route marker, not shrine or branch clutter
- sits in the same world as CH08 pursuit pressure and split-lane landmarks
