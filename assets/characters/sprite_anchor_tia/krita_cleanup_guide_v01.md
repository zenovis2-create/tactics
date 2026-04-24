# Sprite Anchor Tia Krita Cleanup Guide V01

## Purpose

This guide explains how to turn the current Tia source sheets into stable clean sheets before runtime slicing.

Use with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/source/tia_idle_sheet_source_v02.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/source/tia_move_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/source/tia_attack_sheet_source_v02.png`

Use together with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/runtime_manifest_v01.md`
- `/Volumes/AI/tactics/docs/clean_pass_production_guide_v01.md`

## Goal

Produce clean Tia sheets that:

- keep a shared frame box and stable foot pivot
- preserve clear bow-led ranged readability
- keep the ranger asymmetry controlled and intentional
- prevent the lane from drifting into rogue glamour or FX dependence

## Step 1. Lock Shared Framing

- use one frame box size across `idle`, `move`, and `attack`
- keep the foot-center pivot stable
- do not trim each frame independently

## Step 2. Protect The Ranged Hook

Prioritize:

- bow size consistency
- bow angle consistency
- hood or shoulder asymmetry consistency

The bow must stay readable before any projectile or effect does.

## Step 3. Remove Visual Spill

- remove numbering and arrangement marks
- reduce any background residue
- remove overlong motion smears or FX tails if they blur the body

## Step 4. Keep Ally Distance

Tia must remain:

- leaner than Rian
- less magical than Serin
- clearly non-hostile compared with enemy skirmisher

Do not let cleanup create assassin-like coolness or sharpen the costume into noise.

## Step 5. Export Clean Sheets

Export:

- `clean/tia_idle_clean_v01.png`
- `clean/tia_move_clean_v01.png`
- `clean/tia_attack_clean_v01.png`

## Acceptance Checklist

- same frame box across all states
- same foot pivot across all states
- bow remains visible at gameplay scale
- asymmetrical ranger read stays controlled
- sprite does not depend on projectile or trail FX to explain the class
