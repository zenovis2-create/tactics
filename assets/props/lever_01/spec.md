# Lever 01 Spec

## Identity

- Asset ID: `prop_lever_01`
- Working name: `Lever 01`
- Prop family: lever / control device
- Chapter or environment family: fortress / monastery / archive machinery lane

## Purpose

- Primary use: interactable mechanical prop for battle maps
- Game surface: battle map interaction object, concept support, icon extraction
- Runtime importance: focal but secondary to altar-class sacred objectives

## Visual Summary

- One-sentence pitch: a sturdy mechanical lever housing that reads as tactical machinery before any icon or FX appears
- First-read shape: anchored base with upright handle and clear mechanical pivot
- Gameplay meaning: activate, reroute, unlock, or shift battlefield state

## Scale

- Relative scale: waist-high or chest-high against a unit
- Human comparison: large enough to read as a deliberate mechanism, not as clutter
- Tile occupancy: one major tile footprint

## Material Zones

- Primary material: iron or steel housing
- Secondary material: stone or wood base depending on map family
- Accent material: restrained brass, worn warning strip, or small cyan interaction cue

## Color Plan

- Base palette: dark iron, soot leather or wood, muted structural neutrals
- Accent color: restrained amber or cool cyan depending on system type
- Gameplay color cue: interactable machinery, not sacred object

## Shape Rules

- Dominant silhouette: upright handle plus clear base housing
- Core structural forms: base plate, pivot body, handle arm
- Allowed ornament: one clear mechanical plate break, bolts or hinge logic at large scale only
- Forbidden detail: tiny gears, exposed wire spaghetti, excessive engineer clutter, decorative scrollwork

## Interaction Read

- Is it interactable: yes
- If yes, what must signal interactivity: visible handle, anchored housing, distinct from altar/chest silhouettes
- If yes, what marker color family applies: amber by default, cyan if representing route or gate state change
- If no, how should it stay visually secondary:

## Output Requirements

- Required views: front, side, 3/4, board-context 3/4
- Render target: Rhino reference, Krita paintover, Godot object/icon extraction
- Export formats: PNG reference, OBJ/FBX if modeled
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: instantly distinguish from chest, altar, and gate
- Object icon requirement: yes
- Failure conditions: reads like debris, reads like furniture, depends on glow to feel actionable

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG mechanical lever interaction prop, readable handle and base housing, painterly diorama style, gameplay-scale clarity
- Must include: clear lever silhouette, anchored mechanical base, simple strong forms
- Must avoid: tiny gears, clutter, photoreal grime, overbuilt steampunk styling

## Rhino Notes

- Blockout priority: base mass first, then handle, then pivot logic
- Material split strategy: housing / base / accent
- Layer groups: `PROP_LEVER`, `PROP_BASE`, `PROP_ACCENT`, `GUIDES`
- Named views: `LEVER_FRONT`, `LEVER_SIDE`, `LEVER_THREE_QUARTER`

## Krita Notes

- Paintover tasks: sharpen handle readability and icon silhouette
- Icon extraction plan: derive from front or 3/4 silhouette
- Sheet cleanup needs: preserve mechanical clarity over decoration

## Godot Notes

- Runtime slot target: `lever.png` object icon family and battle interaction reference
- Filename target: if promoted, preserve lever naming consistency
- In-engine readability test: compare against altar and chest interaction props

## Review Checklist

- Is the lever immediately readable as machinery?
- Does it differ cleanly from altar and chest families?
- Is the handle visible at gameplay scale?
- Can it survive reduction without tiny detail?
- Does it fit the same world as fortress and monastery props?

