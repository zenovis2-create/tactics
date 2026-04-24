# Hostile Shield 01 Spec

## Identity

- Asset ID: `prop_hostile_shield_01`
- Working name: `Hostile Shield`
- Prop family: shield
- Chapter or environment family: enemy authority defense baseline

## Purpose

- Primary use: hostile shield equipment-support anchor for Enemy Raider and related coercive frontline lanes
- Game surface: loadout support art, enemy equipment support, future hostile equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a harsh authority shield that reads as suppression and control before ornament
- First-read shape: compact wedge or heater-like hostile shield with a firm upper block
- Gameplay meaning: coercive defense, hostile pressure line, enemy-issued protective gear

## Scale

- Relative scale: medium shield sized to matter visually without becoming a heavy ally shield clone
- Human comparison: torso-covering shield for hostile infantry or enforcers
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: dark iron or blackened steel shield face
- Secondary material: soot leather strap support
- Accent material: restrained ember-red seal mark or hostile trim
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: dark iron, soot leather, ash-black fittings
- Accent color: restrained ember red
- Gameplay color cue: hostile defense and suppression, not noble protection

## Shape Rules

- Dominant silhouette: compact hostile shield block with a harder wedge read than ally shields
- Core structural forms: face, rim, strap support, one central mark or bar
- Allowed ornament: one seal mark, one heavy band, or one hostile plate break only
- Forbidden detail: ally heater-shield elegance, jewel insets, parade heraldry, luxury trim, giant spikes

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports enemy class identity and should not overpower the entire character silhouette

## Output Requirements

- Required views: front, side, 3/4, optional equipped-on-character 3/4
- Render target: enemy equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as hostile shield, not ally knight shield or generic wall scrap
- Object icon requirement: optional future hostile equipment icon
- Failure conditions: reads like recolored ally shield, loses wedge read at small size, or becomes too ornate to reproduce consistently

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG hostile shield equipment concept, compact authority shield, dark iron face, soot leather straps, restrained ember-red seal mark, clear silhouette, transparent background
- Must include: readable hostile wedge, practical suppression feel, enemy-issued gear language
- Must avoid: ally heater-shield elegance, luxury heraldry, oversized spikes, glowing sigils, decorative clutter

## Krita Notes

- Cleanup tasks: preserve face/rim/strap separation and keep the silhouette tight
- Icon extraction plan: crop from clean output only after hostile equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze

## Godot Notes

- Runtime slot target: future hostile equipment-support destination or enemy dossier support
- Filename target: `hostile_shield_01`
- In-engine readability test: compare against `paladin_shield`, `hostile_field_blade_01`, and enemy unit token art

## Review Checklist

- Does it read hostile before red is noticed?
- Is the wedge or suppressive block distinct at small size?
- Does the ember accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it clearly from the same world but not the same faction as ally shields?
