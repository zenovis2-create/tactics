# Hostile Field Blade 01 Spec

## Identity

- Asset ID: `prop_hostile_field_blade_01`
- Working name: `Hostile Field Blade`
- Prop family: weapon
- Chapter or environment family: enemy authority melee equipment baseline

## Purpose

- Primary use: hostile melee equipment-support anchor for Enemy Raider and related pursuit infantry lanes
- Game surface: loadout support art, enemy equipment support, future hostile equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a rigid authority-side field blade that reads as coercive military gear before ornament
- First-read shape: short straight blade with compressed hostile guard and grip block
- Gameplay meaning: pursuit infantry sidearm, disciplined threat, hostile field issue weapon

## Scale

- Relative scale: one-handed hostile sidearm sized for raider-class and skirmisher backup reads
- Human comparison: hip-to-chest reach when worn
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: dark iron blade
- Secondary material: soot leather grip
- Accent material: restrained ember-red trim or seal mark
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: dark iron, soot leather, ash-black fittings
- Accent color: restrained ember red
- Gameplay color cue: hostile authority issue weapon, not ally field gear

## Shape Rules

- Dominant silhouette: straight compact blade with harsher guard geometry than ally sword
- Core structural forms: blade, guard, grip, pommel
- Allowed ornament: one small seal-mark or trim notch only
- Forbidden detail: hero-sword flourishes, luxury trim, jagged chaos excess, glowing runes, baroque handguard loops

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports hostile class identity and should not overpower the unit silhouette or become a trophy object

## Output Requirements

- Required views: upright equipment sheet, optional angled support render, cropped icon
- Render target: enemy equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as hostile short blade, not ally sword, not ritual dagger
- Object icon requirement: optional future hostile equipment icon
- Failure conditions: reads like ally recolor, loses guard break at small size, or becomes too ornate to reproduce consistently

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG hostile field blade equipment concept, short straight enemy sword, dark iron, soot leather grip, restrained ember-red seal accent, clear silhouette, transparent background
- Must include: readable guard, compressed hostile feel, practical military silhouette
- Must avoid: ally gold, sacred white accents, oversized anime blade, chaos-spike gimmick, glowing enchantment

## Krita Notes

- Cleanup tasks: preserve blade/guard separation and keep the silhouette tight
- Icon extraction plan: crop from clean output only after hostile equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze

## Godot Notes

- Runtime slot target: future hostile equipment-support destination or enemy dossier support
- Filename target: `hostile_field_blade_01`
- In-engine readability test: compare against `field_sword_01` and enemy unit token art

## Review Checklist

- Does it read hostile before color is noticed?
- Is the guard distinct at small size?
- Does the ember accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it clearly from the same world but not the same faction as ally equipment?
