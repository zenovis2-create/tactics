# f49 CH06_01~CH06_03 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch06_01_stage.tres`, `data/stages/ch06_02_stage.tres`, and `data/stages/ch06_03_stage.tres`, with release validation separated into blockers versus known non-blocking warnings.

This note was updated after f49 authoring landed. The Current QA findings section records the implemented payload, focused runner results, observed warnings, and remaining packaging cautions.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f49_focused_gates"
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
  scripts/dev/support_namecall_pipeline_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
 done

git diff --check
bash scripts/dev/check_runnable_gate0.sh
```

## Acceptance criteria for f49

Block release until all of these are true:

1. Actual CH06_01, CH06_02, and CH06_03 stage coverage
   - `data/stages/ch06_01_stage.tres`, `data/stages/ch06_02_stage.tres`, and `data/stages/ch06_03_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch06_01...`, `ch06_02...`, `ch06_03...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath/route-hook rhythm without copying Farland names, dialogue, UI, art, or scenario-specific names from Farland.
   - CH06_01~CH06_03 are fortress-entry/interior-approach stages, so bark lines may reinforce aftermath, survival, pressure, and route momentum, but must not replace the clear cutscene or next-destination handoff.

2. Optional objective ids are exact
   - CH06_01 bark conditions may only reference:
     - `ch06_01_no_ally_casualties`
     - `ch06_01_scout_survives`
   - CH06_02 bark conditions may only reference:
     - `ch06_02_west_battery_winch`
     - `ch06_02_center_chain_lift_gate`
   - CH06_03 bark conditions may only reference:
     - `ch06_03_no_ally_casualties`
     - `ch06_03_vanguard_survives`
   - No condition may use translated descriptions, decorative prop ids, interactive object labels, backing `flag:` strings, Korean text, or near-miss aliases.
   - CH06_02 optional objective definitions currently use backing `condition = "flag:..."` strings. Bark rules must still reference the optional objective `id` values above, not `flag:` condition strings.
   - CH06_02 has an interaction trio at runtime, but only the current optional objective ids listed above are allowed for bark conditions unless the stage optional objective schema itself changes and the runner expected-id map is updated in the same payload.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, or chapter-flow ownership.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, and support name-call runners still pass.
   - CH06_01 keeps `choice_point_id = &"ch05_ledger_enoch"`, `clear_cutscene_id = &"ch06_01_outro"`, and its next destination ownership intact.
   - CH06_02 keeps `clear_cutscene_id = &"ch06_02_outro"`, `rule_template_id = &"valtor_line_control"`, and interaction-trio stage-resolution ownership intact.
   - CH06_03 keeps `clear_cutscene_id = &"ch06_03_outro"` and next-destination ownership for the interior-citadel approach intact.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH06_01~CH06_03 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index, not left workspace-only.
   - `data/stages/ch06_01_stage.tres`, `data/stages/ch06_02_stage.tres`, and `data/stages/ch06_03_stage.tres` are delivered with the f49 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f49 bark blocker unless it accompanies a failing exit code, missing handoff state, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f49-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.

## Blocker checks and review risks

Treat any of these as blockers for f49 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - `CH06_01`, `CH06_02`, or `CH06_03` lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH05_05 and never loads `res://data/stages/ch06_01_stage.tres`, `res://data/stages/ch06_02_stage.tres`, and `res://data/stages/ch06_03_stage.tres`.

2. Optional id mismatch
   - CH06_01 uses unit ids, condition strings, or translated labels instead of `ch06_01_no_ally_casualties` and `ch06_01_scout_survives`.
   - CH06_02 uses `flag:ch06_02_west_battery_winch`, `flag:ch06_02_center_chain_lift_gate`, decorative object ids, interaction labels, or an invented east-battery optional id instead of the current optional objective ids.
   - CH06_03 uses unit ids, condition strings, or translated labels instead of `ch06_03_no_ally_casualties` and `ch06_03_vanguard_survives`.
   - Any bark condition includes `flag:` prefixes or Korean descriptions instead of objective ids.
   - Runner expected optional-id map is not updated to include exactly these f49 ids.

3. Queue cap/regression risk
   - Any f49 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH06_01~CH06_03 `clear_cutscene_id` values or `next_destination_summary` text.
   - CH06_01 bark authoring breaks the prior CH05 choice-point continuity carried by `choice_point_id = &"ch05_ledger_enoch"`.
   - CH06_02 bark authoring confuses optional objective ids with the `valtor_line_control` interaction-trio runtime state, causing stage-resolution or treasure-ledger regressions.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only and is omitted from the f49 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f49 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document was created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch06_01_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `ch06_01_no_ally_casualties`, `ch06_01_scout_survives`.
- `data/stages/ch06_02_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `ch06_02_west_battery_winch`, `ch06_02_center_chain_lift_gate`.
  - The east battery interaction remains flavor/runtime stage-clear context only, not an optional bark condition.
- `data/stages/ch06_03_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `ch06_03_no_ally_casualties`, `ch06_03_vanguard_survives`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now includes CH06_01~CH06_03 in both the expected optional-id map and authored-stage load loop.

Recorded f49 gate results:

- PASS: `/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/post_battle_bark_queue_runner.gd`
  - Output included `[PASS] post_battle_bark_queue_runner: all assertions passed.`
- PASS: post-battle/readability/handoff/result/treasure/stage-resolution/support regression chain:
  - `post_battle_readability_runner.gd`
  - `post_battle_handoff_runner.gd`
  - `result_entry_tempo_runner.gd`
  - `result_screen_readability_runner.gd`
  - `treasure_ledger_runner.gd`
  - `stage_resolution_runner.gd`
  - `support_namecall_pipeline_runner.gd`
- PASS: `bash scripts/dev/check_runnable_gate0.sh`
  - Output included `Runnable Gate 0 integrity check passed`.
- PASS: `git diff --check -- data/stages/ch06_01_stage.tres data/stages/ch06_02_stage.tres data/stages/ch06_03_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f49-ch06-01-ch06-03-post-battle-bark-release-qa.md`

Observed non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared in isolated headless runners that still exited 0.
- Gate0 reported workspace-only `res://` warnings and Android `[SIGNING-DEFERRED][INTERNAL-QA]` warning, but exited 0.

Remaining delivery caution:

- This is a working-tree completion. Before commit/package, include f49 stage files, `scripts/dev/post_battle_bark_queue_runner.gd`, its `.uid` if required by repository convention, and this QA note if review evidence docs are part of the payload.

## Recommended f49 packaging check

Before packaging or committing f49, include the complete f49 payload:

- `data/stages/ch06_01_stage.tres`
- `data/stages/ch06_02_stage.tres`
- `data/stages/ch06_03_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f49 payload, with only the known warnings above allowed as non-blocking.
