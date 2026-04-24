# Hunter Rig 01 Spec

## Identity

- Asset ID: `prop_hunter_rig_01`
- Working name: `Hunter Rig`
- Prop family: trap device / forest landmark / hunter mechanism
- Chapter or environment family: CH03 Greenwood ambush / trap-literacy landmark

## Purpose

- Primary use: chapter-specific forest landmark for trap-route doubt, scouting literacy, and hunter-device pressure
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal secondary

## Visual Summary

- One-sentence pitch: a compact hunter trap rig that reads as suspicious local mechanism before generic clutter or fortress machinery
- First-read shape: anchored stake-and-frame device with one clear trigger element and tension line
- Gameplay meaning: suspicious tile, trap literacy, ambush setup, unsafe route tell

## Scale

- Relative scale: smaller than altar and well, larger than decorative sticks or roots
- Human comparison: knee-to-waist height device one scout could arm by hand
- Tile occupancy: one focal secondary tile footprint with clear local ownership

## Material Zones

- Primary material: weathered wood stakes and frame
- Secondary material: rope, resin lashings, or bent branch tension parts
- Accent material: restrained amber resin mark or pale trap-tag cloth
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal splinter or string micro-noise

## Color Plan

- Base palette: bark brown, dark rope, muted resin amber, moss-shadow neutrals
- Accent color: restrained amber
- Gameplay color cue: trap suspicion and local device pressure, not sacred-objective or military-control language

## Shape Rules

- Dominant silhouette: low anchored device with one readable trigger or tension element
- Core structural forms: stake anchors, frame, rope line, trigger head or tension arm
- Allowed ornament: one knot, one carved mark, or one resin seam only
- Forbidden detail: siege-engine complexity, giant blades, cartoon bear-trap teeth, vine clutter, decorative totems everywhere

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: intentional device silhouette, readable tension direction, non-natural geometry, clear suspicious footprint
- If yes, what marker color family applies: amber for interactability or suspicious mechanism, red only through gameplay overlays and not baked into the prop
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from lever, gate-control, and random branch clutter
- Object icon requirement: yes, should extract a strong hunter-device icon from the same silhouette family
- Failure conditions: reads like decorative branch pile, reads like fortress machinery, or needs hazard FX alone to communicate the threat

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG forest hunter rig trap prop, weathered stake-and-rope device, restrained amber resin mark, painterly diorama style, gameplay-scale clarity
- Must include: strong suspicious-device silhouette, readable trigger logic, local hunter mechanism feel, restrained detail
- Must avoid: siege-engine complexity, giant blades, fantasy trap excess, photoreal wood, decorative clutter

## Rhino Notes

- Blockout priority: stake anchors, trigger logic, tension line
- Material split strategy: wood stakes / rope or lashings / accent mark
- Layer groups: `PROP_RIG`, `PROP_LINE`, `PROP_ACCENT`, `GUIDES`
- Named views: `RIG_FRONT`, `RIG_SIDE`, `RIG_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify trigger silhouette and suspicious footprint
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint tight and avoid natural branch clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or forest preview support
- Filename target: `hunter_rig_01`
- In-engine readability test: compare directly against lever, gate-control, and forest tile context in CH03 framing

## Review Checklist

- Is the prop immediately readable as a hunter device or trap rig?
- Does it stay distinct from lever and generic forest clutter?
- Is the trigger logic visible at small scale?
- Can it communicate trap suspicion without relying on active hazard FX?
- Does it fit CH03's route-doubt and concealed-hostility tone?
