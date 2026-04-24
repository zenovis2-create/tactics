# Art Runtime Handoff Executive Summary V01

## Current State

The current image-generation backlog is clear:

- `lanes with missing image steps: 0`

The project now has a live chapter-local runtime family layer on top of the
older baseline interaction families.

## Live Runtime Families

Current live chapter-local runtime families:

1. `well`
2. `battery`
3. `shrine`
4. `floodgate`
5. `evidence`
6. `bell`
7. `chain_control`
8. `keeper_lectern`
9. `route_marker`
10. `latch`

## What Is Done

- chapter-local landmark coverage is built out through the current chapter set
- missing `source / clean / runtime` image stages are cleared
- production object icons have been promoted for the live runtime families
- stage-authored object routing exists for all current live families
- runner-backed validation exists for the live runtime set
- briefing-first and codex-dossier-first family surface rules are documented
- first usage-expansion pass has been applied to real authored data
- 8-direction tranche structure is now prepared for:
  - `Rian`
  - `Serin`
  - `Tia`
  - `Bran`
  - `Enemy Raider`
  - `Enemy Skirmisher`
- `Rian` lane has now entered the layered migration pilot with:
  - `base_body`
  - `base_outfit`
  - `weapon_overlay`
  - `shield_overlay`
  - `upper_armor_overlay`
- `Rian` official anchor sheet is now frozen for future image-to-image derivation
- current generated `Rian` layered outputs remain reference-only until re-derived from that anchor
- `Bran` lane has now entered the layered heavy/shield proof migration with:
  - `base_body`
  - `base_outfit`
  - `weapon_overlay`
  - `shield_overlay`
  - `upper_armor_overlay`
- `Serin` lane has now entered the layered support/caster migration with:
  - layered docs and folders in place
- `Tia` lane has now entered the layered ranged-hunter migration with:
  - layered docs and folders in place
- `Enemy Raider` lane has now entered the layered hostile-baseline migration with:
  - layered docs and folders in place
  - frozen anchor sheet created
  - current best-set preview candidate established
- `Enemy Skirmisher` lane has now entered the layered hostile-agile migration with:
  - layered docs and folders in place
  - anchor-first contract explicit
  - frozen anchor sheet created
  - current best-set preview candidate established
- per-lane 8-direction production briefs and runtime manifests now exist for the prepared tranche
- per-lane 8-direction prompt packs now exist for all six prepared lanes

## Current Main References

- [live_runtime_family_summary_v01.md](/Volumes/AI/tactics/docs/generated/live_runtime_family_summary_v01.md)
- [runtime_object_family_stage_usage_v01.md](/Volumes/AI/tactics/docs/generated/runtime_object_family_stage_usage_v01.md)
- [runtime_object_family_ui_surface_scope_v01.md](/Volumes/AI/tactics/docs/generated/runtime_object_family_ui_surface_scope_v01.md)
- [runtime_promotion_record_v01.md](/Volumes/AI/tactics/docs/runtime_promotion_record_v01.md)
- [live_runtime_family_review_pass_v01.md](/Volumes/AI/tactics/docs/generated/live_runtime_family_review_pass_v01.md)

## Active Production Reading

- briefing-first families:
  - `battery`
  - `floodgate`
  - `chain_control`
- codex-dossier-first families:
  - `evidence`
  - `bell`
- live but not first-wave briefing-dossier families:
  - `well`
  - `shrine`
  - `keeper_lectern`
  - `route_marker`
  - `latch`

## Usage Expansion State

Closed gaps in the current pass:

- `CH04_03` briefing authored and validated
- `CH06_02` briefing authored and validated
- `CH10_05` briefing authored and validated
- `CH05_03` records evidence entry validated
- `CH07_01` records evidence entry validated
- late-game briefing and records wording polish applied to the newly authored entries

Selective usage review completed for:

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

## Runtime/UI Polish State

Current review outcome:

- `CH04_03` and `CH06_02` briefing wording drift was corrected
- `CH10_05` briefing retained its family read after localization alignment
- `CH05_03` and `CH07_01` records-evidence wording passed without further change

## Layered Character Preview State

Current ally baseline:

- `Rian` pilot preview is acceptable at:
  - `rian_composite_8dir_preview_v03_lighter_armor`
- `Bran` heavy/shield proof preview is acceptable at:
  - `bran_composite_8dir_preview_v02_balanced_shield`
- `Serin` support/caster preview is acceptable at:
  - `serin_composite_8dir_preview_v01`
