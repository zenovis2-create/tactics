# Headless Art Promotion Master Checklist V01

## Purpose

This document replaces the current piecemeal art-promotion flow with one execution checklist.

Use it to answer:

1. what is already promoted
2. what is next
3. what command proves the slice is still healthy

This is the working execution board for the current headless-first art lane.

## Operating Rule

After each promotion block, run:

`/Volumes/AI/tactics/scripts/dev/headless_art_promotion_suite.sh`

Do not mark a task complete unless the suite passes.

## Current Runtime Baseline

### Already Stable

- [x] `forest` global terrain baseline
- [x] `altar` sacred-object baseline
- [x] `lever` mechanical-object baseline
- [x] `gate_control` route/system-control baseline
- [x] `gate_control` production object slot baseline
- [x] `character-specific battle art preference` for:
  - `Rian`
  - `Serin`
  - `Bran`
  - `Tia`
  - `Enemy Raider`
  - `Enemy Skirmisher`
- [x] `paladin_shield` camp/interlude presentation card surface
- [x] `paladin_shield` party/detail support surface
- [x] `forest + fortress + interaction-family` chapter preview surfaces:
  - `CH02 fortress`
  - `CH04 sacred machinery`
  - `CH06 iron keep`

### Stable But Not Global

- [x] `forest_tile_02` as forest-family support variant
- [x] `fortress_tile_01` as map-specific fortified terrain family member
- [x] `fortress_tile_02` as second fortified terrain family member
- [x] `fortress family` validated across multiple preview contexts

## Immediate Queue

These are the next tasks to execute without reopening high-level strategy.

### Phase 1: Fortress Family Completion

- [x] Add `fortress_edge_01` to `CH02FortressArtPreview`
- [x] Add `fortress_edge_01` to `CH06IronKeepPreview`
- [x] Add headless assertions so both preview runners require `fortress_edge_01`
- [x] Record whether `fortress_edge_01` is sufficient as the first structural fortified-family support surface

### Phase 2: Equipment Family Expansion

- [x] Create `field_sword_01` lane:
  - `spec.md`
  - `krita_cleanup_guide_v01.md`
  - `README_runtime.md`
  - `source / clean / runtime`
- [x] Create first runtime derivatives for `field_sword_01`
- [x] Choose first real in-game destination for `field_sword_01`
- [x] Validate the destination with a dedicated headless runner

### Phase 3: Interaction Object Runtime Routing

- [x] Decide whether `gate_control_01` needs a real production `object_icons` slot now
- [x] If yes, define the canonical runtime filename and destination
- [x] Keep `altar / lever / gate_control` placement rules synchronized with actual preview and runtime usage

### Phase 4: UI Surface Recovery

- [x] Repair broader `CampaignPanel` script-scene drift so `m3_ui_runner.gd` is green again
- [x] Keep narrow image-backed card runners passing during the repair

## Promotion Gates

### Terrain / Prop / Equipment

Mark a non-character asset as promoted only if all are true:

- [ ] a `source` asset exists
- [ ] a `runtime` derivative exists
- [ ] at least one real game or preview surface uses it
- [ ] the headless art promotion suite passes
- [ ] the promotion record is updated

### Character Surface

Mark a character surface as promoted only if all are true:

- [ ] `character_token_art` exists
- [ ] `Unit.tscn` and `unit_actor.gd` prefer it correctly
- [ ] fallback token behavior still works
- [ ] character visual runners pass

## Validation Command

Primary validation:

`/Volumes/AI/tactics/scripts/dev/headless_art_promotion_suite.sh`

Secondary broad validation:

`/Volumes/AI/tactics/scripts/dev/headless_dev_smoke.sh`

Visual QA artifacts after the primary validation:

- [visual_qa_suite_report_v01.md](/Volumes/AI/tactics/docs/generated/visual_qa_suite_report_v01.md)
- [visual_qa_suite_report_v01.json](/Volumes/AI/tactics/docs/generated/visual_qa_suite_report_v01.json)

Current visual QA summary:

- `8/8` runners passing
- representative battle proximity:
  - `CH07` city seal / prayer dais = `1 / 1`
  - `CH09B` archive lectern = `1`
  - `CH10` anchor chain / bell dais = `1 / 1`

## Source Docs

- [art_production_ssot_index.md](/Volumes/AI/tactics/docs/art_production_ssot_index.md)
- [art_pipeline_checkpoint_v01.md](/Volumes/AI/tactics/docs/art_pipeline_checkpoint_v01.md)
- [runtime_promotion_record_v01.md](/Volumes/AI/tactics/docs/runtime_promotion_record_v01.md)
- [environment_equipment_runtime_promotion_plan_v01.md](/Volumes/AI/tactics/docs/environment_equipment_runtime_promotion_plan_v01.md)

## Working Conclusion

The current execution strategy is no longer:

- pick one asset
- improvise the next step

It is now:

- keep the current promoted runtime slice green
- use the complete first-pass fortress family in more chapter-specific surfaces before adding more fortress structural assets
- keep `field_sword_01` at the current camp/detail + preview level until new evidence justifies more UI surfaces
- keep the broader headless UI shell green while new equipment surfaces are introduced
- treat `altar / lever / gate_control` as a real runtime-routed object family, not preview-only semantics
- exercise the interaction object family across multiple chapter contexts before adding a fourth object family
