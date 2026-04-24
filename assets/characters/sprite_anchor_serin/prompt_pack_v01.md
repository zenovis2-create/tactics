# Sprite Anchor Serin Prompt Pack V01

## Purpose

This prompt pack generates the first production-facing concept sheets for `Sprite Anchor Serin`.
The goal is not final polish. The goal is to lock silhouette, proportion, class readability,
and action grammar for the 2D sprite lane.

Use this with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/spec.md`
- `/Volumes/AI/tactics/docs/character_sprite_pipeline.md`
- `/Volumes/AI/tactics/docs/style_bible.md`

## Shared Rules

Apply these rules to every prompt in this pack:

- classic tactical JRPG sprite-sheet feel
- chibi-adjacent tactical proportion
- clean line discipline
- restrained cel-style shading
- gameplay-scale readability first
- transparent or plain neutral background
- no text, no numbering, no speech bubbles
- no cinematic composition
- no glossy modern anime finish
- no giant FX that hide the body

---

## 1. Idle Sheet

### Goal

Generate a baseline idle loop sheet that locks the body silhouette and support-class read.

### Prompt

```text
Use case: stylized-concept
Asset type: tactical RPG character sprite sheet
Primary request: idle animation sheet for a support healer mystic named Serin, designed for a classic tactical JRPG battle sprite pipeline
Subject: young female support mystic with compact chibi-adjacent tactical proportions, slightly enlarged head, soft pale silver-lilac hair, calm gentle expression, short sacred staff
Style/medium: classic tactical JRPG sprite-sheet concept art, clean line discipline, restrained cel-style shading, soft painterly warmth without glossy anime polish
Composition/framing: full-body gameplay sprite sheet on a plain neutral or transparent background, front-facing battle orientation, consistent frame-to-frame body scale, 8-frame idle loop concept
Lighting/mood: soft neutral lighting, readable silhouette, no dramatic rim light
Color palette: warm white robe, muted ash-violet accents, pale silver-lilac hair, brown boots, small restrained violet magic hint only if needed
Materials/textures: simple cloth robe layers, leather boots, wooden sacred staff, small gem or ward accent
Constraints: support/healer class must read before magic; body silhouette must remain readable without effects; robe and hair masses must stay simple; staff head should remain visible at gameplay scale
Avoid: giant spell circles, neon purple glow, overdesigned costume trim, live-service anime gloss, dense hair rendering, dramatic motion, text, panel numbers, background scenery
```

---

## 2. Cast Sheet

### Goal

Generate a cast sequence where Serin gathers support magic without losing her body read.

### Prompt

```text
Use case: stylized-concept
Asset type: tactical RPG character sprite sheet
Primary request: casting animation sheet for a support healer mystic named Serin, designed for a classic tactical JRPG battle sprite pipeline
Subject: compact female support mystic with short sacred staff, calm focused face, soft pale silver-lilac hair, healer/support role
Style/medium: classic tactical JRPG sprite-sheet concept art, clean line discipline, restrained cel-style shading, soft painterly warmth, readable gameplay-scale character animation
Composition/framing: full-body gameplay sprite sheet on a plain neutral or transparent background, front-facing battle orientation, 10 to 12 frame cast sequence, starting from still stance and building into a controlled support spell pose
Lighting/mood: soft neutral lighting, magic read should come from shape and value separation rather than glow intensity
Color palette: warm white robe, muted ash-violet details, pale silver-lilac hair, restrained violet support magic with sacred white accents
Materials/textures: simple cloth robe, wood staff, small sacred gem accent
Constraints: body silhouette must remain readable in every frame; support magic should build gradually; staff and hands must stay clear; FX should support the animation but not dominate it; spell feel should suggest healing or warding, not destructive attack magic
Avoid: giant full-screen magic circle, explosive combat pose, neon purple overload, attack-mage aggression, excessive particles, cinematic angles, text, numbered panels, background scenery
```

---

## 3. Attack Sheet

### Goal

Generate a restrained light attack or sacred bolt release that still fits Serin's support identity.

### Prompt

```text
Use case: stylized-concept
Asset type: tactical RPG character sprite sheet
Primary request: light attack animation sheet for a healer-support mystic named Serin, designed for a classic tactical JRPG battle sprite pipeline
Subject: compact female support mystic with short sacred staff, composed expression, soft pale silver-lilac hair, gentle but battle-capable posture
Style/medium: classic tactical JRPG sprite-sheet concept art, clean line discipline, restrained cel-style shading, readable gameplay-scale battle animation
Composition/framing: full-body gameplay sprite sheet on a plain neutral or transparent background, front-facing battle orientation, 8-frame light attack sequence, staff-guided sacred bolt release
Lighting/mood: soft neutral lighting, readable projectile timing, no dramatic stage lighting
Color palette: warm white robe, muted ash-violet accents, pale silver-lilac hair, restrained violet-white projectile energy
Materials/textures: cloth robe, wood staff, small sacred gem head
Constraints: attack must still feel like a support-class light attack, not a heavy artillery spell; projectile should be compact and readable; body silhouette and staff angle must stay consistent; the sprite should remain clean enough for Godot frame slicing
Avoid: beam cannon scale FX, huge recoil pose, explosive battlefield destruction, neon glow spam, overdone particles, text, panel numbers, background scenery
```

---

## 4. Optional Combined Sheet

### Goal

Generate one overview sheet for fast direction validation before per-state refinement.

### Prompt

```text
Use case: stylized-concept
Asset type: tactical RPG character action overview sheet
Primary request: overview sheet for a support healer mystic named Serin showing idle, cast, and light attack states for a classic tactical JRPG battle sprite pipeline
Subject: compact female support mystic, pale silver-lilac hair, warm white and muted ash-violet robe, short sacred staff
Style/medium: classic tactical JRPG sprite-sheet concept art, clean line discipline, restrained cel-style shading, readable gameplay-scale animation design
Composition/framing: one plain overview sheet on neutral background, grouped action rows for idle, cast, and attack, no text or numbering, consistent front-facing gameplay orientation
Lighting/mood: neutral production-sheet lighting
Color palette: warm white, ash-violet, brown, pale hair, restrained violet-white support magic
Constraints: preserve support-class identity across all states; keep body silhouette readable in every frame; use simple and reusable FX language
Avoid: polished poster presentation, cinematic composition, giant FX, background scenery, labels, modern anime gloss
```

