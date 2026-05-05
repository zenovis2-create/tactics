# f45 CH04_01~CH04_03 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch04_01_stage.tres`, `data/stages/ch04_02_stage.tres`, and `data/stages/ch04_03_stage.tres`, with release validation separated into blockers versus known non-blocking warnings.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f45_focused_gates"
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

## Acceptance criteria for f45

Block release until all of these are true:

1. Actual CH04_01, CH04_02, and CH04_03 stage coverage
   - `data/stages/ch04_01_stage.tres`, `data/stages/ch04_02_stage.tres`, and `data/stages/ch04_03_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch04_01...`, `ch04_02...`, `ch04_03...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text should keep a compact Farland-like aftermath/route-hook rhythm without copying Farland names, dialogue, UI, or art.

2. Optional objective ids are exact
   - CH04_01 bark conditions may only reference:
     - `ch04_01_no_ally_casualties`
     - `ch04_01_scout_survives`
   - CH04_02 bark conditions may only reference:
     - `ch04_02_no_ally_casualties`
     - `ch04_02_vanguard_survives`
   - CH04_03 bark conditions may only reference:
     - `ch04_03_west_sluice_aligned`
     - `ch04_03_east_sluice_aligned`
   - No condition may use legacy aliases, object ids, flag ids, translated labels, or near-miss strings.
   - In particular, CH04_03 conditions must use optional objective ids above, not the flag/object ids `ch04_03_west_sluice_wheel` or `ch04_03_east_sluice_wheel`.

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
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH04_01~CH04_03 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index, not left workspace-only.
   - `data/stages/ch04_01_stage.tres`, `data/stages/ch04_02_stage.tres`, and `data/stages/ch04_03_stage.tres` are delivered with the f45 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Current QA findings

Verified PASS locally against the current working tree:

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
  - Current Gate0 still exits PASS, but any f45-critical runner/stage/resource left untracked should be treated as a delivery blocker.

Current f45 verification state:

1. CH04_01~CH04_03 bark authoring is now covered in the current working tree.
   - `ch04_01_stage.tres`: 4 `post_battle_bark_rules` covering story, bonds, and telemetry.
   - `ch04_02_stage.tres`: 4 `post_battle_bark_rules` covering story, bonds, and telemetry.
   - `ch04_03_stage.tres`: 4 `post_battle_bark_rules` covering story, bonds, and telemetry.

2. Runner coverage now includes CH04_01~CH04_03.
   - `post_battle_bark_queue_runner.gd` includes expected optional ids for CH04_01, CH04_02, and CH04_03.
   - It loads `res://data/stages/ch04_01_stage.tres`, `res://data/stages/ch04_02_stage.tres`, and `res://data/stages/ch04_03_stage.tres` in `_assert_authored_stage_bark_rules()`.
   - It preserves checks for required sections, unsupported sections, stage-prefix ids, non-empty speaker/text, exact optional ids, queue max 4, and idempotency.

3. Optional id mismatch risk was resolved by using objective ids, not backing object/flag ids.
   - CH04_01 uses `ch04_01_no_ally_casualties` and `ch04_01_scout_survives`.
   - CH04_02 uses `ch04_02_no_ally_casualties` and `ch04_02_vanguard_survives`.
   - CH04_03 uses `ch04_03_west_sluice_aligned` and `ch04_03_east_sluice_aligned`, not `ch04_03_west_sluice_wheel` / `ch04_03_east_sluice_wheel`.

4. Delivery/index risk remains open.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `.uid` are currently untracked in this workspace.
   - `data/stages/ch04_01_stage.tres`, `data/stages/ch04_02_stage.tres`, and `data/stages/ch04_03_stage.tres` are dirty in the working tree.
   - The repository has many unrelated staged/dirty files; release reproducibility should be judged from the intended f45 payload, not the whole dirty index.

## Recommended f45 packaging check

Before packaging or committing f45, include the complete f45 payload:

- `data/stages/ch04_01_stage.tres`
- `data/stages/ch04_02_stage.tres`
- `data/stages/ch04_03_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 passed against the working-tree f45 payload.
