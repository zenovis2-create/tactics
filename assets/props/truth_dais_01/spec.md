# Truth Dais 01 Spec

## Identity

- Asset ID: `prop_truth_dais_01`
- Working name: `Truth Dais`
- Prop family: evidence landmark / archive dais / truth-bearing object
- Chapter or environment family: CH05 gray archive / evidence-pressure landmark

## Purpose

- Primary use: chapter-specific archive landmark for evidence focus, truth-bearing interaction, and investigation pressure
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a formal archive truth dais that reads as evidence-bearing authority before altar or generic desk furniture
- First-read shape: raised tabletop or lectern-height platform with one clear document or seal presentation plane
- Gameplay meaning: truth anchor, evidence objective, investigation climax surface, sanctioned record point

## Scale

- Relative scale: smaller than an altar platform, larger and cleaner than ordinary archive furniture
- Human comparison: waist-high to chest-high station one unit can clearly inspect
- Tile occupancy: one focal tile footprint with a deliberate presentation face

## Material Zones

- Primary material: pale archive stone or lacquered desk-like body
- Secondary material: dark iron braces or codex support hardware
- Accent material: restrained white truth-light or pale seal marking
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal paper stacks or dust micro-noise

## Color Plan

- Base palette: pale ash stone, soot-dark iron, parchment bone, ink-dark neutral accents
- Accent color: restrained white
- Gameplay color cue: truth-bearing and evidence priority, distinct from sacred gold or machinery amber

## Shape Rules

- Dominant silhouette: stable dais or lectern mass with one clear top presentation plane
- Core structural forms: base, top plane, codex or seal rest, support braces
- Allowed ornament: one seal plate, one carved edge band, or one codex brace only
- Forbidden detail: cathedral altar language, giant book stacks, decorative quills everywhere, crystal spectacle, bureaucratic clutter sprawl

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable top plane, deliberate object staging, intentional centerline, clean negative space around the prop
- If yes, what marker color family applies: white for evidence or truth priority, amber only if a mechanical action layer is also present elsewhere
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from altar, gate control, and generic archive desk clutter
- Object icon requirement: yes, should extract a strong truth-dais icon from the same silhouette family
- Failure conditions: reads like furniture, reads like altar variant, or needs glow alone to communicate evidence importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG archive truth dais prop, pale stone or lacquered lectern platform, restrained white truth accent, dark archive hardware, painterly diorama style, gameplay-scale clarity
- Must include: strong presentation plane, evidence-bearing authority, archive pressure feel, restrained detail
- Must avoid: cathedral altar styling, giant book clutter, decorative desk mess, crystal glow centerpiece, photoreal paper noise

## Rhino Notes

- Blockout priority: dais mass, top plane, brace logic
- Material split strategy: body / hardware / accent plane
- Layer groups: `PROP_DAIS`, `PROP_BRACE`, `PROP_ACCENT`, `GUIDES`
- Named views: `DAIS_FRONT`, `DAIS_SIDE`, `DAIS_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify top plane and evidence silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint clean and avoid surrounding shelf clutter bleeding into the asset

## Godot Notes

- Runtime slot target: future chapter-specific object icon or archive preview support
- Filename target: `truth_dais_01`
- In-engine readability test: compare directly against altar and gate control in CH05 framing

## Review Checklist

- Is the prop immediately readable as a truth or evidence dais?
- Does it stay distinct from altar and archive furniture?
- Is the top plane visible at small scale?
- Can it communicate evidence priority without relying on strong FX?
- Does it fit CH05's archive-pressure tone?
