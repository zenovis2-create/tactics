# f53 CH08_01~CH08_03 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch08_01_stage.tres`, `data/stages/ch08_02_stage.tres`, and `data/stages/ch08_03_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This note was updated after f53 authoring landed. Current QA findings below reflect the implemented CH08_01~CH08_03 bark payload and executed runner results.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f53_focused_gates"
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
  scripts/dev/ch08_route_pressure_runner.gd \
  scripts/dev/ch08_production_runner.gd \
  scripts/dev/ch08_shell_runner.gd \
  scripts/dev/ch08_split_line_preview_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
 done

git diff --check
bash scripts/dev/check_runnable_gate0.sh
```

If any listed CH08 runner is deliberately out of scope for the final f53 payload, record the release-owner waiver and the reason. Otherwise treat a missing or failing listed runner as a blocker.

## Acceptance criteria for f53

Block release until all of these are true:

1. Actual CH08_01~CH08_03 stage coverage
   - `data/stages/ch08_01_stage.tres`, `data/stages/ch08_02_stage.tres`, and `data/stages/ch08_03_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch08_01...`, `ch08_02...`, `ch08_03...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH08_01~CH08_03 are black-hound pursuit / route-pressure / lower-ruin stages. Bark lines may reinforce vanished-trail narrowing, moonlit ambush pressure, lower-ruin vent/cell-record outcomes, Lete pursuit pressure, and momentum toward the black-mark control route, but must not replace clear cutscenes or next-destination handoffs.

2. Optional objective ids are exact
   - CH08_01 bark conditions may only reference:
     - `ch08_01_west_hound_sign`
     - `ch08_01_east_signal_post`
   - CH08_02 bark conditions may only reference:
     - `ch08_02_west_moon_scent_post`
     - `ch08_02_east_split_line_cache`
   - CH08_03 bark conditions may only reference:
     - `ch08_03_west_vent_capstan`
     - `ch08_03_east_cell_record_case`
   - No condition may use translated descriptions, decorative prop ids, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, state ids, landmark labels, or near-miss aliases.
   - These stages define optional objectives whose backing `condition` fields use `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.
   - CH08_03 has three interactive objects, but only two optional objective ids. `ch08_03_center_holding_gate` is an interaction/runtime progression object, not an optional bark condition id unless the stage optional objective schema itself changes and the runner expected-id map is updated in the same payload.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, choice continuity, or chapter-flow ownership.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, and support name-call runners still pass.
   - CH08_01 keeps `choice_point_id = &"ch07_mira_testimony"`, `clear_cutscene_id = &"ch08_01_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, and `next_destination_summary` for the northern ambush forest intact.
   - CH08_02 keeps `clear_cutscene_id = &"ch08_02_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, black-hound route-pressure objective state ids, and `next_destination_summary` for the lower ruins intact.
   - CH08_03 keeps `clear_cutscene_id = &"ch08_03_outro"`, `win_condition = &"resolve_all_interactions"`, three-object interaction ownership, holding-gate progression, ruin-vent objective state ids, `weather_type = "night"`, and `next_destination_summary` for the black-mark control route intact.
   - CH08 shell flow remains CH08_01 through CH08_05 and still reaches the CH08 camp handoff.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH08_01~CH08_03 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch08_01_stage.tres`, `data/stages/ch08_02_stage.tres`, and `data/stages/ch08_03_stage.tres` are delivered with the f53 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f53 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f53-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.

## Blocker checks and review risks

Treat any of these as blockers for f53 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - `CH08_01`, `CH08_02`, or `CH08_03` lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH07_05 and never loads `res://data/stages/ch08_01_stage.tres`, `res://data/stages/ch08_02_stage.tres`, and `res://data/stages/ch08_03_stage.tres`.

