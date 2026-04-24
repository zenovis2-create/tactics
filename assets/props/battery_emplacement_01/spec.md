# Battery Emplacement 01 Spec

## Identity

- Asset ID: `prop_battery_emplacement_01`
- Working name: `Battery Emplacement`
- Prop family: artillery / fortress landmark / tactical threat prop
- Chapter or environment family: CH02 broken fortress / siege-pressure landmark

## Purpose

- Primary use: chapter-specific fortress landmark for ranged siege pressure, breach teaching, and tactical threat framing
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a disabled or semi-active fortress battery that reads as artillery threat infrastructure before local machine detail
- First-read shape: heavy firing frame on a broad base with a clear forward-facing aim line
- Gameplay meaning: siege pressure, line-of-fire threat, raised tactical danger zone

## Scale

- Relative scale: larger than lever and cache props, smaller than a full gatehouse
- Human comparison: one emplacement that dominates a small platform or pad
- Tile occupancy: one focal tile cluster with a clear front-facing danger direction

## Material Zones

- Primary material: dark iron firing frame and carriage
- Secondary material: weathered wood braces or deck elements
- Accent material: restrained amber machinery base or sighting marker
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal soot noise

## Color Plan

- Base palette: blackened iron, charred wood brown, soot-gray wear, fortress stone neutrals
- Accent color: restrained amber
- Gameplay color cue: siege threat and engineered military control

## Shape Rules

- Dominant silhouette: broad base plus forward-aiming artillery body
- Core structural forms: platform, wheel or brace logic, firing arm or frame, rear support
- Allowed ornament: one sighting ring, one brace pattern, one pressure marker only
- Forbidden detail: fantasy cannon mouths, ornate royal artillery trim, oversized flames, impossible steampunk clutter, chain nests everywhere

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable artillery silhouette, intentional platform placement, clear front-facing threat logic
- If yes, what marker color family applies: amber for device logic, red only for gameplay overlays and not baked into the prop
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from gate control, lever, and generic debris
- Object icon requirement: yes, should extract a strong battery icon from the same silhouette family
- Failure conditions: reads like a cart, reads like a gate machine, or needs VFX alone to communicate artillery pressure

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG fortress battery emplacement prop, dark iron siege frame, weathered braces, restrained amber machinery accent, painterly diorama style, gameplay-scale clarity
- Must include: strong artillery silhouette, forward-facing aim line, engineered military feel, restrained detail
- Must avoid: fantasy cannon excess, oversized muzzle glow, royal trim, steampunk clutter, photoreal grime

## Rhino Notes

- Blockout priority: base mass, artillery frame, aim direction
- Material split strategy: iron frame / brace wood / accent marker
- Layer groups: `PROP_BATTERY`, `PROP_BRACE`, `PROP_ACCENT`, `GUIDES`
- Named views: `BATTERY_FRONT`, `BATTERY_SIDE`, `BATTERY_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify firing direction and icon silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the base footprint tight and avoid wall-rubble spill around the platform

## Godot Notes

- Runtime slot target: future chapter-specific object icon or fortress preview support
- Filename target: `battery_emplacement_01`
- In-engine readability test: compare directly against gate control and fortress-edge support in CH02 framing

## Review Checklist

- Is the prop immediately readable as a battery or artillery emplacement?
- Does it stay distinct from gate-control and lever language?
- Is the firing direction visible at small scale?
- Can it communicate siege threat without relying on glow or muzzle effects?
- Does it fit CH02's broken-fortress pressure tone?
