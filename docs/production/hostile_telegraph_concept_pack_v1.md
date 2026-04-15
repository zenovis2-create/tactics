# Hostile Telegraph Concept Pack V1

## Purpose

This document locks the first hostile telegraph concept pack for `Memory Tactics RPG`.
It translates the broader FX direction into four concrete hostile states that fit the current Godot runtime:

- `mark`
- `charge`
- `command buff`
- `boss danger`

This is an internal production and implementation handoff.
It is not a replacement for `docs/production/fx_telegraph_visual_pack.md`.

## Source Anchors

- global FX language: `docs/production/fx_telegraph_visual_pack.md`
- CH1 boss encounter intent: `docs/production/ch1/ch1_encounter_pacing_variety_spec.md`
- CH1 cross-team lock: `docs/production/ch1/ch1_handoff_gameplay_ui_art_marketing.md`
- live boss telegraph runtime: `scripts/battle/battle_controller.gd`
- live unit feedback nodes: `scripts/battle/unit_actor.gd`, `scenes/battle/Unit.tscn`
- live HUD feedback channel: `scripts/battle/battle_hud.gd`

## Artifact

- concept sheet: `artifacts/ash29/ash29_hostile_telegraph_concept_sheet_v1.png`

## Direction Lock

`Classic tactical pursuit warning`

- These telegraphs should read like battlefield orders, pursuit marks, and danger seals.
- They must stay flatter and more diagrammatic than modern spell VFX.
- Every state needs one dominant read before any secondary ornament.
- The pack should feel compatible with the current portrait and icon direction, especially the ash, parchment, ember, and clipped-seal grammar.

## Runtime Reality

Current implementation only gives us a narrow battle-feedback surface:

- Per-unit marker block via `Unit/Marker`, currently a `ColorRect`.
- Per-unit telegraph text via `Unit/TelegraphLabel`, currently used only for `MARK`.
- HUD transition text via `BattleHUD.set_transition_reason(...)`.
- Boss-state logic via:
  - `boss_mark_telegraphed`
  - `boss_command_buff`
  - `boss_charge_resolve`

Current implementation does **not** provide:

- animated particle systems
- shader-based area telegraphs
- per-state sprite slots on `UnitActor`
- dedicated boss danger overlay nodes

Any art production for this pack must survive those constraints.

## Visual Treatments

### Mark

- Read: `this unit is being hunted next`
- Primary shape: compact stamped ring with one broken seal tick
- Secondary reinforcement: inward target notch or map-tick pin
- Value behavior: bright ember edge, pale interior break, restrained dark under-stamp
- Terrain behavior: survives over mixed ground by relying on silhouette and edge contrast, not fill mass

Implementation mapping:

- Current fallback: `TelegraphLabel = MARK` plus stronger marker tint on the target unit
- Next-safe runtime hook: swap `ColorRect` marker for a texture-backed sprite or add a child `Sprite2D` ring above the unit
- Animation budget: slow opacity pulse or one-step seal snap, no multi-layer particle bloom

### Charge

- Read: `the boss will rush in this direction on the next enemy phase`
- Primary shape: lane arrow or fracture wedge with a forward thrust read
- Secondary reinforcement: broken directional bars or clipped chevrons
- Value behavior: strongest contrast at the edge and head of the wedge, not in the center fill
- Spatial behavior: should scale from one-cell read to a short path or lane read

Implementation mapping:

- Current fallback: `BattleHUD` transition reason text only
- Next-safe runtime hook: lightweight lane overlay texture aligned to path cells or a sequence of simple arrow decals
- Animation budget: one traveling edge sweep or subtle forward pulse

### Command Buff

- Read: `nearby enemies have received a tactical order`
- Primary shape: compact command seal, short bars, or clipped pulse brackets around the affected cluster
- Secondary reinforcement: repeated command ticks, not healing circles
- Value behavior: lower intensity than `boss danger`, but clearer than normal enemy state
- Semantic guardrail: must not look like ally support or sacred healing

Implementation mapping:

- Current fallback: `BattleHUD` transition reason text with `+1 ATK`
- Next-safe runtime hook: brief enemy-adjacent seal sprite or a radius-2 command flash around affected enemies
- Animation budget: single ring expansion or bar pulse, then settle

### Boss Danger

- Read: `this zone or boss action is the highest immediate threat on the board`
- Primary shape: large clipped circle or danger plate with a crisp red boundary
- Secondary reinforcement: boss-grade seal fracture or command crest
- Value behavior: low-opacity center fill, strongest read on the perimeter, sparse high-contrast symbols
- Encounter role: should fit the short exam-like boss map in `CH01_05` without covering units or labels

Implementation mapping:

- Current fallback: transition text plus any marked-unit feedback already present
- Next-safe runtime hook: one overlay texture for danger cells or a boss-adjacent plate anchored in the battlefield layer
- Animation budget: slow breathing alpha or edge flash on state entry

## Production Rules

- Build for `64x64` cell-scale readability first.
- Assume labels and HP text remain visible near the unit.
- Keep negative space so later motion can be added without muddying the image.
- Prefer one clean silhouette plus one secondary recognition detail.
- Use ember red, ash white, parchment neutrals, and clipped dark gray only.
- Do not introduce generic purple energy, giant ritual circles, glossy sci-fi UI, or smoke-heavy painterly effects.

## Engineering Contract

If this pack is implemented in-engine, keep the integration sequence narrow:

1. Add telegraph art as simple overlay textures or sprites, not particles.
2. Route state changes through the existing boss event reasons before adding new gameplay events.
3. Keep all timing lightweight enough for the Godot mobile renderer and current HUD cadence.
4. Preserve existing text feedback as fallback until visual hooks prove readable.

Recommended future node additions, if engineering picks this up:

- `Unit/TelegraphSprite` for per-unit state marks
- `BattleScene/TelegraphOverlayRoot` for lane or danger-zone decals
- optional tiny `AnimationPlayer` or tween-driven pulses instead of shader-heavy effects

## Review Checklist

- Can each state be identified in under one second without reading text?
- Does `mark` read as pursuit rather than magic?
- Does `charge` imply direction instead of just intensity?
- Does `command buff` avoid ally-support confusion?
- Does `boss danger` stay readable without flooding the battlefield?
- Can the current runtime still communicate the state if the art is temporarily absent?
