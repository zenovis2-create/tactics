# Shield Wreck 01 Spec

## Identity

- Asset ID: `prop_shield_wreck_01`
- Working name: `Shield Wreck`
- Prop family: battlefield wreck / cover landmark / siege remnant
- Chapter or environment family: CH06 iron keep / siege-aftershock cover landmark

## Purpose

- Primary use: chapter-specific siege landmark for true cover read, failed defense memory, and horizontal battlefield shaping
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal secondary

## Visual Summary

- One-sentence pitch: a broken fortress shield wall remnant that reads as true cover and aftermath of siege pressure before decorative debris
- First-read shape: broad rectangular shield fragments or plated barricade remains with one strong broken edge
- Gameplay meaning: cover, stubborn defense, battlefield memory, line-of-fire interruption

## Scale

- Relative scale: larger than loose debris, smaller than a full barricade gate
- Human comparison: chest-high wreckage one unit can clearly crouch behind
- Tile occupancy: one focal cover tile cluster with a clear defensive face

## Material Zones

- Primary material: battered iron or steel shield plates
- Secondary material: broken wood braces or collapsed support frame
- Accent material: restrained fortress-blue paint remnant or faded insignia
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal rust or splinter noise

## Color Plan

- Base palette: dark iron, soot-gray wear, weathered wood brown, ash-black siege neutrals
- Accent color: restrained fortress blue
- Gameplay color cue: real cover and stubborn defense identity

## Shape Rules

- Dominant silhouette: broad shield or barricade slab with one readable break
- Core structural forms: shield plates, brace logic, impact break, base debris support
- Allowed ornament: one faded insignia panel or one broad rivet band only
- Forbidden detail: ornate heraldic flourishes, spike forests, heroic trophy display, chain clutter, rubble explosion everywhere

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it should read as true cover first and background story second; it must not compete with route-control or objective props

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from generic rubble, gate machinery, and altar silhouettes
- Object icon requirement: optional future cover icon or landmark support icon
- Failure conditions: reads like random wall chunk, reads too decorative, or loses the cover-facing slab read at small scale

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG siege shield wreck prop, broken shield-wall remnant, battered iron plates, weathered wood braces, restrained fortress-blue paint remnant, painterly diorama style, gameplay-scale clarity
- Must include: strong cover silhouette, broad defensive slab read, siege-aftershock feel, restrained detail
- Must avoid: ornate heraldry, trophy-pile styling, photoreal rust, decorative clutter, giant spike barricade excess

## Rhino Notes

- Blockout priority: cover slab, break direction, support braces
- Material split strategy: shield plates / support frame / accent remnant
- Layer groups: `PROP_WRECK`, `PROP_BRACE`, `PROP_ACCENT`, `GUIDES`
- Named views: `WRECK_FRONT`, `WRECK_SIDE`, `WRECK_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify cover-facing silhouette and break edge
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint tight and avoid rubble spill swallowing the main slab

## Godot Notes

- Runtime slot target: future chapter-specific landmark or cover-support icon
- Filename target: `shield_wreck_01`
- In-engine readability test: compare directly against fortress edge and gate-control in CH06 framing

## Review Checklist

- Is the prop immediately readable as broken shield-wall cover?
- Does it stay distinct from gate-control and ordinary rubble?
- Is the cover-facing slab visible at small scale?
- Can it communicate siege aftermath without turning into decorative junk?
- Does it fit CH06's iron-keep and artillery-pressure tone?
