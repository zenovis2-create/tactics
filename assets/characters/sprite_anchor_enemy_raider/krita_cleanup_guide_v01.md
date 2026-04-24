# Sprite Anchor Enemy Raider Krita Cleanup Guide V01

## Purpose

This guide explains how to turn the current Enemy Raider source sheets into stable clean sheets before runtime slicing.

Use with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/source/enemy_raider_idle_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/source/enemy_raider_move_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/source/enemy_raider_attack_sheet_source_v01.png`

Use together with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/runtime_manifest_v01.md`
- `/Volumes/AI/tactics/docs/clean_pass_production_guide_v01.md`

## Goal

Produce clean Enemy Raider sheets that:

- keep a shared frame box and stable foot pivot
- preserve hostile posture before color
- keep ember-red accent restrained and secondary
- maintain clear distance from ally frontline silhouettes

## Step 1. Lock Shared Framing

- use one frame box size across `idle`, `move`, and `attack`
- keep the foot-center pivot stable
- do not trim frames independently

## Step 2. Preserve Hostile Body Language

Prioritize:

- compressed forward posture
- rigid shoulder and chest shape
- controlled weapon angle

The unit must read as hostile before the red accent is noticed.

## Step 3. Control Accent Spread

- keep red accent small and deliberate
- remove glow or splash that lets color do the whole job
- reduce any ally-like softness in the face or stance

## Step 4. Remove Source Artifacts

- remove numbering and poster-like arrangement marks
- remove background residue
- clean duplicated or broken edge fragments

## Step 5. Export Clean Sheets

Export:

- `clean/enemy_raider_idle_clean_v01.png`
- `clean/enemy_raider_move_clean_v01.png`
- `clean/enemy_raider_attack_clean_v01.png`

## Acceptance Checklist

- same frame box across all states
- same foot pivot across all states
- hostile read survives with color muted
- red accent remains restrained
- silhouette does not drift toward ally swordsman language
