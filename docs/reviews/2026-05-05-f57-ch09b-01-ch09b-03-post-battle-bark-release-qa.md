# f57 CH09B_01~CH09B_03 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch09b_01_stage.tres`, `data/stages/ch09b_02_stage.tres`, and `data/stages/ch09b_03_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This note has been updated after the f57 bark implementation landed in the working tree. `Current QA findings` records the actual payload list, executed runner results, observed warnings, and final packaging caveats.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f57_focused_gates"
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
  scripts/dev/ch09b_revision_runner.gd \
  scripts/dev/ch09b_root_archive_preview_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
done

git diff --check
bash scripts/dev/check_runnable_gate0.sh
```

A missing or failing focused post-battle runner, CH09B runner, `git diff --check`, or Gate0 is a blocker unless explicitly waived by the release owner. If `ch09b_root_archive_preview_runner.gd` is waived because f57 is text-only and visual preview validation is too broad/expensive for the bark slice, record the release-owner waiver and still run `ch09b_revision_runner.gd`.

## Acceptance criteria for f57

Block release until all of these are true:

1. Actual CH09B_01~CH09B_03 stage coverage
   - `data/stages/ch09b_01_stage.tres`, `data/stages/ch09b_02_stage.tres`, and `data/stages/ch09b_03_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch09b_01...`, `ch09b_02...`, `ch09b_03...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH09B_01~CH09B_03 are Noah/CH09B root-archive approach stages: root gate, erased-name shelves, and last-keeper route. Bark lines may reinforce aftermath, archive pressure, erased-name testimony, root-gate/index discovery, memory-lattice stabilization, no-casualty discipline, and CH09B route momentum, but must not replace clear cutscenes, objective text, campaign handoff, Noah roster/presentation ownership, or next-destination summaries.

2. Optional objective ids are exact
   - CH09B_01 bark conditions may only reference:
     - `ch09b_01_west_root_seal`
     - `ch09b_01_east_root_index`
   - CH09B_02 bark conditions may only reference:
     - `ch09b_02_west_erased_shelf`
     - `ch09b_02_east_revision_shelf`
   - CH09B_03 bark conditions may only reference:
     - `ch09b_03_center_memory_lattice`
     - `ch09b_03_east_keeper_record`
   - CH09B_03 also has an interactive object `ch09b_03_west_keeper_latch`, but it is not currently an optional objective id. Do not use it in `optional_completed` or `optional_failed` bark conditions unless the stage optional-objective data and all validators are intentionally migrated together.
   - No condition may use translated descriptions, decorative prop ids, terrain/landmark labels, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, state ids, route labels, or near-miss aliases.
   - CH09B_01~CH09B_03 optional objectives define backing `condition` fields with `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, chapter-flow ownership, Noah presentation/roster ownership, or CH09B route handoff.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, support name-call, and CH09B focused runners still pass.
   - CH09B_01 keeps `choice_point_id = &"ch09a_kyle_testimony"`, `start_cutscene_id = &"ch09b_01_intro"`, `clear_cutscene_id = &"ch09b_01_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, optional objectives for west root seal and east root index, and `next_destination_summary` for entering the erased-name shelves intact.
   - CH09B_02 keeps `start_cutscene_id = &"ch09b_02_intro"`, `clear_cutscene_id = &"ch09b_02_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, optional objectives for west erased shelf and east revision shelf, and `next_destination_summary` for moving toward the last keeper cell intact.
   - CH09B_03 keeps `start_cutscene_id = &"ch09b_03_intro"`, `clear_cutscene_id = &"ch09b_03_outro"`, `win_condition = &"resolve_all_interactions"`, three-object interaction ownership, optional objectives for center memory lattice and east keeper record, `weather_type = "night"`, and `next_destination_summary` for descending toward the revision room intact.
   - `ch09b_revision_runner.gd` still validates root-gate, erased-shelf, keeper-route, and revision-core objective progression. f57 bark authoring must not regress CH09B_04 coverage already present in that runner.
   - `ch09b_root_archive_preview_runner.gd` still loads the CH09B root-archive preview when it is included in the focused gate pack; bark text must not introduce new missing visual/resource dependencies.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH09B_01~CH09B_03 in both the authored-stage load loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch09b_01_stage.tres`, `data/stages/ch09b_02_stage.tres`, and `data/stages/ch09b_03_stage.tres` are delivered with the f57 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f57 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f57-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.
- Cutscene runner ObjectDB/resource leak warning at process exit
  - Non-blocking only when the cutscene runner exits 0 and no assertion failed.
  - Treat as a blocker if paired with nonzero exit, missing cutscene linkage, missing handoff state, or a new leak/error pattern tied to the f57 bark payload.

## Blocker checks and review risks

Treat any of these as blockers for f57 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - CH09B_01, CH09B_02, or CH09B_03 lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH09A_05 and never loads `res://data/stages/ch09b_01_stage.tres`, `res://data/stages/ch09b_02_stage.tres`, and `res://data/stages/ch09b_03_stage.tres`.

