# Floodgate Wheel 01 Spec

## Identity

- Asset ID: `prop_floodgate_wheel_01`
- Working name: `Floodgate Wheel`
- Prop family: flood control / sacred machinery landmark / route-state device
- Chapter or environment family: CH04 drowned monastery / water-control landmark

## Purpose

- Primary use: chapter-specific sacred-machinery landmark for CH04 flood-control encounters and route-state puzzles
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a large monastery floodgate wheel that reads as water-control machinery before generic lever or gate device
- First-read shape: broad circular wheel on a heavy support housing with clear water-control identity
- Gameplay meaning: flood-state change, route opening, channel redirection, sacred-mechanical authority

## Scale

- Relative scale: larger than a lever, smaller than a full gate structure
- Human comparison: chest-high to head-high control wheel mounted on a service housing
- Tile occupancy: one focal tile cluster with a clear interaction face

## Material Zones

- Primary material: worn brass or pale metal control wheel
- Secondary material: damp stone or iron support housing
- Accent material: restrained cyan route-state accent
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal rust or wet grime noise

## Color Plan

- Base palette: worn brass, pale wet stone, muted iron, cool gray-blue damp neutrals
- Accent color: restrained cyan
- Gameplay color cue: sacred water control and route-state change

## Shape Rules

- Dominant silhouette: broad circular wheel with clear support housing
- Core structural forms: wheel, axle hub, support frame, base or service platform
- Allowed ornament: one seal plate or one engraved ring only
- Forbidden detail: factory machinery clutter, steampunk excess, giant pipe nests, cathedral altar toppers, decorative chain forests

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable wheel profile, intentional service housing, clear front-facing interaction side
- If yes, what marker color family applies: cyan for flood-state change, amber only if the broader interaction system needs it
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from lever, gate control, and altar
- Object icon requirement: yes, should extract a strong flood-control icon from the same silhouette family
- Failure conditions: reads like generic valve, reads like gate-control recolor, or requires VFX to communicate water-state importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG monastery floodgate wheel prop, worn brass control wheel, damp stone housing, restrained cyan route-state accent, painterly diorama style, gameplay-scale clarity
- Must include: strong wheel silhouette, clear support housing, sacred-mechanical water control feel, restrained detail
- Must avoid: factory valve overload, steampunk clutter, giant pipe walls, photoreal wet rust, decorative excess

## Rhino Notes

- Blockout priority: wheel profile, housing mass, service-side readability
- Material split strategy: wheel / housing / accent marker
- Layer groups: `PROP_WHEEL`, `PROP_HOUSING`, `PROP_ACCENT`, `GUIDES`
- Named views: `WHEEL_FRONT`, `WHEEL_SIDE`, `WHEEL_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify wheel silhouette and housing separation
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint compact and avoid spill-channel clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or flooded-monastery preview support
- Filename target: `floodgate_wheel_01`
- In-engine readability test: compare directly against gate control and altar in CH04 framing

## Review Checklist

- Is the prop immediately readable as a floodgate wheel or water-control landmark?
- Does it stay distinct from gate-control and altar language?
- Is the wheel silhouette visible at small scale?
- Can it communicate route-state change without relying on active water FX?
- Does it fit CH04's sacred-machinery tone?
