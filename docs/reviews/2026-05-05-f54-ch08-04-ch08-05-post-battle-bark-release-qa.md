# f54 CH08_04~CH08_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch08_04_stage.tres` and `data/stages/ch08_05_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This note was updated after f54 authoring landed. Current QA findings below reflect the implemented CH08_04~CH08_05 bark payload, executed runner results, observed warnings, and final packaging caveats.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f54_focused_gates"
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

If any listed CH08 runner is deliberately out of scope for the final f54 payload, record the release-owner waiver and the reason. Otherwise treat a missing or failing listed runner as a blocker.

## Acceptance criteria for f54

Block release until all of these are true:

1. Actual CH08_04~CH08_05 stage coverage
   - `data/stages/ch08_04_stage.tres` and `data/stages/ch08_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch08_04...`, `ch08_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH08_04~CH08_05 are black-mark control / Lete final-hunt stages. Bark lines may reinforce west/east control-brand cleanup, signal-route opening, Lete defection pressure, black-hound casualty restraint, transfer-gate relief, and momentum toward Kyle's outer defense line, but must not replace clear cutscenes, recruitment/choice handling, or next-destination handoffs.

2. Optional objective ids are exact
   - CH08_04 bark conditions may only reference:
     - `ch08_04_west_control_brand`
     - `ch08_04_east_control_brand`
   - CH08_05 bark conditions may only reference:
     - `lete_defects_alive`
     - `no_black_hound_casualties`
   - No condition may use translated descriptions, decorative prop ids, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, rule-template ids, state ids, landmark labels, or near-miss aliases.
   - These stages define optional objectives whose backing `condition` fields use `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.
   - CH08_04 interactive object resource ids match its optional ids, but bark validation should still treat the optional objective table as the source of truth rather than decorative prop ids or labels.
   - CH08_05 is easy to mis-key because its optional ids are legacy-style generic ids (`lete_defects_alive`, `no_black_hound_casualties`) while the relief/runtime object is stage-prefixed (`ch08_05_transfer_gate_latch`) and rule-template flags include `lete_escape_route_cut` / `lete_hunt_collapsing`. Bark conditions must use the optional ids, not the relief object id, rule-template flags, or runtime state ids.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, choice continuity, recruitment/hidden-recruit ownership, or chapter-flow ownership.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, support name-call, and CH08 focused runners still pass.
   - CH08_04 keeps `clear_cutscene_id = &"ch08_04_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership, control-brand objective state ids, and `next_destination_summary` for Lete's signal stronghold intact.
   - CH08_05 keeps `choice_point_id = &"ch08_lete_defection"`, `clear_cutscene_id = &"ch08_05_outro"`, `turn_limit = 12`, `win_condition = &"defeat_all_enemies"`, `rule_template_id = &"lete_route_cut"`, transfer-gate latch relief modifiers, black-hound/defection optional ids, and `next_destination_summary` for Kyle's outer defense line intact.
   - CH08 shell flow remains CH08_01 through CH08_05 and still reaches the CH08 camp handoff.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH08_04~CH08_05 in both the authored-stage loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch08_04_stage.tres` and `data/stages/ch08_05_stage.tres` are delivered with the f54 payload.
   - `git diff --check` passes.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f54 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f54-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.

## Blocker checks and review risks

Treat any of these as blockers for f54 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - `CH08_04` or `CH08_05` lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH08_03 and never loads `res://data/stages/ch08_04_stage.tres` and `res://data/stages/ch08_05_stage.tres`.

2. Optional id mismatch
   - CH08_04 uses `flag:ch08_04_west_control_brand`, `flag:ch08_04_east_control_brand`, translated descriptions, decorative prop ids, landmark labels, objective state ids, or interactive object resource paths instead of `ch08_04_west_control_brand` and `ch08_04_east_control_brand`.
   - CH08_05 uses `flag:lete_defects_alive`, `flag:no_black_hound_casualties`, `ch08_05_transfer_gate_latch`, `lete_escape_route_cut`, `lete_hunt_collapsing`, `lete_route_cut_relief`, translated descriptions, decorative prop ids, landmark labels, rule-template ids, unit ids, or interactive object resource paths instead of `lete_defects_alive` and `no_black_hound_casualties`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of optional objective ids.
   - Runner expected optional-id map is not updated to include exactly these f54 ids.

