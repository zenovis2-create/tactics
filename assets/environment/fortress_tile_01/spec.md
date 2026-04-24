# Fortress Tile 01 Spec

## Identity

- Asset ID: `tile_fortress_01`
- Working name: `Fortress Tile 01`
- Tile family: fortress / stone floor
- Chapter or biome: Hardren / Valtor / monastery-adjacent fortified interiors

## Purpose

- Primary use: baseline fortified stone terrain tile for tactical board readability
- Runtime slot: tile card, tile icon, board reference
- Gameplay role: neutral fortified ground, defensive lane support, hard-surface chapter baseline

## Visual Summary

- One-sentence pitch: a fortified stone floor tile that reads as deliberate military architecture rather than wilderness or sacred ornament
- First-read terrain cue: cut stone mass, clear edge structure, restrained cracks and seams
- Gameplay meaning: stable footing, engineered battlefield, stronghold route

## Scale And Framing

- Tile footprint: single-tile read
- Camera expectation: top-down and slight isometric gameplay framing
- Must-read zone in the tile: central stone plane must remain readable under units and overlays

## Material Zones

- Primary material: cut gray stone
- Secondary material: darker mortar or seam shadow
- Accent material: restrained cold metal or worn banner trace only if needed

## Color Plan

- Base palette: cool gray stone, muted blue-gray shadow, restrained brown wear
- Accent color: minimal cool steel hint only if necessary
- Contrast requirement: clearer and more geometric than plain tile, but still subordinate to unit readability

## Shape Rules

- Dominant shape cue: clean stone block pattern or plate-like floor geometry
- Texture breakup rule: broad seam logic, no noisy rubble field
- Edge readability rule: tile edges should imply masonry discipline, not broken clutter
- Forbidden clutter: loose debris piles, heavy moss takeover, excessive sacred ornament, random collapse noise

## Gameplay Readability

- How cover is implied: not by the tile alone; this is a stable ground tile, not a cover tile
- How hazard is implied: not by default
- How elevation is implied: through stronger edge structure, not large height shift
- How this differs from neighboring tile families: more engineered than plain, less organic than forest, less blocking than wall

## Output Requirements

- Needed outputs: tile icon, tile card, board reference
- Render framing: centered orthographic tile support plus board-context 3/4
- Export formats: PNG
- Background handling: transparent for icon, neutral backing optional for tile card

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG fortress stone floor tile, painterly diorama style, engineered stone surface, disciplined seam pattern, gameplay-scale clarity
- Must include: clear fortified ground read, broad stone logic, stable center plane
- Must avoid: photoreal masonry, heavy debris, giant cracks, sacred overload, muddy texture noise

## Runtime Goal

- Must serve as the second terrain family after forest
- Must immediately contrast with forest on the same board
- Must remain unit-safe at gameplay scale

