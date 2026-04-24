# Character Anchor Knight Prompt Pack V01

## Purpose

This prompt pack is the first source-image generation bundle for the `character_anchor_knight` lane.

It is meant to generate the first `source` images for the world-scale human anchor.

## Primary Generation Target

- asset: `character_anchor_knight`
- use case: `stylized-concept`
- output target:
  - `front`
  - `side`
  - `3/4`
- intended use:
  - source image generation
  - Rhino blockout reference
  - style-anchor review

## Master Prompt

```text
Use case: stylized-concept
Asset type: tactical RPG character modeling sheet
Primary request: worn veteran knight character for an original tactical RPG, intended as the visual anchor for the entire asset set
Scene/background: plain neutral studio background, no scenery, no props except the equipped sword and shield
Subject: male veteran knight, short dark hair, clean-shaven, restrained and tired expression, heavy armor, one-handed sword and large shield
Style/medium: painterly diorama-style stylized 3D concept art, original hybrid style inspired by classic tactical RPG readability
Composition/framing: full body character sheet with front view, strict side view, and 3/4 view; neutral stance; readable turnaround for modeling
Lighting/mood: soft studio lighting, readable forms, no dramatic rim light
Color palette: muted iron gray, dark worn leather, deep navy accent cloth
Materials/textures: worn steel plate armor, leather straps, cloth tabard accent, large shield with one simple heraldic focal point
Constraints: medium stylized proportions between chibi and realistic; slightly larger head; broad shoulders; compact legs; heavy armor; large readable silhouette; minimal fine detail; clear material separation; must read clearly at zoomed-out combat-map scale
Avoid: photorealism, anime prettiness, elaborate filigree, thin chains, tiny ornaments, oversized cape motion, busy background, extreme pose, excessive glow, overdesigned weapon, decorative clutter
```

## Variant A

Use when the master prompt produces too much ornament or too much heroic glamor.

```text
Same subject and turnaround, but reduce ornament, reduce facial glamor, make the armor more practical, more worn, and more military. Prioritize silhouette clarity and shield readability over style flourishes.
```

## Variant B

Use when the master prompt produces something too plain or under-designed.

```text
Same subject and turnaround, but strengthen the deep navy cloth accent, slightly reinforce the central shield heraldic focal point, and make veteran wear more visible without adding micro-detail.
```
