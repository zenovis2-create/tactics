# Sprite Anchor Enemy Skirmisher Spec

## Identity

- Asset ID: `sprite_anchor_enemy_skirmisher_01`
- Working name: `Sprite Anchor Enemy Skirmisher`
- Character type: enemy
- Class or archetype: hostile skirmisher / light pursuit hunter
- Chapter or faction: early empire / field pursuit detachments

## Purpose

- Primary use: establish the second hostile lane for enemy class-distance validation
- Runtime surface: battle sprite, idle baseline, move baseline, attack baseline
- Production role: enemy visual anchor for agile hostile units that are not heavy infantry

## Sprite Pipeline Mode

- Production mode: 2D sprite sheet
- Source method: AI concept -> Krita cleanup -> Godot sprite import
- Proportion target: chibi-adjacent tactical sprite aligned to hostile family, but lighter and faster than Enemy Raider
- Camera read target: battle-map first, portrait support second

## Visual Summary

- One-sentence pitch: a lighter hostile field hunter whose leaner silhouette and faster posture make it read as a pursuit skirmisher rather than a rigid infantry blocker
- Emotional read: predatory alertness, discipline, pressure
- First-read silhouette: lean hostile frame, light ranged or thrown-weapon read, compressed aggressive posture
- Must-read class signal: hostile agile threat, distinct from both ranger allies and enemy raider infantry

## Style Rules

- Line character: clean and firm, slightly harsher than ally ranged classes
- Shading style: restrained cel-style shading with the same global finish as allies and raider
- Detail budget: low-to-medium; silhouette and stance must do more work than trim
- Chibi/stylization level: classic tactical JRPG sprite with slightly enlarged head and compact tactical body
- Forbidden polish: glossy rogue coolness, magical assassin spectacle, gritty realism, oversized FX

## Proportion

- Head size note: slightly oversized for readable face and enemy icon clarity
- Torso note: lean torso with compressed hostile angle
- Leg note: compact but more agile than raider
- Hand / weapon exaggeration: weapon may be slightly enlarged for fast recognition, but should not dominate the whole silhouette

## Loadout

- Primary weapon: short bow, crossbow, or light hostile ranged tool
- Secondary item: minimal field utility gear or quiver
- Shield:
- Signature prop: pursuit-ready light weapon plus hostile posture

## Material And Color Plan

- Primary materials: iron fittings, leather, hard cloth
- Accent material: restrained ember-red hostile trim or seal mark
- Base palette: dark authority cloth, soot leather, iron gray
- Accent color: ember red
- Forbidden colors: ally gold, sacred white, vivid magical blue or green

## Animation Set

- Required states: `idle`, `move`, `attack`, `hit`
- Minimum states: `idle`, `attack`
- One-shot actions: `attack`, `hit`
- Looping actions: `idle`, `move`
- FX handled in character sheet or separated: keep attack read mostly weapon-led, with minimal hostile spark if needed

## Sheet Layout

- Required views or framing: front-facing gameplay sprite sequence only
- Sheet type: action sheet plus movement baseline
- Target frame count: 8-frame idle, 8-frame move, 8-frame attack
- Background: transparent or plain neutral backdrop during concept stage
- Transparent export needed: yes

## Runtime Readability

- Zoomed-out read goal: instantly distinguish from ally ranger, ally frontline, and enemy raider
- Token/icon implication: lean hostile posture and light weapon should remain readable at token size
- Failure conditions: reads like Tia recolored, reads like generic rogue from another game, depends on red accent alone

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: classic tactical JRPG hostile skirmisher sprite sheet, lean empire pursuit hunter, compact tactical proportions, light ranged weapon, ember-red hostile accent, same rendering family as enemy raider
- Must include: lighter hostile silhouette, pursuit posture, enemy-coded gear discipline
- Must avoid: ally ranger softness, magical spectacle, western gritty realism, assassin-glamour coolness, oversized weapon effects

## Krita Notes

- Cleanup tasks: keep weapon silhouette readable, reinforce hostile posture, control red accent spread
- Separation tasks: make sure the unit still reads hostile with color muted
- Text removal or label cleanup: remove generated numbering or poster-like arrangement
- Frame consistency risks: drifting too close to ally ranger body language, losing hostile compression, over-lightening the value structure

## Godot Notes

- Import target: hostile skirmisher battle sprite
- Sprite slicing plan: fixed frame box and fixed foot-center pivot
- Animation names: `idle`, `move`, `attack`, `hit`
- Loop/non-loop notes: `idle` and `move` loop
- Test scene: compare directly against Enemy Raider and Tia

## Review Checklist

- Does the unit read as hostile before red is noticed?
- Is it clearly lighter and faster than Enemy Raider?
- Is it clearly not an ally ranger recolor?
- Does it stay in the same rendering family as the current roster?
- Could this serve as the second hostile baseline?

