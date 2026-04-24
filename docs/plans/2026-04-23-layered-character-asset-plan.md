# Layered Character Asset Plan

**Date:** 2026-04-23

## Objective

Migrate the current directional character prep from:

- full-character 8dir base

to:

- layered 8dir character assets

using this layer set:

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `shield_overlay`
- `upper_armor_overlay`

## Phase A: Contract Migration

### A1. Freeze the layered contract

Use:

- [2026-04-23-layered-character-asset-design.md](/Volumes/AI/tactics/docs/plans/2026-04-23-layered-character-asset-design.md)

### A1b. Freeze the anchor-first derivation rule

Do this before trusting any layered output as production-ready.

Rule:

- anchor sheet first
- all variants derived from anchor
- consistency beats speed

### A2. Mark current full-character 8dir sheets as reference-only

Do not delete them yet.

Reclassify them as:

- legacy reference
- silhouette benchmark

### A3. Mark pre-anchor layered outputs as reference-only derived exploration

Until the anchor-first rule is fully applied, any generated layered outputs must
remain:

- reference-only
- not final
- usable for direction and silhouette review only

## Phase B: Lane Structure Migration

Per lane, replace the current flat `8dir` assumption with sublayers:

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

## Phase C: Pilot Lane

Start with:

- `Rian`

Required output for the pilot:

- body layer skeleton
- outfit layer skeleton
- weapon overlay skeleton
- upper armor overlay skeleton

Optional in pilot:

- shield overlay can remain unused if no shield is intended

Reason:

- Rian is the clearest ally baseline
- easier to prove separation than Serin

## Phase D: Heavy Proof Lane

Second lane:

- `Bran`

Required:

- shield overlay must be explicit
- upper armor overlay must be explicit

Reason:

- Bran is the strongest test of the equipment-driven read

## Phase E: Remaining Ally Lanes

Apply to:

- `Serin`
- `Tia`

Key caution:

- do not over-split character identity into gear layers

Current status:

- `Serin` layered support/caster lane docs and folders are in place
- `Tia` layered ranged-hunter lane docs and folders are now in place

## Phase F: Enemy Baseline Lanes

Apply to:

- `Enemy Raider`
- `Enemy Skirmisher`

Enemy rule:

- keep the same contract
- but allow narrower variation than allies

Current status:

- `Enemy Raider` layered hostile-baseline lane docs and folders are now in place
- `Enemy Skirmisher` layered hostile agile lane docs and folders are now in place
- `Enemy Skirmisher` anchor-first contract is now explicit
- `Enemy Raider` official anchor sheet is now frozen
- `Enemy Skirmisher` official anchor sheet is now frozen
- `Enemy Raider` current best-set preview candidate is:
  - `base_body v01`
  - `base_outfit v01`
  - `weapon_overlay v03_sword_led`
  - `upper_armor_overlay v02_compact`
- `Enemy Skirmisher` current best-set preview candidate is:
  - `base_body v01`
  - `base_outfit v02_disciplined`
  - `weapon_overlay v02_clean`
  - `upper_armor_overlay v02_light`
- enemy preview review is now tracked through:
  - [layered_enemy_preview_review_v03.md](/Volumes/AI/tactics/docs/generated/layered_enemy_preview_review_v03.md)

## Phase G: Composite Preview Generation

For each lane, generate:

- one composite preview per direction

These previews are for:

- review
- alignment checking
- early runtime planning

## Phase H: Portrait And Token Derivatives

Generate from the current best-set composite preview only.

Targets:

- `runtime/portraits/*.png`
- `runtime/tokens/*.png`

Locked sizes:

- portrait: `1024x1024`
- token: `48x48`

## File Naming

Examples:

- `rian_base_body_front_source_v01.png`
- `rian_base_outfit_front_right_clean_v01.png`
- `rian_weapon_overlay_left_runtime_v01.png`
- `bran_shield_overlay_back_runtime_v01.png`
- `enemy_raider_upper_armor_overlay_front_left_runtime_v01.png`
- `tia_composite_front_preview_v01.png`

## Exit Criteria

### Exit A

`Rian` pilot lane migrated to layered structure.

Current status:

- `Rian` layered pilot folder migration is in place
- legacy monolithic direction sheets are retained as reference-only assets
- layered lane docs and manifest are in place
- `Rian` official anchor sheet is now frozen
- current generated layers remain reference-only until re-derived from that anchor

### Exit B

`Bran` heavy proof lane migrated and shield logic proven visually.

Current status:

- `Bran` layered heavy/shield proof folder migration is in place
- layered lane docs, manifest, and prompt pack are in place
- `shield_overlay` is now a required proof layer in the lane contract

### Exit C

All six lanes have layered folder structure and lane-specific layered docs.

### Exit D

At least one composite preview exists for each lane.

## Notes

- do not continue generating monolithic 8dir bases as if they were the final contract
- use current monolithic sheets only as reference while migrating
