# f44 CH03_04~CH03_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch03_04_stage.tres` and `data/stages/ch03_05_stage.tres`, with validation separated into blockers versus known non-blocking warnings.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f44_focused_gates"
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

## Acceptance criteria for f44

Block release until all of these are true:

1. Actual CH03_04 and CH03_05 stage coverage
   - `data/stages/ch03_04_stage.tres` and `data/stages/ch03_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch03_04...`, `ch03_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.

2. Optional objective ids are exact
   - CH03_04 bark conditions may only reference:
     - `ch03_04_west_resin_shrine_read`
     - `ch03_04_east_ember_device_tuned`
   - CH03_05 bark conditions may only reference:
     - `tia_defeats_enemy_boss`
     - `no_structures_destroyed`
   - No condition may use legacy aliases, object ids, flag ids, translated labels, or near-miss strings.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, `telemetry` sections.
   - Campaign handoff includes compact bark lines without stealing final-stage/ending ownership.
   - Readability, result tempo, treasure ledger, stage resolution, and support name-call runners still pass.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index, not left workspace-only.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Current QA findings

Verified PASS locally:

- `/opt/homebrew/bin/godot4 --version` -> `4.6.2.stable.official.71f334935`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_readability_runner.gd`
- `scripts/dev/post_battle_handoff_runner.gd`
- `scripts/dev/result_screen_readability_runner.gd`
- `scripts/dev/result_entry_tempo_runner.gd`
- `scripts/dev/treasure_ledger_runner.gd`
- `scripts/dev/stage_resolution_runner.gd`
- `scripts/dev/support_namecall_pipeline_runner.gd`
- `git diff --check`
- `bash scripts/dev/check_runnable_gate0.sh`

Known non-blocking warnings observed:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners.
  - Treat as warning only when the runner exits 0 and the test intentionally constructs `CampaignController` without Main-owned SaveService.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 still exits PASS, but any f44-critical runner/stage/resource left untracked should be treated as a delivery blocker.

Current f44 verification state:

1. CH03_04 and CH03_05 now have authored `post_battle_bark_rules`.
   - `ch03_04_stage.tres` carries 4 rules covering story, bonds, and telemetry.
   - `ch03_05_stage.tres` carries 4 rules covering story, bonds, and telemetry.
   - The rules keep the Farland-like rhythm to compact aftermath/route-hook barks without copying original UI, art, names, or dialogue.

2. Runner coverage now includes CH03_04 and CH03_05.
   - `post_battle_bark_queue_runner.gd` includes expected optional ids for both stages.
   - The authored-stage loop includes `res://data/stages/ch03_04_stage.tres` and `res://data/stages/ch03_05_stage.tres`.
   - The runner still enforces required sections, unsupported-section rejection, stage-prefix ids, non-empty speaker/text, exact optional id checks, max-4 queue cap, and idempotency.

3. Optional id mismatch risk was resolved by using objective ids, not object/flag ids.
   - CH03_04 conditions reference `ch03_04_west_resin_shrine_read` and `ch03_04_east_ember_device_tuned`.
   - CH03_05 conditions reference `tia_defeats_enemy_boss` and `no_structures_destroyed`.

4. Remaining delivery/index risk.
   - `post_battle_bark_queue_runner.gd` and its `.uid` are still untracked unless explicitly included by the operator.
   - The repo has unrelated staged/dirty files; release reproducibility should be judged from the intended f44 payload, not the whole dirty index.

## Recommended f44 blocker check update

Before packaging or committing f44, include the complete f44 payload:

- `data/stages/ch03_04_stage.tres`
- `data/stages/ch03_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 passed against the working-tree payload.
