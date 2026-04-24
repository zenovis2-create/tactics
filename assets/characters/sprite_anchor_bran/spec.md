# Sprite Anchor Bran Spec

## Identity

- Asset ID: `sprite_anchor_bran_01`
- Working name: `Sprite Anchor Bran`
- Character type: playable
- Class or archetype: heavy knight / wall defender / shield-line veteran
- Chapter or faction: Hardren / fortress defender lane

## Purpose

- Primary use: establish the 2D battle-sprite production standard for heavy armored ally classes
- Runtime surface: battle sprite, idle baseline, guarded move baseline, shield-led attack or bash baseline
- Production role: style anchor for heavy knight and wall-defender sprites

## Sprite Pipeline Mode

- Production mode: 2D sprite sheet
- Source method: AI concept -> Krita cleanup -> Godot sprite import
- Proportion target: chibi-adjacent tactical sprite with the broadest upper-body mass among ally anchors
- Camera read target: battle-map first, portrait support second

## Visual Summary

- One-sentence pitch: a scarred shield-wall veteran whose mass, shield, and fortress-like stance communicate endurance before aggression
- Emotional read: judgment, endurance, guarded loyalty
- First-read silhouette: shield mass, broad shoulders, compact heavy stance
- Must-read class signal: true heavy frontline defender, clearly heavier than Rian

## Style Rules

- Line character: clean and firm, slightly heavier contour than Serin and Rian
- Shading style: restrained cel-style shading with soft painterly warmth
- Detail budget: low-to-medium; armor plates and shield mass should do most of the work
- Chibi/stylization level: classic tactical JRPG sprite with slightly enlarged head and compact sturdy body
- Forbidden polish: excessive ornamental knight trim, giant fantasy cape, over-rendered metal texture, boss-like threat exaggeration

## Proportion

- Head size note: slightly oversized for readable veteran expression
- Torso note: broadest torso and shoulder mass among current ally anchors
- Leg note: short, heavy, planted stance
- Hand / weapon exaggeration: shield should be slightly oversized; weapon can be secondary to shield read

## Loadout

- Primary weapon: short sword or compact knight weapon
- Secondary item: large shield
- Shield: required, major silhouette feature
- Signature prop: fortress-like shield line and compact mantle/tabard break

## Material And Color Plan

- Primary materials: steel armor, worn leather, heavy cloth
- Accent material: restrained fortress-blue or oath-gold minor trim
- Base palette: cold steel gray, worn leather brown, dark muted blue-gray cloth
- Accent color: muted fortress blue
- Forbidden colors: bright royal gold, vivid hero-red, saturated shine-heavy trim

## Animation Set

- Required states: `idle`, `move`, `attack`, `hit`
- Minimum states: `idle`, `attack`
- One-shot actions: `attack`, `hit`
- Looping actions: `idle`, `move`
- FX handled in character sheet or separated: no class-defining FX; body and shield must carry the identity

## Sheet Layout

- Required views or framing: front-facing gameplay sprite sequence only
- Sheet type: action sheet plus movement baseline
- Target frame count: 8-frame idle, 8-frame move, 8-frame attack
- Background: transparent or plain neutral backdrop during concept stage
- Transparent export needed: yes

## Runtime Readability

- Zoomed-out read goal: instantly distinguish Bran from Rian by shield mass and armored width
- Token/icon implication: shield outline and shoulder block should remain readable in token-size derivatives
- Failure conditions: reads like generic knight, shield too small to matter, silhouette too similar to Rian, armor detail turns noisy

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: classic tactical JRPG heavy knight sprite sheet, veteran wall defender with large shield, broad shoulders, compact heavy proportions, fortress defender read, muted steel and leather palette
- Must include: large shield, broad torso, grounded stance, veteran face
- Must avoid: oversized cape drama, luxury knight ornament, giant fantasy weapon, magical FX dependence

## Krita Notes

- Cleanup tasks: keep shield size consistent, stabilize shoulder width, unify armor plate read
- Separation tasks: shield edge must stay distinct from body mass
- Text removal or label cleanup: remove any generated numbering or poster-like arrangement marks
- Frame consistency risks: shield shrinking between frames, sword taking over the silhouette, armor detail density increasing unevenly

## Godot Notes

- Import target: battle character sprite sheet
- Sprite slicing plan: fixed frame box and fixed foot-center pivot
- Animation names: `idle`, `move`, `attack`, `hit`
- Loop/non-loop notes: `idle` and `move` loop
- Test scene: battle scene next to Rian and enemy infantry over plain and fortress tiles

## Review Checklist

- Does Bran read as a heavy defender before he reads as a swordsman?
- Is the shield the dominant gear read?
- Is the silhouette clearly heavier than Rian?
- Do the frames stay grounded rather than flashy?
- Does he still fit the same game as Serin, Rian, and Tia?

