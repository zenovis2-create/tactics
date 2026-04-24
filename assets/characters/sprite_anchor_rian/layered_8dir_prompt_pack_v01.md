# Sprite Anchor Rian Layered 8Dir Prompt Pack V01

## Purpose

This prompt pack generates the first layered 8-direction production set for
`Sprite Anchor Rian`.

The goal is not to produce one finished character sheet.

The goal is to produce separable layers for:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `upper_armor_overlay`

Optional in this pilot:

- `shield_overlay`

## Use With

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/layered_8dir_production_brief_v01.md`
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
- preserve Rian's command read in every direction

## Current Regeneration Rule

Do not use these prompts as prompt-only full-sheet regeneration.

The next approved Rian regeneration pass must use:

- `source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`
- `source/8dir/masked_edit_v01/masks/rian_weapon_overlay_mask_v01.png`
- `source/8dir/masked_edit_v01/masks/rian_upper_armor_overlay_mask_v01.png`

Generate one layer at a time. Preserve the black/protected mask region and edit
only the white target region.

## Layer 1: Base Body

```text
Use case: stylized-concept
Asset type: layered tactical RPG 8-direction character base
Primary request: generate Rian's base body layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: composed young male frontline commander with compact chibi-adjacent tactical proportions, slightly enlarged head, alert expression, stable stance, readable body mass, visible face and hair silhouette, no weapon or armor overlays
Style/medium: classic tactical JRPG character base art, clean line discipline, restrained cel-style shading, soft painterly warmth without glossy anime polish
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, neutral stance, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: preserve frontline command and light sword leadership through posture alone; maintain stable shoulder line and grounded stance; no sword, no shield, no visible upper armor layer
Avoid: heavy knight mass, heroic poster posing, text, numbering, background scenery, extra props
```

## Layer 2: Base Outfit

```text
Use case: stylized-concept
Asset type: layered tactical RPG 8-direction outfit layer
Primary request: generate Rian's base outfit layer across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: minimal command cloth base for a frontline swordsman, under-cloth and lower-body outfit that supports tactical readability, stable mantle split only if it is identity-essential and not gear-swappable, no weapon, no shield, no swappable upper armor mass
Style/medium: classic tactical JRPG character layer art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction views intended for an 8-view layered turnaround set, full-body, centered, plain neutral background
Lighting/mood: soft neutral lighting
Constraints: preserve Rian's command identity without locking in swappable gear; keep lower-body cloth and boot silhouette clear; keep the read lighter than Bran
Avoid: ornate coat, bulky plate chest armor, giant cape flare, weapon silhouettes, background scenery, text, numbering
```

## Layer 3: Weapon Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG equipment overlay
Primary request: generate Rian's sword overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: one-handed tactical sword aligned for Rian's hand placement and stance, compact but readable, consistent scale across all directions
Style/medium: classic tactical JRPG equipment overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction equipment overlays for an 8-view layered stack, centered on the same body alignment zone, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: the sword must remain readable but lighter than knight gear; maintain direction-appropriate angle; keep the overlay clean enough to compose over the base body and outfit
Avoid: giant fantasy blade, glowing slash effects, oversized motion trail, extra hands, text, numbering, scenery
```

### Masked Edit Addendum

Use `rian_weapon_overlay_mask_v01.png`.

Constrain edits to the sword and hilt region only. Preserve Rian's face, body,
outfit, stance, and non-weapon gear from the official visual reference.

## Layer 4: Upper Armor Overlay

```text
Use case: stylized-concept
Asset type: layered tactical RPG armor overlay
Primary request: generate Rian's upper armor overlay across front, front-right, right, back-right, back, back-left, left, and front-left views
Subject: swappable upper-body gear for a frontline commander, including chest armor and shoulder armor with controlled tactical mass, lighter than Bran's heavy defender armor
Style/medium: classic tactical JRPG armor overlay art, clean line discipline, restrained cel-style shading
Composition/framing: single-direction armor overlays for an 8-view layered stack, full-body alignment, plain neutral or transparent background
Lighting/mood: soft neutral lighting
Constraints: preserve command read without turning the overlay into a heavy knight shell; armor must compose cleanly over the base outfit; maintain stable shoulder width in every direction
Avoid: full-body armor replacement, giant pauldrons, luxury trim, cape explosion, text, numbering, scenery
```

### Masked Edit Addendum

Use `rian_upper_armor_overlay_mask_v01.png`.

Constrain edits to compact chest and shoulder armor only. Preserve Rian's face,
hair, stance, command cloth, lower outfit, weapon position, and ally-side
identity from the official visual reference.

## Optional Layer: Shield Overlay

This pilot does not require a shield overlay.

If one is generated later, treat it as optional support only and do not let it
take over Rian's core read.
