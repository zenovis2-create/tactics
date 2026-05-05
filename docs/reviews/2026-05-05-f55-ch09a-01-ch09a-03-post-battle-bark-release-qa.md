# f55 CH09A_01~CH09A_03 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch09a_01_stage.tres`, `data/stages/ch09a_02_stage.tres`, and `data/stages/ch09a_03_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This note was updated after f55 authoring landed. Current QA findings below reflect the implemented CH09A_01~CH09A_03 bark payload, executed runner results, observed warnings, and final packaging caveats.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f55_focused_gates"
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

If `ch09_shell_runner.gd` is waived because the f55 slice is limited to CH09A_01~CH09A_03 and the full shell runner is too broad/expensive, record the release-owner waiver and still run `ch09a_broken_standard_runner.gd`. A missing or failing focused post-battle runner, `ch09a_broken_standard_runner.gd`, `git diff --check`, or Gate0 is a blocker unless explicitly waived by the release owner.

## Acceptance criteria for f55

Block release until all of these are true:

1. Actual CH09A_01~CH09A_03 stage coverage
   - `data/stages/ch09a_01_stage.tres`, `data/stages/ch09a_02_stage.tres`, and `data/stages/ch09a_03_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch09a_01...`, `ch09a_02...`, `ch09a_03...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH09A_01~CH09A_03 are Kyle/CH09A approach stages: outer defense line, bridge of banners, and nameless oath hall. Bark lines may reinforce aftermath, route pressure, Kyle bridge-line momentum, recovered command traces, and officer-route discovery, but must not replace clear cutscenes, interaction objective text, campaign handoff, Kyle roster/presentation ownership, or next-destination summaries.

2. Optional objective ids are exact
   - CH09A_01 bark conditions may only reference:
     - `ch09a_01_west_defense_tablet`
     - `ch09a_01_east_signal_standard`
   - CH09A_02 bark conditions may only reference:
     - `ch09a_02_bridge_banner_ledger`
     - `ch09a_02_oath_pike_post`
   - CH09A_03 bark conditions may only reference:
     - `ch09a_03_west_oath_roll`
     - `ch09a_03_east_censor_mark`
   - No condition may use translated descriptions, decorative prop ids, terrain/landmark labels, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, state ids, route labels, or near-miss aliases.
   - These stages define optional objectives whose backing `condition` fields use `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.
   - CH09A_01 and CH09A_02 interactive object resource ids match their optional ids, but bark validation should still treat the optional objective table as the source of truth rather than decorative prop ids, object resource paths, or labels.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, chapter-flow ownership, Kyle presentation/roster ownership, or CH09A camp handoff.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, support name-call, and CH09 focused runners still pass.
   - CH09A_01 keeps `clear_cutscene_id = &"ch09a_01_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, `outer_line_locked` / `outer_line_partial` / `outer_line_broken` state ids, and `next_destination_summary` for Kyle's bridge zone intact.
   - CH09A_02 keeps `clear_cutscene_id = &"ch09a_02_outro"`, `weather_type = "rain"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, `bridge_line_locked` / `bridge_line_partial` / `bridge_line_broken` state ids, and `next_destination_summary` for the oath review barracks intact.
   - CH09A_03 keeps `clear_cutscene_id = &"ch09a_03_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, `oath_hall_unread` / `oath_hall_partial` / `oath_hall_confirmed` state ids, and `next_destination_summary` for the abandoned officer quarters intact.
   - CH09 shell flow still reaches CH09A camp after CH09A_05 and preserves Kyle/카일 roster and presentation-card handoff.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH09A_01~CH09A_03 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch09a_01_stage.tres`, `data/stages/ch09a_02_stage.tres`, and `data/stages/ch09a_03_stage.tres` are delivered with the f55 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f55 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f55-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.
- Cutscene runner ObjectDB/resource leak warning at process exit
  - Non-blocking only when the cutscene runner exits 0 and no assertion failed.
  - Treat as a blocker if paired with nonzero exit, missing cutscene linkage, missing handoff state, or a new leak/error pattern tied to the f55 bark payload.

## Blocker checks and review risks

Treat any of these as blockers for f55 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - CH09A_01, CH09A_02, or CH09A_03 lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH08_05 and never loads `res://data/stages/ch09a_01_stage.tres`, `res://data/stages/ch09a_02_stage.tres`, and `res://data/stages/ch09a_03_stage.tres`.

