# Sprite Anchor Serin Layered 8Dir Prompt Pack V01

## Purpose

This prompt pack generates the first layered 8-direction production set for
`Sprite Anchor Serin`.

The goal is not to produce one finished character sheet.

The goal is to produce separable layers for:

- `base_body`
- `base_outfit`
- `weapon_overlay`

Optional only if justified:

- `shield_overlay`
- `upper_armor_overlay`

## Use With

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/layered_8dir_production_brief_v01.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-plan.md`
- `/Volumes/AI/tactics/docs/style_bible.md`

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
- preserve support/healer first and caster second
- preserve calm posture and staff-compatible hand/body alignment

## Layer 1: Base Body

```text
Use case: stylized-concept
Asset type: layered tactical RPG 8-direction character base
Primary request: generate Serin's base body layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: composed young support-caster with compact tactical proportions, readable face and hair silhouette, calm posture, soft body mass, no staff and no swappable gear overlays
Style/medium: classic tactical JRPG character base art, clean line discipline, restrained cel-style shading, soft painterly warmth without glossy anime polish
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, neutral stance, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: preserve healer/support read through posture and gentler silhouette, not through FX; keep the body compatible with a later staff overlay; no shield, no armor shell, no oversized robe flare
Avoid: aggressive battle pose, offensive mage posture, full robe identity baked into the body, text, numbering, scenery, extra props
```

## Layer 2: Base Outfit

```text
Use case: stylized-concept
Asset type: layered tactical RPG outfit layer
Primary request: generate Serin's base outfit layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: support/healer robe base with stable lower-body cloth and calm outer contour, preserving Serin's core support identity while leaving swappable upper gear separate
Style/medium: classic tactical JRPG character layer art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: robe identity must live here, not in upper armor; preserve support/healer first, caster second; keep the silhouette clean and not blob-like
Avoid: full armor shell, giant mantle, combat-mage aggression, giant floating cloth, weapon silhouettes, text, numbering, scenery
```

## Layer 3: Weapon Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG equipment overlay
Primary request: generate Serin's staff overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: compact staff aligned for Serin's hand placement and calm support posture, readable but not oversized, consistent scale and orientation across all directions
Style/medium: classic tactical JRPG equipment overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction equipment overlays for an 8-view layered stack, centered on the same body alignment zone, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: the staff is required and must read as support gear first, not a destructive battle staff; maintain direction-appropriate angle; clean composition over the base body and outfit
Avoid: giant wizard staff, glowing spell FX, motion trails, extra hands, text, numbering, scenery
```

## Optional Layer: Shield Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG equipment overlay
Primary request: generate an optional light shield overlay for Serin only if a support-gear proof case is explicitly needed, across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: small defensive support shield, restrained scale, secondary to staff and support posture
Style/medium: classic tactical JRPG equipment overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction equipment overlays for an 8-view layered stack, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: the shield must remain optional, light, and secondary; do not let it take over Serin's identity
Avoid: tank shield mass, heavy defender read, giant heraldry, text, numbering, scenery
```

## Optional Layer: Upper Armor Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG armor overlay
Primary request: generate Serin's optional upper support-gear overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: light swappable upper-body support gear only, such as a modest shoulder or chest support piece that composes over the robe base without replacing it
Style/medium: classic tactical JRPG armor overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction armor overlays for an 8-view layered stack, full-body alignment, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: this layer must stay secondary to the robe identity; it must not become the whole support silhouette; keep it lighter and quieter than fighter armor
Avoid: full robe replacement, bulky chest shell, giant pauldrons, armored battlemage read, text, numbering, scenery
```
