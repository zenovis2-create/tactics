# Art Pipeline Checkpoint V01

## Purpose

This document records the current state of the Farland Tactics art-production pipeline
after the first full setup pass across characters, environment support, and equipment support.

It answers:

1. what has been built
2. what is production-ready enough to continue from
3. what is still candidate-only
4. what the next highest-value gaps are

## Current Outcome

The project now has a real production framework, not just a loose collection of ideas.

The following are now in place:

- shared art SSOT and lane documentation
- reusable asset templates
- locked ally character class lanes
- a first hostile character lane
- generated anchor assets
- runtime frame extraction for core ally anchors
- runtime frame extraction for the first hostile anchor
- Godot dev preview scenes for sprite comparison
- environment and equipment source/clean/runtime folder structure
- first environment and equipment source candidates
- clean/runtime environment and equipment derivatives
- promoted forest and altar runtime surfaces
- promoted character-specific battle art preference surfaces
- Rhino production scaffolding for 3D-oriented asset work

## Completed Work

### 1. Shared Documentation

Completed:

- [style_bible.md](/Volumes/AI/tactics/docs/style_bible.md)
- [character_sprite_pipeline.md](/Volumes/AI/tactics/docs/character_sprite_pipeline.md)
- [character_sprite_style_lock_v01.md](/Volumes/AI/tactics/docs/character_sprite_style_lock_v01.md)
- [character_class_silhouette_color_matrix_v01.md](/Volumes/AI/tactics/docs/character_class_silhouette_color_matrix_v01.md)
- [environment_prop_tile_matrix_v01.md](/Volumes/AI/tactics/docs/environment_prop_tile_matrix_v01.md)
- [art_production_ssot_index.md](/Volumes/AI/tactics/docs/art_production_ssot_index.md)
- [next_art_production_backlog_v01.md](/Volumes/AI/tactics/docs/next_art_production_backlog_v01.md)

Result:

- The project now has a readable source-of-truth path for both character and environment production.

### 2. Character Production Lane

Completed anchors:

- Serin
- Rian
- Tia
- Bran
- Enemy Raider

For each lane, the project now has some combination of:

- `spec.md`
- `prompt_pack_v01.md`
- chosen source sheets
- slicing manifests
- runtime extraction scripts
- Godot preview support

Result:

- The character lane is no longer hypothetical.
- It has moved from concept generation into runtime-ready frame production.

### 3. Character Runtime State

Completed runtime-ready ally anchors:

- Serin
- Rian
- Tia
- Bran

Completed hostile runtime anchor:

- Enemy Raider
- Enemy Skirmisher
- Enemy Skirmisher

Result:

- Characters can now be compared in-engine as sprites rather than only as concept sheets.
- The first hostile lane now follows the same runtime model as the ally lane.
- A second hostile lane now exists for enemy class-distance validation.

### 4. Godot Preview Support

Completed:

- single-character preview for Serin
- ally roster gallery
- battle sprite roster gallery
- battle integration preview
- enemy raider preview
- battle integration asset-loading validation runner
- campaign-panel image-backed presentation card validation runner
- campaign-panel image-backed presentation card validation runner
- battle-unit character-specific art preference validation

Result:

- The project can validate style and readability inside Godot, not only in isolated image folders.
- The project can validate integration asset loading in headless checks.
- The project can validate an image-backed equipment-support presentation surface.
- The project can validate an image-backed equipment-support presentation surface.
- The project can validate character-specific battle art preference over generic token fallback.

### 5. Environment / Prop / Equipment Lane

Completed anchor specs:

- Paladin Shield
- Field Sword 01
- Altar 01
- Lever 01
- Gate Control 01
- Forest Tile 01
- Forest Tile 02
- Fortress Tile 01
- Fortress Tile 02
- Fortress Edge 01
- Character Anchor Knight

Completed support docs:

- runtime READMEs
- Krita cleanup guides
- Rhino setup and render helpers for anchor-style work

Completed source candidates:

- `forest_tile_01_source_v02.png`
- `altar_01_source_v02.png`
- `lever_01_source_v01.png`
- `paladin_shield_source_v02.png`
- `forest_tile_02_source_v01.png`
- `fortress_tile_01_source_v01.png`
- `fortress_tile_02_source_v01.png`
- `field_sword_01_source_v01.png`
- `fortress_edge_01_source_v01.png`

Completed clean/runtime derivatives:

- `forest_tile_01_clean_v01.png`
- `forest_tile_01_tile_card_v01.png`
- `forest_tile_01_tile_icon_v01.png`
- `forest_tile_01_integration_v01.png`
- `forest_tile_02_clean_v01.png`
- `forest_tile_02_tile_card_v01.png`
- `forest_tile_02_tile_icon_v01.png`
- `forest_tile_02_integration_v01.png`
- `fortress_tile_01_clean_v01.png`
- `fortress_tile_01_tile_card_v01.png`
- `fortress_tile_01_tile_icon_v01.png`
- `fortress_tile_01_integration_v01.png`
- `fortress_edge_01_clean_v01.png`
- `fortress_edge_01_tile_card_v01.png`
- `fortress_edge_01_tile_icon_v01.png`
- `fortress_edge_01_integration_v01.png`
- `altar_01_clean_v01.png`
- `altar_01_object_icon_v01.png`
- `altar_01_integration_v01.png`
- `lever_01_clean_v01.png`
- `lever_01_object_icon_v01.png`
- `lever_01_integration_v01.png`
- `paladin_shield_clean_v01.png`
- `paladin_shield_equipment_v01.png`
- `paladin_shield_icon_v01.png`
- `paladin_shield_integration_v01.png`
- `field_sword_01_clean_v01.png`
- `field_sword_01_equipment_v01.png`
- `field_sword_01_icon_v01.png`
- `field_sword_01_integration_v01.png`

