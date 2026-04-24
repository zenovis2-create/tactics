# Forest Tile 01 Spec

## Identity

- Asset ID: `tile_forest_01`
- Working name: `Forest Tile 01`
- Tile family: forest
- Chapter or biome: Greenwood / general woodland support set

## Purpose

- Primary use: baseline forest terrain tile for tactical board readability
- Runtime slot: tile card, tile icon, board reference
- Gameplay role: soft cover, movement tax, natural route contrast

## Visual Summary

- One-sentence pitch: a dark, readable forest floor tile with enough tree-root and canopy language to imply cover without obscuring movement
- First-read terrain cue: clustered organic mass with a darker floor value than plain ground
- Gameplay meaning: slower movement, partial protection, natural ambush space

## Scale And Framing

- Tile footprint: single-tile read
- Camera expectation: top-down and slight isometric gameplay framing
- Must-read zone in the tile: center mass must still feel traversable, with vegetation pushed toward readable clusters

## Material Zones

- Primary material: mossy earth
- Secondary material: root, bark, or low undergrowth
- Accent material: restrained cool-green highlight or dew-lit edge

## Color Plan

- Base palette: muted moss green, dark soil brown, cool shadow green
- Accent color: subdued pale green edge highlight
- Contrast requirement: darker than plain tile, but not so dark that units disappear on top

## Shape Rules

- Dominant shape cue: clustered asymmetrical foliage masses anchored by root lines
- Texture breakup rule: use broad leaf mass suggestion, not dense fine leaf noise
- Edge readability rule: silhouette variation should happen near tile corners and sides, not cover the whole footprint
- Forbidden clutter: full-tile bush blob, branch spaghetti, leaf confetti noise, strong bloom

## Gameplay Readability

- How cover is implied: darker clustered organic masses on tile perimeter with one or two stronger root or brush shapes
- How hazard is implied: not a hazard tile by default; avoid red or diseased reads
- How elevation is implied: not by height, by density only
- How this differs from neighboring tile families: more organic edge breakup than plain, softer and greener than swamp, less vertical obstruction than wall

## Output Requirements

- Needed outputs: tile icon, tile card, board reference
- Render framing: centered orthographic tile sheet plus board-context 3/4
- Export formats: PNG
- Background handling: transparent for icon, neutral backing for tile card

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG forest terrain tile, painterly diorama style, dark mossy ground, root clusters, readable cover, muted palette, small-scale clarity
- Must include: root/brush clustering, traversable center, restrained organic detail
- Must avoid: photoreal forest floor, dense grass noise, cinematic fog, giant tree trunks blocking the tile

## Rhino Notes

- Large-form terrain scaffold: one shallow ground plane plus 2-3 raised organic clusters
- Repeating shape strategy: reusable root and brush masses with variation by rotation and scaling
- Layer needs: `TILE_GROUND`, `TILE_FOLIAGE`, `TILE_ACCENT`, `GUIDES`

## Krita Notes

- Paintover tasks: simplify foliage read, tune tile card contrast
- Tile card polish: ensure forest family reads instantly beside plain and wall
- Icon extraction needs: center on the strongest root/foliage cue

## Godot Notes

- Runtime filename target: `forest.png`
- Neighbor comparison targets: plain, wall, highground
- In-engine readability test: confirm ally and enemy tokens remain visible over tile

## Review Checklist

- Is this clearly distinct from plain ground?
- Can the player infer cover/slow terrain quickly?
- Does it avoid noise at small size?
- Does it stay readable under unit tokens and overlays?
- Does it fit the existing board art family?

