# Revision Core 01 Spec

## Identity

- Asset ID: `prop_revision_core_01`
- Working name: `Revision Core`
- Prop family: revision core / root-archive landmark / late-game pressure device
- Chapter or environment family: CH09B root archive / revision-pressure landmark

## Purpose

- Primary use: chapter-specific late-game archive landmark for revision pressure, central rewrite authority, and battlefield-rule mutation framing
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a rigid revision core that reads as central archive rewrite pressure before altar or ordinary keeper hardware
- First-read shape: concentrated core housing with one strong central seal or revision ring held inside a stable frame
- Gameplay meaning: revision field source, rule rewrite pressure, dangerous archive authority, late-game central objective

## Scale

- Relative scale: larger and denser than the lectern, smaller than a full chamber structure
- Human comparison: chest-high to head-high core device that dominates a tile and nearby rule reading
- Tile occupancy: one focal tile cluster with a clearly readable center

## Material Zones

- Primary material: dark archive metal or pale pressure-frame housing
- Secondary material: keeper braces, record clamps, or stabilizer struts
- Accent material: restrained white-cyan revision line with clipped root-seal geometry
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal grime or micro-etching

## Color Plan

- Base palette: soot-dark metal, pale archive stone, parchment-neutral edges, ink-black recesses
- Accent color: restrained white-cyan
- Gameplay color cue: dangerous revision authority and controlled rule mutation

## Shape Rules

- Dominant silhouette: stable frame around a concentrated central core
- Core structural forms: outer frame, center seal or ring, lower base, side stabilizers
- Allowed ornament: one clipped seal band, one root-record brace line, or one ring fracture only
- Forbidden detail: giant crystal spectacle, altar-like wings, pipe clutter, book piles, decorative baroque excess

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: clear central core, deliberate staging, stable outer frame, unmistakable high-value device silhouette
- If yes, what marker color family applies: white-cyan for revision pressure, hostile edge treatment only through gameplay overlays rather than baked glow
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from archive lectern, truth dais, altar, and gate control
- Object icon requirement: yes, should extract a strong revision-core icon from the same silhouette family
- Failure conditions: reads like generic machine box, reads like altar variant, or relies on VFX alone to communicate pressure

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG revision core prop, rigid archive frame with central seal core, restrained white-cyan revision accent, root-archive pressure feel, painterly diorama style, gameplay-scale clarity
- Must include: strong central core silhouette, stable outer frame, late-game rule-pressure feel, restrained detail
- Must avoid: crystal spectacle, altar wings, pipe clutter, photoreal grime, decorative clutter

## Rhino Notes

- Blockout priority: core silhouette, frame mass, center seal
- Material split strategy: core housing / stabilizers / accent line
- Layer groups: `PROP_CORE`, `PROP_FRAME`, `PROP_ACCENT`, `GUIDES`
- Named views: `CORE_FRONT`, `CORE_SIDE`, `CORE_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify central core and outer frame separation
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint clean and avoid shelf or aisle clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or root-archive preview support
- Filename target: `revision_core_01`
- In-engine readability test: compare directly against archive lectern, truth dais, and gate control in CH09B framing

## Review Checklist

- Is the prop immediately readable as a revision core or rewrite-pressure source?
- Does it stay distinct from archive lectern and altar language?
- Is the central core visible at small scale?
- Can it communicate late-game pressure without relying on heavy FX?
- Does it fit CH09B's root-archive pressure tone?
