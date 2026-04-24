# Banner Mast 01 Spec

## Identity

- Asset ID: `prop_banner_mast_01`
- Working name: `Banner Mast`
- Prop family: fortress landmark / civic-military marker / chapter landmark
- Chapter or environment family: CH02 broken fortress / recapture identity landmark

## Purpose

- Primary use: chapter-specific fortress identity landmark for CH02 regroup, recapture, and military ownership beats
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a damaged fortress banner mast that reads as faction identity and contested ground before decorative heraldry
- First-read shape: tall vertical mast with one torn banner plane and a heavy stone or iron base
- Gameplay meaning: regroup point, recapture symbol, defended strongpoint, faction ownership marker

## Scale

- Relative scale: taller than local props, smaller than a full watchtower or gatehouse
- Human comparison: one mast that rises clearly above unit height and marks a control space
- Tile occupancy: one focal tile cluster with strong vertical read

## Material Zones

- Primary material: weathered timber or iron mast
- Secondary material: fortress stone or iron base housing
- Accent material: restrained Hardren-blue or faded military cloth banner
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal frayed-fabric micro-noise

## Color Plan

- Base palette: dark weathered timber, fortress stone neutrals, soot metal accents
- Accent color: muted fortress blue
- Gameplay color cue: defended territory, military identity, rally point

## Shape Rules

- Dominant silhouette: tall vertical mast with one readable banner plane
- Core structural forms: mast, base, banner or standard plane, top finial or fastening point
- Allowed ornament: one broad heraldic tear or emblem plane only
- Forbidden detail: luxurious parade drapery, multiple streamers, giant royal crests, decorative tassel forests, glossy ceremonial polish

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: strong landmark placement, readable banner plane, clear base ownership on the tile
- If yes, what marker color family applies: amber for interactability, fortress blue only as identity color and not as system-only marker
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from battery, gate control, and altar
- Object icon requirement: yes, should extract a strong banner-mast icon from the same silhouette family
- Failure conditions: reads like generic pole clutter, reads like a decorative flag instead of a landmark, or requires text or VFX to communicate importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG fortress banner mast prop, weathered vertical mast, torn military banner, heavy base, restrained fortress-blue accent, painterly diorama style, gameplay-scale clarity
- Must include: strong vertical silhouette, readable banner plane, fortress-identity feel, restrained detail
- Must avoid: parade-banner luxury, many streamers, oversized royal crest, glossy ceremonial polish, photoreal cloth

## Rhino Notes

- Blockout priority: mast height, base mass, banner plane read
- Material split strategy: mast / base / banner cloth
- Layer groups: `PROP_MAST`, `PROP_BASE`, `PROP_BANNER`, `GUIDES`
- Named views: `MAST_FRONT`, `MAST_SIDE`, `MAST_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify mast height and banner silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the base footprint compact and avoid excess loose fabric around the form

## Godot Notes

- Runtime slot target: future chapter-specific object icon or fortress preview support
- Filename target: `banner_mast_01`
- In-engine readability test: compare directly against battery emplacement and gate-control in CH02 framing

## Review Checklist

- Is the prop immediately readable as a fortress banner mast or rally landmark?
- Does it stay distinct from battery and gate-control language?
- Is the vertical silhouette visible at small scale?
- Can it communicate recapture identity without turning into parade decoration?
- Does it fit CH02's broken-fortress tone?
