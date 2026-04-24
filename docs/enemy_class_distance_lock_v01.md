# Enemy Class Distance Lock V01

## Purpose

This document locks the first internal separation rules for hostile battle-sprite classes.

It exists because the project now has more than one enemy lane:

- Enemy Raider
- Enemy Skirmisher

That is enough to stop designing enemies one-by-one and start defining enemy family rules.

## Scope

Applies to:

- hostile field infantry
- hostile skirmisher/ranged pressure units
- future enemy class anchors derived from these families

It does not yet define:

- named bosses
- magic-specialist enemy lanes
- large monster or late-game authority variants

## Shared Hostile Family Rules

All hostile units should share these traits:

- posture feels more compressed and procedural than allies
- silhouettes read as pressure, pursuit, or suppression rather than openness
- ember-red is a controlled accent, not a full-body fill
- line and shading stay in the same overall rendering family as the ally roster
- hostility must be legible before color is noticed

## Current Hostile Anchor Set

### Enemy Raider

Role:

- baseline hostile melee infantry
- pressure and suppression through rigid presence

Current sheet set:

- idle `v01`
- move `v01`
- attack `v01`

### Enemy Skirmisher

Role:

- lighter hostile pursuit unit
- faster pressure with a leaner silhouette

Current sheet set:

- idle `v01`
- move `v01`
- attack `v01`

## Core Distance Rules

### Raider vs Skirmisher

- Raider is heavier, blockier, and more shield- or wedge-led.
- Skirmisher is leaner, quicker, and more weapon-led.
- Raider should feel like line pressure.
- Skirmisher should feel like pursuit pressure.

### Hostile vs Ally Ranger

- Enemy skirmisher must not read like Tia recolored.
- Tia reads wary, human, asymmetrical, and forest-native.
- Enemy skirmisher reads disciplined, coercive, and authority-bound.

### Hostile vs Ally Frontline

- Rian and Bran read anchored and human.
- Hostile units read compressed, harsher, and less open in stance.
- Even when both carry blades, hostile units should not inherit ally calm.

## Enemy Matrix

| Enemy lane | Anchor | First-read job | Silhouette priority | Accent family | Motion read |
| --- | --- | --- | --- | --- | --- |
| hostile melee infantry | Enemy Raider | line pressure | compact block, shield or rigid upper wedge, short blade | ember red | controlled, pressing, procedural |
| hostile skirmisher | Enemy Skirmisher | pursuit pressure | lean frame, lighter ranged tool, compressed aggressive angle | ember red | quicker, lighter, disciplined |

## Failure Cases

Reject a hostile sheet if:

- it reads like an ally recolor
- it needs the red accent to feel hostile
- skirmisher and raider collapse into one silhouette family
- the unit becomes too stylish, glamorous, or rogue-like
- the rendering finish breaks away from the ally roster family

## Immediate Use

Use this document when:

- generating the next hostile class lane
- reviewing whether an enemy feels too close to an ally lane
- deciding whether a new enemy belongs under `raider-family` or `skirmisher-family`

## Use With

- `/Volumes/AI/tactics/docs/character_class_silhouette_color_matrix_v01.md`
- `/Volumes/AI/tactics/docs/character_sprite_style_lock_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/`

