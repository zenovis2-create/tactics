# f46 CH04_04~CH04_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch04_04_stage.tres` and `data/stages/ch04_05_stage.tres`, with release validation separated into blockers versus known non-blocking warnings.

This note is a pre-implementation QA scout. Re-check and update the Current QA findings section after f46 authoring lands so the doc does not go stale.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f46_focused_gates"
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

## Acceptance criteria for f46

Block release until all of these are true:

1. Actual CH04_04 and CH04_05 stage coverage
   - `data/stages/ch04_04_stage.tres` and `data/stages/ch04_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch04_04...`, `ch04_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text should keep a compact Farland-like aftermath/route-hook rhythm without copying Farland names, dialogue, UI, or art.

2. Optional objective ids are exact
   - CH04_04 bark conditions may only reference:
     - `ch04_04_north_seal_read`
     - `ch04_04_south_seal_read`
   - CH04_05 bark conditions may only reference:
     - `ark_survives_flooded_section`
     - `collect_2_research_logs`
   - No condition may use legacy aliases, object ids, flag ids, translated labels, or near-miss strings.
   - In particular, CH04_04 conditions must use optional objective ids above, not backing object/flag ids `ch04_04_north_reliquary_seal` or `ch04_04_south_reliquary_seal`.
   - In particular, CH04_05 conditions must use optional objective ids above. The matching flag strings currently happen to mirror the ids, but bark rules should still be reviewed as objective-id references, not object/flag authoring shortcuts.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without stealing final-stage/ending ownership.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, and support name-call runners still pass.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH04_04~CH04_05 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index, not left workspace-only.
   - `data/stages/ch04_04_stage.tres` and `data/stages/ch04_05_stage.tres` are delivered with the f46 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f46 bark blocker unless it accompanies a failing exit code, missing handoff state, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f46-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.

## Blocker checks and review risks

Treat any of these as blockers for f46 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - `CH04_04` or `CH04_05` lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH04_03 and never loads `res://data/stages/ch04_04_stage.tres` / `res://data/stages/ch04_05_stage.tres`.

2. Optional id mismatch
   - CH04_04 uses object/flag ids (`ch04_04_north_reliquary_seal`, `ch04_04_south_reliquary_seal`) instead of objective ids (`ch04_04_north_seal_read`, `ch04_04_south_seal_read`).
   - CH04_05 uses translated text, labels, or ad hoc aliases instead of `ark_survives_flooded_section` and `collect_2_research_logs`.
   - Runner expected optional-id map is not updated to include exactly these f46 ids.

3. Queue cap/regression risk
   - Any f46 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only and is omitted from the f46 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f46 payload, not the whole dirty index.

5. Stale QA-doc risk
   - Because this document was created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented working-tree snapshot:

- `/opt/homebrew/bin/godot4 --version` -> `4.6.2.stable.official.71f334935`
- `data/stages/ch04_04_stage.tres` exposes optional objective ids:
  - `ch04_04_north_seal_read`
  - `ch04_04_south_seal_read`
- `data/stages/ch04_05_stage.tres` exposes optional objective ids:
  - `ark_survives_flooded_section`
  - `collect_2_research_logs`
- CH04_04 now has 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
- CH04_05 now has 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now includes CH04_04~CH04_05 expected optional ids and actual stage coverage.
- Focused gate pack and Gate0 passed against the implemented f46 working-tree payload.
- Remaining risk is packaging/index inclusion, not working-tree runtime correctness.

## Recommended f46 packaging check

Before packaging or committing f46, include the complete f46 payload:

- `data/stages/ch04_04_stage.tres`
- `data/stages/ch04_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f46 payload, with only the known warnings above allowed as non-blocking.
