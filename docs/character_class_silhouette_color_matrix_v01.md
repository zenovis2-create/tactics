# Character Class Silhouette And Color Matrix V01

## Purpose

This document turns the current sprite-anchor work into a reusable class matrix.
It defines how each major class lane should differentiate itself through silhouette,
value, color, and motion priority before any fine detail is added.

Current anchor set:

- Serin: support / healer / mystic
- Rian: frontline / command swordsman
- Tia: ranger / skirmisher / ranged hunter
- Bran: heavy knight / wall defender
- Enemy Raider: hostile melee infantry / pursuit soldier

## Global Rule

Every class must be recognizable in this order:

1. body silhouette
2. signature equipment
3. motion pattern
4. color family
5. FX

If a class relies on FX before silhouette or gear, the design is off.

## Class Matrix

| Class lane | Anchor | Silhouette priority | Signature gear read | Value tendency | Accent family | Motion read |
| --- | --- | --- | --- | --- | --- | --- |
| support / healer / mystic | Serin | robe column, soft hair mass, compact staff profile | short sacred staff | lighter than average, but not washed out | ash-violet / restrained sacred white | calm, controlled, supportive |
| frontline / command swordsman | Rian | shoulder line, grounded torso, compact mantle split | one-handed sword | mid-to-dark stable values | ash blue / muted navy | efficient, deliberate, grounded |
| ranger / skirmisher / ranged hunter | Tia | bow curve, asymmetry, lean upper shape | bow + quiver | mid values with sharper dark grouping | muted forest green | agile, quiet, hunter-like |
| heavy knight / wall defender | Bran | shield mass, broad shoulder block, compact heavy stance | large shield + short sword | darker and heavier than frontline, but still readable | muted fortress blue | weighty, controlled, defensive |
| hostile melee infantry / pursuit soldier | Enemy Raider | compressed hostile block, rigid upper shape, shield-or-guard wedge | short sword + hostile shield read | dark neutral values with harder accent contrast | ember red | pressuring, disciplined, hostile |

## Support / Healer / Mystic Rules

### Silhouette

- Keep the body compact and vertical.
- Robe or cloth should reinforce a stable support read.
- Staff silhouette must remain visible in idle and action states.

### Value

- May sit lighter than frontline units.
- Internal separation must still survive gameplay scale.
- Avoid turning the body into a bright low-contrast blob.

### Color

- Ash-violet and restrained sacred white are preferred.
- Purple may exist, but neon purple is disallowed.
- Gold should stay ceremonial and small.

### Motion

- Casting reads as controlled buildup, not explosive release.
- Attack reads as a light sacred action, not artillery.
- Idle should feel calm and steady.

## Frontline / Command Swordsman Rules

### Silhouette

- Broadest upper-body read among the non-heavy classes.
- Sword and shoulder line must stay clear.
- Cloth break should support leadership identity, not dominate the body.

### Value

- Mid-to-dark values with clear armor and cloth separation.
- Avoid full-body dark uniformity.
- Steel and cloth should remain separable.

### Color

- Muted navy or ash-blue command accent.
- Avoid hero-red spotlighting.
- Avoid luxury gold trim dominance.

### Motion

- Move reads tactical, not athletic.
- Attack reads efficient and compact.
- Idle reads alert and burdened, not relaxed.

## Ranger / Skirmisher / Ranged Hunter Rules

### Silhouette

- Leaner than frontline, less vertical than support.
- Bow curvature is a major identity tool.
- Use asymmetry deliberately: hood break, shoulder break, strap cluster, or quiver silhouette.

### Value

- Mid values with sharper dark grouping than support.
- Keep enough separation between hood, face, and torso.
- Do not let the silhouette collapse into one dark cloak mass.

### Color

- Muted forest green and earth browns are preferred.
- Green should stay subdued and practical.
- Avoid saturated “magical forest” reads.

### Motion

- Move reads agile but controlled.
- Attack reads hunter-like and direct.
- Avoid magical or spectacle-heavy projectile language.

