# Sprite Anchor Tia Layered 8Dir Prompt Pack V01

## Purpose

This prompt pack defines Tia as a layered 8-direction ranged hunter lane.

The goal is not one finished composite sheet.

The goal is to produce separable layers for:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `upper_armor_overlay`

Optional:

- `shield_overlay`

## Use With

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-design.md`
- `/Volumes/AI/tactics/docs/style_bible.md`

## Shared Rules

Apply these rules to every prompt in this pack:

- classic tactical JRPG sprite-style character asset
- single-layer directional concept only, not a full composite sheet
- 8-direction coverage required
- clean line discipline
- restrained cel-style shading
- gameplay-scale readability first
- plain neutral or transparent background
- no text, no numbering, no labels
- no cinematic composition
- no oversized FX
- preserve ranged hunter read in every direction
- preserve forest skirmisher agility without drifting into rogue posture

## Layer 1: Base Body

```text
Use case: stylized-concept
Asset type: layered tactical RPG 8-direction character base
Primary request: generate Tia's base body layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: agile young female ranged hunter with compact tactical proportions, clear head and hair silhouette, alert expression, light-footed stance, readable body mass, no bow or swappable upper gear
Style/medium: classic tactical JRPG character base art, clean line discipline, restrained cel-style shading, soft painterly warmth without glossy anime polish
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, neutral background, centered
Lighting/mood: soft neutral lighting
Constraints: preserve ranged-hunter posture and readable body line; do not drift into assassin or dagger-user silhouette; no weapon, no shield, no heavy upper armor
Avoid: giant hood, dark rogue styling, heroic poster pose, text, numbering, background scenery
```

## Layer 2: Base Outfit

```text
Use case: stylized-concept
Asset type: layered tactical RPG outfit layer
Primary request: generate Tia's base outfit layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: light hunter clothing with stable asymmetry, lower-body cloth and boot silhouette suitable for a forest skirmisher, baseline identity clothing that should remain even when upper gear swaps
Style/medium: classic tactical JRPG character layer art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction views intended for an 8-view layered turnaround set, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: keep the lane clearly lighter than Rian and much lighter than Bran; preserve asymmetry in the base outfit instead of swappable armor; no bow, no shield, no giant cloak
Avoid: rogue leather fetish styling, bulky plate pieces, weapon silhouettes, text, numbering, scenery
```

## Layer 3: Weapon Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG equipment overlay
Primary request: generate Tia's bow overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: elegant but practical bow aligned for Tia's hand placement and stance, readable arc and string shape, consistent scale across all directions
Style/medium: classic tactical JRPG equipment overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction equipment overlays for an 8-view layered stack, centered on the same body alignment zone, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: bow overlay is required for combat-ready composite reads; preserve hunter read, not magical staff read; keep the overlay clean enough to compose over body and outfit
Avoid: oversized fantasy bow, glowing FX, extra hands, text, numbering, scenery
```

## Optional Layer: Upper Armor Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG armor overlay
Primary request: generate Tia's swappable upper hunter gear overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: light upper-body hunter gear that can sit over the base outfit without erasing its asymmetry, restrained shoulder or chest accents only, no heavy fighter mass
Style/medium: classic tactical JRPG armor overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction armor overlays for an 8-view layered stack, centered, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: this layer is only for swappable upper hunter gear; it must not carry the lane's core asymmetry or make Tia read as a heavy frontliner
Avoid: giant pauldrons, full chest shell, tank silhouette, text, numbering, scenery
```

## Optional Layer: Shield Overlay

This lane does not require a shield overlay.

If created later, it should be treated as optional and likely unused.
