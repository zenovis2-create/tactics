# f50 CH06_04~CH06_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch06_04_stage.tres` and `data/stages/ch06_05_stage.tres`, with release validation separated into blockers versus known non-blocking warnings.

This note was updated after f50 authoring landed. The Current QA findings section records the implemented payload, focused runner results, observed warnings, and remaining packaging cautions.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f50_focused_gates"
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

## Acceptance criteria for f50

Block release until all of these are true:

1. Actual CH06_04 and CH06_05 stage coverage
   - `data/stages/ch06_04_stage.tres` and `data/stages/ch06_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch06_04...`, `ch06_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath/route-hook rhythm without copying Farland names, dialogue, UI, art, or scenario-specific names from Farland.
   - CH06_04~CH06_05 are oath-hall/final-keep stages, so bark lines may reinforce aftermath, survival, pressure, oath/record evidence, and route momentum, but must not replace clear cutscenes or next-destination handoffs.

2. Optional objective ids are exact
   - CH06_04 bark conditions may only reference:
     - `ch06_04_west_archive_case`
     - `ch06_04_ceremonial_seal`
   - CH06_05 bark conditions may only reference:
     - `valtor_civilian_escapes`
     - `fort_resistance_zero`
   - No condition may use translated descriptions, decorative prop ids, interactive object resource ids, backing `flag:` strings, Korean text, or near-miss aliases.
   - CH06_04 optional objective definitions currently use backing `condition = "flag:..."` strings. Bark rules must reference the optional objective `id` values above, not `flag:` condition strings.
   - CH06_04 has three interactive objects, including `ch06_04_east_archive_case`, but only the two current optional objective ids listed above are allowed for bark conditions unless the stage optional objective schema itself changes and the runner expected-id map is updated in the same payload.
   - CH06_05 uses legacy-style optional ids without the `ch06_05_` prefix. Bark conditions must use the actual current ids above unless the stage optional objective ids are intentionally migrated and every dependent validation surface is updated in the same payload.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, or chapter-flow ownership.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, and support name-call runners still pass.
   - CH06_04 keeps `clear_cutscene_id = &"ch06_04_outro"`, `rule_template_id = &"oath_hall_records"`, `rule_template_modifiers.template_family = "interaction_trio"`, the interaction trio ownership, and `next_destination_summary` for the internal ramp intact.
   - CH06_05 keeps `clear_cutscene_id = &"ch06_05_outro"`, `win_condition = &"resolve_all_interactions_and_defeat_all_enemies"`, `turn_limit = 12`, the keep-dais/barricade interaction ownership, and `next_destination_summary` for the purification-site advance intact.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH06_04~CH06_05 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch06_04_stage.tres` and `data/stages/ch06_05_stage.tres` are delivered with the f50 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f50 bark blocker unless it accompanies a failing exit code, missing handoff state, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f50-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.

## Blocker checks and review risks

Treat any of these as blockers for f50 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - `CH06_04` or `CH06_05` lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH06_03 and never loads `res://data/stages/ch06_04_stage.tres` and `res://data/stages/ch06_05_stage.tres`.

2. Optional id mismatch
   - CH06_04 uses `flag:ch06_04_west_archive_case`, `flag:ch06_04_ceremonial_seal`, `ch06_04_east_archive_case`, decorative prop ids, interactive object resource ids, or Korean descriptions instead of `ch06_04_west_archive_case` and `ch06_04_ceremonial_seal`.
   - CH06_05 uses `flag:valtor_civilian_escapes`, `flag:fort_resistance_zero`, invented `ch06_05_*` aliases, decorative prop ids, or Korean descriptions instead of `valtor_civilian_escapes` and `fort_resistance_zero`.
   - Any bark condition includes `flag:` prefixes or translated descriptions instead of objective ids.
   - Runner expected optional-id map is not updated to include exactly these f50 ids.

3. Queue cap/regression risk
   - Any f50 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH06_04~CH06_05 `clear_cutscene_id` values or `next_destination_summary` text.
   - CH06_04 bark authoring confuses optional objective ids with the `oath_hall_records` interaction-trio runtime state or the third east-archive object, causing stage-resolution or treasure-ledger regressions.
   - CH06_05 bark authoring confuses the keep-dais/barricade interaction state with optional objective ids, causing result or stage-resolution regressions.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f50 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f50 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document was created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch06_04_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `ch06_04_west_archive_case`, `ch06_04_ceremonial_seal`.
  - `ch06_04_east_archive_case` remains an interaction-trio object only, not an optional bark condition.
- `data/stages/ch06_05_stage.tres` now defines 4 `post_battle_bark_rules` covering `story`, `bonds`, and `telemetry`.
  - Optional objective ids used: `valtor_civilian_escapes`, `fort_resistance_zero`.
  - Keep-dais/barricade runtime flags remain stage-clear context only, not optional bark conditions.
- `scripts/dev/post_battle_bark_queue_runner.gd` now includes CH06_04~CH06_05 in both the expected optional-id map and authored-stage load loop.

Recorded f50 gate results:

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
- PASS: `git diff --check -- data/stages/ch06_04_stage.tres data/stages/ch06_05_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f50-ch06-04-ch06-05-post-battle-bark-release-qa.md`

Observed non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared in isolated headless runners that still exited 0.
- Gate0 reported workspace-only `res://` warnings and Android `[SIGNING-DEFERRED][INTERNAL-QA]` warning, but exited 0.

Scope clarification:

- The f50 bark delta added only `post_battle_bark_rules` to CH06_04~CH06_05 and CH06_04~CH06_05 coverage to `post_battle_bark_queue_runner.gd`.
- CH06_04~CH06_05 `decorative_props` PNG references, interaction objective text/state-id edits, and related prop assets existed in the inspected stage files before the f50 bark authoring patch in this session. They are not image-generation or asset-authoring changes from this f50 non-image bark slice.
- If a later commit/package includes the whole dirty stage files, review those pre-existing decorative prop/resource changes under the art/packaging lane, not as f50 bark implementation ownership.

Remaining delivery caution:

- This is a working-tree completion. Before commit/package, include f50 bark stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, its `.uid` if required by repository convention, and this QA note if review evidence docs are part of the payload.
- Because the repo is already dirty, package owners must separately decide whether pre-existing CH06_04~CH06_05 decorative prop assets and decorative prop validation runners are part of the same delivery bundle.

## Recommended f50 packaging check

Before packaging or committing f50, include the complete f50 payload:

- `data/stages/ch06_04_stage.tres`
- `data/stages/ch06_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f50 payload, with only the known warnings above allowed as non-blocking.
