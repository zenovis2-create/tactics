# Heavy Armor Support 01 Spec

## Identity

- Asset ID: `prop_heavy_armor_support_01`
- Working name: `Heavy Armor Support`
- Prop family: armor
- Chapter or environment family: neutral ally heavy-armor equipment baseline

## Purpose

- Primary use: heavy armor equipment-support anchor for Bran-class and anchor-knight-adjacent lanes
- Game surface: loadout support art, camp/interlude presentation, future equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a broad field-armor set that reads as defensive heavy gear before prestige or parade detail
- First-read shape: broad cuirass with compact pauldron and waist mass
- Gameplay meaning: frontline heavy protection, not ceremonial plate or boss regalia

## Scale

- Relative scale: torso-focused equipment-support set sized for broad human frontline builds
- Human comparison: chest, shoulder, and waist armor grouping rather than full mannequin suit
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: muted steel plate shell
- Secondary material: dark leather straps and under-support
- Accent material: restrained deep navy cloth or enamel inset
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: ash steel, soot leather, muted brown support straps
- Accent color: deep navy
- Gameplay color cue: ally-facing heavy defense identity

## Shape Rules

- Dominant silhouette: broad cuirass, shoulder mass, clear waist break
- Core structural forms: breastplate, shoulder plates, leather strap logic, waist guard or tabard break
- Allowed ornament: one restrained heraldic plate break or navy inset
- Forbidden detail: parade gold trim, filigree borders, tiny rivet clutter, lace-like edge decoration, dense layered micro-plates

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports class and loadout identity and should not read like a standalone character portrait

## Output Requirements

- Required views: upright or slightly angled armor support sheet, optional cropped icon
- Render target: equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as heavy armor, not shield or generic metal slab
- Object icon requirement: optional future equipment icon
- Failure conditions: silhouette collapses into a rectangle, straps vanish, or detail noise overpowers the main mass

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG heavy armor support concept, broad field cuirass, muted steel plate, dark leather straps, restrained deep navy accent, clear heavy silhouette, transparent background
- Must include: broad chest mass, readable shoulder plates, practical strap logic, grounded ally heavy-class identity
- Must avoid: ornate parade armor, giant fantasy spikes, gold luxury overload, cape-led composition, glossy loot-card rendering

## Krita Notes

- Cleanup tasks: preserve chest/shoulder/strap separation and keep the silhouette broad at small scale
- Icon extraction plan: crop from clean output only after equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze beyond the form

## Godot Notes

- Runtime slot target: future equipment-support destination, likely camp/interlude or party detail
- Filename target: `heavy_armor_support_01`
- In-engine readability test: compare against paladin shield and anchor-knight reference surfaces

## Review Checklist

- Does it read as heavy armor before decoration?
- Is the broad chest and shoulder mass readable at small size?
- Does the navy accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it visually consistent with current ally equipment language?
