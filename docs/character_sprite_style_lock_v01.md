# Character Sprite Style Lock V01

## Purpose

This document locks the shared visual rules for the 2D battle-sprite lane after the first
comparison pass between:

- Serin support-caster anchor
- Rian frontline-swordsman anchor

It exists to stop future sprite work from drifting character-by-character.

## Scope

Applies to:

- playable battle sprites
- enemy battle sprites
- class-anchor sprite sheets
- combat-state sheets such as idle, move, cast, attack, and hit

Does not directly define:

- portraits
- map props
- tile cards
- environment landmark kits

## Style Summary

The chosen lane is:

- classic tactical JRPG battle-sprite grammar
- chibi-adjacent tactical proportions
- restrained cel-style shading
- low-to-mid saturation palette
- soft painterly warmth without glossy anime finish

## Locked Shared Rules

### 1. Value Range

- Sprites should stay inside a subdued world palette.
- Bright units are allowed, but not washed-out units.
- Support units may be lighter than frontline units, but still need enough internal contrast to survive gameplay scale.

### 2. Silhouette Order

Every sprite must follow this read priority:

1. body
2. equipment or signature prop
3. FX

If FX becomes the dominant silhouette, the frame fails review.

### 3. Line And Edge Discipline

- Outer contour must stay clear at gameplay scale.
- Internal costume separation should remain readable without becoming noisy.
- Soft classes may use gentler line rhythm, but not blurred edges.

### 4. Color Discipline

- No neon spell color by default.
- No rainbow accent spread inside one character.
- Class distinction should come from silhouette and gear first, color second.

### 5. Motion Discipline

- Idle should be subtle but visible.
- Move should feel tactical, not acrobatic.
- Attack should feel efficient, not poster-like.
- Cast should feel controlled, not explosive.

### 6. FX Discipline

- FX is support information, not the main character read.
- Support/caster effects must remain smaller and cleaner than offensive-mage spectacle.
- A frame should still identify the class with FX removed.

## Class-Lane Adjustments

### Support / Mystic Lane

Use Serin as the current anchor.

- slightly lighter palette is acceptable
- robe and staff must stay readable
- facial softness is allowed
- internal contrast must still be strong enough for gameplay scale
- staff and sleeves need clearer separation than the current weakest support examples

### Frontline / Sword Lane

Use Rian as the current anchor.

- stronger shoulder and weapon read
- firmer outer contour
- stable grounded stance
- no oversized knight mass unless the unit is explicitly a heavy class

## Comparative Findings That Are Now Locked

From the Serin / Rian comparison:

- Rian's equipment split and contour strength are a good baseline for readability.
- Serin's palette and softness are valid, but support units need stronger robe/staff separation than the weakest early outputs.
- Ranged or magical effects must never overpower the body.
- Frontline units should not become too dark and uniform.
- Support units should not become too bright and low-contrast.

## Failure Cases

Reject a sprite sheet if:

- the FX reads before the character
- the character only reads because of color, not silhouette
- the face and body drift in scale across frames
- attack/cast poses feel like poster art instead of gameplay animation
- a support unit reads like a generic child mage
- a frontline unit reads like a generic armored villager

## Current Production Baseline

### Serin

- Idle baseline: `v02`
- Cast baseline: `v03`
- Attack baseline: `v03`

### Rian

- Idle baseline: `v01`
- Move baseline: `v01`
- Attack baseline: `v01`

These are baseline candidates, not permanent final-lock assets.

## Use With

- `/Volumes/AI/tactics/docs/style_bible.md`
- `/Volumes/AI/tactics/docs/character_sprite_pipeline.md`
- `/Volumes/AI/tactics/docs/production/character_visual_identity_pack.md`
- `/Volumes/AI/tactics/assets/templates/sprite_character/spec.md`

