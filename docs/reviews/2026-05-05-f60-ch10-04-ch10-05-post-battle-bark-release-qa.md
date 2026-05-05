# f60 CH10_04~CH10_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch10_04_stage.tres` and `data/stages/ch10_05_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This is a release-QA scout note. It defines the gates f60 must satisfy before release-readiness is claimed. Current working-tree observations are listed separately from the acceptance gates so known warnings are not confused with blockers.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f60_focused_gates"
export HOME="$GODOT_QA_HOME"
mkdir -p "$GODOT_QA_HOME"

for script in \
  scripts/dev/post_battle_bark_queue_runner.gd \
  scripts/dev/post_battle_readability_runner.gd \
  scripts/dev/post_battle_handoff_runner.gd \
  scripts/dev/result_screen_readability_runner.gd \
  scripts/dev/result_entry_tempo_runner.gd \
  scripts/dev/treasure_ledger_runner.gd \
  scripts/dev/stage_resolution_runner.gd \
  scripts/dev/support_namecall_pipeline_runner.gd \
  scripts/dev/ch10_final_bell_preview_runner.gd \
  scripts/dev/ch10_phase3_cinematic_runner.gd \
  scripts/dev/ch06_ch10_boss_surface_runner.gd \
  scripts/dev/ch10_shell_runner.gd \
  scripts/dev/ch06_ch10_cutscene_runner.gd \
  scripts/dev/three_star_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
done

git diff --check -- \
  data/stages/ch10_04_stage.tres \
  data/stages/ch10_05_stage.tres \
  scripts/dev/post_battle_bark_queue_runner.gd \
  docs/reviews/2026-05-05-f60-ch10-04-ch10-05-post-battle-bark-release-qa.md

bash scripts/dev/check_runnable_gate0.sh
```

A missing or failing focused post-battle runner, f60-relevant CH10 runner, `ch10_shell_runner.gd`, `ch06_ch10_cutscene_runner.gd`, `three_star_runner.gd`, `git diff --check`, or Gate0 is a blocker unless explicitly waived by the release owner. `ch10_final_bell_preview_runner.gd`, `ch10_phase3_cinematic_runner.gd`, and `ch06_ch10_boss_surface_runner.gd` are the focused late-CH10/final-bell surface runners for this slice and should not be waived unless the release owner provides a written waiver and an equivalent CH10_04~CH10_05 validation record.

## Acceptance criteria for f60

Block release until all of these are true:

1. Actual CH10_04~CH10_05 stage coverage
   - `data/stages/ch10_04_stage.tres` and `data/stages/ch10_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch10_04...`, `ch10_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH10_04~CH10_05 are final-tower endgame stages: king's edict / stair opening and final bell / last-name resolution. Bark lines may reinforce aftermath, final approach pressure, edict-throne discipline, name-call/bell pressure, optional-objective discipline, no-casualty discipline, and route momentum into the final resolution, but must not replace clear cutscenes, objective text, campaign handoff, final-boss mechanics, final ending ownership, postgame title return, NG+ unlock, or next-destination summaries.

