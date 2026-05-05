# f51 CH07_01~CH07_03 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch07_01_stage.tres`, `data/stages/ch07_02_stage.tres`, and `data/stages/ch07_03_stage.tres`, with release validation separated into blockers versus known non-blocking warnings.

This note was updated after f51 authoring landed. The Current QA findings section records the implemented payload, focused runner results, observed warnings, and remaining packaging cautions.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f51_focused_gates"
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
  scripts/dev/ch07_procession_control_runner.gd \
  scripts/dev/ch07_shell_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
 done

git diff --check
bash scripts/dev/check_runnable_gate0.sh
```

## Acceptance criteria for f51

Block release until all of these are true:

1. Actual CH07_01~CH07_03 stage coverage
   - `data/stages/ch07_01_stage.tres`, `data/stages/ch07_02_stage.tres`, and `data/stages/ch07_03_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch07_01...`, `ch07_02...`, `ch07_03...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath/route-hook rhythm without copying Farland names, dialogue, UI, art, map names, or scenario-specific nouns from Farland.
   - CH07_01~CH07_03 are blank-market / silent-square / nameless-procession route stages. Bark lines may reinforce aftermath, route restoration, queue/procession pressure, witness/record evidence, and momentum toward the shrine/cathedral path, but must not replace clear cutscenes or next-destination handoffs.

2. Optional objective ids are exact
   - CH07_01 bark conditions may only reference:
     - `ch07_01_market_route_board`
     - `ch07_01_queue_bell`
   - CH07_02 bark conditions may only reference:
     - `ch07_02_silence_plaque`
     - `ch07_02_queue_release_post`
   - CH07_03 bark conditions may only reference:
     - `ch07_03_procession_roll`
     - `ch07_03_witness_mark`
   - No condition may use translated descriptions, decorative prop ids, interactive object resource paths, backing `flag:` strings, Korean text, or near-miss aliases.
   - These stages currently define optional objectives whose backing `condition` fields use `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, or chapter-flow ownership.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, and support name-call runners still pass.
   - CH07_01 keeps `clear_cutscene_id = &"ch07_01_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, and `next_destination_summary` for the silent-square advance intact.
   - CH07_02 keeps `clear_cutscene_id = &"ch07_02_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, and `next_destination_summary` for the shrine-entry pursuit intact.
   - CH07_03 keeps `clear_cutscene_id = &"ch07_03_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, and `next_destination_summary` for the cathedral-forecourt advance intact.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH07_01~CH07_03 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch07_01_stage.tres`, `data/stages/ch07_02_stage.tres`, and `data/stages/ch07_03_stage.tres` are delivered with the f51 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f51 bark blocker unless it accompanies a failing exit code, missing handoff state, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f51-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.

## Blocker checks and review risks

Treat any of these as blockers for f51 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - `CH07_01`, `CH07_02`, or `CH07_03` lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH06_05 and never loads `res://data/stages/ch07_01_stage.tres`, `res://data/stages/ch07_02_stage.tres`, and `res://data/stages/ch07_03_stage.tres`.

2. Optional id mismatch
   - CH07_01 uses `flag:ch07_01_market_route_board`, `flag:ch07_01_queue_bell`, translated descriptions, decorative prop ids, interactive object resource paths, or other aliases instead of `ch07_01_market_route_board` and `ch07_01_queue_bell`.
   - CH07_02 uses `flag:ch07_02_silence_plaque`, `flag:ch07_02_queue_release_post`, translated descriptions, decorative prop ids, interactive object resource paths, or other aliases instead of `ch07_02_silence_plaque` and `ch07_02_queue_release_post`.
   - CH07_03 uses `flag:ch07_03_procession_roll`, `flag:ch07_03_witness_mark`, translated descriptions, decorative prop ids, interactive object resource paths, or other aliases instead of `ch07_03_procession_roll` and `ch07_03_witness_mark`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of objective ids.
   - Runner expected optional-id map is not updated to include exactly these f51 ids.

3. Queue cap/regression risk
   - Any f51 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH07_01~CH07_03 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with the interaction-object runtime state ids (`market_route_*`, `silence_square_*`, `procession_route_*`), causing stage-resolution or treasure-ledger regressions.
   - Bark authoring treats decorative market/procession props as optional objectives, causing delivery/index or runtime-resource validation noise outside the f51 bark lane.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f51 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f51 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document was created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch07_01_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `ch07_01_market_route_board`, `ch07_01_queue_bell`.
- `data/stages/ch07_02_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `ch07_02_silence_plaque`, `ch07_02_queue_release_post`.
- `data/stages/ch07_03_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `ch07_03_procession_roll`, `ch07_03_witness_mark`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now includes CH07_01~CH07_03 in both the expected optional-id map and authored-stage load loop.

Recorded f51 gate results:

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
- PASS: CH07 focused adjacent gates:
  - `ch07_procession_control_runner.gd`
  - `ch07_shell_runner.gd`
- PASS: `bash scripts/dev/check_runnable_gate0.sh`
  - Output included `Runnable Gate 0 integrity check passed`.
- PASS: `git diff --check -- data/stages/ch07_01_stage.tres data/stages/ch07_02_stage.tres data/stages/ch07_03_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f51-ch07-01-ch07-03-post-battle-bark-release-qa.md`

Observed non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared in isolated headless runners that still exited 0.
- Gate0 reported workspace-only `res://` warnings and Android `[SIGNING-DEFERRED][INTERNAL-QA]` warning, but exited 0.

Scope clarification:

- The f51 bark delta added only `post_battle_bark_rules` to CH07_01~CH07_03 and CH07_01~CH07_03 coverage to `post_battle_bark_queue_runner.gd`.
- CH07_01 `decorative_props` PNG references existed in the inspected stage file before the f51 bark authoring patch in this session. They are not image-generation or asset-authoring changes from this f51 non-image bark slice.
- If a later commit/package includes the whole dirty stage file, review pre-existing decorative prop/resource ownership under the art/packaging lane, not as f51 bark implementation ownership.

Remaining delivery caution:

- This is a working-tree completion. Before commit/package, include f51 bark stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, its `.uid` if required by repository convention, and this QA note if review evidence docs are part of the payload.
- Because the repo is already dirty, package owners must separately decide whether pre-existing CH07 decorative prop assets are part of the same delivery bundle.

## Recommended f51 packaging check

Before packaging or committing f51, include the complete f51 payload:

- `data/stages/ch07_01_stage.tres`
- `data/stages/ch07_02_stage.tres`
- `data/stages/ch07_03_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f51 payload, with only the known warnings above allowed as non-blocking.
