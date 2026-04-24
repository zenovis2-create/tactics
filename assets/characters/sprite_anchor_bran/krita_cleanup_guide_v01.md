# Sprite Anchor Bran Krita Cleanup Guide V01

## Purpose

This guide explains how to turn the current Bran source sheets into stable clean sheets before runtime slicing.

Use with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/source/bran_idle_sheet_source_v02.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/source/bran_move_sheet_source_v02.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/source/bran_attack_sheet_source_v02.png`

Use together with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/runtime_manifest_v01.md`
- `/Volumes/AI/tactics/docs/clean_pass_production_guide_v01.md`

## Goal

Produce clean Bran sheets that:

- keep a shared frame box and stable foot pivot
- preserve shield-first heavy-defender readability
- keep Bran clearly heavier than Rian
- prevent armor detail from growing noisier than the silhouette

## Step 1. Lock Shared Framing

- use one frame box size across `idle`, `move`, and `attack`
- keep the foot-center pivot stable
- do not trim frames independently

## Step 2. Preserve Shield Dominance

Prioritize:

- shield size consistency
- shoulder width consistency
- grounded heavy stance

The shield must stay more important than the sword.

## Step 3. Remove Structural Noise

- remove numbering and poster-like marks
- remove soft background residue
- reduce armor edge clutter if it starts to read as texture noise

## Step 4. Protect Ally Hierarchy

Bran must remain:

- heavier than Rian
- less ornamental than a boss lane
- readable without magic or impact effects

Do not let cleanup turn him into a generic detailed knight sheet.

## Step 5. Export Clean Sheets

Export:

- `clean/bran_idle_clean_v01.png`
- `clean/bran_move_clean_v01.png`
- `clean/bran_attack_clean_v01.png`

## Acceptance Checklist

- same frame box across all states
- same foot pivot across all states
- shield remains the dominant class signal
- silhouette stays broader and heavier than Rian
- armor mass reads cleanly without texture clutter
