# Transfer Gate Latch 01 Spec

## Identity

- Asset ID: `prop_transfer_gate_latch_01`
- Working name: `Transfer Gate Latch`
- Prop family: route latch / pursuit relief device / engineered remnant
- Chapter or environment family: CH08 split-line / route-release landmark

## Purpose

- Primary use: chapter-specific pursuit landmark for route release, blocked-lane relief, and engineered route-state change
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a compact transfer-gate latch that reads as route-release device and engineered remnant before generic gate-control or fortress machinery
- First-read shape: sturdy latch housing with one strong release arm or locking bar
- Gameplay meaning: open path, release blocked lane, relieve pursuit pressure, route-state change

## Scale

- Relative scale: larger than a lever, smaller than full gate machinery
- Human comparison: waist-high to chest-high mechanism clearly attached to a barrier or route edge
- Tile occupancy: one focal tile footprint with a readable control face

## Material Zones

- Primary material: dark iron latch body or locking plate
- Secondary material: weathered wood or stone support bracket
- Accent material: restrained amber or pale route marker
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal rust or grease noise

## Color Plan

- Base palette: soot-dark iron, weathered support wood, split-lane dust neutrals
- Accent color: restrained amber
- Gameplay color cue: route release and mechanical change, not sacred-object authority

## Shape Rules

- Dominant silhouette: compact mechanical housing with one readable release arm
- Core structural forms: latch plate, locking bar, hinge or release handle, base bracket
- Allowed ornament: one rivet band, one tension bolt, or one route notch only
- Forbidden detail: giant fortress gate framing, pipe clutter, decorative shrine motifs, steampunk gear nests, modern industrial realism

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: clear release arm, visible lock state, deliberate placement on a route edge or barrier
- If yes, what marker color family applies: amber for route release, pale white only if used as confirmation of state change elsewhere
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from split-marker post, altar, and gate-control
- Object icon requirement: yes, should extract a strong latch icon from the same silhouette family
- Failure conditions: reads like generic box clutter, reads like gate-control recolor, or needs UI arrows alone to communicate release meaning

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG route-release latch prop, compact iron latch housing, clear release arm, restrained amber route accent, painterly diorama style, gameplay-scale clarity
- Must include: strong release-mechanism silhouette, engineered remnant feel, pursuit-relief device identity, restrained detail
- Must avoid: giant gate framing, pipe clutter, shrine styling, modern industrial realism, text, labels, watermarks

## Rhino Notes

- Blockout priority: latch silhouette, release arm, support bracket
- Material split strategy: latch body / release arm / support bracket / accent marker
- Layer groups: `PROP_LATCH`, `PROP_ARM`, `PROP_BRACKET`, `PROP_ACCENT`, `GUIDES`
- Named views: `LATCH_FRONT`, `LATCH_SIDE`, `LATCH_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify release arm and lock state silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint tight and avoid environmental barrier clutter swallowing the mechanism

## Godot Notes

- Runtime slot target: future chapter-specific object icon or pursuit-lane preview support
- Filename target: `transfer_gate_latch_01`
- In-engine readability test: compare directly against split marker post and gate-control in CH08 framing

## Review Checklist

- Is the prop immediately readable as a route latch or release device?
- Does it stay distinct from split-marker and gate-control language?
- Is the release arm visible at small scale?
- Can it communicate route-state relief without relying on overlays?
- Does it fit CH08's pursuit-lane tone?
