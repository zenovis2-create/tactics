# Short Bow 01 Spec

## Identity

- Asset ID: `prop_short_bow_01`
- Working name: `Short Bow`
- Prop family: bow
- Chapter or environment family: neutral ally ranged equipment baseline

## Purpose

- Primary use: ranged equipment-support anchor for Tia-class and other ranger or skirmisher lanes
- Game surface: loadout support art, camp/interlude presentation, future equipment icons
- Runtime importance: support

## Visual Summary

- One-sentence pitch: a practical field bow that reads as agile ranged gear before hunting-romance ornament
- First-read shape: compact recurve arc with clear grip break
- Gameplay meaning: reliable ranged field weapon, not ceremonial trophy gear

## Scale

- Relative scale: short to medium bow sized for compact tactical units
- Human comparison: body-height or slightly shorter when strung
- Tile occupancy: not a map prop, only an equipment-support surface

## Material Zones

- Primary material: warm ash or dark field wood bow body
- Secondary material: muted leather grip wrap
- Accent material: restrained pale metal fastener or moss-green wrap accent
- Surface finish note: matte painted-miniature treatment, broad wear only

## Color Plan

- Base palette: ash wood, dark leather, brown wrap, subdued field neutrals
- Accent color: restrained moss green
- Gameplay color cue: ally-facing ranged identity

## Shape Rules

- Dominant silhouette: clear arc with visible grip break and compact limb tips
- Core structural forms: upper limb, lower limb, grip, string line
- Allowed ornament: one restrained wrap accent or small fastening detail
- Forbidden detail: giant heroic longbow proportions, antler flourishes, dangling trophies, excessive leaf ornament, glowing arrows

## Interaction Read

- Is it interactable: no
- If no, how should it stay visually secondary: it supports class identity and should not overpower the character silhouette or UI frame around it

## Output Requirements

- Required views: upright or slightly angled equipment sheet, optional support render, cropped icon
- Render target: equipment support surfaces and future UI extraction
- Export formats: transparent PNG
- Transparent background needed: yes

## Runtime Readability

- Small-scale read goal: immediately read as bow, not staff, lance, or decorative branch
- Object icon requirement: optional future equipment icon
- Failure conditions: arc disappears at small size, grip break vanishes, or the bow becomes too ornate to reproduce consistently

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: tactical RPG short bow equipment concept, compact field bow, ash wood, dark leather grip, restrained moss-green accent, clear arc silhouette, transparent background
- Must include: readable arc, visible grip break, practical ranger identity, grounded field-equipment feel
- Must avoid: giant sniper bow, ornate elven fantasy overload, neon magical arrow effects, antler clutter, glossy hero-weapon rendering

## Krita Notes

- Cleanup tasks: preserve arc/grip/string readability and keep the limb tips clean
- Icon extraction plan: crop from clean output only after equipment surface framing is confirmed
- Sheet cleanup needs: neutral transparent background, no paper tone, no glow haze beyond the form

## Godot Notes

- Runtime slot target: future equipment-support destination, likely camp/interlude or party detail
- Filename target: `short_bow_01`
- In-engine readability test: compare against sacred staff, field sword, and Tia-class token art

## Review Checklist

- Does it read as a bow before ornament?
- Is the arc readable at small size?
- Does the green accent stay secondary?
- Can the silhouette survive icon reduction?
- Is it visually consistent with current ally equipment language?
