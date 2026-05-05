# f56 CH09A_04~CH09A_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch09a_04_stage.tres` and `data/stages/ch09a_05_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This note was updated after f56 authoring landed. `Current QA findings` reflects the implemented CH09A_04~CH09A_05 bark payload, executed runner output, observed warnings, and final packaging caveats.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f56_focused_gates"
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
  scripts/dev/ch09a_broken_standard_runner.gd \
  scripts/dev/ch09_shell_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
done

git diff --check
bash scripts/dev/check_runnable_gate0.sh
```

A missing or failing focused post-battle runner, CH09A runner, `git diff --check`, or Gate0 is a blocker unless explicitly waived by the release owner. If `ch09_shell_runner.gd` is waived because the f56 slice is limited to CH09A_04~CH09A_05 and the full shell runner is too broad/expensive, record the release-owner waiver and still run `ch09a_broken_standard_runner.gd`.

## Acceptance criteria for f56

Block release until all of these are true:

1. Actual CH09A_04~CH09A_05 stage coverage
   - `data/stages/ch09a_04_stage.tres` and `data/stages/ch09a_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch09a_04...`, `ch09a_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH09A_04~CH09A_05 are Kyle/CH09A approach stages: abandoned officer detention route and the spearline/root-access gate. Bark lines may reinforce aftermath, route pressure, Kyle-line testimony, recovered command traces, censor-pike/root-access discovery, no-casualty discipline, and CH09A camp momentum, but must not replace clear cutscenes, objective text, campaign handoff, Kyle roster/presentation ownership, or next-destination summaries.

2. Optional objective ids are exact
   - CH09A_04 bark conditions may only reference:
     - `ch09a_04_west_cell_witness`
     - `ch09a_04_east_censor_pike`
   - CH09A_05 bark conditions may only reference:
     - `karl_testifies`
     - `no_ally_casualties`
   - `karl_testifies` is the current optional objective id in `ch09a_05_stage.tres`; do not silently rename it to `kyle_testifies` inside bark conditions unless stage data and all validators are intentionally migrated together.
   - No condition may use translated descriptions, decorative prop ids, terrain/landmark labels, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, state ids, route labels, or near-miss aliases.
   - CH09A_04 optional objectives define backing `condition` fields with `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.
   - CH09A_05 mixes a backing `flag:karl_testifies` condition and a direct `no_ally_casualties` condition. Bark rules must still reference optional objective `id` values, not the underlying completion-condition syntax.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, chapter-flow ownership, Kyle presentation/roster ownership, or CH09A camp handoff.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, support name-call, and CH09 focused runners still pass.
   - CH09A_04 keeps `clear_cutscene_id = &"ch09a_04_outro"`, `win_condition = &"defeat_all_enemies"`, two-object interaction ownership, optional objectives for west-cell witness and east-censor pike, and `next_destination_summary` for breaking the censor pike / securing the root approach line intact.
   - CH09A_05 keeps `clear_cutscene_id = &"ch09a_05_outro"`, `win_condition = &"defeat_all_enemies"`, `turn_limit = 12`, no-interactive-object ownership, optional objectives for `karl_testifies` and `no_ally_casualties`, and `next_destination_summary` for entering the inner archive with the recovered seal intact.
   - CH09 shell flow still reaches CH09A camp after CH09A_05 and preserves Kyle/카일 roster and presentation-card handoff.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH09A_04~CH09A_05 in both the authored-stage load loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch09a_04_stage.tres` and `data/stages/ch09a_05_stage.tres` are delivered with the f56 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f56 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f56-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.
- Cutscene runner ObjectDB/resource leak warning at process exit
  - Non-blocking only when the cutscene runner exits 0 and no assertion failed.
  - Treat as a blocker if paired with nonzero exit, missing cutscene linkage, missing handoff state, or a new leak/error pattern tied to the f56 bark payload.

## Blocker checks and review risks

Treat any of these as blockers for f56 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - CH09A_04 or CH09A_05 lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH09A_03 and never loads `res://data/stages/ch09a_04_stage.tres` and `res://data/stages/ch09a_05_stage.tres`.

