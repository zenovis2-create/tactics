# Altar 01 Krita Cleanup Guide V01

## Purpose

This guide converts the current altar candidate into a runtime-friendly battlefield objective asset.

Source candidate:

- `/Volumes/AI/tactics/assets/props/altar_01/source/altar_01_source_v02.png`

## Current Problem

The current image reads correctly as a sacred objective, but it is still a candidate illustration.

Why:

- the white paper-like background is still attached
- the object needs a cleaner runtime silhouette
- local glow and base shadow need to be controlled for in-engine placement

## Cleanup Goal

Produce a cleaned altar asset that:

- has transparent background
- reads as an objective before any UI marker
- can sit on the board without looking pasted from concept art

## Step 1. Remove Background

- cut away the white paper texture completely
- keep only the altar mass and the minimal grounding shadow needed for contact with the board

## Step 2. Preserve The Objective Read

Keep:

- stable base
- top slab structure
- focal relic housing
- controlled sacred accent

Do not let cleanup flatten the altar into generic stone furniture.

## Step 3. Reduce Nonessential Softness

- trim any excessive outer haze
- keep edges crisp enough to function as a gameplay prop
- preserve readability at small scale

## Step 4. Control Accent Brightness

- the sacred focal point should remain visible
- the accent must not become a giant glow blob
- the object should still read as important if the glow is muted

## Step 5. Export Runtime Candidate

Export:

- `altar_01_clean_v01.png`

Store it under:

- `/Volumes/AI/tactics/assets/props/altar_01/clean/`

## Step 6. Prepare Runtime Derivatives

Later exports may include:

- object icon version
- integration preview version
- larger concept support version

Suggested names:

- `altar_01_clean_v01.png`
- `altar_01_object_icon_v01.png`
- `altar_01_integration_v01.png`

## Acceptance Checklist

- background fully removed
- altar still reads as a sacred objective
- focal top element remains visible
- local glow is controlled
- runtime silhouette is cleaner than the raw concept candidate