- `Tia` ranged-hunter preview is acceptable at:
  - `tia_composite_8dir_preview_v02_bgfix`

Current enemy baseline:

- `Enemy Raider` is currently usable as a provisional hostile melee baseline at:
  - `enemy_raider_composite_8dir_preview_v03_sword_led`
- `Enemy Skirmisher` is currently acceptable as a hostile agile baseline at:
  - `enemy_skirmisher_composite_8dir_preview_v02_corrected`

Current review references:

- [layered_enemy_preview_review_v01.md](/Volumes/AI/tactics/docs/generated/layered_enemy_preview_review_v01.md)
- [layered_enemy_preview_review_v02.md](/Volumes/AI/tactics/docs/generated/layered_enemy_preview_review_v02.md)
- [layered_enemy_preview_review_v03.md](/Volumes/AI/tactics/docs/generated/layered_enemy_preview_review_v03.md)
- [roster_layered_preview_board_v03_raider_sword_led.png](/Volumes/AI/tactics/docs/generated/roster_layered_preview_board_v03_raider_sword_led.png)

## Portrait/Token Derivative State

Current derivative slice is now populated for:

- `Rian`
- `Serin`
- `Tia`
- `Bran`
- `Enemy Raider`
- `Enemy Skirmisher`

Derivative outputs:

- portrait: `1024x1024`
- token: `48x48`

Current preferred derivative baseline:

- `*_portrait_v02_single_view.png`
- `*_token_v02_single_view.png`

Generator:

- [build_layered_character_derivatives.py](/Volumes/AI/tactics/scripts/dev/build_layered_character_derivatives.py)

Review:

- [character_derivative_qa_review_v01.md](/Volumes/AI/tactics/docs/generated/character_derivative_qa_review_v01.md)

Current derivative slice posture:

- derivative slice is complete enough to close
- the next recommended character slice is battle-state sheet generation

Current next-step references:

- [rian_battle_state_pilot_design_v01.md](/Volumes/AI/tactics/docs/generated/rian_battle_state_pilot_design_v01.md)
- [rian_battle_state_pilot_plan_v01.md](/Volumes/AI/tactics/docs/generated/rian_battle_state_pilot_plan_v01.md)
- [serin_battle_state_pilot_design_v01.md](/Volumes/AI/tactics/docs/generated/serin_battle_state_pilot_design_v01.md)
- [serin_battle_state_pilot_plan_v01.md](/Volumes/AI/tactics/docs/generated/serin_battle_state_pilot_plan_v01.md)
- [tia_battle_state_pilot_design_v01.md](/Volumes/AI/tactics/docs/generated/tia_battle_state_pilot_design_v01.md)
- [tia_battle_state_pilot_plan_v01.md](/Volumes/AI/tactics/docs/generated/tia_battle_state_pilot_plan_v01.md)
- [bran_battle_state_pilot_design_v01.md](/Volumes/AI/tactics/docs/generated/bran_battle_state_pilot_design_v01.md)
- [bran_battle_state_pilot_plan_v01.md](/Volumes/AI/tactics/docs/generated/bran_battle_state_pilot_plan_v01.md)
- [enemy_raider_battle_state_pilot_design_v01.md](/Volumes/AI/tactics/docs/generated/enemy_raider_battle_state_pilot_design_v01.md)
- [enemy_skirmisher_battle_state_pilot_design_v01.md](/Volumes/AI/tactics/docs/generated/enemy_skirmisher_battle_state_pilot_design_v01.md)

Current `Rian` pilot status:

- `source/rian_idle_sheet_source_v02_layered.png`
- `source/rian_move_sheet_source_v02_layered.png`
- `source/rian_attack_sheet_source_v02_layered.png`

These now exist as the first layered state-sheet pilot sources.

Current `Rian` constrained follow-up:

- official visual source of truth remains `source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png`
- next layer repair is constrained to `weapon_overlay` and `upper_armor_overlay`
- masked edit pack is available at `source/8dir/masked_edit_v01/`
- deterministic alpha-isolated baseline outputs now exist for both target overlays
- QA board accepts the baseline as an alignment / rollback reference
- direct visual check found the weapon baseline is not final-clean because it
  still contains non-weapon fragments
- Asset Engine + ComfyUI verification found the imported `*_anchor_derived`
  sheets are useful concept/layer-intent sources, but not runtime-ready alpha
  layers