2. Optional objective ids are exact
   - CH10_04 bark conditions may only reference:
     - `ch10_04_edict_throne`
     - `no_ally_casualties`
   - CH10_05 bark conditions may only reference:
     - `all_allies_name_called`
     - `no_ally_casualties`
   - No condition may use translated descriptions, decorative prop ids, terrain/landmark labels, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, state ids, route labels, or near-miss aliases.
   - CH10_04 and CH10_05 optional objectives define backing `condition` fields with `flag:...` or runtime condition strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.
   - CH10_05 interactive object ids `ch10_05_bell_dais` and `ch10_05_anchor_chain` are object ids, not optional objective ids; bark conditions must not use them unless they are separately added as optional objective ids by the stage owner and runner expectations are updated accordingly.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, chapter-flow ownership, CH10 shell ownership, CH10 ending ownership, final-bell preview ownership, final-boss surface ownership, or final route handoff.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, support name-call, three-star, cutscene, CH10 shell, and f60-relevant CH10 focused runners still pass.
   - CH10_04 keeps `start_cutscene_id = &"ch10_04_intro"`, `clear_cutscene_id = &"ch10_04_outro"`, `win_condition = &"resolve_all_interactions_and_defeat_all_enemies"`, edict-throne interaction ownership, `interaction_objective_state_ids` for `edict_throne_closed` / `edict_throne_open`, `weather_type = "rain"`, and `next_destination_summary` for descending to the bell chamber intact.
   - CH10_05 keeps `start_cutscene_id = &"ch10_05_intro"`, `clear_cutscene_id = &""`, `win_condition = &"resolve_all_interactions_and_defeat_all_enemies"`, `rule_template_id = &"karon_bell_pressure"`, `choice_point_id = &"ch10_tower_name"`, bell-dais and anchor-chain interaction ownership, final-bell pressure modifiers, name-call optional objective, `weather_type = "night"`, and final `next_destination_summary` intact.
   - `ch10_final_bell_preview_runner.gd` still validates CH10_04~CH10_05 final-bell route presentation.
   - `ch10_phase3_cinematic_runner.gd` still validates final phase cinematic ownership.
   - `ch06_ch10_boss_surface_runner.gd` still validates late boss/final pressure surfaces.
   - `ch10_shell_runner.gd` still reaches CH10 intro, CH10_01~CH10_05 flow, final resolution, postgame title return, and NG+ unlock. Bark text must not introduce new missing visual/resource dependencies or alter final ending ownership.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH10_04~CH10_05 in both the authored-stage load loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch10_04_stage.tres` and `data/stages/ch10_05_stage.tres` are delivered with the f60 payload.
   - Directly referenced f60 resources are delivered or already tracked, including `data/objects/ch10_04_edict_throne.tres`, `data/objects/ch10_05_bell_dais.tres`, and `data/objects/ch10_05_anchor_chain.tres`.
   - If CH10_05 decorative prop files are release-owned by the f60 payload, their image/import resources are delivered or explicitly waived as pre-existing workspace content.
   - `git diff --check` passes against the f60-owned files.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f60 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f60-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.
- Cutscene runner ObjectDB/resource leak warning at process exit
  - Non-blocking only when the cutscene runner exits 0 and no assertion failed.
  - Treat as a blocker if paired with nonzero exit, missing cutscene linkage, missing handoff state, or a new leak/error pattern tied to the f60 bark payload.

## Blocker checks and review risks

Treat any of these as blockers for f60 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - CH10_04 or CH10_05 lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH10_03 and never loads `res://data/stages/ch10_04_stage.tres` and `res://data/stages/ch10_05_stage.tres`.

2. Optional id mismatch
   - CH10_04 uses `flag:ch10_04_edict_throne`, Korean descriptions, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch10_04_edict_throne` and `no_ally_casualties`.
   - CH10_05 uses `flag:all_allies_name_called`, Korean descriptions, terrain labels, landmark labels, objective state ids, object resource paths, interactive object ids (`ch10_05_bell_dais`, `ch10_05_anchor_chain`), or runtime condition syntax instead of `all_allies_name_called` and `no_ally_casualties`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of optional objective ids.
   - Runner expected optional-id map is not updated to include exactly these f60 ids.

3. Queue cap/regression risk
   - Any f60 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff, final-bell, and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH10_04 `clear_cutscene_id`, CH10_05 empty final `clear_cutscene_id`, or either `next_destination_summary`.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids, decorative prop ids, object resource paths, terrain labels, landmark labels, backing `flag:` conditions, or rule-template modifier ids, causing stage-resolution, final-bell preview, CH10 shell, boss-surface, or three-star regressions.
   - CH10_04 bark authoring breaks edict-throne objective ownership, rain presentation, or stair-opening handoff into CH10_05.
   - CH10_05 bark authoring breaks bell-dais/anchor-chain interaction ownership, Karon/Karuon bell-pressure modifiers, name-call optional objective, choice-point ownership, postgame title return, or NG+ unlock.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.
   - Bark lines imply a different final ending, final-bell rule state, final boss resolution, or NG+ state than the CH10 shell/final systems own.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f60 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - CH10 object/resources referenced by the f60-owned stage payload remain workspace-only or missing when Gate0/package validation runs.
   - CH10_05 decorative prop image/import resources are referenced by modified stage data but are omitted from package validation without a release-owner waiver.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f60 payload, not the whole dirty index.

6. QA-doc freshness risk
   - This document must remain aligned with the implemented working-tree payload. If f60 files change again, update `Current QA findings` with the new runner results, observed warnings, and payload list before claiming release-readiness.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch10_04_stage.tres` and `data/stages/ch10_05_stage.tres` now each define 4 compact `post_battle_bark_rules`.
- Each f60 stage covers the required result sections: `story`, `bonds`, and `telemetry`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now extends both the expected optional-id map and the authored-stage load loop through CH10_04~CH10_05.
- f60 bark conditions use only exact optional objective ids:
  - CH10_04: `ch10_04_edict_throne`, `no_ally_casualties`.
  - CH10_05: `all_allies_name_called`, `no_ally_casualties`.