## Heavy Knight / Wall Defender Rules

### Silhouette

- Shield must be a first-read mass.
- Broadest upper-body read among current ally anchors.
- The body should feel planted and compact, not tall.

### Value

- May sit darker than frontline swordsmen.
- Armor and cloth still need readable separation.
- Avoid turning the whole sprite into one dark iron blob.

### Color

- Muted fortress-blue is preferred for cloth accent.
- Keep metal, leather, and cloth clearly separated.
- Avoid luxury-paladin ornament unless the unit is explicitly a ceremonial variant.

### Motion

- Movement reads weighty and steady.
- Attack reads practical and shield-line efficient.
- The class should feel defensive even when attacking.

## Hostile Melee Infantry / Pursuit Soldier Rules

### Silhouette

- Posture should feel compressed and disciplined.
- Upper-body block should read more rigid than ally frontline units.
- Shield or guard wedge should support the hostile read when present.

### Value

- Darker neutral grouping is acceptable.
- Avoid unreadable full-black armor masses.
- Hostile silhouettes must remain readable without relying on red alone.

### Color

- Ember red is a hostile accent, not a full-body fill.
- Red should stay controlled around cloth, seal, or trim zones.
- Avoid ally gold, sacred white, or hopeful blue accents.

### Motion

- Move reads like pressure and pursuit.
- Attack reads harsh and efficient.
- Avoid heroic flourish or ally-like openness.

## Inter-Class Distance Rules

### Support vs Frontline

- Support is staff-led and calmer.
- Frontline is shoulder-and-blade-led and firmer.
- They must never be differentiated by color alone.

### Frontline vs Ranger

- Frontline uses mass and stability.
- Ranger uses asymmetry and bow curve.
- Ranger should never read like “lighter knight.”

### Frontline vs Heavy Knight

- Frontline uses sword and stance as the main read.
- Heavy knight uses shield and width as the main read.
- Heavy knight should not just be “Rian with more armor.”

### Heavy Knight vs Support

- Heavy knight reads blocky and protective.
- Support reads vertical and gentle.
- Their silhouettes should separate before color is even noticed.

### Ally vs Hostile Infantry

- Allies read more open, anchored, and human.
- Hostile infantry reads more rigid, compressed, and procedural.
- Hostility should be visible through posture and shape before the ember-red accent is noticed.

### Hostile Infantry vs Heavy Knight

- Heavy knight reads protective and fortress-like.
- Hostile infantry reads coercive and pursuit-oriented.
- If both carry shields, the ally shield should feel stabilizing while the enemy shield feels imposing or suppressive.

### Support vs Ranger

- Support reads vertical and composed.
- Ranger reads angled and ready to reposition.
- Support uses softer palette family; ranger uses earthier palette family.

## Failure Cases

Reject a class sheet if:

- the silhouette could belong to another lane with a recolor
- the weapon or prop is too small to matter
- all dark shapes merge at gameplay scale
- support uses oversized offensive FX
- frontline uses overly cute or overly clean support-style read
- ranger becomes a generic hooded blob

## Current Baseline Picks

### Serin

- Idle: `v02`
- Cast: `v03`
- Attack: `v03`

### Rian

- Idle: `v01`
- Move: `v01`
- Attack: `v01`

### Tia

- Idle: `v02`
- Move: `v01`
- Attack: `v02`

### Bran

- Idle: `v02`
- Move: `v02`
- Attack: `v02`

### Enemy Raider

- Idle: `v01`
- Move: `v01`
- Attack: `v01`

These are current style-lock candidates for class-lane comparison.

## Use With

- `/Volumes/AI/tactics/docs/character_sprite_pipeline.md`
- `/Volumes/AI/tactics/docs/character_sprite_style_lock_v01.md`
- `/Volumes/AI/tactics/docs/style_bible.md`
- `/Volumes/AI/tactics/docs/enemy_class_distance_lock_v01.md`
