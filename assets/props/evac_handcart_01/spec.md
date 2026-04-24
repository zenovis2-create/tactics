# Evac Handcart 01 Spec

## Identity

- Asset ID: `prop_evac_handcart_01`
- Working name: `Evac Handcart`
- Prop family: furniture / civilian route anchor / escort prop
- Chapter or environment family: CH01 ash-field escort / civilian rescue landmark

## Purpose

- Primary use: chapter-specific civilian rescue prop for CH01 escort maps and route readability
- Game surface: battle map support prop, escort landmark, icon extraction support
- Runtime importance: focal secondary

## Visual Summary

- One-sentence pitch: a small civilian handcart that reads as evacuation burden and route anchor before generic clutter
- First-read shape: compact two-wheeled cart with handle bars and bundled supplies
- Gameplay meaning: escort, evacuation pressure, fragile civilian movement, non-military urgency

## Scale

- Relative scale: larger than loose bundle clutter, smaller than gate or altar props
- Human comparison: waist-high cart one villager could plausibly push
- Tile occupancy: one focal secondary tile footprint

## Material Zones

- Primary material: worn wood cart body and wheels
- Secondary material: cloth bundles, rope ties, or blanket wraps
- Accent material: restrained green or pale household cloth marker
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal splinter or fabric noise

## Color Plan

- Base palette: dusty brown wood, muted cloth beige, dry rope, soot-gray wear
- Accent color: restrained civilian green cloth or faded pale blue cloth
- Gameplay color cue: civilian rescue and route guidance, not sacred or military control

## Shape Rules

- Dominant silhouette: two-wheeled cart body with readable handles
- Core structural forms: cart box, wheels, handle bars, bundled top load
- Allowed ornament: one cloth wrap or blanket fold only
- Forbidden detail: market-cart abundance, merchant luxury trim, weapon racks, treasure chest styling, clutter spill everywhere

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable cart silhouette, clear handle direction, intentional bundle load, visible route anchor presence
- If yes, what marker color family applies: amber for interactability, civilian green for route comprehension if needed
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from cache, altar, and rubble clutter
- Object icon requirement: yes, should extract a strong escort-route icon from the same silhouette family
- Failure conditions: reads like generic crate pile, reads like merchant cart, or needs color alone to communicate escort relevance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG civilian evacuation handcart prop, worn wood cart, bundled supplies, restrained cloth wrap, painterly diorama style, gameplay-scale clarity
- Must include: strong handcart silhouette, readable wheels and handles, civilian rescue feel, restrained detail
- Must avoid: merchant market styling, ornate wagon overload, treasure loot read, military artillery cart read, photoreal wood

## Rhino Notes

- Blockout priority: cart box, wheel silhouette, handle direction
- Material split strategy: wood / cloth bundles / accent cloth
- Layer groups: `PROP_CART`, `PROP_BUNDLE`, `PROP_ACCENT`, `GUIDES`
- Named views: `CART_FRONT`, `CART_SIDE`, `CART_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify wheel and handle silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the bundle footprint tight and avoid clutter spill around the wheels

## Godot Notes

- Runtime slot target: future chapter-specific object icon or escort preview support
- Filename target: `evac_handcart_01`
- In-engine readability test: compare directly against cache, well, and civilian route markers in CH01 framing

## Review Checklist

- Is the prop immediately readable as a civilian handcart?
- Does it stay distinct from cache and military machinery?
- Are the wheel and handle silhouettes visible at small scale?
- Can it communicate escort burden without looking decorative?
- Does it fit CH01's ash-field rescue tone?