- f60 did not create or modify image assets, portraits, UI art, or visual resources. `ch10_final_bell_preview_runner.gd` was run only as an existing CH10 regression/surface-loading gate. CH10_05 `decorative_props` / PNG-facing stage dressing were present in the pre-f60 working-tree snapshot before this bark authoring slice; they are broader dirty stage-surface data, not f60-owned bark delta, even though they appear in the current HEAD diff.
- f60 preserves existing stronger systems: optional objective stars, bonus EXP/progression, memory fragment command unlock, support/name-call, treasure ledger, telemetry, CH10_04 clear cutscene handoff, CH10_05 empty final `clear_cutscene_id`, edict-throne interaction, bell-dais/anchor-chain interactions, `karon_bell_pressure` template ownership, name-call/choice-point flow, CH10 shell final resolution, postgame title return, NG+ unlock, and `StageResolutionService` behavior.

Executed f60 gates from `/Volumes/AI/tactics` with `/opt/homebrew/bin/godot4`:

- PASS: `scripts/dev/post_battle_bark_queue_runner.gd`.
- PASS: `scripts/dev/post_battle_readability_runner.gd`.
- PASS: `scripts/dev/post_battle_handoff_runner.gd`.
- PASS: `scripts/dev/result_entry_tempo_runner.gd`.
- PASS: `scripts/dev/result_screen_readability_runner.gd`.
- PASS: `scripts/dev/treasure_ledger_runner.gd`.
- PASS: `scripts/dev/stage_resolution_runner.gd`.
- PASS: `scripts/dev/support_namecall_pipeline_runner.gd`.
- PASS: `scripts/dev/ch10_tower_chain_runner.gd`.
- PASS: `scripts/dev/ch10_shell_runner.gd`.
- PASS: `scripts/dev/ch10_phase3_cinematic_runner.gd`.
- PASS: `scripts/dev/ch10_final_bell_preview_runner.gd`.
- PASS: `scripts/dev/ch06_ch10_boss_surface_runner.gd` after updating the runner to validate f32+ post-battle cutscene handoff metadata instead of expecting direct clear-cutscene playback inside `BattleController`.
- PASS: `scripts/dev/ending_credits_roll_runner.gd`.
- PASS: `scripts/dev/true_ending_runner.gd`.
- PASS: `scripts/dev/ch06_ch10_cutscene_runner.gd`.
- PASS: `scripts/dev/three_star_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch10_04_stage.tres data/stages/ch10_05_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f60-ch10-04-ch10-05-post-battle-bark-release-qa.md` exited 0 for tracked diffs. Because `scripts/dev/post_battle_bark_queue_runner.gd` and this QA note are currently untracked, that Git command does not inspect their content until they are staged/tracked; run a separate local whitespace scan or stage them before package validation.

Observed known warnings, all non-blocking in this f60 run because the relevant commands exited 0:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` in isolated headless result/handoff/support runners.
- `ch06_ch10_cutscene_runner.gd` emitted ObjectDB/resource leak cleanup warnings after PASS.
- Gate0 reported existing workspace-only `res://` targets and Android `[SIGNING-DEFERRED][INTERNAL-QA] package/signed=false`; Gate0 still exited PASS and public release remains blocked by separate signing custody.

Remaining delivery caution:

- Working-tree implementation/QA is complete for f60 after the listed gates. Package/index readiness is still BLOCKED until the f60 payload is staged/included or explicitly waived by the release owner: CH10_04~CH10_05 stage bark changes, `scripts/dev/post_battle_bark_queue_runner.gd`, `scripts/dev/ch06_ch10_boss_surface_runner.gd`, this QA note, and `scripts/dev/post_battle_bark_queue_runner.gd.uid` if repository convention requires it.
- `data/objects/ch10_04_edict_throne.tres`, `data/objects/ch10_05_bell_dais.tres`, and `data/objects/ch10_05_anchor_chain.tres` are directly referenced by the modified stage files and should remain present in the release payload; scoped status shows them as already tracked/pre-existing rather than new f60 blockers.
- CH10_05 decorative prop image/import resources are broader pre-existing dirty stage-surface dependencies, not f60-owned bark delta. If packaging the full CH10_05 stage diff, include those resources or obtain a release-owner waiver/scope split; do not count them as f60 bark implementation work.
- The repository still has broader pre-existing dirty/untracked work. Treat only the listed f60 bark/runner/QA files as this slice's owned payload unless the release owner explicitly expands scope.

## Recommended f60 packaging check

Before packaging or committing f60, include the complete f60 payload:

- `data/stages/ch10_04_stage.tres`
- `data/stages/ch10_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- `scripts/dev/ch06_ch10_boss_surface_runner.gd`
- keep these already-tracked stage dependencies present in the release payload: `data/objects/ch10_04_edict_throne.tres`, `data/objects/ch10_05_bell_dais.tres`, `data/objects/ch10_05_anchor_chain.tres`
- if packaging the full CH10_05 dirty stage diff, include or explicitly scope-waive the pre-existing CH10_05 decorative prop image/import resources
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f60 payload, with only the known warnings above allowed as non-blocking.