2. Optional id mismatch
   - CH09A_01 uses `flag:ch09a_01_west_defense_tablet`, `flag:ch09a_01_east_signal_standard`, translated descriptions, decorative prop ids, terrain labels, landmark labels, objective state ids, or interactive object resource paths instead of `ch09a_01_west_defense_tablet` and `ch09a_01_east_signal_standard`.
   - CH09A_02 uses `flag:ch09a_02_bridge_banner_ledger`, `flag:ch09a_02_oath_pike_post`, translated descriptions, decorative prop ids, terrain labels, landmark labels, objective state ids, or interactive object resource paths instead of `ch09a_02_bridge_banner_ledger` and `ch09a_02_oath_pike_post`.
   - CH09A_03 uses `flag:ch09a_03_west_oath_roll`, `flag:ch09a_03_east_censor_mark`, translated descriptions, terrain labels, landmark labels, objective state ids, or interactive object resource paths instead of `ch09a_03_west_oath_roll` and `ch09a_03_east_censor_mark`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of optional objective ids.
   - Runner expected optional-id map is not updated to include exactly these f55 ids.

3. Queue cap/regression risk
   - Any f55 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff, interaction-objective, and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH09A_01~CH09A_03 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids, decorative prop ids, object resource paths, or backing `flag:` conditions, causing stage-resolution or interaction-victory regressions.
   - CH09A_01 bark authoring breaks the two-control outer-line progression, `outer_line_locked` / `outer_line_partial` / `outer_line_broken` state chain, or bridge-zone handoff.
   - CH09A_02 bark authoring breaks the two-control bridge progression, rain bridge-pressure setup, `bridge_line_locked` / `bridge_line_partial` / `bridge_line_broken` state chain, or oath-barracks handoff.
   - CH09A_03 bark authoring breaks the two-clue oath-hall progression, `oath_hall_unread` / `oath_hall_partial` / `oath_hall_confirmed` state chain, or abandoned-officer-route handoff.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f55 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f55 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document is created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented f55 snapshot:

- `data/stages/ch09a_01_stage.tres`, `data/stages/ch09a_02_stage.tres`, and `data/stages/ch09a_03_stage.tres` now each define four compact `post_battle_bark_rules`.
- Each stage covers the supported sections: `story`, `bonds`, and `telemetry`.
- Bark ids use lowercase stage prefixes and remain stage-local unique.
- Optional objective condition ids are exact:
  - CH09A_01: `ch09a_01_west_defense_tablet`, `ch09a_01_east_signal_standard`.
  - CH09A_02: `ch09a_02_bridge_banner_ledger`, `ch09a_02_oath_pike_post`.
  - CH09A_03: `ch09a_03_west_oath_roll`, `ch09a_03_east_censor_mark`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now covers CH09A_01~CH09A_03 in both the authored-stage load loop and expected optional-id map.
- The intended f55-owned authoring is text-only/non-image: post-battle bark rules plus runner/QA coverage. The current dirty stage-file diffs against HEAD also include broader CH09A terrain/decorative/objective metadata that was present in the workspace before this bark authoring slice; if packaging from this workspace, release ownership must either split those broader changes out or explicitly include them as non-f55/pre-existing stage work. f55 did not create image files and did not alter skill systems, EXP, support/name-call, reward, cutscene, shell-flow, Kyle presentation ownership, or stage-resolution code.

Recorded f55 gate results:

- PASS: `post_battle_bark_queue_runner.gd`.
- PASS: post-battle readability/handoff/result/treasure/stage-resolution/support regression chain.
- PASS: `ch09a_broken_standard_runner.gd`.
- PASS: `ch09_shell_runner.gd`.
- PASS: `ch06_ch10_cutscene_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch09a_01_stage.tres data/stages/ch09a_02_stage.tres data/stages/ch09a_03_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f55-ch09a-01-ch09a-03-post-battle-bark-release-qa.md`.

Observed non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared only inside isolated headless campaign/controller runner contexts with exit code 0.
- `ch06_ch10_cutscene_runner.gd` passed but emitted the known ObjectDB/resource leak warning pattern at exit.
- Gate0 still reports known workspace-only `res://` warnings from the broader dirty worktree, but exited PASS and did not identify an f55-owned missing reference.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...` remains expected and separate from bark authoring; public release remains blocked by signing custody.

Remaining delivery caution:

- Before commit/package, include f55 bark stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, its `.uid` if required by repository convention, and this QA note if review evidence docs are part of the payload.

## Recommended f55 packaging check

Before packaging or committing f55, include the complete f55 payload:

- `data/stages/ch09a_01_stage.tres`
- `data/stages/ch09a_02_stage.tres`
- `data/stages/ch09a_03_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f55 payload, with only the known warnings above allowed as non-blocking.
