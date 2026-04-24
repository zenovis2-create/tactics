# Environment, Prop, And Tile Matrix V01

## Purpose

This document locks the non-character visual production lanes so props, tiles, and maps
can be produced with the same consistency that now exists for battle sprites.

It turns the current anchor work into a reusable matrix for:

- equipment-support props
- interactable objective props
- terrain tiles
- stage-level map composition

## Current Anchor Set

- Paladin Shield: equipment-support prop
- Altar 01: interactable sacred objective prop
- Forest Tile 01: baseline cover / slow terrain tile
- CH02~CH06 map production kit: map-side composition and landmark language

## Global Rule

For environment-side assets, the player must read in this order:

1. gameplay meaning
2. silhouette / mass
3. material family
4. local color cue
5. ornament or secondary texture

If a prop or tile needs close inspection before its gameplay role is understood, it fails.

## Production Matrix

| Lane | Anchor | First-read job | Dominant read | Value tendency | Accent family | Production focus |
| --- | --- | --- | --- | --- | --- | --- |
| equipment-support prop | Paladin Shield | defensive class identity | large outer contour and rim | mid-to-dark, controlled contrast | deep navy | silhouette and material split |
| interactable sacred prop | Altar 01 | objective / ritual / evidence point | top slab plus focal relic mass | light-to-mid with strong focal contrast | vow gold / soft cyan | interactivity before ornament |
| terrain tile | Forest Tile 01 | cover / slow route | clustered organic edge masses | darker than plain, but token-safe | subdued pale green | board readability at small scale |
| stage map composition | CH02~CH06 production kit | route, landmark, and objective clarity | landmark hierarchy and lane separation | mid-value environments with highlighted interaction zones | chapter-dependent, marker-controlled | screenshot readability and path logic |

## Equipment-Support Prop Rules

### Silhouette

- One major contour read first.
- Functional mass must beat decorative identity.
- Rim thickness and edge clarity matter more than surface detailing.

### Value

- Keep a controlled contrast envelope.
- The prop should stay readable over character art and UI.
- Avoid muddy mid-value compression that erases the edge.

### Color

- One accent color maximum.
- Equipment accent should support class identity, not become collectible-card flair.

### Failure Case

- Reads like a generic slab
- Looks ornate before it looks useful
- Loses class identity when reduced

## Interactable Sacred Prop Rules

### Silhouette

- Must read as intentional and interactable before any icon overlay.
- Stable base + focal top mass is preferred.
- The top or front plane should visually invite interaction.

### Value

- Focal object contrast should be localized and clear.
- Do not rely on glow alone.

### Color

- Sacred objective props may use vow-gold or cool cyan accents.
- Accent should mark purpose, not become visual noise.

### Failure Case

- Reads as furniture
- Reads as debris
- Needs UI marker to feel important

## Terrain Tile Rules

### Silhouette

- Tile families differentiate through edge language and clustered mass.
- Terrain must not become a miniature diorama that hides units.

### Value

- Tiles sit below character readability.
- Terrain can differentiate itself from neighboring tiles, but not overpower sprites or UI overlays.

### Color

- Terrain family color is supportive, not dominant.
- Gameplay meaning must survive if saturation is reduced.

### Failure Case

- Units disappear against the tile
- Plain/forest/wall distinction collapses
- Organic detail becomes noise

## Map Composition Rules

### Landmark Hierarchy

- One screenshot should explain the map.
- Primary route, major landmark, and objective cluster should separate cleanly.

### Prop Placement

- Interaction props must sit where the player can identify them as meaningful.
- Optional routes need visual foreshadowing.
- Cover and clutter must remain different categories.

### Hazard Read

- Hazard needs an environmental cause.
- Art cannot invent ambiguity where rules need clarity.

### Failure Case

- Route is visually unclear
- Objective is visually buried
- Clutter mimics tactical geometry
- Screenshot mood exists, but gameplay read fails

## Cross-Lane Distance Rules

### Equipment Prop vs Interactable Prop

- Equipment prop supports the unit.
- Interactable prop organizes the space around it.
- If both use a focal accent, the interactable prop should feel more “placed” and less “carried.”

### Interactable Prop vs Terrain

- Interactable prop should pop through structure and shape, not only color.
- Terrain should stay subordinate to the interactable read.

### Terrain vs Character

- Terrain exists to host the character, not compete with it.
- Small-scale readability always resolves in favor of characters and objective markers.

### Map vs Everything Else

- Map composition is the orchestration layer.
- Individual props and tiles can be beautiful, but map readability still wins.

## Locked Visual Priorities

From the current anchor work:

- large masses beat intricate detail
- one focal accent beats distributed ornament
- gameplay meaning must survive desaturation and size reduction
- interactables must be recognizable before icons
- tile families must remain distinct under token and HUD overlap

## Use With

- `/Volumes/AI/tactics/docs/style_bible.md`
- `/Volumes/AI/tactics/docs/rhino_rules.md`
- `/Volumes/AI/tactics/docs/production/ch2_ch6_stage_visual_map_production_kit.md`
- `/Volumes/AI/tactics/assets/ui/production/README.md`
- `/Volumes/AI/tactics/assets/props/paladin_shield/spec.md`
- `/Volumes/AI/tactics/assets/props/altar_01/spec.md`
- `/Volumes/AI/tactics/assets/environment/forest_tile_01/spec.md`

