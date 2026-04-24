# Character Sprite Pipeline

## Purpose

This document defines the dedicated production lane for playable and enemy character art
when the project uses 2D sprite sheets for characters instead of full 3D character renders.

Environment, props, tile cards, and map-side support art may still use Rhino/Krita/Godot.
This document exists to prevent the character lane from drifting into a different game.

## Production Split

Use this split by default:

- Characters: `2D sprite sheets`
- Character FX: `2D FX sheets`, separated from the body whenever possible
- Props, environment, map support, and interaction objects: `Rhino + Krita + Godot`

This is the recommended `2D character + 2.5D environment` production model for this project.

## Why This Split Works

- Characters need expressive readability, iteration speed, and controllable action poses.
- Props and maps benefit from repeatable shape construction and reusable render angles.
- The game can preserve a handcrafted tactical feeling without forcing every surface into the same toolchain.

## Character Style Lock

Character sprites should feel:

- adjacent to classic tactical JRPG battle sprites
- warm and readable rather than glossy
- stylized enough to read on a tactical map
- emotionally restrained, not gacha-dramatic

They must not feel:

- photoreal
- overly modern live-service anime polish
- painterly western concept art
- disconnected from the environment palette and UI language

## Character Sprite Rules

### 1. Readability Wins

- Each character needs one dominant silhouette hook.
- Weapon, staff, shield, hair mass, cloak cut, or shoulder shape should do most of the identity work.
- FX must not be required to identify the class.

### 2. Detail Budget Is Limited

- Use clean line discipline.
- Keep shading simple and consistent.
- Avoid hair-strand rendering, cloth micro-folds, tiny jewelry, and lace-level trim.
- If a feature disappears at reduced scale, it should probably not exist.

### 3. Animation Should Be Layer-Friendly

Whenever possible, separate:

- body
- weapon
- major spell circle or projectile
- impact FX

This improves retiming, recoloring, and reuse in Godot.

### 4. Sheets Need A Production Purpose

Use one of these sheet modes:

- `turn sheet`: front / side / 3/4 consistency
- `idle + action set`: gameplay implementation
- `full sequence`: one specific skill or attack showcase

Do not generate large frame counts without a runtime use.

## Recommended Character Workflow

1. Write a sprite-character `spec.md`.
2. Generate or paint a clean turn sheet.
3. Lock silhouette, color, and loadout.
4. Build action sheets state-by-state:
   - `idle`
   - `move`
   - `attack`
   - `cast`
   - `hit`
   - `death` if needed
5. Separate reusable FX where possible.
6. Import into Godot and check gameplay-scale readability.
7. Revise only after in-engine review.

## Godot Runtime Rules

- Prefer consistent animation names across the roster.
- Keep frame sizes and pivots predictable.
- Test sprites against the real tile and board palette, not on white backgrounds only.
- If a sprite reads well in isolation but fails on the board, it fails review.

## Krita Role

Krita is the cleanup and production polish layer for character sprites.

Use Krita for:

- frame cleanup
- line and value consistency
- palette unification
- sheet labeling
- transparent export preparation

Do not use Krita to rescue a broken silhouette that should have been fixed in the design stage.

## Relationship To Existing Docs

This document should be read with:

- `/Volumes/AI/tactics/docs/style_bible.md`
- `/Volumes/AI/tactics/docs/production/character_visual_identity_pack.md`
- `/Volumes/AI/tactics/docs/character_sheets.md`

Priority:

1. `style_bible.md` for cross-surface world rules
2. `character_visual_identity_pack.md` for portrait and in-game identity language
3. this document for sprite-sheet production workflow

## Immediate Use

Use this sprite pipeline for:

- playable roster battle sprites
- enemy battle sprites
- class baseline sprite anchors
- spell and attack sequence planning

Do not use this as the primary workflow for:

- map terrain
- interaction props
- tile cards
- environment landmark kits

