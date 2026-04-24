# Implementation Checklist V01

## Usage

Work from top to bottom.

After each checked block, run:

`/Volumes/AI/tactics/scripts/dev/headless_art_promotion_suite.sh`

If the suite fails, the block is not complete.

## A. Current Baseline Lock

- [x] `m3_ui_runner.gd` is green
- [x] `headless_art_promotion_suite.sh` is green
- [x] `forest` is the global terrain baseline
- [x] `fortress` is a validated map-specific family
- [x] `altar / lever / gate_control` are runtime-routed object families
- [x] `paladin_shield` has live UI destinations
- [x] `field_sword_01` has live preview + support destinations

## B. Next Implementation Targets

### 1. CH03 Forest-Trap Surface

- [x] create `CH03 forest-trap / hunter-device` preview spec
- [x] add preview scene
- [x] add preview script
- [x] add runner
- [x] verify family usage is consistent with current rules
- [x] run full suite

### 2. Post-CH05 Interaction Family Exercise

- [x] choose the next chapter surface after CH05 for interaction-family validation
- [x] define which of `altar / lever / gate_control` belongs in that context
- [x] add preview scene/script/runner
- [x] run full suite

### 2A. Chapter Surface Sufficiency Review

- [x] review whether the current `CH03 / CH05 / CH07 / CH08` set is enough before adding another surface
- [x] document the sufficiency judgment

### 3. Equipment Family Decision

- [x] decide whether `field_sword_01` needs another UI/runtime destination
- [x] keep `field_sword_01` at the current support level unless a new UI surface or chapter need appears

### 4. Fortress Family Breadth Check

- [x] use fortress family in one more chapter-specific surface
- [x] review whether `fortress_edge_01` is repeating too obviously
- [x] decide whether another fortress structural support surface is truly needed

### 5. Maintenance Mode

- [x] confirm the current surface set is sufficient for the present implementation phase
- [x] confirm `field_sword_01` remains at the current support level
- [x] confirm the fortress family remains at the current breadth
- [x] move the implementation lane into maintenance mode

### 6. Completion Review

- [x] confirm the implementation lane meets its phase-complete definition
- [x] document the completion review

## C. Runtime Promotion Rules

Before promoting any new runtime-facing asset:

- [ ] `source` exists
- [ ] `runtime` derivative exists
- [ ] chapter/context destination exists
- [ ] dedicated runner exists
- [ ] `headless_art_promotion_suite.sh` passes
- [ ] `runtime_promotion_record_v01.md` updated

## D. Validation Commands

Primary:

```bash
/Volumes/AI/tactics/scripts/dev/headless_art_promotion_suite.sh
```

Broader project safety:

```bash
/Volumes/AI/tactics/scripts/dev/headless_dev_smoke.sh
```

UI shell:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd
```

## E. Reference Docs

- [implementation_scope_spec_v01.md](/Volumes/AI/tactics/docs/implementation_scope_spec_v01.md)
- [headless_art_promotion_master_checklist_v01.md](/Volumes/AI/tactics/docs/headless_art_promotion_master_checklist_v01.md)
- [art_pipeline_checkpoint_v01.md](/Volumes/AI/tactics/docs/art_pipeline_checkpoint_v01.md)
- [runtime_promotion_record_v01.md](/Volumes/AI/tactics/docs/runtime_promotion_record_v01.md)

## F. Stop Conditions

Do not widen scope if any of these are true:

- [ ] `m3_ui_runner.gd` failed
- [ ] `headless_art_promotion_suite.sh` failed
- [ ] a new surface has no clear family ownership
- [ ] a new asset has no real runtime destination
- [ ] a new family is being proposed before existing families are exercised

## H. Maintenance Rule

Do not add new chapter surfaces or new family assets unless:

- [ ] a concrete runtime gap appears
- [ ] an existing family fails to communicate its chapter role
- [ ] a new UI/runtime destination cannot be served by the current equipment family

## G. Newly Added Chapter Surfaces

- [x] `CH03 forest-trap / hunter-device`
- [x] `CH05 archive-pressure`
- [x] `CH07 ritual-city`
- [x] `CH08 split-line / pursuit pressure`
- [x] `CH09B root archive / revision pressure`
