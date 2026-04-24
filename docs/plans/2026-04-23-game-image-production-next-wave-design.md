# Game Image Production Next Wave Design

**Date:** 2026-04-23

## Goal

Define the next image-production wave for the game, including:

- playable character 8-direction bases
- battle-state image sets
- runtime object-family support images
- folder and naming rules that keep the work scalable

This wave is about real game-facing image production, not more runtime-family
 invention.

## Current Starting Point

The project already has:

- cleared `source / clean / runtime` backlog for the tracked asset lanes
- ten live chapter-local runtime object families
- first-pass authored usage expansion for:
  - `CH04_03`
  - `CH06_02`
  - `CH10_05`
  - `CH05_03`
  - `CH07_01`
- stable art/runtime checkpoint and handoff docs

What it does **not** yet have as a production-complete set:

- 8-direction player character bases
- 8-direction enemy character bases
- a tranche-by-tranche image-production order for the remaining game-facing art

What it now has in prepared form:

- a standardized folder convention for directional character outputs
- prepared 8-direction lane structure for:
  - `Rian`
  - `Serin`
  - `Tia`
  - `Bran`
  - `Enemy Raider`
  - `Enemy Skirmisher`

## Recommended Scope

### Included

- player party 8-direction base images
- enemy baseline 8-direction base images
- per-character minimum battle-state image targets
- supporting object-family image tranche planning
- explicit folder and file naming rules

### Excluded

- reworking the current runtime family system
- reopening `civic_seal`
- solving shutdown warning hygiene issues
- implementing `asset-engine v2`

## Recommended Production Tranches

### Tranche 1: Player 8-Direction Base Set

Target characters:

- `Rian`
- `Serin`
- `Tia`
- `Bran`

Required outputs per character:

- `front`
- `back`
- `left`
- `right`

Reason:

- these are the highest-value missing gameplay-facing image assets
- they create the base for later state variants and sprite conversion

### Tranche 2: Enemy 8-Direction Base Set

Target characters:

- `Enemy Raider`
- `Enemy Skirmisher`

Required outputs per character:

- `front`
- `back`
- `left`
- `right`

Reason:

- enough to establish enemy-direction baseline without exploding scope

### Tranche 3: Battle-State Expansion

Apply after 8-direction bases exist.

Required state set:

- `idle`
- `move`
- `attack`
- `hit`

Preferred order:

1. `idle`
2. `move`
3. `attack`
4. `hit`

Reason:

- this keeps the minimum animation and pose set tied to gameplay needs

### Tranche 4: Runtime Object-Family Support Images

High-value families:

- `battery`
- `floodgate`
- `chain_control`
- `evidence`
- `bell`

Selective families:

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

Reason:

- object support art should follow character directional foundations, not replace them

## Folder Strategy

### Character Root Rule

Keep all directional work inside the existing character lane folders instead of
 creating a separate global `8dir/` tree.

Reason:

- avoids splitting per-character context across multiple roots
- keeps `spec / source / clean / runtime` together

### Recommended Character Structure

Per character lane:

- `source/8dir/`
- `clean/8dir/`
- `runtime/8dir/`
- `runtime/portraits/`
- `runtime/tokens/`

Example:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/source/8dir/`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/clean/8dir/`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime/8dir/`

### Direction File Naming Rule

Source:

- `<character>_<view>_source_v01.png`

Clean:

- `<character>_<view>_clean_v01.png`

Runtime:

- `<character>_<view>_runtime_v01.png`

Views:

- `front`
- `back`
- `left`
- `right`

Example:

- `rian_front_source_v01.png`
- `rian_back_clean_v01.png`
- `rian_left_runtime_v01.png`

### Optional Sheet Naming Rule

If a combined direction sheet is used:

- `<character>_8dir_sheet_source_v01.png`
- `<character>_8dir_sheet_clean_v01.png`

Reason:

- allows both “single sheet” and “split per-view” workflows

## Character-Specific Read Goals

### `Rian`

- first-read: frontline command
- dominant hook: sword arm and mantle split
- risk: collapsing into generic swordsman

### `Serin`

- first-read: support caster
- dominant hook: staff silhouette and contained support posture
- risk: reading too ornamental instead of utility-clear

### `Tia`

- first-read: ranged skirmisher
- dominant hook: bow curve and asymmetrical ranger stance
- risk: over-thin silhouette at map scale

### `Bran`

- first-read: heavy wall unit
- dominant hook: shield mass and armored width
- risk: turning into over-detailed knight noise

### `Enemy Raider`

- first-read: hostile melee pressure
- dominant hook: aggressive weapon-forward silhouette
- risk: drifting too close to Rian

### `Enemy Skirmisher`

- first-read: hostile ranged pressure
- dominant hook: compressed pursuit posture
- risk: drifting too close to Tia

## Completion Standard

### Tranche 1 Complete When

All four player characters have:

- 8-direction source set
- 8-direction clean set
- 8-direction runtime set
- updated runtime manifest or equivalent lane note

### Tranche 2 Complete When

Both enemy baseline characters have the same.

### Tranche 3 Complete When

At least one player character and one enemy character have:

- `idle`
- `move`
- `attack`
- `hit`

expressed on top of the 8-direction baseline.

## Recommended Execution Order

1. `Rian`
2. `Serin`
3. `Tia`
4. `Bran`
5. `Enemy Raider`
6. `Enemy Skirmisher`

Reason:

- start with the cleanest frontline readability case
- then lock the support, ranged, and heavy ally reads
- then mirror that baseline into enemy reads

## Working Conclusion

The next game-image wave should start with 8-direction player bases inside the
 existing character lanes, using strict `source / clean / runtime` and `8dir`
 subfolders, then expand outward into enemy bases and battle-state variants.
