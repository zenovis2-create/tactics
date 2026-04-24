# Field Lance 01 Spec

## Identity

- Asset ID: `prop_field_lance_01`
- Working name: `Field Lance`
- Prop family: lance
- Chapter or environment family: neutral ally cavalry and thrust-weapon baseline

## Purpose

- Primary use: thrust-weapon equipment-support anchor for officer, cavalry, and disciplined frontline lanes
- Game surface: loadout support art, camp/interlude presentation, future equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a disciplined field lance that reads as rank-and-thrust military gear before ceremonial prestige
- First-read shape: long thrusting line with narrow head and readable grip break
- Gameplay meaning: mounted or formation-ready pole weapon, not a fantasy relic spear

## Scale

- Relative scale: long reach weapon sized for officer and cavalry presentation
- Human comparison: clearly taller than the wielder, but still practical and field-manufactured
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: ash wood shaft
- Secondary material: muted steel lance head and butt cap
- Accent material: restrained navy wrap or pale rank-band accent
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: ash wood, muted steel, dark leather, subdued military neutrals
- Accent color: restrained navy
- Gameplay color cue: ally-facing disciplined military identity

## Shape Rules

- Dominant silhouette: long straight shaft with narrow thrusting head
- Core structural forms: shaft, head, grip-wrap zone, butt cap
- Allowed ornament: one restrained wrap or rank-band detail
- Forbidden detail: banner overload, giant fantasy wing blades, trident forks, tassel clutter, ceremonial gem-heavy polearms

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports class and faction identity and should not overpower the character silhouette or UI frame around it

## Output Requirements

- Required views: upright equipment sheet, optional angled support render, cropped icon
- Render target: equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as lance or thrust-weapon, not staff, pike prop, or generic spear branch
- Object icon requirement: optional future equipment icon
- Failure conditions: head disappears at small size, silhouette reads like a plain stick, or ornament makes it look ceremonial rather than military

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG field lance equipment concept, disciplined military thrust weapon, ash wood shaft, muted steel narrow head, restrained navy wrap accent, clear long silhouette, transparent background
- Must include: readable shaft, narrow head, practical officer or cavalry identity, grounded field-equipment feel
- Must avoid: giant fantasy halberd heads, banners, trident forms, gem overload, ornate ceremonial clutter, glossy hero-weapon rendering

## Krita Notes

- Cleanup tasks: preserve shaft/head separation and keep the narrow head readable at small scale
- Icon extraction plan: crop from clean output only after equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze beyond the form

## Godot Notes

- Runtime slot target: future equipment-support destination, likely camp/interlude or party detail
- Filename target: `field_lance_01`
- In-engine readability test: compare against field sword, sacred staff, and bow support surfaces

## Review Checklist

- Does it read as a lance before ornament?
- Is the head readable at small size?
- Does the navy accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it visually consistent with current ally equipment language?
