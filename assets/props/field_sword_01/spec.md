# Field Sword 01 Spec

## Identity

- Asset ID: `prop_field_sword_01`
- Working name: `Field Sword`
- Prop family: sword
- Chapter or environment family: neutral ally equipment baseline

## Purpose

- Primary use: frontline equipment-support anchor for command swordsman and knight-adjacent lanes
- Game surface: loadout support art, camp/interlude presentation, future equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a disciplined one-handed battlefield sword that reads as serviceable frontline gear before prestige
- First-read shape: straight blade with stable guard and compact pommel
- Gameplay meaning: reliable field weapon, not ceremonial relic

## Scale

- Relative scale: one-handed sidearm sized for Rian-class and Bran backup weapon reads
- Human comparison: hip-to-chest reach when worn
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: muted steel blade
- Secondary material: dark leather grip
- Accent material: restrained ash-bronze guard or muted navy pommel inset
- Surface finish note: low-gloss painted-miniature treatment, broad wear only

## Color Plan

- Base palette: ash steel, dark leather, brown grip wraps
- Accent color: muted navy
- Gameplay color cue: ally-facing reliable frontline equipment

## Shape Rules

- Dominant silhouette: straight blade, compact crossguard, grounded pommel
- Core structural forms: blade, guard, grip, pommel
- Allowed ornament: one restrained accent on pommel or guard
- Forbidden detail: jewel-heavy fantasy trim, serration clutter, filigree, lace-like guard shapes, oversized hero-weapon proportions

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports character/loadout read and should not overpower shield-heavy or class-silhouette surfaces

## Output Requirements

- Required views: upright equipment sheet, optional angled support render, cropped icon
- Render target: equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as standard frontline sword, not greatsword, staff, or relic
- Object icon requirement: optional future equipment icon
- Failure conditions: reads as generic silver line with no grip/guard break, or becomes too ornate to reproduce consistently

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG field sword equipment concept, straight one-handed battlefield blade, muted steel, dark leather grip, restrained navy accent, clear silhouette, transparent background
- Must include: readable guard, grip, pommel, practical military silhouette
- Must avoid: oversized anime hero sword, glowing runes, ceremonial overload, jagged chaos ornament

## Krita Notes

- Cleanup tasks: preserve blade/guard separation and keep edge silhouette stable
- Icon extraction plan: crop from clean output only after loadout destination is chosen
- Sheet cleanup needs: neutral transparent background, no paper tone

## Godot Notes

- Runtime slot target: future equipment-support destination, likely camp/interlude or party detail
- Filename target: `field_sword_01`
- In-engine readability test: compare against paladin shield support surface and frontline token art

## Review Checklist

- Does it read as a practical frontline weapon before ornament?
- Is the guard distinct at small size?
- Does the navy accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it visually consistent with current ally equipment language?