2. Optional id mismatch
   - CH09B_01 uses `flag:ch09b_01_west_root_seal`, `flag:ch09b_01_east_root_index`, translated descriptions, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch09b_01_west_root_seal` and `ch09b_01_east_root_index`.
   - CH09B_02 uses `flag:ch09b_02_west_erased_shelf`, `flag:ch09b_02_east_revision_shelf`, translated descriptions, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch09b_02_west_erased_shelf` and `ch09b_02_east_revision_shelf`.
   - CH09B_03 uses `flag:ch09b_03_center_memory_lattice`, `flag:ch09b_03_east_keeper_record`, `ch09b_03_west_keeper_latch`, decorative prop ids, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch09b_03_center_memory_lattice` and `ch09b_03_east_keeper_record`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of optional objective ids.
   - Runner expected optional-id map is not updated to include exactly these f57 ids.

3. Queue cap/regression risk
   - Any f57 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff, interaction-objective, and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH09B_01~CH09B_03 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids, decorative prop ids, object resource paths, or backing `flag:` conditions, causing stage-resolution or interaction-victory regressions.
   - CH09B_01 bark authoring breaks root-gate two-object interaction ownership, `choice_point_id = &"ch09a_kyle_testimony"`, or the route handoff from Kyle testimony into the archive gate.
   - CH09B_02 bark authoring breaks erased-shelf two-object interaction ownership, missing-name route trace, or last-keeper-cell handoff.
   - CH09B_03 bark authoring breaks three-object keeper-route interaction ownership, the non-optional west keeper latch requirement, Noah memory-lattice handoff, night presentation, or revision-room transition.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f57 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - CH09B object resources referenced by the f57-owned stage payload remain workspace-only or missing when Gate0/package validation runs.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f57 payload, not the whole dirty index.

6. QA-doc freshness risk
   - This document must remain aligned with the implemented working-tree payload. If f57 files change again, update `Current QA findings` with the new runner results, observed warnings, and payload list before claiming release-readiness.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch09b_01_stage.tres`, `data/stages/ch09b_02_stage.tres`, and `data/stages/ch09b_03_stage.tres` now each define 4 compact `post_battle_bark_rules`.
- Each f57 stage covers the required result sections: `story`, `bonds`, and `telemetry`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now extends both the expected optional-id map and the authored-stage load loop through CH09B_01~CH09B_03.
- f57 bark conditions use only exact optional objective ids:
  - CH09B_01: `ch09b_01_west_root_seal`, `ch09b_01_east_root_index`.
  - CH09B_02: `ch09b_02_west_erased_shelf`, `ch09b_02_east_revision_shelf`.
  - CH09B_03: `ch09b_03_center_memory_lattice`, `ch09b_03_east_keeper_record`.
- CH09B_03 `ch09b_03_west_keeper_latch` remains a required interaction object only; f57 did not use it in `optional_completed` / `optional_failed` bark conditions.
- f57 did not create or modify image assets, portraits, UI art, or visual resources. `ch09b_03_stage.tres` already contained `decorative_props` / PNG-facing stage dressing in the pre-f57 working-tree snapshot; those visual-surface lines are broader dirty stage data and are not part of the f57-owned bark delta. `ch09b_root_archive_preview_runner.gd` was run only as an existing CH09B regression/surface-loading gate.
- f57 preserves existing stronger systems: optional objective stars, bonus EXP/progression, memory fragment command unlock, support/name-call, treasure ledger, telemetry, cutscene IDs, `next_destination_summary`, and `StageResolutionService` behavior.

Executed f57 gates from `/Volumes/AI/tactics` with `/opt/homebrew/bin/godot4`:

- PASS: `scripts/dev/post_battle_bark_queue_runner.gd`.
- PASS: `scripts/dev/post_battle_readability_runner.gd`.
- PASS: `scripts/dev/post_battle_handoff_runner.gd`.
- PASS: `scripts/dev/result_entry_tempo_runner.gd`.
- PASS: `scripts/dev/result_screen_readability_runner.gd`.
- PASS: `scripts/dev/treasure_ledger_runner.gd`.
- PASS: `scripts/dev/stage_resolution_runner.gd`.
- PASS: `scripts/dev/support_namecall_pipeline_runner.gd`.
- PASS: `scripts/dev/ch09b_revision_runner.gd`.
- PASS: `scripts/dev/ch09b_root_archive_preview_runner.gd`.
- PASS: `scripts/dev/ch09_shell_runner.gd`.
- PASS: `scripts/dev/ch06_ch10_cutscene_runner.gd`.
- PASS: `scripts/dev/three_star_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch09b_01_stage.tres data/stages/ch09b_02_stage.tres data/stages/ch09b_03_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f57-ch09b-01-ch09b-03-post-battle-bark-release-qa.md` exited 0 for tracked diffs. Because `scripts/dev/post_battle_bark_queue_runner.gd` and this QA note are currently untracked, that Git command does not inspect their content until they are staged/tracked; a separate local whitespace scan was run for the f57-owned untracked files.
- PASS: local whitespace scan for f57-owned untracked files: `scripts/dev/post_battle_bark_queue_runner.gd`, `scripts/dev/post_battle_bark_queue_runner.gd.uid`, and this QA note.

Observed known warnings, all non-blocking in this f57 run because the relevant commands exited 0:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` in isolated headless result/handoff/support runners.
- `ch06_ch10_cutscene_runner.gd` emitted ObjectDB/resource leak cleanup warnings after PASS.
- Gate0 reported existing workspace-only `res://` targets and Android `[SIGNING-DEFERRED][INTERNAL-QA] package/signed=false`; Gate0 still exited PASS and public release remains blocked by separate signing custody.

Remaining delivery caution:

- Working-tree implementation/QA is complete for f57 after the listed gates. Package/index readiness is still BLOCKED until the f57 payload is staged/included or explicitly waived by the release owner: CH09B_01~CH09B_03 stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, this QA note, and `scripts/dev/post_battle_bark_queue_runner.gd.uid` if repository convention requires it.
- The repository still has broader pre-existing dirty/untracked work. Treat only the listed f57 bark/runner/QA files as this slice's owned payload unless the release owner explicitly expands scope.

## Recommended f57 packaging check

Before packaging or committing f57, include the complete f57 payload:

- `data/stages/ch09b_01_stage.tres`
- `data/stages/ch09b_02_stage.tres`
- `data/stages/ch09b_03_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f57 payload, with only the known warnings above allowed as non-blocking.
