# Seal Frame 01 Spec

## Identity

- Asset ID: `prop_seal_frame_01`
- Working name: `Seal Frame`
- Prop family: seal device / archive landmark / unseal mechanism
- Chapter or environment family: CH05 gray archive / seal-pressure landmark

## Purpose

- Primary use: chapter-specific archive landmark for unseal beats, revision pressure, and controlled interaction footprints
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a rigid archive seal frame that reads as controlled truth-lock machinery before generic gate-control or desk furniture
- First-read shape: upright frame or plate structure with one clear sealed center
- Gameplay meaning: unseal target, record lock, revision barrier, controlled archive-state mechanism

## Scale

- Relative scale: taller and narrower than a desk, smaller than a gate structure
- Human comparison: chest-high to head-high frame one unit can clearly interact with
- Tile occupancy: one focal tile footprint with a clearly readable centerline

## Material Zones

- Primary material: dark iron or pale archive metal frame
- Secondary material: pale stone or lacquered support plate
- Accent material: restrained white seal line or pale glyph band
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal soot or paper dust micro-noise

## Color Plan

- Base palette: soot-dark iron, pale archive stone, parchment neutrals, ink-dark accents
- Accent color: restrained white
- Gameplay color cue: seal pressure, truth lock, controlled archive interaction

## Shape Rules

- Dominant silhouette: upright frame with a strong sealed center
- Core structural forms: outer frame, center plate or slot, lower base, side braces
- Allowed ornament: one seal band, one archive brace pattern, or one carved panel only
- Forbidden detail: giant cathedral arches, decorative book piles, crystal centerpiece, bureaucratic clutter, steampunk pipe nests

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable central lock area, deliberate frame profile, clear support base, controlled object staging
- If yes, what marker color family applies: white for seal or truth-lock priority, amber only if layered with local machine logic elsewhere
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from truth dais, gate control, and generic archive shelving
- Object icon requirement: yes, should extract a strong seal-frame icon from the same silhouette family
- Failure conditions: reads like a door, reads like gate-control recolor, or needs VFX alone to communicate seal pressure

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG archive seal frame prop, rigid iron frame with pale sealed center, restrained white truth-lock accent, painterly diorama style, gameplay-scale clarity
- Must include: strong frame silhouette, clear sealed center, archive-pressure feel, restrained detail
- Must avoid: cathedral arch excess, gate-door read, pipe clutter, crystal glow centerpiece, photoreal grime

## Rhino Notes

- Blockout priority: frame silhouette, sealed center, base support
- Material split strategy: outer frame / center plate / accent band
- Layer groups: `PROP_FRAME`, `PROP_CENTER`, `PROP_ACCENT`, `GUIDES`
- Named views: `SEAL_FRONT`, `SEAL_SIDE`, `SEAL_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify centerline and frame silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint clean and avoid surrounding shelf clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or archive preview support
- Filename target: `seal_frame_01`
- In-engine readability test: compare directly against truth dais and gate control in CH05 framing

## Review Checklist

- Is the prop immediately readable as a seal frame or truth-lock device?
- Does it stay distinct from gate control and truth dais language?
- Is the center seal area visible at small scale?
- Can it communicate archive pressure without relying on heavy FX?
- Does it fit CH05's archive-pressure tone?
