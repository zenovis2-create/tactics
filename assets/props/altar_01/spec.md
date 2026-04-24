# Altar 01 Spec

## Identity

- Asset ID: `prop_altar_01`
- Working name: `Altar 01`
- Prop family: altar
- Chapter or environment family: monastery / sacred ruin / evidence-interaction family

## Purpose

- Primary use: interactable sacred focal prop for battle maps
- Game surface: battle map interaction object, concept support, icon extraction
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a waist-high sacred altar that reads as interactable and story-relevant before any UI marker appears
- First-read shape: stable stone base with one raised focal plane or relic housing
- Gameplay meaning: objective, purification point, memory/evidence anchor

## Scale

- Relative scale: waist-high to chest-high against player unit
- Human comparison: one soldier can clearly stand beside and interact with it
- Tile occupancy: one major tile footprint

## Material Zones

- Primary material: pale aged stone
- Secondary material: metal trim or carved inlay
- Accent material: vow-gold or soft cyan sacred focal mark, depending on gameplay state
- Surface finish note: illustrated stone planes, restrained wear, no hyper-real stone grain

## Color Plan

- Base palette: pale ash stone, worn iron, parchment-bone highlights
- Accent color: soft gold by default, optional cool cyan in activated states
- Gameplay color cue: sacred objective, ally-aligned interaction point

## Shape Rules

- Dominant silhouette: rectangular or octagonal altar mass with one vertical focal element
- Core structural forms: base, top slab, relic or seal housing
- Allowed ornament: broad seal engraving, one ring motif, one fractured relic inset
- Forbidden detail: tiny scripture lines, lace stonework, fragile hanging chains, cathedral clutter explosion

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: raised focal center, clean presentation plane, non-rubble silhouette, clear top surface
- If yes, what marker color family applies: amber for interactability, white/gold for sacred narrative weight
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from generic chest or scenery clutter
- Object icon requirement: yes, should extract a strong altar icon from the same silhouette family
- Failure conditions: reads as furniture, reads as wall chunk, or relies only on glow to communicate importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG sacred altar interaction prop, pale stone, restrained sacred trim, readable top slab, painterly diorama style, gameplay-scale clarity
- Must include: strong altar silhouette, focal top element, sacred but restrained identity
- Must avoid: cathedral overload, giant glowing crystal centerpiece, tiny scripture detail, photoreal stone

## Rhino Notes

- Blockout priority: base mass, top slab, focal relic housing
- Material split strategy: stone base / trim / sacred accent
- Layer groups: `PROP_ALTAR`, `PROP_TRIM`, `PROP_ACCENT`, `GUIDES`
- Named views: `ALTAR_FRONT`, `ALTAR_SIDE`, `ALTAR_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify sacred focal mark and icon silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: mark interaction zone and material split clearly

## Godot Notes

- Runtime slot target: `altar.png` object icon family and battle interaction reference
- Filename target: if promoted to runtime object art, preserve altar naming consistency
- In-engine readability test: compare against chest and lever interactions at gameplay camera distance

## Review Checklist

- Is the altar immediately recognizable as an objective prop?
- Does it read as sacred without over-decoration?
- Is the focal top form visible at small scale?
- Can it share a silhouette family with the runtime altar icon?
- Does it fit the monastery and memory-object language of the project?