Result:

- Environment and equipment lanes now exist as actual production tracks.
- They are still less mature than the character lane, but they now include reusable runtime-facing derivatives.

### 6. First Runtime Promotion

Completed:

- forest production runtime baseline
- altar production runtime baseline
- m3 UI runner restored to green after CampaignPanel handoff alignment
- character-specific battle art preference baseline
- paladin shield presentation-card support baseline
- field_sword weapon-preview support baseline
- field_sword camp/detail support baseline
- lever mechanical-objective baseline
- gate-control production object-slot baseline
- fortress-edge structural support decision baseline
- paladin shield presentation-card support baseline

Result:

- the slice now uses real promoted runtime environment surfaces for two highly visible gameplay reads
- the broader campaign UI shell is headless-validated again, not only narrow card runners
- the slice now uses promoted character-specific battle presentation surfaces for the current anchor roster
- the slice now exposes the first promoted equipment-support presentation surface
- the slice now exposes a second live equipment-support destination through sword-class weapon previews
- the slice now exposes a second image-backed equipment-support presentation surface through field_sword support
- the slice now exposes both sacred and mechanical interaction object baselines
- the slice now exposes a route/system-control object slot baseline
- the slice now exposes a runtime-routed three-family interaction object lane
- the slice now validates a second terrain family in a fortress-like preview
- the slice now validates fortress-family surfaces across both CH02- and CH06-like contexts
- the slice now validates fortress-family structural support through `fortress_edge_01`
- the slice now treats `fortress_edge_01` as sufficient for the current first-pass fortress family
- the slice now validates the interaction-object family in a CH05 archive-pressure context
- the slice now has a reviewed CH02 fortress screenshot assembly pass
- the slice now uses promoted character-specific battle presentation surfaces for the current anchor roster
- the slice now exposes the first promoted equipment-support presentation surface

## What Is Stable

These areas are stable enough to use as the baseline:

### Character Style Family

Stable enough:

- Serin selected set
- Rian selected set
- Tia selected set
- Bran selected set
- Enemy Raider selected set

Meaning:

- class distance and ally/enemy posture rules are established
- future sprite work should reuse these lanes rather than inventing new visual logic

### Folder Model

Stable enough:

- `source -> clean -> runtime`
- spec-driven production
- prompt-pack-driven generation
- Godot-first readability review

Meaning:

- new assets should now follow the same structure by default

### Documentation Hierarchy

Stable enough:

- style bible at the top
- lane lock docs under it
- asset spec under those

Meaning:

- decisions now have a place to live instead of being hidden in chat

## What Is Candidate-Only

These are usable for iteration, but not yet strong enough to call fully production-ready:

### Paladin Shield

Status:

- spec exists
- runtime folder model exists
- Rhino helpers exist
- visual candidate exists
- runtime-facing derivatives exist

Gap:

- still needs actual in-game hookup beyond support outputs

### Battle Integration Preview

Status:

- preview logic exists
- clean runtime environment assets are referenced
- asset loading has passed headless validation

Gap:

- integration screen is useful for direction, but not yet for final sign-off
- no final captured visual review artifact is stored yet

## Main Risks

### 1. Character Lane Is More Mature Than Environment Lane

Risk:

- characters may look more resolved than the world they live in

What that means:

- the game can feel like finished sprites standing on prototype scenery

### 2. Environment Read Still Needs Variety And Final Board Tuning

Risk:

- environment integration tests can overstate progress

What that means:

- the first clean runtime assets work, but the board can still look repetitive or under-varied

### 3. Toolchain Balance

Risk:

- there is now enough documentation that work can slow down if every step becomes over-formalized

What that means:

- the team should now prefer using the templates and anchors rather than generating more meta-docs unless needed

## Recommended Next Actions

### Highest Priority

1. Add a second hostile lane beyond Enemy Raider
2. Build one more terrain family beyond forest
3. Hook paladin shield support output into a real in-game presentation surface

### Next Priority

1. add at least one second hostile lane beyond Enemy Raider
2. build a stronger real battle screenshot once the cleaned environment assets exist

### Do Not Prioritize Yet

- store art
- trailer production
- character FX over-polish
- advanced animation systems

## Working Conclusion

The first pipeline pass succeeded.

The project now has:

- a real character sprite production system
- a real environment/equipment production structure
- the first promoted runtime environment surfaces
- enough anchors to keep future work consistent

The next phase is no longer “design the pipeline.”
The next phase is “expand runtime coverage and replace more visible placeholder surfaces with the now-established art lanes.”
