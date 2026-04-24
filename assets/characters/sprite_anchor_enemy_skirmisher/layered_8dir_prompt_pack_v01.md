# Sprite Anchor Enemy Skirmisher Layered 8Dir Prompt Pack V01

## Purpose

This prompt pack generates the first layered 8-direction production set for
`Sprite Anchor Enemy Skirmisher`.

The goal is not to produce one finished character sheet.

The goal is to produce separable layers for:

- `base_body`
- `base_outfit`
- `weapon_overlay`

Optional only if justified:

- `upper_armor_overlay`
- `shield_overlay`

This lane must remain subordinate to the anchor-first rule.

## Use With

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-design.md`
- `/Volumes/AI/tactics/docs/style_bible.md`

## Anchor Rule

Do not promote generated layers as production truth until this anchor exists:

- `source/8dir/anchor/enemy_skirmisher_anchor_8dir_sheet_source_v01.png`

All layered outputs are expected to be derived from that frozen anchor once it
is available.

## Shared Rules

Apply these rules to every prompt in this pack:

- classic tactical JRPG sprite-style character layer
- single-layer directional concept only, not a final composite sheet
- 8-direction coverage required
- clean line discipline
- restrained cel-style shading
- gameplay-scale readability first
- plain neutral or transparent background
- no text, no numbering, no labels
- no cinematic composition
- no oversized FX
- preserve hostile agile threat first and pursuit hunter second
- do not drift toward ally-ranger softness

## Layer 1: Base Body

```text
Use case: stylized-concept
Asset type: layered tactical RPG 8-direction character base
Primary request: generate Enemy Skirmisher base body across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: hostile agile ranged skirmisher with compact tactical proportions, lean body mass, compressed aggressive posture, readable face and hair silhouette, clear enemy intent, no weapon and no swappable upper gear overlays
Style/medium: classic tactical JRPG character base art, clean line discipline, restrained cel-style shading, soft painterly warmth without glossy anime polish
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: preserve hostile agile threat through posture and silhouette alone; body must remain lighter than defender lanes; no bow, no shield, no visible upper armor shell
Avoid: ally-hero calmness, generic rogue poster posing, heavy knight mass, text, numbering, scenery, extra props
```

## Layer 2: Base Outfit

```text
Use case: stylized-concept
Asset type: layered tactical RPG outfit layer
Primary request: generate Enemy Skirmisher base outfit across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: hostile hunter cloth base with mobile lower-body silhouette and readable enemy-side outfit contour, keeping the skirmisher read distinct from Tia and leaving swappable upper gear separate
Style/medium: classic tactical JRPG character layer art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: preserve pursuit-hunter hostility without turning into an ally hunter; keep the lower-body read mobile and predatory; avoid bulky armor mass
Avoid: ornate hero cloth, ally-ranger softness, full armor shell, giant mantle, weapon silhouettes, text, numbering, scenery
```

## Layer 3: Weapon Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG equipment overlay
Primary request: generate Enemy Skirmisher ranged-weapon overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: compact hostile ranged weapon aligned for the skirmisher's hand placement and aggressive posture, readable but not oversized, consistent scale across all directions
Style/medium: classic tactical JRPG equipment overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction equipment overlays for an 8-view layered stack, centered on the same body alignment zone, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: the weapon is required and must preserve ranged-threat read; keep it cleaner and more disposable than a hero weapon; maintain direction-appropriate angle
Avoid: giant fantasy bow or crossbow, glowing FX, motion trails, extra hands, text, numbering, scenery
```

## Optional Layer: Upper Armor Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG armor overlay
Primary request: generate optional Enemy Skirmisher upper gear overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: restrained enemy upper-body reinforcement such as light shoulder or chest gear that composes over the base outfit without replacing the lane identity
Style/medium: classic tactical JRPG armor overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction armor overlays for an 8-view layered stack, full-body alignment, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: keep this layer secondary; do not let it create defender mass; do not let it erase the hostile agile silhouette
Avoid: full-body armor replacement, giant pauldrons, heavy knight shell, text, numbering, scenery
```

## Optional Layer: Shield Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG equipment overlay
Primary request: generate an optional light shield overlay for Enemy Skirmisher only if a specific proof case requires it, across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: small secondary shield with restrained scale, clearly subordinate to the ranged-weapon read and agile posture
Style/medium: classic tactical JRPG equipment overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction equipment overlays for an 8-view layered stack, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: shield must remain optional, light, and secondary; it must not turn the skirmisher into a defender
Avoid: tank shield mass, heraldic front-liner read, giant guard plate, text, numbering, scenery
```