3. Queue cap/regression risk
   - Any f54 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff, route-pressure, and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH08_04~CH08_05 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids, rule-template flags, or resource ids, causing stage-resolution, route-pressure, shell-flow, or treasure-ledger regressions.
   - CH08_04 bark authoring breaks the two-control-brand interaction progression, `black_mark_control_locked` / `black_mark_control_partial` / `black_mark_control_open` state chain, or signal-route handoff.
   - CH08_05 bark authoring breaks the Lete defection choice path, hidden-recruit/recruitment ownership, transfer-gate latch relief, black-hound casualty optional objective, `lete_route_cut` rule-template behavior, or 12-turn pressure.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f54 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f54 payload, not the whole dirty index.

6. Stale QA-doc risk
   - Because this document is created before implementation, update this section after authoring lands with actual runner results, observed warnings, and final payload list.

## Current QA findings

Implemented f54 snapshot:

- `data/stages/ch08_04_stage.tres` and `data/stages/ch08_05_stage.tres` now each define four compact `post_battle_bark_rules`.
- Each stage covers the supported sections: `story`, `bonds`, and `telemetry`.
- Bark ids use lowercase stage prefixes and remain stage-local unique.
- Optional objective condition ids are exact:
  - CH08_04: `ch08_04_west_control_brand`, `ch08_04_east_control_brand`.
  - CH08_05: `lete_defects_alive`, `no_black_hound_casualties`.
- CH08_05 did not use `ch08_05_transfer_gate_latch`, `lete_escape_route_cut`, `lete_hunt_collapsing`, `lete_route_cut_relief`, or `lete_early_alliance` as optional bark condition ids.
- `scripts/dev/post_battle_bark_queue_runner.gd` now covers CH08_04~CH08_05 in both the authored-stage load loop and expected optional-id map.
- The intended f54-owned authoring is text-only/non-image: post-battle bark rules plus runner/QA coverage. The current dirty stage-file diffs against HEAD also include broader CH08 terrain/decorative/optional-objective/choice metadata that predate or sit outside this bark slice in the workspace; if packaging from this workspace, release ownership must either split those broader changes out or explicitly include them as non-f54/pre-existing stage work. f54 did not create image files and did not alter skill systems, EXP, support/name-call, reward, cutscene, shell-flow, hidden-recruit ownership, or stage-resolution code.

Recorded f54 gate results:

- PASS: `post_battle_bark_queue_runner.gd`.
- PASS: post-battle readability/handoff/result/treasure/stage-resolution/support regression chain.
- PASS: `ch08_route_pressure_runner.gd`.
- PASS: `ch08_production_runner.gd`.
- PASS: `ch08_shell_runner.gd`.
- PASS: `ch08_split_line_preview_runner.gd`.
- PASS: `ch06_ch10_cutscene_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch08_04_stage.tres data/stages/ch08_05_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f54-ch08-04-ch08-05-post-battle-bark-release-qa.md`.

Observed non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared only inside isolated headless campaign/controller runner contexts with exit code 0.
- `ch06_ch10_cutscene_runner.gd` passed but emitted the known ObjectDB/resource leak warning pattern at exit.
- Gate0 still reports known workspace-only `res://` warnings from the broader dirty worktree, but exited PASS and did not identify an f54-owned missing reference.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...` remains expected and separate from bark authoring; public release remains blocked by signing custody.

Remaining delivery caution:

- Before commit/package, include f54 bark stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, its `.uid` if required by repository convention, and this QA note if review evidence docs are part of the payload.

## Recommended f54 packaging check

Before packaging or committing f54, include the complete f54 payload:

- `data/stages/ch08_04_stage.tres`
- `data/stages/ch08_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f54 payload, with only the known warnings above allowed as non-blocking.
