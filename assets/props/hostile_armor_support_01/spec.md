# Hostile Armor Support 01 Spec

## Identity

- Asset ID: `prop_hostile_armor_support_01`
- Working name: `Hostile Armor Support`
- Prop family: armor
- Chapter or environment family: enemy authority armor baseline

## Purpose

- Primary use: hostile armor equipment-support anchor for Enemy Raider and coercive authority lanes
- Game surface: loadout support art, enemy equipment support, future hostile equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a compressed hostile armor set that reads as authority pressure before ceremonial rank
- First-read shape: rigid chest block with compressed shoulder mass and harsher plate edges
- Gameplay meaning: coercive field armor, suppression, enemy authority protection

## Scale

- Relative scale: torso-focused armor-support set sized for compact hostile infantry builds
- Human comparison: chest, shoulder, and waist grouping rather than a full mannequin suit
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: dark iron or blackened steel plate shell
- Secondary material: soot leather straps and under-support
- Accent material: restrained ember-red trim or hostile seal plate
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: dark iron, soot leather, ash-black straps
- Accent color: restrained ember red
- Gameplay color cue: hostile defensive authority, not ally fortress protection

## Shape Rules

- Dominant silhouette: compressed cuirass, hard shoulder line, rigid waist break
- Core structural forms: chest plate, shoulder plates, leather strap logic, lower plate break
- Allowed ornament: one hostile seal plate or trim bar only
- Forbidden detail: ally-like noble heraldry, gold trim, micro-plate clutter, parade armor, spiked chaos spectacle

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports enemy class identity and should not read like a standalone portrait prop

## Output Requirements

- Required views: upright or slightly angled armor support sheet, optional cropped icon
- Render target: enemy equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as hostile armor, not ally heavy armor or generic metal slab
- Object icon requirement: optional future hostile armor icon
- Failure conditions: reads like recolored ally armor, silhouette collapses into one black mass, or red trim becomes the only differentiator

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG hostile armor support concept, compressed enemy cuirass, dark iron plate, soot leather straps, restrained ember-red seal accent, clear hostile silhouette, transparent background
- Must include: rigid chest mass, readable shoulder plates, practical hostile authority feel
- Must avoid: ally noble armor language, gold trim, giant spikes, glossy loot-card rendering, decorative clutter

## Krita Notes

- Cleanup tasks: preserve chest/shoulder/strap separation and keep the hostile silhouette readable at small scale
- Icon extraction plan: crop from clean output only after enemy equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze

## Godot Notes

- Runtime slot target: future hostile equipment-support destination or enemy dossier support
- Filename target: `hostile_armor_support_01`
- In-engine readability test: compare against `heavy_armor_support_01`, `hostile_shield_01`, and enemy unit token art

## Review Checklist

- Does it read hostile before the red accent is noticed?
- Is the rigid chest block distinct at small size?
- Does the ember accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it clearly from the same world but not the same faction as ally armor?
