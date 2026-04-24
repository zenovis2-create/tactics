# City Seal Dais 01 Spec

## Identity

- Asset ID: `prop_city_seal_dais_01`
- Working name: `City Seal Dais`
- Prop family: civic oath landmark / seal objective / ritual-city anchor
- Chapter or environment family: CH07 ritual city / city-seal objective landmark

## Purpose

- Primary use: chapter-specific ritual-city landmark for civic oath, city-seal objectives, and public memory pressure
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a formal city-seal dais that reads as civic oath and public authority before generic altar or desk-like monument
- First-read shape: stable raised dais with one clear seal plane or civic plate at the center
- Gameplay meaning: city seal objective, civic oath anchor, witness point, public legitimacy space

## Scale

- Relative scale: comparable to a small altar but more civic and planar
- Human comparison: waist-high to chest-high platform one unit can clearly stand beside and interact with
- Tile occupancy: one focal tile footprint with a deliberate public-facing center

## Material Zones

- Primary material: pale civic stone or polished municipal slab
- Secondary material: dark metal seal plate or civic frame
- Accent material: restrained white-gold or pale civic-blue seal marking
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal marble or metal noise

## Color Plan

- Base palette: pale civic stone, soot-dark metal, parchment neutrals, restrained city-blue or white-gold accent
- Accent color: restrained white-gold
- Gameplay color cue: public oath and formal city authority, distinct from private sacred ritual

## Shape Rules

- Dominant silhouette: stable dais mass with one readable seal plane
- Core structural forms: base, top plate, seal or civic crest panel, side brace or trim band
- Allowed ornament: one civic seal band, one oath panel, or one carved edge line only
- Forbidden detail: cathedral altar excess, giant sermon statuary, banner clutter, decorative chain forests, crystal spectacle

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable top plane, centered civic seal, clean staging, strong negative space around the prop
- If yes, what marker color family applies: white-gold for civic oath and city authority, amber only if paired with mechanical logic elsewhere
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, bell frame, and generic monument clutter
- Object icon requirement: yes, should extract a strong city-seal icon from the same silhouette family
- Failure conditions: reads like altar variant, reads like desk furniture, or needs glow alone to communicate civic importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG city seal dais prop, pale civic stone platform, centered seal plate, restrained white-gold civic accent, painterly diorama style, gameplay-scale clarity
- Must include: strong civic plane, readable seal center, public authority feel, restrained detail
- Must avoid: cathedral altar styling, giant statuary, banner clutter, crystal glow centerpiece, photoreal marble or metal noise

## Rhino Notes

- Blockout priority: dais mass, top seal plane, civic brace logic
- Material split strategy: dais body / seal plate / accent band
- Layer groups: `PROP_DAIS`, `PROP_SEAL`, `PROP_ACCENT`, `GUIDES`
- Named views: `SEALDAIS_FRONT`, `SEALDAIS_SIDE`, `SEALDAIS_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify seal plane and public-facing silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint clean and avoid surrounding civic clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or ritual-city preview support
- Filename target: `city_seal_dais_01`
- In-engine readability test: compare directly against altar and bell frame in CH07 framing

## Review Checklist

- Is the prop immediately readable as a city-seal or civic oath dais?
- Does it stay distinct from altar and generic monument clutter?
- Is the seal plane visible at small scale?
- Can it communicate public authority without relying on strong FX?
- Does it fit CH07's ritual-city tone?
