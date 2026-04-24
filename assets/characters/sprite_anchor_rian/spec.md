# Sprite Anchor Rian Spec

## Identity

- Asset ID: `sprite_anchor_rian_01`
- Working name: `Sprite Anchor Rian`
- Character type: playable
- Class or archetype: frontline commander / tactical swordsman
- Chapter or faction: early ally roster, ash-field command line

## Purpose

- Primary use: establish the 2D battle-sprite production standard for frontline human allies
- Runtime surface: battle sprite, movement baseline, light melee sequence baseline
- Production role: style anchor for sword and vanguard-class sprites

## Sprite Pipeline Mode

- Production mode: 2D sprite sheet
- Source method: AI concept -> Krita cleanup -> Godot sprite import
- Proportion target: chibi-adjacent tactical sprite with stronger heroic line than support units
- Camera read target: battle-map first, portrait support second

## Visual Summary

- One-sentence pitch: a composed frontline commander whose sword and cloak split make him read as tactical leadership before pure aggression
- Emotional read: controlled burden, alertness, discipline
- First-read silhouette: short cape or mantle split, compact sword arm, stable stance
- Must-read class signal: mobile frontline swordsman, not a heavy knight

## Style Rules

- Line character: clean and consistent, slightly firmer than Serin
- Shading style: restrained cel-style shading with mild painterly softness
- Detail budget: low-to-medium; silhouette and stance must do most of the work
- Chibi/stylization level: classic tactical JRPG sprite, slightly enlarged head, compact grounded body
- Forbidden polish: flashy protagonist glamor, oversized wind effects, overbuilt armor ornament

## Proportion

- Head size note: slightly oversized for readable expression
- Torso note: compact torso with stronger shoulder read than support units
- Leg note: short but grounded stance, stable foot placement
- Hand / weapon exaggeration: sword may be slightly enlarged for readability, but should remain lighter than a knight weapon

## Loadout

- Primary weapon: one-handed sword
- Secondary item: no shield by default in anchor version
- Shield:
- Signature prop: directional mantle split or command-mark cloth detail

## Material And Color Plan

- Primary materials: field cloth, leather straps, light armor pieces, steel sword
- Accent material: restrained command-mark metal or emblem detail
- Base palette: ash blue-gray, muted brown leather, subdued steel, dark slate cloth
- Accent color: controlled ash-blue / muted navy command accent
- Forbidden colors: bright hero red, saturated gold luxury trim, neon FX accents

## Animation Set

- Required states: `idle`, `move`, `attack`, `hit`
- Minimum states: `idle`, `attack`
- One-shot actions: `attack`, `hit`
- Looping actions: `idle`, `move`
- FX handled in character sheet or separated: body-first, minimal weapon trail only if needed

## Sheet Layout

- Required views or framing: front-facing gameplay sprite sequence only
- Sheet type: action sheet plus movement baseline
- Target frame count: 8-frame idle, 8-frame move, 8-frame attack
- Background: transparent or plain neutral backdrop during concept stage
- Transparent export needed: yes

## Runtime Readability

- Zoomed-out read goal: instantly distinguish Rian from knight and healer lanes while preserving “frontline ally” identity
- Token/icon implication: sword arm, shoulder line, and mantle split should remain identifiable in token-size derivatives
- Failure conditions: reads like generic villager swordsman, reads too much like Bran, silhouette collapses without FX

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: classic tactical JRPG frontline commander sprite sheet, calm young swordsman with compact tactical proportions, short mantle split, light field armor, restrained expression, clear sword silhouette, subdued ash-blue palette
- Must include: stable stance, readable sword, tactical-leader read, restrained cloak or mantle shape
- Must avoid: giant cape motion, anime protagonist hair drama, oversized power aura, knight-level armor mass, decorative clutter

## Krita Notes

- Cleanup tasks: unify sword angle, head scale, and mantle shape across frames
- Separation tasks: keep weapon silhouette clear from body
- Text removal or label cleanup: remove any generated numbering or poster-like composition cues
- Frame consistency risks: drifting sword length, unstable shoulder width, cape edge changing too much between frames

## Godot Notes

- Import target: battle character sprite sheet
- Sprite slicing plan: fixed frame box and fixed foot-center pivot
- Animation names: `idle`, `move`, `attack`, `hit`
- Loop/non-loop notes: `idle` and `move` loop
- Test scene: battle scene next to Serin, Bran, and standard enemy infantry for class separation

## Review Checklist

- Does Rian read as frontline command rather than heavy knight?
- Is the sword visible and readable at gameplay scale?
- Does the mantle or cloth break help class identity?
- Are the frames stable without flashy FX?
- Does the sprite feel like part of the same world as Serin and the current environment lane?

