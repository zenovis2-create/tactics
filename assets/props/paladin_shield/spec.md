# Paladin Shield Spec

## Identity

- Asset ID: `prop_paladin_shield_01`
- Working name: `Paladin Shield`
- Prop family: shield
- Chapter or environment family: neutral ally equipment baseline

## Purpose

- Primary use: character equipment anchor for knight and heavy frontline classes
- Game surface: battle map, inventory/support art, loadout renders
- Runtime importance: focal

## Visual Summary

- One-sentence pitch: a large, battle-worn knight shield that reads as reliable protection before ornament
- First-read shape: broad upper half with tapered lower body
- Gameplay meaning: frontline defense, oath-bearing ally gear

## Scale

- Relative scale: oversized for readability, covering shoulder-to-knee on anchor knight
- Human comparison: large enough to be a dominant silhouette feature
- Tile occupancy: visually significant but still attached gear, not a full obstacle prop

## Material Zones

- Primary material: worn steel shell
- Secondary material: dark leather grip and internal strap support
- Accent material: deep navy heraldic inset or enamel focal mark
- Surface finish note: low-gloss, painted miniature feel with broad wear, no micro-scratches

## Color Plan

- Base palette: muted iron gray and soot-dark leather
- Accent color: deep navy
- Gameplay color cue: ally-facing defensive identity, restrained noble tone

## Shape Rules

- Dominant silhouette: tall heater-style shield with strong top width
- Core structural forms: outer rim, central plate, one focal crest area
- Allowed ornament: one large heraldic symbol or central gem-like mark
- Forbidden detail: filigree, layered micro-trim, hanging tassels, thin chains, dense scripture

## Interaction Read

- Is it interactable: no
- If yes, what must signal interactivity:
- If yes, what marker color family applies:
- If no, how should it stay visually secondary: only secondary when off-character; on-character it should remain a major class read

## Output Requirements

- Required views: front, side, 3/4, equipped-on-character 3/4
- Render target: Rhino reference, Krita paintover, token/readability review
- Export formats: PNG reference sheet, OBJ and FBX if modeled as a separate reusable asset
- Transparent background needed: yes for equipment sheet extraction

## Runtime Readability

- Small-scale read goal: instantly distinguish knight/paladin class from lighter melee units
- Object icon requirement: no dedicated icon required yet
- Failure conditions: reads like generic wall slab, loses navy focal point, or becomes too ornate to reproduce cleanly

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: large veteran knight shield, painterly tactical RPG equipment concept, broad heater silhouette, worn steel and deep navy heraldry, strong readability, plain background
- Must include: thick rim, central focal mark, heavy readable shape
- Must avoid: gothic lace detail, tiny embossing, jewel overload, glossy realism

## Rhino Notes

- Blockout priority: silhouette first, then rim thickness, then central panel break
- Material split strategy: steel shell / leather grip / navy accent as separate layers or named parts
- Layer groups: `PROP_SHIELD`, `PROP_LEATHER`, `PROP_ACCENT`, `GUIDES`
- Named views: `SHIELD_FRONT`, `SHIELD_SIDE`, `SHIELD_THREE_QUARTER`

## Krita Notes

- Paintover tasks: sharpen heraldic focal area and value separation
- Icon extraction plan: optional later for loadout or UI support
- Sheet cleanup needs: keep neutral backdrop and clear contour edge

## Godot Notes

- Runtime slot target: equipment art reference, eventual loadout illustration support
- Filename target: if exported to runtime later, keep `paladin_shield_01`
- In-engine readability test: compare on knight token against lighter-class silhouettes

## Review Checklist

- Is the shield readable at gameplay scale?
- Does it communicate defense before decoration?
- Does the navy accent support ally identity without becoming flashy?
- Is the rim thick enough to survive reduction?
- Can it be modeled and rerendered without detail creep?

