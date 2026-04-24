# Scavenged Cache 01 Spec

## Identity

- Asset ID: `prop_scavenged_cache_01`
- Working name: `Scavenged Cache`
- Prop family: chest / supply cache / investigation prop
- Chapter or environment family: CH01 ruined village / investigation reward landmark

## Purpose

- Primary use: interactable chapter-specific investigation prop for CH01 search points and quiet reward beats
- Game surface: battle map interaction object, chapter-specific prop, icon extraction support
- Runtime importance: focal secondary

## Visual Summary

- One-sentence pitch: a hastily hidden village cache that reads as searchable civilian stash before military loot chest
- First-read shape: compact crate or chest bundle with one readable lid or strapped cover break
- Gameplay meaning: investigate, recover clues or small supplies, reward careful routing

## Scale

- Relative scale: smaller than altar and well, larger than loose clutter
- Human comparison: knee-to-waist height stash that one unit can clearly inspect
- Tile occupancy: one focal secondary tile footprint

## Material Zones

- Primary material: worn wood crate or chest body
- Secondary material: cloth wrap, rope tie, or leather strap
- Accent material: restrained pale cloth tag or scavenged seal scrap
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal splinter noise

## Color Plan

- Base palette: dusty wood brown, dry cloth beige, muted leather, soot-dark bindings
- Accent color: restrained pale ash-blue or faded village cloth
- Gameplay color cue: investigation prop, not sacred objective and not military machinery

## Shape Rules

- Dominant silhouette: compact box or bundle mass with one clear opening plane
- Core structural forms: crate body, lid break, strap or wrap, small support feet if needed
- Allowed ornament: one cloth knot, seal scrap, or bundled paper edge only
- Forbidden detail: treasure-chest fantasy trim, jewel lock, weapon rack spill, ornate metal corners, clutter explosion

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable lid or opening plane, intentional placement, non-rubble silhouette, clear stash logic
- If yes, what marker color family applies: amber for interactability, no sacred white/gold hierarchy
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, lever, and generic barrel clutter
- Object icon requirement: yes, should extract a strong cache icon from the same silhouette family
- Failure conditions: reads like treasure reward chest, reads like rubble, or needs glow to communicate importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG ruined village scavenged cache interaction prop, worn wood crate, cloth wrap or strap, subtle investigation landmark, painterly diorama style, gameplay-scale clarity
- Must include: strong stash silhouette, readable opening plane, civilian scavenged feel, restrained detail
- Must avoid: ornate treasure chest styling, military supply crate overload, jewel lock, explosive clutter, photoreal wood

## Rhino Notes

- Blockout priority: box mass, lid or opening plane, wrap/strap logic
- Material split strategy: wood / cloth-or-leather wrap / accent scrap
- Layer groups: `PROP_CACHE`, `PROP_WRAP`, `PROP_ACCENT`, `GUIDES`
- Named views: `CACHE_FRONT`, `CACHE_SIDE`, `CACHE_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify lid break and icon silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the base footprint tight and avoid rubble spill around the prop

## Godot Notes

- Runtime slot target: future chapter-specific object icon or investigation preview support
- Filename target: `scavenged_cache_01`
- In-engine readability test: compare directly against memory well, altar, and generic village clutter in CH01 framing

## Review Checklist

- Is the prop immediately readable as a searchable cache?
- Does it stay distinct from altar, lever, and treasure-chest fantasy language?
- Is the opening plane visible at small scale?
- Can it communicate quiet investigation rather than loud reward spectacle?
- Does it fit CH01's ruined-village survival tone?
