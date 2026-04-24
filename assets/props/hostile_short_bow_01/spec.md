# Hostile Short Bow 01 Spec

## Identity

- Asset ID: `prop_hostile_short_bow_01`
- Working name: `Hostile Short Bow`
- Prop family: weapon
- Chapter or environment family: enemy authority ranged equipment baseline

## Purpose

- Primary use: hostile ranged equipment-support anchor for Enemy Skirmisher and related pursuit-hunter lanes
- Game surface: loadout support art, enemy equipment support, future hostile equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a compact hostile field bow that reads as pursuit equipment before hunter romance or ally ranger styling
- First-read shape: tight bow arc with a severe grip break and restrained hostile fittings
- Gameplay meaning: enemy pursuit ranged tool, disciplined pressure weapon, hostile field issue gear

## Scale

- Relative scale: short to medium bow sized for compact hostile units
- Human comparison: body-height or slightly shorter when strung
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: dark field wood or blackened composite bow body
- Secondary material: soot leather grip wrap
- Accent material: restrained ember-red seal strip or hardware mark
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: dark wood, soot leather, ash-black fittings
- Accent color: restrained ember red
- Gameplay color cue: hostile ranged identity, not ally hunter gear

## Shape Rules

- Dominant silhouette: compact hostile arc with visible grip break
- Core structural forms: upper limb, lower limb, grip, string line
- Allowed ornament: one seal strip or one hostile fastening detail only
- Forbidden detail: elven flourish, antler motifs, glowing arrow language, oversized heroic longbow proportions, ally-style ranger charm

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports hostile class identity and should not become a trophy prop or overpower unit posture

## Output Requirements

- Required views: upright equipment sheet, optional angled support render, cropped icon
- Render target: enemy equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as hostile bow, not ally ranger bow, staff, or decorative branch
- Object icon requirement: optional future hostile equipment icon
- Failure conditions: reads like ally recolor, grip break vanishes at small size, or ornament outweighs the threat read

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG hostile short bow equipment concept, compact enemy bow, dark wood, soot leather grip, restrained ember-red hostile seal accent, clear silhouette, transparent background
- Must include: readable arc, hostile grip break, practical pursuit-hunter identity, grounded field-equipment feel
- Must avoid: ally green cues, elven flourish, magical arrow effects, oversized heroic bow, decorative clutter

## Krita Notes

- Cleanup tasks: preserve arc/grip/string readability and keep the hostile silhouette tight
- Icon extraction plan: crop from clean output only after hostile equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze

## Godot Notes

- Runtime slot target: future hostile equipment-support destination or enemy dossier support
- Filename target: `hostile_short_bow_01`
- In-engine readability test: compare against `short_bow_01`, `hostile_field_blade_01`, and enemy skirmisher token art

## Review Checklist

- Does it read hostile before the red accent is noticed?
- Is the grip break distinct at small size?
- Does the ember accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it clearly hostile and not an ally ranger recolor?