- existing layer alpha proof found alpha separation alone is not enough because
  generated equipment sheets do not align to the accepted Rian body/reference

Current review:

- [rian_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/rian_battle_state_pilot_review_v01.md)
- [rian_masked_overlay_edit_pack_v01.md](/Volumes/AI/tactics/docs/generated/rian_masked_overlay_edit_pack_v01.md)
- [rian_masked_overlay_baseline_record_v01.md](/Volumes/AI/tactics/docs/generated/rian_masked_overlay_baseline_record_v01.md)
- [rian_masked_overlay_baseline_review_v01.md](/Volumes/AI/tactics/docs/generated/rian_masked_overlay_baseline_review_v01.md)
- [rian_weapon_overlay_cleanup_checkpoint_v01.md](/Volumes/AI/tactics/docs/generated/rian_weapon_overlay_cleanup_checkpoint_v01.md)
- [rian_asset_engine_comfy_verification_v01.md](/Volumes/AI/tactics/docs/generated/rian_asset_engine_comfy_verification_v01.md)
- [rian_existing_layer_alpha_proof_review_v01.md](/Volumes/AI/tactics/docs/generated/rian_existing_layer_alpha_proof_review_v01.md)

Current `Serin` pilot status:

- `source/serin_idle_sheet_source_v02_layered.png`
- `source/serin_cast_sheet_source_v03_layered.png`
- `source/serin_attack_sheet_source_v03_layered.png`

Current review:

- [serin_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/serin_battle_state_pilot_review_v01.md)

Current `Tia` pilot status:

- `source/tia_idle_sheet_source_v02_layered.png`
- `source/tia_move_sheet_source_v02_layered.png`
- `source/tia_attack_sheet_source_v03_layered.png`

Current review:

- [tia_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/tia_battle_state_pilot_review_v01.md)

Current `Bran` pilot status:

- `source/bran_idle_sheet_source_v03_layered.png`
- `source/bran_move_sheet_source_v03_layered.png`
- `source/bran_attack_sheet_source_v03_layered.png`

Current review:

- [bran_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/bran_battle_state_pilot_review_v01.md)

Current `Enemy Raider` pilot status:

- `source/enemy_raider_idle_sheet_source_v02_layered.png`
- `source/enemy_raider_move_sheet_source_v02_layered.png`
- `source/enemy_raider_attack_sheet_source_v02_layered.png`

Current review:

- [enemy_raider_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/enemy_raider_battle_state_pilot_review_v01.md)

Current `Enemy Skirmisher` pilot status:

- `source/enemy_skirmisher_idle_sheet_source_v02_layered.png`
- `source/enemy_skirmisher_move_sheet_source_v02_layered.png`
- `source/enemy_skirmisher_attack_sheet_source_v02_layered.png`

Current review:

- [enemy_skirmisher_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/enemy_skirmisher_battle_state_pilot_review_v01.md)

Current character state posture:

- battle-state pilot slice has passed the candidate-runtime checkpoint
- the runtime promotion decision pass has been applied for the safe lanes
- `Serin`, `Tia`, and `Enemy Skirmisher` are now promoted into main runtime
- `Rian`, `Bran`, and `Enemy Raider` remain candidate lanes

Current promotion references:

- [character_state_runtime_promotion_decision_v01.md](/Volumes/AI/tactics/docs/generated/character_state_runtime_promotion_decision_v01.md)
- [character_state_runtime_promotion_record_v01.md](/Volumes/AI/tactics/docs/generated/character_state_runtime_promotion_record_v01.md)

## Current Non-Blocking Issue

Some test runners still emit shutdown warnings after `PASS`.

Current status:

- tracked
- non-blocking
- narrowed enough for a separate engineering-hygiene lane

References:

- [runner_shutdown_warning_review_v01.md](/Volumes/AI/tactics/docs/generated/runner_shutdown_warning_review_v01.md)
- [runner_shutdown_warning_followup_v01.md](/Volumes/AI/tactics/docs/generated/runner_shutdown_warning_followup_v01.md)

## Recommended Immediate Posture

Main lane:

- current art/runtime slice is at a stable checkpoint
- the next slice should be chosen deliberately rather than continued by inertia
- current layered roster baseline is strong enough to move on without further
  enemy over-polish

Secondary lane:

- keep shutdown-warning investigation separate as engineering hygiene

## Working Conclusion

The project has moved from ad hoc image generation into a documented runtime art
system with validated chapter-local object families.
