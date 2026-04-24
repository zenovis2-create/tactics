# Sprite Anchor Serin Spec

## Identity

- Asset ID: `sprite_anchor_serin_01`
- Working name: `Sprite Anchor Serin`
- Character type: playable
- Class or archetype: healer / support mystic
- Chapter or faction: early ally roster, sacred-field support lane

## Purpose

- Primary use: establish the 2D battle-sprite production standard for the playable roster
- Runtime surface: battle sprite, spell-cast sequence baseline, portrait-support reference
- Production role: style anchor for support and caster-class sprites

## Sprite Pipeline Mode

- Production mode: 2D sprite sheet
- Source method: AI concept -> Krita cleanup -> Godot sprite import
- Proportion target: chibi-adjacent tactical sprite, cleaner and softer than enemy units
- Camera read target: battle-map first, close-up support second

## Visual Summary

- One-sentence pitch: a calm sacred-field support caster who reads as gentle and reliable before her magic appears
- Emotional read: restraint, compassion, steadiness
- First-read silhouette: compact robe body, short staff, soft hair mass, small sacred accent shapes
- Must-read class signal: healer-support mystic rather than offensive mage

## Style Rules

- Line character: clean and consistent, slightly soft, not sketchy
- Shading style: restrained cel-style shading with limited painterly softening
- Detail budget: low-to-medium; all costume reads must survive gameplay scale
- Chibi/stylization level: classic tactical JRPG sprite, slightly enlarged head, compact body
- Forbidden polish: glossy anime highlights, hyper-detailed hair strands, luxury ornament, overblown magical spectacle in idle frames

## Proportion

- Head size note: slightly oversized for emotional clarity at combat scale
- Torso note: compact torso with robe layers simplified into clear major shapes
- Leg note: short legs and clear boot read
- Hand / weapon exaggeration: staff head may be slightly enlarged for class readability

## Loadout

- Primary weapon: light sacred staff
- Secondary item: no shield
- Shield:
- Signature prop: small ward-light or restrained support magic ring in cast frames

## Material And Color Plan

- Primary materials: soft robe cloth, leather boots, wood staff, pale trim
- Accent material: restrained sacred gem or ward-ring light
- Base palette: warm white, muted ash-violet, pale silver-lilac hair, soft leather brown
- Accent color: soft violet-lilac magic, with controlled sacred white highlights
- Forbidden colors: neon purple, saturated pink-magenta overload, glossy gold luxury trim

## Animation Set

- Required states: `idle`, `cast`, `attack`, `hit`
- Minimum states: `idle`, `cast`
- One-shot actions: `cast`, `attack`, `hit`
- Looping actions: `idle`
- FX handled in character sheet or separated: separate major FX from body wherever possible; keep body silhouette readable without the FX

## Sheet Layout

- Required views or framing: front-facing gameplay sprite sequence only
- Sheet type: action sheet plus anchor idle sheet
- Target frame count: 8-frame idle, 12-frame cast, 8-frame light attack baseline
- Background: transparent or plain neutral backdrop during concept stage
- Transparent export needed: yes

## Runtime Readability

- Zoomed-out read goal: instantly distinguish support/caster unit from knight and ranger classes
- Token/icon implication: head silhouette and staff head should remain identifiable in token-size derivatives
- Failure conditions: reads like generic child mage, robe becomes a white blob, staff vanishes at small scale, magic effect overwhelms the body

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: classic tactical RPG support mystic sprite sheet, calm healer girl with compact proportions, soft robe layers, short sacred staff, restrained violet support magic, clean background, readable gameplay-scale silhouette
- Must include: compact support silhouette, readable staff, gentle expression, restrained magic buildup, classic tactical sprite grammar
- Must avoid: live-service anime gloss, cinematic effects, giant spell circle dominating every frame, overdesigned costume, excessive idle motion

## Krita Notes

- Cleanup tasks: unify face size, hand size, and robe edge thickness across frames
- Separation tasks: place major spell ring, projectile, and impact FX on separate layers where practical
- Text removal or label cleanup: remove any accidental lettering or numbered panel artifacts from generated sheets
- Frame consistency risks: drifting head size, inconsistent staff angle, violet FX value overpowering the face

## Godot Notes

- Import target: battle character sprite sheet
- Sprite slicing plan: slice by frame with fixed frame box and fixed pivot near foot center
- Animation names: `idle`, `cast`, `attack`, `hit`
- Loop/non-loop notes: only `idle` loops by default
- Test scene: battle scene with forest, plain, and cathedral tiles plus ally/enemy units for scale comparison

## Review Checklist

- Does Serin read as support first and caster second?
- Do idle frames work without relying on magical FX?
- Is the staff visible and class-defining at gameplay scale?
- Are robe and hair masses stable across frames?
- Does the sprite belong to the same world as the current UI, tokens, and map palette?

