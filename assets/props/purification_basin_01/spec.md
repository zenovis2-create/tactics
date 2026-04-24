# Purification Basin 01 Spec

## Identity

- Asset ID: `prop_purification_basin_01`
- Working name: `Purification Basin`
- Prop family: sacred basin / monastery landmark / purification prop
- Chapter or environment family: CH04 drowned monastery / purification-chamber landmark

## Purpose

- Primary use: chapter-specific sacred-machinery landmark for CH04 purification chambers, relic cleansing beats, and safe activation targets
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a clean-lined monastery purification basin that reads as a ritual target before altar or generic fountain furniture
- First-read shape: elevated basin bowl or chambered vessel with a clear receiving plane and controlled sacred geometry
- Gameplay meaning: purification target, cleansing station, safe activation point, sacred-object priority under pressure

## Scale

- Relative scale: smaller than a full altar platform, larger than ordinary clutter or basin fragments
- Human comparison: waist-high to chest-high sacred basin one unit can clearly approach and use
- Tile occupancy: one focal tile footprint with a clearly readable top plane

## Material Zones

- Primary material: pale stone basin body
- Secondary material: worn brass or pale metal frame details
- Accent material: restrained white-cyan purification line or basin glow
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal water droplets or stone grain

## Color Plan

- Base palette: pale stone, soft wet gray, worn brass, cool monastery neutrals
- Accent color: restrained white-cyan
- Gameplay color cue: purification and safe activation, distinct from flood-control cyan and altar gold

## Shape Rules

- Dominant silhouette: bowl or vessel on a stable base with one readable sacred plane
- Core structural forms: basin rim, interior plane, support base, minor frame detail
- Allowed ornament: one clean ring, one seal panel, or one modest inlay band only
- Forbidden detail: huge fountains, angelic statuary overload, cathedral excess, chain curtains, crystal centerpiece spectacle

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: clear receiving plane, deliberate centerline, stable base silhouette, clean sacred geometry
- If yes, what marker color family applies: white-cyan for purification priority, amber only if the broader interaction layer requires it
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, floodgate wheel, and generic fountain furniture
- Object icon requirement: yes, should extract a strong purification icon from the same silhouette family
- Failure conditions: reads like decorative basin furniture, reads like altar variant, or requires water FX alone to communicate purity

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG monastery purification basin prop, pale stone vessel, restrained white-cyan sacred line, worn brass trim, painterly diorama style, gameplay-scale clarity
- Must include: strong basin silhouette, readable top plane, sacred purification feel, restrained detail
- Must avoid: giant fountain excess, cathedral statuary overload, glowing crystal centerpiece, photoreal water, decorative clutter

## Rhino Notes

- Blockout priority: basin plane, rim shape, base mass
- Material split strategy: basin body / frame detail / accent line
- Layer groups: `PROP_BASIN`, `PROP_FRAME`, `PROP_ACCENT`, `GUIDES`
- Named views: `BASIN_FRONT`, `BASIN_SIDE`, `BASIN_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify basin silhouette and receiving plane
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint compact and avoid water-channel clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or monastery preview support
- Filename target: `purification_basin_01`
- In-engine readability test: compare directly against altar and floodgate wheel in CH04 framing

## Review Checklist

- Is the prop immediately readable as a purification basin or cleansing target?
- Does it stay distinct from altar and flood-control machinery?
- Is the top plane visible at small scale?
- Can it communicate purification without relying on active water FX?
- Does it fit CH04's sacred-machinery tone?
