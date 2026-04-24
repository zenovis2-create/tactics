# Split Marker Post 01 Spec

## Identity

- Asset ID: `prop_split_marker_post_01`
- Working name: `Split Marker Post`
- Prop family: route marker / pursuit landmark / split-line guide
- Chapter or environment family: CH08 split-line / pursuit-pressure landmark

## Purpose

- Primary use: chapter-specific pursuit landmark for divided-route readability, fork pressure, and lane-comfort contrast
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal secondary

## Visual Summary

- One-sentence pitch: a stark route-marker post that reads as split-path guidance and pursuit pressure before shrine or machinery
- First-read shape: upright post with one or two directional arms or split-marker plates
- Gameplay meaning: divided route comfort, pursuit lane guidance, unsafe fork, commitment pressure

## Scale

- Relative scale: smaller than altar or gate-control, larger than loose forest clutter
- Human comparison: waist-high to chest-high marker one unit can clearly notice while moving
- Tile occupancy: one focal secondary tile footprint with a readable directional face

## Material Zones

- Primary material: weathered wood or dark iron post body
- Secondary material: marker plates, straps, or bracket hardware
- Accent material: restrained pale route paint or warning cloth strip
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal splinter or rust micro-noise

## Color Plan

- Base palette: weathered wood brown, soot-dark metal, split-lane dust neutrals
- Accent color: restrained pale white or faded danger-red cloth hint used sparingly
- Gameplay color cue: route choice and pursuit pressure, not sacred-object or machine authority

## Shape Rules

- Dominant silhouette: vertical post plus one clear split-direction arm
- Core structural forms: post, cross-arm or marker plate, support brace, base footing
- Allowed ornament: one carved arrow panel, one cloth strip, or one bracket only
- Forbidden detail: signboard clutter, hanging charm clusters, decorative shrine language, giant banners, modern road-sign styling

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable directional split, intentional path-facing placement, clear route-ownership logic
- If yes, what marker color family applies: pale white for route clarity, amber only if directly tied to a stateful interaction
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, lever, and generic branch clutter
- Object icon requirement: yes, should extract a strong route-marker icon from the same silhouette family
- Failure conditions: reads like a random branch post, reads like shrine clutter, or needs overlays alone to communicate divided-route meaning

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG split route marker post, weathered directional post with one or two route arms, restrained warning cloth, painterly diorama style, gameplay-scale clarity
- Must include: strong directional silhouette, pursuit-lane guidance feel, restrained detail
- Must avoid: road-sign modernity, decorative shrine styling, banner overload, photoreal wood or rust, text, labels, watermarks

## Rhino Notes

- Blockout priority: post silhouette, direction arm, base footing
- Material split strategy: post / marker plate / accent strip
- Layer groups: `PROP_POST`, `PROP_MARKER`, `PROP_ACCENT`, `GUIDES`
- Named views: `POST_FRONT`, `POST_SIDE`, `POST_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify directional read and split-lane silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint tight and avoid branch clutter swallowing the main post

## Godot Notes

- Runtime slot target: future chapter-specific object icon or split-line preview support
- Filename target: `split_marker_post_01`
- In-engine readability test: compare directly against altar and hunter-rig language in CH08 framing

## Review Checklist

- Is the prop immediately readable as a split-route marker?
- Does it stay distinct from altar and generic wilderness clutter?
- Is the directional arm visible at small scale?
- Can it communicate route commitment pressure without relying on UI overlays?
- Does it fit CH08's pursuit-lane tone?
