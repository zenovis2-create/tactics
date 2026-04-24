# Robe Support 01 Spec

## Identity

- Asset ID: `prop_robe_support_01`
- Working name: `Robe Support`
- Prop family: armor
- Chapter or environment family: neutral ally robe-equipment baseline

## Purpose

- Primary use: robe equipment-support anchor for Serin-class and other support or caster-adjacent lanes
- Game surface: loadout support art, camp/interlude presentation, future equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a calm field robe set that reads as support-class attire before spell spectacle or luxury costume detail
- First-read shape: vertical cloth fall with readable collar, sleeve mass, and waist break
- Gameplay meaning: support or mystic field gear, not parade vestment or high-fantasy opera robe

## Scale

- Relative scale: torso-focused equipment-support set sized for compact support builds
- Human comparison: shoulder, chest, sleeve, and hem grouping rather than full mannequin suit
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: warm pale robe cloth
- Secondary material: muted leather belt, trim, or under-support cloth
- Accent material: restrained ash-violet or pale sacred trim
- Surface finish note: matte painted-miniature treatment, broad folds only

## Color Plan

- Base palette: warm white, parchment bone, ash-violet, muted leather brown
- Accent color: restrained soft violet
- Gameplay color cue: ally-facing support identity

## Shape Rules

- Dominant silhouette: vertical robe fall with compact shoulder and sleeve mass
- Core structural forms: collar, robe body, sleeve mass, belt or waist break, hem shape
- Allowed ornament: one restrained sacred trim line or small clasp detail
- Forbidden detail: oversized layered capes, lace borders, luxury embroidery, giant magic circles, dense trim patterns

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports class and loadout identity and should not read like a standalone character portrait

## Output Requirements

- Required views: upright or slightly angled robe support sheet, optional cropped icon
- Render target: equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as robe or support garment, not banner, cape, or dress costume
- Object icon requirement: optional future equipment icon
- Failure conditions: silhouette collapses into a plain cloth block, trim overwhelms the body, or the robe reads more glamorous than practical

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG robe support concept, calm field robe, warm white cloth, ash-violet trim, muted leather belt, clear support silhouette, transparent background
- Must include: readable vertical robe fall, collar and sleeve mass, practical support-class identity, grounded field-equipment feel
- Must avoid: ornate opera robe styling, giant capes, gold luxury trim, spell-effect spectacle, glossy loot-card rendering

## Krita Notes

- Cleanup tasks: preserve collar/sleeve/belt separation and keep the robe silhouette readable at small scale
- Icon extraction plan: crop from clean output only after equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze beyond the form

## Godot Notes

- Runtime slot target: future equipment-support destination, likely camp/interlude or party detail
- Filename target: `robe_support_01`
- In-engine readability test: compare against sacred staff and Serin-class reference surfaces

## Review Checklist

- Does it read as robe support gear before magic?
- Is the vertical silhouette readable at small size?
- Does the violet accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it visually consistent with current ally equipment language?