2. Optional id mismatch
   - CH08_01 uses `flag:ch08_01_west_hound_sign`, `flag:ch08_01_east_signal_post`, translated descriptions, decorative prop ids, landmark labels, objective state ids, or interactive object resource paths instead of `ch08_01_west_hound_sign` and `ch08_01_east_signal_post`.
   - CH08_02 uses `flag:ch08_02_west_moon_scent_post`, `flag:ch08_02_east_split_line_cache`, translated descriptions, decorative prop ids, landmark labels, objective state ids, or interactive object resource paths instead of `ch08_02_west_moon_scent_post` and `ch08_02_east_split_line_cache`.
   - CH08_03 uses `flag:ch08_03_west_vent_capstan`, `flag:ch08_03_east_cell_record_case`, `ch08_03_center_holding_gate`, translated descriptions, decorative prop ids, landmark labels, objective state ids, or interactive object resource paths instead of `ch08_03_west_vent_capstan` and `ch08_03_east_cell_record_case`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of objective ids.
   - Runner expected optional-id map is not updated to include exactly these f53 ids.

3. Queue cap/regression risk
   - Any f53 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH08_01~CH08_03 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids or resource ids, causing stage-resolution, route-pressure, shell-flow, or treasure-ledger regressions.
   - CH08_01 bark authoring breaks the CH07 Mira testimony continuity carried by `choice_point_id = &"ch07_mira_testimony"`.
   - CH08_03 bark authoring breaks the three-step ruin-vent interaction flow, center holding gate behavior, or night-weather presentation.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f53 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f53 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document may be created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented f53 snapshot:

- `data/stages/ch08_01_stage.tres`, `data/stages/ch08_02_stage.tres`, and `data/stages/ch08_03_stage.tres` now each define four compact `post_battle_bark_rules`.
- Each stage covers the existing supported sections: `story`, `bonds`, and `telemetry`.
- Bark ids use lowercase stage prefixes and remain stage-local unique.
- Optional objective condition ids are exact:
  - CH08_01: `ch08_01_west_hound_sign`, `ch08_01_east_signal_post`.
  - CH08_02: `ch08_02_west_moon_scent_post`, `ch08_02_east_split_line_cache`.
  - CH08_03: `ch08_03_west_vent_capstan`, `ch08_03_east_cell_record_case`.
- CH08_03 `ch08_03_center_holding_gate` remains a required interaction/progression object only and was not used as an optional bark condition.
- `scripts/dev/post_battle_bark_queue_runner.gd` now covers CH08_01~CH08_03 in both the authored-stage load loop and expected optional-id map.
- The f53 authored delta is text-only/non-image authoring: post-battle bark rules plus runner/QA coverage. The broader CH08 stage files already contain terrain/decorative/choice metadata in the dirty worktree; if those full files are packaged from this workspace, release ownership must treat that broader stage diff as pre-existing or include it explicitly. f53 did not create image files and did not alter skill systems, EXP, support/name-call, reward, cutscene, shell-flow, or stage-resolution code.

Recorded f53 gate results:

- PASS: `post_battle_bark_queue_runner.gd`.
- PASS: post-battle readability/handoff/result/treasure/stage-resolution/support regression chain.
- PASS: `ch08_route_pressure_runner.gd`.
- PASS: `ch08_production_runner.gd`.
- PASS: `ch08_shell_runner.gd`.
- PASS: `ch08_split_line_preview_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch08_01_stage.tres data/stages/ch08_02_stage.tres data/stages/ch08_03_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f53-ch08-01-ch08-03-post-battle-bark-release-qa.md`.

Observed non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared only inside isolated headless campaign/controller runner contexts with exit code 0.
- Gate0 still reports known workspace-only `res://` warnings from the broader dirty worktree, but exited PASS and did not identify an f53-owned missing reference.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...` remains expected and separate from bark authoring; public release remains blocked by signing custody.

Remaining delivery caution:

- Before commit/package, include f53 bark stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, its `.uid` if required by repository convention, and this QA note if review evidence docs are part of the payload.

## Recommended f53 packaging check

Before packaging or committing f53, include the complete f53 payload:

- `data/stages/ch08_01_stage.tres`
- `data/stages/ch08_02_stage.tres`
- `data/stages/ch08_03_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f53 payload, with only the known warnings above allowed as non-blocking.
