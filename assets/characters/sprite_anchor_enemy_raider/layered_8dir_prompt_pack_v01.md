# Sprite Anchor Enemy Raider Layered 8Dir Prompt Pack V01

## Purpose

This prompt pack defines the layered 8-direction hostile baseline contract for
`Sprite Anchor Enemy Raider`.

The goal is not to produce one finished enemy sheet.

The goal is to produce separable layers for:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `upper_armor_overlay`

Optional in the first hostile baseline:

- `shield_overlay`

## Use With

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/layered_8dir_production_brief_v01.md`
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
- preserve hostile melee pressure in every direction
- preserve rigid infantry posture and ember-red enemy cue
- do not drift toward ally warmth or generic bandit looseness

## Anchor Rule

Image generation should follow:

- anchor sheet first
- all variants derived from anchor
- consistency beats speed

Do not trust independent layer generation as final production truth.

## Layer 1: Base Body

```text
Use case: stylized-concept
Asset type: layered tactical RPG 8-direction enemy base
Primary request: generate Enemy Raider's base body layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: hostile melee infantry raider with compact tactical proportions, compressed aggressive posture, rigid upper-body angle, readable face and body mass, strong enemy silhouette without weapon or armor overlays
Style/medium: classic tactical JRPG character base art, clean line discipline, restrained cel-style shading, readable gameplay-scale silhouette
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: preserve hostile melee pressure first and rigid authority infantry second; preserve enemy read through stance and body attitude alone; no weapon, no shield, no upper armor shell
Avoid: ally warmth, generic bandit slouch, heroic poster posing, giant FX, text, numbering, scenery
```

## Layer 2: Base Outfit

```text
Use case: stylized-concept
Asset type: layered tactical RPG 8-direction outfit layer
Primary request: generate Enemy Raider's base outfit layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: hostile infantry under-cloth and lower-body outfit with controlled enemy mass, stable cloth and boot silhouette, restrained ember-red cue, no weapon, no shield, no swappable upper armor shell
Style/medium: classic tactical JRPG character layer art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: preserve enemy hostility without decorative hero styling; keep lower-body read stable; remain harsher and more rigid than ally lanes
Avoid: noble tabard, heroic cape, generic rogue looseness, oversized chest armor, text, numbering, scenery
```

## Layer 3: Weapon Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG equipment overlay
Primary request: generate Enemy Raider's melee weapon overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: compact threatening melee weapon aligned for enemy-raider hand placement and stance, readable at tactical scale, directionally correct across all eight views
Style/medium: classic tactical JRPG equipment overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction equipment overlays for an 8-view layered stack, centered on the same body alignment zone, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: weapon should read dangerous but not fantastical; maintain compact hostile infantry scale; compose cleanly over body and outfit layers
Avoid: giant fantasy blade, glow trails, fire FX, extra hands, text, numbering, scenery
```

## Layer 4: Upper Armor Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG armor overlay
Primary request: generate Enemy Raider's upper armor overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: hostile infantry upper-body armor including chest armor and shoulder armor with controlled mass, harsher and more rigid than ally gear, but lighter than a heavy defender shell
Style/medium: classic tactical JRPG armor overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction armor overlays for an 8-view layered stack, full-body alignment, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: preserve melee pressure and enemy authority; armor must compose cleanly over base outfit; maintain compact silhouette and no noble knight read
Avoid: full-body tank shell, luxury trim, massive pauldrons, decorative cape burst, text, numbering, scenery
```

## Optional Layer: Shield Overlay

This lane does not require a shield overlay in the first hostile baseline pass.

If one is generated later, it should remain subordinate to the raider's melee
pressure read rather than replacing it.
