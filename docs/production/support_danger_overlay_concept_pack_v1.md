# Support And Danger Overlay Concept Pack V1

## Purpose

This document locks the first ally support and battlefield danger overlay pack for `Memory Tactics RPG`.
It translates the broader FX direction into three concrete readable states that fit the current Godot runtime:

- `heal`
- `protect`
- `danger zone`

This is an internal production and implementation handoff.
It is not a replacement for `docs/production/fx_telegraph_visual_pack.md`.

## Source Anchors

- global FX language: `docs/production/fx_telegraph_visual_pack.md`
- portrait/style anchor: `artifacts/ash15/ash15_portrait_sheet_v3.png`
- icon/style anchor: `artifacts/ash16/ash16_equipment_icon_sheet_v1.png`
- hostile telegraph baseline: `docs/production/hostile_telegraph_concept_pack_v1.md`
- live battle HUD shell: `scripts/battle/battle_hud.gd`, `scenes/battle/BattleHUD.tscn`
- live unit feedback nodes: `scripts/battle/unit_actor.gd`, `scenes/battle/Unit.tscn`
- live objective/interactable state: `scripts/battle/battle_controller.gd`, `scripts/battle/interactive_object_actor.gd`

## Artifact

- concept sheet: `artifacts/ash30/ash30_support_danger_overlay_concept_sheet_v1.png`

## Direction Lock

`Classic tactical protection clarity`

- These overlays should read like vows, wards, and battlefield caution plates.
- They must stay flatter and more diagrammatic than modern spell FX.
- Every state needs one dominant read before any secondary ornament.
- The pack should feel compatible with the current portrait and icon direction, especially the ash, parchment, vow-gold, pale-blue, and clipped-seal grammar.

## Runtime Reality

Current implementation gives us only a narrow battle-feedback surface:

- Per-unit marker block via `Unit/Marker`, currently a `ColorRect`.
- Per-unit text feedback via `Unit/TelegraphLabel`, currently used only for `MARK`.
- HUD objective and transition text via `BattleHUD`.
- Full-screen UI dimmer via `BattleHUD/OverlayScrim`.
- Objective-state tracking from `BattleController.get_objective_state_snapshot()`.
- Interactable object marker blocks via `InteractiveObject/Marker`.

Current implementation does **not** provide:

- heal or protect gameplay events
- dedicated support FX sprite slots on units
- tile-anchored battlefield overlay nodes
- shader-based zone plates
- icon-backed objective or danger overlays in battle space

Any art production for this pack must survive those constraints.

## Visual Treatments

### Heal

- Read: `this unit is being restored or stabilized`
- Primary shape: open ward ring or lifted hand-seal arc
- Secondary reinforcement: one small inner pulse tick or vow notch
- Value behavior: pale blue center restraint with clean soft-white edge and a small gold accent
- Semantic guardrail: should feel calm and restorative, not explosive or magical-swirly

Implementation mapping:

- Current fallback: `BattleHUD` transition or objective text only
- Next-safe runtime hook: one compact `Unit/TelegraphSprite` ward ring above the unit, preserving HP text and names
- Animation budget: one outward pulse or brief opacity lift, no particles

### Protect

- Read: `this unit is shielded, guarded, or under a protective order`
- Primary shape: shield arc, clipped half-circle, or doubled ward bracket
- Secondary reinforcement: short stabilizing bars or a vow-seal lock
- Value behavior: stronger gold edge than `heal`, with pale blue support and low fill mass
- Semantic guardrail: must read sturdier and more deliberate than healing, not like a buff aura

Implementation mapping:

- Current fallback: `BattleHUD` transition text only
- Next-safe runtime hook: compact shield-arc sprite near the marker block or a small plate behind the unit feet
- Animation budget: one seal snap or gentle hold pulse

### Danger Zone

- Read: `this tile or zone is unsafe to occupy next`
- Primary shape: clipped danger plate, lane strip, or perimeter-led zone ring
- Secondary reinforcement: map ticks, short fracture bars, or one seal-break symbol
- Value behavior: ember-red boundary with parchment-ash center kept very low opacity
- Spatial behavior: should scale from one-cell warning to short lane or clustered zone read
- Semantic guardrail: danger is information-first; it must not look like fire damage, poison fog, or boss-only spectacle

Implementation mapping:

- Current fallback: objective text plus any future hostile telegraph copy
- Next-safe runtime hook: `BattleScene/TelegraphOverlayRoot` containing simple per-cell or per-lane overlay sprites
- Animation budget: slow perimeter breath or single edge flash on entry

## Production Rules

- Build for `64x64` cell-scale readability first.
- Assume unit name, HP, and telegraph labels may remain visible near the same tile.
- Keep negative space so later animation pulses do not muddy the shape.
- Prefer one clean silhouette plus one secondary recognition detail.
- Use pale blue, vow gold, ember red, parchment neutrals, ash gray, and soft white only.
- Do not introduce purple magic, glossy RPG shields, heavy bloom, smoke sheets, or cinematic splash framing.
- Keep support overlays calmer than hostile telegraphs so the board hierarchy stays intact.

## Engineering Contract

If this pack is implemented in-engine, keep the integration sequence narrow:

1. Add support and danger art as simple overlay textures or sprites, not particles.
2. Reuse existing HUD text and objective-state channels as fallback until visual hooks prove readable.
3. Land support marks on units first and danger-zone decals second.
4. Keep timing lightweight enough for the Godot mobile renderer and the current HUD cadence.
5. Avoid coupling art hooks to unfinished heal/protect mechanics; support visuals should tolerate purely presentational use first.

Recommended future node additions, if engineering picks this up:

- `Unit/TelegraphSprite` for heal/protect state marks
- `BattleScene/TelegraphOverlayRoot` for danger-zone decals
- optional tiny `AnimationPlayer` or tween-driven pulses instead of shader-heavy effects

## Review Checklist

- Can `heal`, `protect`, and `danger zone` each be identified in under one second without reading text?
- Does `heal` feel restorative rather than magical spectacle?
- Does `protect` read as guarding rather than healing or buff spam?
- Does `danger zone` stay readable without drowning terrain or units?
- Can the runtime still communicate state if the art is temporarily absent?