2. Optional id mismatch
   - CH09A_04 uses `flag:ch09a_04_west_cell_witness`, `flag:ch09a_04_east_censor_pike`, translated descriptions, decorative prop ids, terrain labels, landmark labels, objective state ids, or interactive object resource paths instead of `ch09a_04_west_cell_witness` and `ch09a_04_east_censor_pike`.
   - CH09A_05 uses `flag:karl_testifies`, `kyle_testifies`, translated descriptions, terrain labels, landmark labels, unit ids, objective state ids, or runtime condition syntax instead of `karl_testifies` and `no_ally_casualties`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of optional objective ids.
   - Runner expected optional-id map is not updated to include exactly these f56 ids.

3. Queue cap/regression risk
   - Any f56 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff, interaction-objective, and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH09A_04~CH09A_05 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids, decorative prop ids, object resource paths, or backing `flag:` conditions, causing stage-resolution or interaction-victory regressions.
   - CH09A_04 bark authoring breaks the two-object detention/censor-pike optional objective ownership, defeat-all-enemies victory path, or root-approach handoff.
   - CH09A_05 bark authoring breaks the boss/spearline finale flow, `turn_limit = 12`, no-interactive-object assumption, Kyle/카일 testimony handoff, no-casualty optional outcome, or post-CH09A camp transition.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f56 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f56 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document is created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented f56 snapshot:

- `data/stages/ch09a_04_stage.tres` and `data/stages/ch09a_05_stage.tres` now each define four compact `post_battle_bark_rules`.
- Each stage covers the supported sections: `story`, `bonds`, and `telemetry`.
- Bark ids use lowercase stage prefixes and remain stage-local unique.
- Optional objective condition ids are exact:
  - CH09A_04: `ch09a_04_west_cell_witness`, `ch09a_04_east_censor_pike`.
  - CH09A_05: `karl_testifies`, `no_ally_casualties`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now covers CH09A_04~CH09A_05 in both the authored-stage load loop and expected optional-id map.
- The intended f56-owned authoring is text-only/non-image: post-battle bark rules plus runner/QA coverage. f56 did not create image files and did not alter skill systems, EXP, support/name-call, reward, cutscene, shell-flow, Kyle presentation ownership, or stage-resolution code.

Recorded f56 gate results:

- PASS: `post_battle_bark_queue_runner.gd`.
- PASS: post-battle readability/handoff/result/treasure/stage-resolution/support regression chain.
- PASS: `ch09a_broken_standard_runner.gd`.
- PASS: `ch09_shell_runner.gd`.
- PASS: `ch06_ch10_cutscene_runner.gd`.
- PASS: `three_star_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch09a_04_stage.tres data/stages/ch09a_05_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f56-ch09a-04-ch09a-05-post-battle-bark-release-qa.md`.

Observed non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared only inside isolated headless campaign/controller runner contexts with exit code 0.
- `ch06_ch10_cutscene_runner.gd` passed but emitted the known ObjectDB/resource leak warning pattern at exit.
- Gate0 still reports known workspace-only `res://` warnings from the broader dirty worktree, but exited PASS and did not identify an f56-owned missing reference.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...` remains expected and separate from bark authoring; public release remains blocked by signing custody.

Remaining delivery caution:

- Before commit/package, include f56 bark stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, its `.uid` if required by repository convention, and this QA note if review evidence docs are part of the payload.
- CH09A_04 currently references workspace-only object resources `data/objects/ch09a_04_west_cell_witness.tres` and `data/objects/ch09a_04_east_censor_pike.tres`; if packaging the CH09A_04 stage file from this workspace, include/own those object resources or split the broader object-resource stage work away from the f56 bark package.
- The workspace already contains broad unrelated dirty/untracked assets and scripts. Do not treat those as f56 payload unless explicitly owned by the release; also do not let them hide f56-owned missing/stale files.

## Recommended f56 packaging check

Before packaging or committing f56, include the complete f56 payload:

- `data/stages/ch09a_04_stage.tres`
- `data/stages/ch09a_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f56 payload, with only the known warnings above allowed as non-blocking.
