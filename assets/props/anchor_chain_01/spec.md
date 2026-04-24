# Anchor Chain 01 Spec

## Identity

- Asset ID: `prop_anchor_chain_01`
- Working name: `Anchor Chain`
- Prop family: terminal-control object / bell-lane anchor / endgame landmark
- Chapter or environment family: CH10 final approach / bell-pressure landmark

## Purpose

- Primary use: chapter-specific endgame landmark for bell-lane suppression, terminal route reopening, and final objective-state relief
- Game surface: battle map landmark, chapter-specific prop, icon extraction support
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a heavy anchor chain fixture that reads as terminal control of the bell-lane before generic machine clutter or shrine language
- First-read shape: anchored chain assembly with one clear locking point or restraint bar
- Gameplay meaning: release pressure, reopen final approach, interrupt the terminal bell line, endgame state-control object

## Scale

- Relative scale: larger and heavier than local latches, smaller than a full gatehouse
- Human comparison: chest-high to head-high chain assembly that dominates its tile cluster
- Tile occupancy: one focal tile footprint with a clear anchor point

## Material Zones

- Primary material: dark iron chain and anchor housing
- Secondary material: pale stone or dark support frame
- Accent material: restrained pale seal break or white-ash release mark
- Surface finish note: painterly diorama treatment, broad wear only, no photoreal rust or chain micro-noise

## Color Plan

- Base palette: blackened iron, ash-gray stone, soot-dark recesses, muted endgame neutrals
- Accent color: restrained pale white or ash-gold release mark
- Gameplay color cue: terminal suppression and last-route reopening, not generic machinery authority

## Shape Rules

- Dominant silhouette: heavy chain loop with one readable anchor fixture
- Core structural forms: chain line, anchor mount, lock point, support base
- Allowed ornament: one restraint plate, one seal break line, or one heavy bolt band only
- Forbidden detail: decorative chain forests, altar wings, giant bell bodies, crystal glow spectacle, steampunk pipe clutter

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: readable chain anchor point, clear lock state, deliberate central placement on the approach line
- If yes, what marker color family applies: pale white for release or severance relief, amber only if a broader interaction layer also exists
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if needed later
- Transparent background needed: yes for icon extraction support

## Runtime Readability

- Small-scale read goal: instantly distinguish from gate control, lectern, and ordinary chain clutter
- Object icon requirement: yes, should extract a strong anchor-chain icon from the same silhouette family
- Failure conditions: reads like random chain pile, reads like shrine remnant, or relies on VFX alone to communicate endgame importance

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG anchor chain control prop, heavy dark iron chain assembly, clear lock point, restrained pale release mark, painterly diorama style, gameplay-scale clarity
- Must include: strong anchor silhouette, readable chain line, terminal-control feel, restrained detail
- Must avoid: decorative chain clutter, giant bell body attachment, steampunk pipe nests, photoreal rust, shrine styling

## Rhino Notes

- Blockout priority: anchor point, chain line, lock fixture
- Material split strategy: chain / housing / accent mark
- Layer groups: `PROP_CHAIN`, `PROP_HOUSING`, `PROP_ACCENT`, `GUIDES`
- Named views: `CHAIN_FRONT`, `CHAIN_SIDE`, `CHAIN_THREE_QUARTER`

## Krita Notes

- Paintover tasks: clarify chain anchor and lock-state silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: keep the footprint tight and avoid environmental clutter swallowing the chain read

## Godot Notes

- Runtime slot target: future chapter-specific object icon or final-approach preview support
- Filename target: `anchor_chain_01`
- In-engine readability test: compare directly against bell-frame and gate-control language in CH10 framing

## Review Checklist

- Is the prop immediately readable as an anchor-chain control object?
- Does it stay distinct from gate-control and shrine language?
- Is the lock point visible at small scale?
- Can it communicate terminal release without relying on FX?
- Does it fit CH10's final bell-pressure tone?
