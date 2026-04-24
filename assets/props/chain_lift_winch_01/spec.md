# Chain Lift Winch 01 Spec

## Identity

- Asset ID: `prop_chain_lift_winch_01`
- Working name: `Chain Lift Winch`
- Prop family: siege machinery / navigation objective / chain-lift device
- Chapter or environment family: CH06 iron keep / route-control landmark

## Purpose

- Primary use: chapter-specific siege landmark for route-state change, navigation objectives, and military engineering reads
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a heavy chain-lift winch that reads as navigation objective and siege engineering before generic gate-control or workshop clutter
- First-read shape: broad drum or wheel body with heavy chain run and grounded support frame
- Gameplay meaning: route-state change, lift or gate motion, navigation objective, battlefield engineering control

## Scale

- Relative scale: larger than a lever, comparable to a major local machine but smaller than a full gatehouse
- Human comparison: chest-high to head-high machine that clearly dominates a control tile
- Tile occupancy: one focal tile cluster with clear mechanical direction

## Material Zones

- Primary material: dark iron drum or wheel body
- Secondary material: chain run and support frame or braces
- Accent material: restrained amber machinery marker or worn brass highlight
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal oil or rust noise

## Color Plan

- Base palette: blackened iron, soot-gray chain, weathered wood or dark brace material, ash-black siege neutrals
- Accent color: restrained amber
- Gameplay color cue: route-control and military engineering identity

## Shape Rules

- Dominant silhouette: broad drum or wheel plus strong chain line
- Core structural forms: drum, chain, support frame, base or housing
- Allowed ornament: one brace band, one tension marker, or one rivet strip only
- Forbidden detail: steampunk clutter, giant pipe tangles, ornate crest plates, decorative gear nests, glowing furnace excess

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable chain direction, deliberate control mass, clear front-facing service side
- If yes, what marker color family applies: amber for machinery control, red only in overlays and not baked into the prop
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from gate control, battery emplacement, and generic workshop clutter
- Object icon requirement: yes, should extract a strong chain-lift icon from the same silhouette family
- Failure conditions: reads like random machine pile, reads like gate-control recolor, or loses chain direction at small scale

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG chain-lift winch prop, dark iron drum, heavy chain run, grounded support frame, restrained amber machinery accent, painterly diorama style, gameplay-scale clarity
- Must include: strong machine silhouette, readable chain direction, siege engineering feel, restrained detail
- Must avoid: steampunk clutter, giant pipe tangles, ornate crest plates, furnace-glow overload, photoreal grime

## Rhino Notes

- Blockout priority: drum mass, chain direction, support frame
- Material split strategy: drum / chain / support frame / accent marker
- Layer groups: `PROP_WINCH`, `PROP_CHAIN`, `PROP_FRAME`, `PROP_ACCENT`, `GUIDES`
- Named views: `WINCH_FRONT`, `WINCH_SIDE`, `WINCH_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify chain run and machine silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint tight and avoid spare workshop clutter swallowing the machine

## Godot Notes

- Runtime slot target: future chapter-specific landmark or route-control icon
- Filename target: `chain_lift_winch_01`
- In-engine readability test: compare directly against gate-control and battery emplacement in CH06 framing

## Review Checklist

- Is the prop immediately readable as a chain-lift winch or navigation-control machine?
- Does it stay distinct from gate-control and battery language?
- Is the chain direction visible at small scale?
- Can it communicate route-state engineering without turning into generic clutter?
- Does it fit CH06's iron-keep siege tone?
