# Battle Sprite-First Render Design

**Date:** 2026-04-22

## Goal

Replace the current ally battle-unit rendering path so the playable party uses battle sprite frames first, while token art remains a strict fallback for missing assets.

## Problem

The current runtime presents units as static token or character images instead of readable SRPG battle sprites.

Concrete causes:
- `Unit.tscn` defaults to `TokenArt` as the visible battle surface.
- `CharacterVisualRoot` is hidden by default.
- `unit_actor.gd` resolves a single `character_token_art/*.png` texture instead of frame-based runtime sprite sets.
- Movement snapping and attack lunge exist, but character visual state is not connected to a proper sprite animation source.

This creates the exact player-facing failure:
- allies look like still photos
- enemies and allies read as tokens, not battle units
- the battle layer does not resemble classic SRPG presentation

## Scope

This wave is intentionally narrow.

Included:
- ally party only: `rian`, `serin`, `tia`, `bran`
- sprite-first render path in battle
- runtime frame loading for `idle`, `move`, `attack`
- fallback to existing token art if a sprite set is missing
- scene defaults changed so sprite path is the primary visual path

Excluded:
- enemy sprite conversion
- new art generation
- map/background overhaul
- full walk interpolation redesign
- defeat/hit bespoke animation authoring

## Recommended Approach

Use the existing `assets/characters/sprite_anchor_* / runtime / {idle,move,attack}` frame sets as the new primary source for ally battle visuals.

Why this approach:
- the assets already exist
- it removes the biggest presentation failure without reopening the entire art pipeline
- token fallback remains intact, so the change is reversible and low-risk

## Architecture

### 1. Sprite-first asset resolution

Add a new battle-art loading path that can resolve frame sequences from the sprite anchor runtime directories.

Primary source:
- `assets/characters/sprite_anchor_rian/runtime/...`
- `assets/characters/sprite_anchor_serin/runtime/...`
- `assets/characters/sprite_anchor_tia/runtime/...`
- `assets/characters/sprite_anchor_bran/runtime/...`

Fallback source:
- existing `assets/ui/production/character_token_art/*.png`
- existing generic `unit_token_art/*.png`

### 2. Unit scene behavior

Keep both visual layers in the unit scene, but reverse the priority.

New rule:
- if runtime sprite frames exist, show `CharacterVisualRoot`
- otherwise show `TokenArt`

This preserves compatibility with existing runner coverage and non-party units.

### 3. Minimal battle animation contract

For this wave, the actor only needs three meaningful visual states:
- `idle`
- `move`
- `attack`

Optional fallback behavior:
- `hit` falls back to `idle`
- `defeat` falls back to `idle` or last attack frame if no dedicated set exists

This keeps the contract small and prevents fake completeness.

### 4. Mapping policy

Do not infer from every display name in the game.
Start with a narrow explicit mapping for the four ally units.

Recommended mapping:
- `Rian` -> `sprite_anchor_rian`
- `Serin` -> `sprite_anchor_serin`
- `Tia` -> `sprite_anchor_tia`
- `Bran` -> `sprite_anchor_bran`

This avoids accidental breakage for bosses, recruits, and enemy variants.

## Risks

### Risk 1: Image path and import mismatch

Godot runtime frame loading from arbitrary asset folders can fail if the loader assumes resource imports that are not present or uses the wrong path form.

Mitigation:
- use the same `Image.load` + `ImageTexture.create_from_image` approach already used in `BattleArtCatalog`
- verify exact frame counts with a headless runner

### Risk 2: Existing tests assume token visibility

Several existing runners validate token fallback and current character-layer behavior.

Mitigation:
- update tests to reflect the new priority
- keep fallback behavior intact for missing sprite sets

### Risk 3: Animation player is currently placeholder-only

The current `AnimationPlayer` contains empty placeholder animations.

Mitigation:
- do not depend on authored Godot animations for this wave
- drive sprite-frame cycling in code first

## Success Criteria

The change is successful if:
- ally party units render with battle sprite frames in battle
- missing sprite assets still fall back to token art without breaking battle flow
- `idle`, `move`, and `attack` visibly switch state in runtime
- existing battle logic remains unchanged
- headless verification proves the four ally units resolve sprite-first visuals correctly
