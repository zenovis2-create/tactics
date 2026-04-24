# Sprite Anchor Enemy Raider Spec

## Identity

- Asset ID: `sprite_anchor_enemy_raider_01`
- Working name: `Sprite Anchor Enemy Raider`
- Character type: enemy
- Class or archetype: pursuit infantry / authority raider
- Chapter or faction: early empire / authority field unit

## Purpose

- Primary use: establish the 2D battle-sprite production standard for baseline hostile melee infantry
- Runtime surface: battle sprite, idle baseline, move baseline, attack baseline
- Production role: enemy visual anchor for common authority-line units

## Sprite Pipeline Mode

- Production mode: 2D sprite sheet
- Source method: AI concept -> Krita cleanup -> Godot sprite import
- Proportion target: chibi-adjacent tactical sprite aligned to ally style family, but with harsher posture and more rigid silhouette
- Camera read target: battle-map first, portrait support second

## Visual Summary

- One-sentence pitch: a rigid empire pursuit soldier whose compressed posture and red-accent authority read make him feel hostile before detail
- Emotional read: pressure, obedience, suppression
- First-read silhouette: compact shieldless infantry block with wedge-like upper read and harsher forward angle
- Must-read class signal: hostile melee pursuer, clearly not an ally swordsman

## Style Rules

- Line character: clean and firm, slightly harsher than ally units
- Shading style: restrained cel-style shading with the same global finish as allies
- Detail budget: low-to-medium; authority shape language should do most of the work
- Chibi/stylization level: classic tactical JRPG sprite with slightly enlarged head and compact hostile body
- Forbidden polish: monstrous grimdark distortion, western gritty realism, overly cool antihero styling, FX-led hostility

## Proportion

- Head size note: slightly oversized for readable expression and enemy icon clarity
- Torso note: compact torso with rigid shoulder and chest shape
- Leg note: planted but slightly compressed stance
- Hand / weapon exaggeration: weapon may be slightly enlarged for hostile readability, but should stay lower-mass than boss weapons

## Loadout

- Primary weapon: short sword or crude authority blade
- Secondary item: optional small arm guard or reinforced shoulder, but no major ally-like shield silhouette
- Shield:
- Signature prop: authority strap, seal-mark cloth, or rigid pursuit-line gear read

## Material And Color Plan

- Primary materials: iron, leather, hard cloth
- Accent material: hostile seal mark or restrained execution-red trim
- Base palette: cold iron gray, soot leather, dark authority cloth
- Accent color: ember red
- Forbidden colors: ally gold, bright sacred white, clean hopeful sky-blue

## Animation Set

- Required states: `idle`, `move`, `attack`, `hit`
- Minimum states: `idle`, `attack`
- One-shot actions: `attack`, `hit`
- Looping actions: `idle`, `move`
- FX handled in character sheet or separated: no major FX; hostility must come from posture and silhouette

## Sheet Layout

- Required views or framing: front-facing gameplay sprite sequence only
- Sheet type: action sheet plus movement baseline
- Target frame count: 8-frame idle, 8-frame move, 8-frame attack
- Background: transparent or plain neutral backdrop during concept stage
- Transparent export needed: yes

## Runtime Readability

- Zoomed-out read goal: instantly distinguish hostile field infantry from Rian and Bran while remaining inside the same world
- Token/icon implication: enemy posture and accent placement should read clearly in token-size derivatives
- Failure conditions: reads like generic ally swordsman recolor, reads like a bandit from another game, silhouette depends on red accent alone

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: classic tactical JRPG enemy infantry sprite sheet, rigid empire pursuit soldier, compact tactical proportions, harsh authority posture, ember-red hostile accent, readable melee silhouette
- Must include: compressed hostile posture, enemy gear discipline, clear hostile read
- Must avoid: western gritty realism, monstrous proportions, ally-like warmth, boss-level ornament, magical aura

## Krita Notes

- Cleanup tasks: keep hostile red small and controlled, sharpen body posture, stabilize weapon angle
- Separation tasks: enemy silhouette should remain readable without relying on glow or strong background
- Text removal or label cleanup: remove any generated numbering or poster-like arrangement marks
- Frame consistency risks: drift toward ally body language, red accent spreading too far, face softening too much

## Godot Notes

- Import target: baseline enemy battle sprite
- Sprite slicing plan: fixed frame box and fixed foot-center pivot
- Animation names: `idle`, `move`, `attack`, `hit`
- Loop/non-loop notes: `idle` and `move` loop
- Test scene: battle scene next to Rian and Bran for ally/enemy distance check

## Review Checklist

- Does the unit read as hostile before color?
- Is the silhouette clearly different from ally swordsmen?
- Is the ember-red accent restrained but effective?
- Does the unit fit the same rendering family as the allies?
- Could this serve as a reusable enemy baseline?

