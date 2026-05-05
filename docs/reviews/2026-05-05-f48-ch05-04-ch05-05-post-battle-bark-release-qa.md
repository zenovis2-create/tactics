# f48 CH05_04~CH05_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch05_04_stage.tres` and `data/stages/ch05_05_stage.tres`, with release validation separated into blockers versus known non-blocking warnings.

This note has been updated after f48 authoring landed. Re-check the Current QA findings section again if the f48 payload changes before packaging.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f48_focused_gates"
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

## Acceptance criteria for f48

Block release until all of these are true:

1. Actual CH05_04 and CH05_05 stage coverage
   - `data/stages/ch05_04_stage.tres` and `data/stages/ch05_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch05_04...`, `ch05_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text should keep a compact Farland-like aftermath/route-hook rhythm without copying Farland names, dialogue, UI, art, or scenario-specific names from Farland.
   - CH05_05 is chapter-end/final-hop adjacent, so bark lines must not steal ownership from the clear cutscene, next destination summary, or later chapter handoff.

2. Optional objective ids are exact
   - CH05_04 bark conditions may only reference:
     - `ch05_04_truth_shelf_index`
     - `ch05_04_zero_transfer_ledger`
   - CH05_05 bark conditions may only reference:
     - `defeat_boss_without_noah_dying`
     - `collect_3_ledger_entries`
   - No condition may use translated descriptions, decorative prop ids, interactive object labels, backing `flag:` strings, Korean text, or near-miss aliases.
   - CH05_04 optional ids currently mirror backing flag strings; review bark rules as optional-objective-id references, not as object/flag authoring shortcuts.
   - CH05_05 currently uses legacy-style optional ids without the `ch05_05_` prefix. These exact objective ids are allowed for conditions, while bark rule ids must still use the `ch05_05...` stage prefix.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, or final/ending ownership rules.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, and support name-call runners still pass.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH05_04~CH05_05 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index, not left workspace-only.
   - `data/stages/ch05_04_stage.tres` and `data/stages/ch05_05_stage.tres` are delivered with the f48 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f48 bark blocker unless it accompanies a failing exit code, missing handoff state, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f48-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.

## Blocker checks and review risks

Treat any of these as blockers for f48 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - `CH05_04` or `CH05_05` lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH05_03 and never loads `res://data/stages/ch05_04_stage.tres` / `res://data/stages/ch05_05_stage.tres`.

2. Optional id mismatch
   - CH05_04 uses decorative prop/object ids such as `ch05_truth_shelf_index_cabinet_blocker_01`, `ch05_zero_transfer_ledger_coffer_01`, or translated labels instead of `ch05_04_truth_shelf_index` and `ch05_04_zero_transfer_ledger`.
   - CH05_05 invents prefixed aliases such as `ch05_05_defeat_boss_without_noah_dying` or `ch05_05_collect_3_ledger_entries` instead of the existing objective ids `defeat_boss_without_noah_dying` and `collect_3_ledger_entries`.
   - Any bark condition includes `flag:` prefixes or Korean descriptions instead of objective ids.
   - Runner expected optional-id map is not updated to include exactly these f48 ids.

3. Queue cap/regression risk
   - Any f48 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff/chapter-boundary risk
   - CH05_05 bark authoring overrides or suppresses `clear_cutscene_id = &"ch05_05_outro"`.
   - CH05_05 bark authoring drops or rewrites `next_destination_summary` ownership for the move toward the next chapter.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only and is omitted from the f48 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f48 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document was created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch05_04_stage.tres` exposes optional objective ids:
  - `ch05_04_truth_shelf_index`
  - `ch05_04_zero_transfer_ledger`
- `data/stages/ch05_05_stage.tres` exposes optional objective ids:
  - `defeat_boss_without_noah_dying`
  - `collect_3_ledger_entries`
- CH05_04 now has 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
- CH05_05 now has 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now includes CH05_04~CH05_05 expected optional ids and actual stage coverage.
- Focused gate pack and Gate0 passed against the implemented f48 working-tree payload.
- Remaining risk is packaging/index inclusion, not working-tree runtime correctness.

## Recommended f48 packaging check

Before packaging or committing f48, include the complete f48 payload:

- `data/stages/ch05_04_stage.tres`
- `data/stages/ch05_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f48 payload, with only the known warnings above allowed as non-blocking.
