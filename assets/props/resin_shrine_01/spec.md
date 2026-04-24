# Resin Shrine 01 Spec

## Identity

- Asset ID: `prop_resin_shrine_01`
- Working name: `Resin Shrine`
- Prop family: shrine / forest landmark / investigation prop
- Chapter or environment family: CH03 Greenwood ambush / hidden forest landmark

## Purpose

- Primary use: chapter-specific forest landmark for trap-route doubt, hidden ritual memory, and Greenwood investigation beats
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a small resin-marked forest shrine that reads as local hunter-ritual landmark before generic altar or forest clutter
- First-read shape: low shrine core with one vertical marker, resin-stained wood or stone, and a focused offering plane
- Gameplay meaning: hidden route clue, trap-language anchor, memory or witness point inside the forest chapter

## Scale

- Relative scale: smaller than altar, larger than loose clutter or trail markers
- Human comparison: knee-to-waist height landmark one unit can clearly inspect
- Tile occupancy: one focal tile footprint with clear local ownership

## Material Zones

- Primary material: weathered wood or pale stone shrine core
- Secondary material: resin-coated bark, root, or support pieces
- Accent material: restrained amber resin glow or moss-green ritual accent
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal bark or sap detail

## Color Plan

- Base palette: muted bark brown, moss green, pale worn stone, dark forest shadow neutrals
- Accent color: restrained amber resin
- Gameplay color cue: investigation and hidden ritual pressure, not pure sacred-objective language

## Shape Rules

- Dominant silhouette: compact shrine mass with one clear upright marker
- Core structural forms: base, offering plane, upright post or marker, resin-bearing support
- Allowed ornament: one broad resin seam, one tied cloth strip, or one carved symbol plane only
- Forbidden detail: cathedral altar language, chain clutter, hanging bells everywhere, glowing crystal centerpiece, dense vine overgrowth

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: intentional focal plane, readable upright marker, clean surrounding silhouette, non-rubble footprint
- If yes, what marker color family applies: amber for interactability, white only if the specific beat is memory-bearing, green only if tied to safe route clues
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, lever, and generic stump clutter
- Object icon requirement: yes, should extract a strong shrine icon from the same silhouette family
- Failure conditions: reads like altar recolor, reads like random stump pile, or depends on glow alone to communicate meaning

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG forest resin shrine prop, Greenwood hidden landmark, weathered wood and pale stone, restrained amber resin accent, painterly diorama style, gameplay-scale clarity
- Must include: strong compact shrine silhouette, one upright marker, resin-bearing detail, hidden forest landmark feel
- Must avoid: cathedral altar styling, giant crystal glow, overgrown vine clutter, photoreal bark, decorative excess

## Rhino Notes

- Blockout priority: shrine mass, offering plane, upright marker
- Material split strategy: core structure / resin-bearing support / accent seam
- Layer groups: `PROP_SHRINE`, `PROP_SUPPORT`, `PROP_ACCENT`, `GUIDES`
- Named views: `SHRINE_FRONT`, `SHRINE_SIDE`, `SHRINE_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify marker silhouette and offering plane
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint tight and avoid surrounding thicket clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or forest preview support
- Filename target: `resin_shrine_01`
- In-engine readability test: compare directly against altar, lever, and forest tile context in CH03 framing

## Review Checklist

- Is the prop immediately readable as a forest shrine or hidden ritual landmark?
- Does it stay distinct from altar and generic forest clutter?
- Is the upright marker visible at small scale?
- Can it communicate Greenwood ritual pressure without turning into a cathedral prop?
- Does it fit CH03's route-doubt and concealed-hostility tone?
