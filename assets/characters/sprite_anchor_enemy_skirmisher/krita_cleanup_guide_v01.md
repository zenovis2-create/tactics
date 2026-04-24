# Sprite Anchor Enemy Skirmisher Krita Cleanup Guide V01

## Purpose

This guide explains how to turn the current Enemy Skirmisher source sheets into stable clean sheets before runtime slicing.

Use with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/source/enemy_skirmisher_idle_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/source/enemy_skirmisher_move_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/source/enemy_skirmisher_attack_sheet_source_v01.png`

Use together with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/runtime_manifest_v01.md`
- `/Volumes/AI/tactics/docs/clean_pass_production_guide_v01.md`

## Goal

Produce clean Enemy Skirmisher sheets that:

- keep a shared frame box and stable foot pivot
- preserve lean hostile skirmisher readability
- maintain distance from Tia's ally-ranger silhouette
- keep the weapon-led attack clear without relying on large FX

## Step 1. Lock Shared Framing

- use one frame box size across `idle`, `move`, and `attack`
- keep the foot-center pivot stable
- do not trim frames independently

## Step 2. Preserve The Lean Hostile Read

Prioritize:

- light weapon silhouette consistency
- compressed pursuit posture
- clear separation from ally-ranger softness

The unit should read as faster and lighter than Enemy Raider, but still clearly hostile.

## Step 3. Control Color And FX

- keep hostile red restrained
- remove oversized attack effects
- do not let action trails replace the weapon read

## Step 4. Remove Source Artifacts

- remove numbering and poster-like arrangement marks
- remove background residue
- clean duplicated or broken edge fragments

## Step 5. Export Clean Sheets

Export:

- `clean/enemy_skirmisher_idle_clean_v01.png`
- `clean/enemy_skirmisher_move_clean_v01.png`
- `clean/enemy_skirmisher_attack_clean_v01.png`

## Acceptance Checklist

- same frame box across all states
- same foot pivot across all states
- hostile read survives before color is noticed
- unit stays lighter than Enemy Raider
- silhouette does not drift toward Tia's ally-ranger language
