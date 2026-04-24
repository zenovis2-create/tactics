# Sprite Anchor Rian Krita Cleanup Guide V01

## Purpose

This guide explains how to turn the current Rian source sheets into stable clean sheets before runtime slicing.

Use with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/rian_idle_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/rian_move_sheet_source_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/rian_attack_sheet_source_v01.png`

Use together with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime_manifest_v01.md`
- `/Volumes/AI/tactics/docs/clean_pass_production_guide_v01.md`

## Goal

Produce clean Rian sheets that:

- keep a shared frame box and stable foot pivot
- preserve sword-led frontline readability
- keep Rian distinct from Bran's heavier silhouette
- reduce cloak or mantle drift that weakens the command read

## Step 1. Lock Shared Framing

- use one frame box size across `idle`, `move`, and `attack`
- keep the foot-center pivot stable
- do not crop each frame independently

## Step 2. Stabilize The Command Silhouette

Prioritize:

- sword angle consistency
- shoulder width consistency
- short mantle or cloth split consistency

Rian should read as disciplined frontline command, not as a generic villager swordsman.

## Step 3. Reduce Noise

- remove numbering and poster-like layout marks
- reduce any soft concept haze behind the body
- keep weapon trail minimal or remove it if it overstates the action

## Step 4. Protect Class Distance

Rian must remain:

- lighter than Bran
- firmer than Serin
- less asymmetrical than Tia

If cleanup increases armor mass too much, pull it back.

## Step 5. Export Clean Sheets

Export:

- `clean/rian_idle_clean_v01.png`
- `clean/rian_move_clean_v01.png`
- `clean/rian_attack_clean_v01.png`

## Acceptance Checklist

- same frame box across all states
- same foot pivot across all states
- sword remains readable at gameplay scale
- mantle split supports identity without becoming noisy
- silhouette does not drift toward Bran's heavy defender mass
