# Layered Character Asset Design

**Date:** 2026-04-23

## Goal

Replace the current `full character 8dir base` assumption with a layered
character asset contract that supports visible equipment changes in-game.

Target coverage for this wave:

- playable party:
  - `Rian`
  - `Serin`
  - `Tia`
  - `Bran`
- enemy baselines:
  - `Enemy Raider`
  - `Enemy Skirmisher`

## Recommendation

Use a **semi-modular layered character system**.

Required layers:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `shield_overlay`
- `upper_armor_overlay`

Excluded from independent layering in this wave:

- lower-body armor
- boots
- small accessories
- hair swaps

These stay inside `base_outfit`.

## Hard Rule

This design uses an **anchor-first image-to-image contract**.

The contract is:

1. anchor sheet first
2. all variants derived from the anchor
3. consistency beats speed

That means:

- do not generate each layer as an unrelated fresh character design
- do not let outfit, armor, or weapon layers redefine the character's face,
  body mass, or core proportions
- treat text-only layer generation as exploration only, never as the final
  consistency contract

## Why This Approach

This is the smallest structure that still gives real visible equipment change.

It is better than:

- a monolithic full-character render set, which locks equipment visually
- a fully modular paper-doll system, which would explode production complexity

This structure is a practical midpoint:

- enough flexibility to show equipment changes
- enough constraint to keep 8-direction production feasible

## Asset Contract

Each character lane should be treated as a composite stack, not a finished
single image.

Default visual stack:

1. `base_body`
2. `base_outfit`
3. `upper_armor_overlay`
4. `weapon_overlay`
5. `shield_overlay`

Draw order can vary slightly by side or back view, but this is the baseline.

## Anchor Rule

Each lane must have one locked anchor source before production variants are
trusted.

Recommended anchor type:

- one 8-direction base character sheet

That anchor is the upstream reference for:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `shield_overlay`
- `upper_armor_overlay`

Any layer or later state that is not visibly anchored back to the lane anchor
should be treated as drift risk.

## Direction Standard

All character layers in this system use the same 8-direction set:

- `front`
- `front_right`
- `right`
- `back_right`
- `back`
- `back_left`
- `left`
- `front_left`

No layer is considered complete unless all eight views exist for that layer.

## Folder Structure

Per character lane:

- `source/8dir/base_body/`
- `source/8dir/base_outfit/`
- `source/8dir/weapon_overlay/`
- `source/8dir/shield_overlay/`
- `source/8dir/upper_armor_overlay/`

- `clean/8dir/base_body/`
- `clean/8dir/base_outfit/`
- `clean/8dir/weapon_overlay/`
- `clean/8dir/shield_overlay/`
- `clean/8dir/upper_armor_overlay/`

- `runtime/8dir/base_body/`
- `runtime/8dir/base_outfit/`
- `runtime/8dir/weapon_overlay/`
- `runtime/8dir/shield_overlay/`
- `runtime/8dir/upper_armor_overlay/`

- `runtime/8dir/composite_preview/`
- `runtime/portraits/`
- `runtime/tokens/`

Reason:

- source and clean stay layer-parallel
- runtime outputs remain separable from composition previews
- portrait and token derivatives remain downstream surfaces, not primary layers

## File Naming Rules

Per layer:

- `<character>_<layer>_<view>_source_v01.png`
- `<character>_<layer>_<view>_clean_v01.png`
- `<character>_<layer>_<view>_runtime_v01.png`

Examples:

- `rian_base_body_front_source_v01.png`
- `rian_base_outfit_back_right_clean_v01.png`
- `bran_shield_overlay_left_runtime_v01.png`
- `enemy_raider_upper_armor_overlay_front_left_runtime_v01.png`

Composite preview naming:

- `<character>_composite_<view>_preview_v01.png`

Examples:

- `serin_composite_front_preview_v01.png`
- `tia_composite_back_left_preview_v01.png`

## Layer Semantics

### `base_body`

Contains:

- body mass
- head
- face
- hair
- bare hands if needed
- bare silhouette essentials

Must not contain:

- weapon
- shield
- visible chest armor that should change with gear

### `base_outfit`

Contains:

- underwear-equivalent gameplay-safe base clothing
- fixed cloth shapes needed for character identity
- lower-body and boot shapes for this wave

Must not contain:

- swappable upper armor
- swappable weapon or shield mass

### `weapon_overlay`

Contains:

- one visible weapon profile per direction

Must stay:

- readable
- anchored to hand placement
- separable from body silhouette

### `shield_overlay`

Contains:

- shield only

Used only for shield-capable characters or enemy families that need it.

### `upper_armor_overlay`

Contains:

- chest armor
- shoulder armor
- mantle or outer upper-body pieces **only if they are gear-driven**

Must not contain:

- permanent identity features that would disappear on equipment swap

## Character-Specific Guidance

### `Rian`

Keep in `base_body`:

- head and calm command face
- compact stance

Keep in `base_outfit`:

- minimal command cloth base

Move to overlays:

- sword
- optional upper armor

Do not let the mantle split become gear-dependent unless that mantle is truly a
swappable armor piece.

### `Serin`

Keep in `base_body`:

- head
- soft hair mass
- calm healer read

Keep in `base_outfit`:

- robe base
- lower robe silhouette

Move to overlays:

- staff
- upper-body robe or shoulder support gear only if swappable

### `Tia`

Keep in `base_body`:

- lean stance
- face and head silhouette

Keep in `base_outfit`:

- ranger base clothing
- lower-body mobility silhouette
- core asymmetry if it is identity, not gear

Move to overlays:

- bow
- upper hunter gear if gear-driven

### `Bran`

Keep in `base_body`:

- broad body mass
- planted stance

Keep in `base_outfit`:

- heavy under-cloth silhouette
- lower-body weight

Move to overlays:

- shield
- sword
- upper armor

Bran is the clearest proof case for why layered gear matters.

### `Enemy Raider`

Keep in `base_body`:

- rigid hostile posture

Keep in `base_outfit`:

- authority cloth base

Move to overlays:

- weapon
- upper armor if applicable

### `Enemy Skirmisher`

Keep in `base_body`:

- lean hostile frame

Keep in `base_outfit`:

- hostile agile base outfit

Move to overlays:

- light ranged weapon
- upper armor if applicable

## Runtime Assumption

This design does **not** require immediate runtime compositing in the same wave.

Two acceptable early modes:

1. asset-prep mode
   - layered outputs exist on disk
   - composite previews are authored offline
2. runtime-composite mode
   - game assembles layers dynamically

This design only requires that the files be composable.

It does not force the engine implementation immediately.

## Migration From Current Prep

Current prepared 8dir files should be treated as:

- temporary reference
- silhouette benchmark
- fallback concept sheet

They should **not** define the final contract.

Likewise, any layer images created before the anchor-first contract is enforced
should be treated as:

- reference-only derived exploration
- not final production truth

For example:

- `rian_8dir_sheet_source_v01.png`
- `rian_8dir_sheet_source_v02.png`

should be retained as references, not as the final layered source standard.

## Acceptance Standard

This design is successful if:

1. each of the six lanes can express visible equipment change
2. the base body and base outfit remain stable across equipment swaps
3. overlays remain aligned across all 8 directions
4. character identity does not vanish when equipment changes

## Working Conclusion

The project should stop treating directional character art as a finished single
sheet and start treating it as a layered stack built around:

- stable body
- stable outfit
- swappable visible gear
