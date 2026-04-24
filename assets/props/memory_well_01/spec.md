# Memory Well 01 Spec

## Identity

- Asset ID: `prop_memory_well_01`
- Working name: `Memory Well`
- Prop family: furniture / landmark / investigation prop
- Chapter or environment family: CH01 ruined village / memory-disturbance landmark

## Purpose

- Primary use: interactable chapter-specific landmark for CH01 investigation and memory-disturbance beats
- Game surface: battle map interaction object, chapter-specific landmark, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a worn village well that reads as investigation landmark first, and as a memory-disturbance trigger second
- First-read shape: circular or octagonal stone well with one clear vertical frame or pulley element
- Gameplay meaning: investigate, recover clues, trigger narrative disturbance, then extract

## Scale

- Relative scale: one major tile landmark, larger than lever but smaller than gate-control infrastructure
- Human comparison: waist-high stone rim with one upright timber or iron support
- Tile occupancy: one focal tile footprint with a readable interaction zone

## Material Zones

- Primary material: pale worn stone rim and base
- Secondary material: weathered wood beam or iron frame support
- Accent material: restrained memory-cyan or pale gold disturbance mark used sparingly
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal rubble noise

## Color Plan

- Base palette: pale ash stone, weathered brown timber, muted iron, dry dust neutrals
- Accent color: pale memory-cyan kept very restrained
- Gameplay color cue: chapter investigation landmark with narrative weight

## Shape Rules

- Dominant silhouette: round or faceted well mass with a single upright support or hanging frame
- Core structural forms: rim, inner shaft opening, support post, capstone or pulley crossbar
- Allowed ornament: one broad seal fracture, rope notch, or memory stain only
- Forbidden detail: crowded bucket clutter, chain tangles, vine overload, cathedral ornament, tiny masonry cracks everywhere

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: clean rim opening, intentional landmark placement, readable upright support, non-rubble silhouette
- If yes, what marker color family applies: amber for interactability, pale cyan only when memory disturbance is active
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, chest, or generic rubble
- Object icon requirement: yes, should extract a strong well landmark icon from the same silhouette family
- Failure conditions: reads as generic stone ring, reads as shrine instead of well, or depends only on glow to communicate importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG ruined village memory well interaction prop, pale worn stone well, weathered timber support, restrained memory-disturbance accent, painterly diorama style, gameplay-scale clarity
- Must include: strong well silhouette, readable rim opening, one upright support element, restrained narrative disturbance read
- Must avoid: horror well excess, giant ghost glow, ivy-overgrown ruin clutter, photoreal stone, decorative cathedral language

## Rhino Notes

- Blockout priority: well rim, shaft opening, support frame
- Material split strategy: stone / timber-or-iron support / memory accent
- Layer groups: `PROP_WELL`, `PROP_SUPPORT`, `PROP_ACCENT`, `GUIDES`
- Named views: `WELL_FRONT`, `WELL_SIDE`, `WELL_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify rim opening and icon silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the interaction zone clear and avoid rubble spill around the base

## Godot Notes

- Runtime slot target: future chapter-specific object icon or landmark preview support
- Filename target: `memory_well_01`
- In-engine readability test: compare directly against altar and lever in CH01-like ruined village framing

## Review Checklist

- Is the prop immediately readable as a well landmark?
- Does it stay distinct from altar and lever families?
- Is the rim opening visible at small scale?
- Can it communicate memory disturbance without becoming a magical shrine?
- Does it fit CH01's quiet ruined-village tone?
