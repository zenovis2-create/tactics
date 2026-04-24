# Archive Lectern 01 Spec

## Identity

- Asset ID: `prop_archive_lectern_01`
- Working name: `Archive Lectern`
- Prop family: keeper lectern / revision control / root-archive landmark
- Chapter or environment family: CH09B root archive / revision-pressure landmark

## Purpose

- Primary use: chapter-specific late-game archive landmark for revision control, safe-cell creation, and keeper-record authority
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a rigid keeper lectern that reads as revision-control authority before altar or ordinary archive furniture
- First-read shape: upright lectern body with one strong reading plane and clipped seal hardware
- Gameplay meaning: archive rewrite control, safe-cell relief, keeper record authority, late-game rule intervention

## Scale

- Relative scale: similar to a truth dais but more vertical and more controlled
- Human comparison: chest-high station one unit can clearly operate under pressure
- Tile occupancy: one focal tile footprint with a clear front-facing interaction plane

## Material Zones

- Primary material: pale archive stone or lacquered lectern body
- Secondary material: dark keeper hardware, braces, or clipped seal fittings
- Accent material: restrained white-cyan revision line or pale seal band
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal paper or soot micro-noise

## Color Plan

- Base palette: pale archive stone, soot-dark metal, parchment bone, ink-dark neutral accents
- Accent color: restrained white-cyan
- Gameplay color cue: revision control and stabilizing intervention, not generic sacred objective

## Shape Rules

- Dominant silhouette: upright lectern mass with one clear reading plane
- Core structural forms: base, slanted plane, support brace, clipped seal hardware
- Allowed ornament: one clipped seal band, one keeper brace line, or one record plate only
- Forbidden detail: cathedral altar styling, giant codex stacks, crystal spectacle, desk clutter spread, ornate baroque trim

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable slanted plane, deliberate central staging, clear hardware lock point
- If yes, what marker color family applies: white-cyan for revision stabilization, white if the beat is truth-bearing rather than mechanical
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from truth dais, altar, and gate control
- Object icon requirement: yes, should extract a strong lectern icon from the same silhouette family
- Failure conditions: reads like generic desk furniture, reads like altar variant, or requires VFX alone to communicate revision control

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG archive lectern prop, rigid keeper reading station, pale archive stone, dark seal hardware, restrained white-cyan revision accent, painterly diorama style, gameplay-scale clarity
- Must include: strong lectern silhouette, readable slanted plane, revision-control authority, restrained detail
- Must avoid: cathedral altar styling, giant book clutter, crystal centerpiece, photoreal paper dust, decorative desk mess

## Rhino Notes

- Blockout priority: lectern mass, slanted plane, keeper hardware
- Material split strategy: body / hardware / accent line
- Layer groups: `PROP_LECTERN`, `PROP_HARDWARE`, `PROP_ACCENT`, `GUIDES`
- Named views: `LECTERN_FRONT`, `LECTERN_SIDE`, `LECTERN_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify reading plane and hardware silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint clean and avoid surrounding shelf clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or root-archive preview support
- Filename target: `archive_lectern_01`
- In-engine readability test: compare directly against truth dais and seal frame in CH09B framing

## Review Checklist

- Is the prop immediately readable as a keeper lectern or revision-control station?
- Does it stay distinct from truth dais and altar language?
- Is the slanted plane visible at small scale?
- Can it communicate stabilization or control without relying on heavy FX?
- Does it fit CH09B's root-archive pressure tone?
