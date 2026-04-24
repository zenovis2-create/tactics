# Sacred Staff 01 Spec

## Identity

- Asset ID: `prop_sacred_staff_01`
- Working name: `Sacred Staff`
- Prop family: staff
- Chapter or environment family: neutral ally support equipment baseline

## Purpose

- Primary use: support-healer equipment-support anchor for Serin-adjacent lanes
- Game surface: loadout support art, camp/interlude presentation, future equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a compact sacred field staff that reads as calm support equipment before magic spectacle
- First-read shape: short vertical shaft with one readable sacred head motif
- Gameplay meaning: healer-support tool, not offensive relic weapon

## Scale

- Relative scale: short to medium staff sized for compact support-unit loadout presentation
- Human comparison: shoulder-to-head height when carried by Serin-class units
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: warm ash wood shaft
- Secondary material: pale metal or bone-like head structure
- Accent material: restrained sacred gem or ward inset
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: ash wood, parchment bone, pale silver, muted leather wrap
- Accent color: restrained sacred violet or pale blue-violet
- Gameplay color cue: ally-facing support identity

## Shape Rules

- Dominant silhouette: straight shaft with compact crowned head motif
- Core structural forms: shaft, head, grip wrap, small accent inset
- Allowed ornament: one sacred ring, petal, or ward-head motif only
- Forbidden detail: giant halo structures, dangling charms, excessive filigree, oversized crystal clusters, floating magic parts

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports healer-class identity and should not overpower the body silhouette or UI slot around it

## Output Requirements

- Required views: upright equipment sheet, optional angled support render, cropped icon
- Render target: equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as support staff, not spear, lance, or relic wand
- Object icon requirement: optional future equipment icon
- Failure conditions: head motif disappears at small size, silhouette reads like a spear, or the gem/glow dominates the structure

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG sacred staff equipment concept, compact healer staff, ash wood shaft, pale sacred metal head, restrained violet ward gem, clean silhouette, transparent background
- Must include: readable shaft, compact sacred head motif, support-class identity, grounded handcrafted feel
- Must avoid: oversized crystal staff, floating magic rings, offensive battle-mage spectacle, ornate ceremonial overload, spear-like proportions

## Krita Notes

- Cleanup tasks: preserve shaft/head separation and keep the head motif readable at small scale
- Icon extraction plan: crop from clean output only after equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze beyond the form

## Godot Notes

- Runtime slot target: future equipment-support destination, likely camp/interlude or party detail
- Filename target: `sacred_staff_01`
- In-engine readability test: compare against field sword and paladin shield support surfaces plus Serin-class token art

## Review Checklist

- Does it read as a support staff before magic?
- Is the head motif readable at small size?
- Does the sacred accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it visually consistent with current ally equipment language?
