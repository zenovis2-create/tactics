# Bell Frame 01 Spec

## Identity

- Asset ID: `prop_bell_frame_01`
- Working name: `Bell Frame`
- Prop family: ritual-city landmark / bell mechanism / civic ritual prop
- Chapter or environment family: CH07 ritual city / sermon-pressure landmark

## Purpose

- Primary use: chapter-specific ritual-city landmark for civic pressure, sermon threat, and ceremonial route focus
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a restrained civic bell frame that reads as ritual-city warning and public pressure before generic shrine or machinery
- First-read shape: upright bell support frame with one clear suspended bell or bell housing
- Gameplay meaning: civic ritual pressure, warning toll, sermon-space authority, public-state landmark

## Scale

- Relative scale: taller than altar and lever, smaller than a full tower or gatehouse
- Human comparison: chest-high to head-high frame or shrine-scale bell support that can own a tile cluster
- Tile occupancy: one focal tile footprint with a strong vertical read

## Material Zones

- Primary material: pale stone or dark civic metal support frame
- Secondary material: bronze or iron bell body
- Accent material: restrained white-gold or muted civic cloth accent
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal metal noise

## Color Plan

- Base palette: pale civic stone, worn bronze, soot iron, muted neutral cloth
- Accent color: restrained white-gold
- Gameplay color cue: ritual-city pressure and public sacred authority

## Shape Rules

- Dominant silhouette: upright frame with one readable bell mass
- Core structural forms: support posts, crossbar, bell body, hanging point or bell housing
- Allowed ornament: one civic seal plate or one restrained cloth tab only
- Forbidden detail: cathedral overload, giant choir-frame complexity, many hanging charms, decorative chain forests, crystal glow spectacle

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable bell mass, clear frame support, deliberate city-facing presentation
- If yes, what marker color family applies: white-gold for civic ritual importance, amber only if the broader interaction system requires it
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, lever, and gate-control
- Object icon requirement: yes, should extract a strong bell-frame icon from the same silhouette family
- Failure conditions: reads like generic arch clutter, reads like machinery rather than ritual pressure, or requires VFX alone to communicate importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG ritual city bell frame prop, upright civic bell support, restrained bronze bell, pale stone or dark frame, painterly diorama style, gameplay-scale clarity
- Must include: strong bell silhouette, readable support frame, civic ritual pressure feel, restrained detail
- Must avoid: cathedral overload, giant choir-frame complexity, decorative chain forests, crystal glow spectacle, photoreal metal grime

## Rhino Notes

- Blockout priority: frame silhouette, bell body, hanging point
- Material split strategy: frame / bell / accent detail
- Layer groups: `PROP_BELL`, `PROP_FRAME`, `PROP_ACCENT`, `GUIDES`
- Named views: `BELL_FRONT`, `BELL_SIDE`, `BELL_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify bell silhouette and support frame
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint clean and avoid surrounding civic clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or ritual-city preview support
- Filename target: `bell_frame_01`
- In-engine readability test: compare directly against altar and gate-control in CH07 framing

## Review Checklist

- Is the prop immediately readable as a bell frame or civic ritual landmark?
- Does it stay distinct from altar and gate-control language?
- Is the bell silhouette visible at small scale?
- Can it communicate public pressure without relying on active sound or FX?
- Does it fit CH07's ritual-city tone?
