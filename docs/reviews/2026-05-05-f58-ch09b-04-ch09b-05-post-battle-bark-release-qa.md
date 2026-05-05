# f58 CH09B_04~CH09B_05 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch09b_04_stage.tres` and `data/stages/ch09b_05_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This is a release-QA scout note. It defines the gates f58 must satisfy before release-readiness is claimed. Current working-tree observations are listed separately from the acceptance gates so known warnings are not confused with blockers.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f58_focused_gates"
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
  scripts/dev/ch09b_revision_runner.gd \
  scripts/dev/ch09b_root_archive_preview_runner.gd \
  scripts/dev/ch09_shell_runner.gd \
  scripts/dev/ch06_ch10_cutscene_runner.gd \
  scripts/dev/three_star_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
done

git diff --check -- \
  data/stages/ch09b_04_stage.tres \
  data/stages/ch09b_05_stage.tres \
  scripts/dev/post_battle_bark_queue_runner.gd \
  docs/reviews/2026-05-05-f58-ch09b-04-ch09b-05-post-battle-bark-release-qa.md

bash scripts/dev/check_runnable_gate0.sh
```

A missing or failing focused post-battle runner, CH09B runner, `ch09_shell_runner.gd`, `ch06_ch10_cutscene_runner.gd`, `three_star_runner.gd`, `git diff --check`, or Gate0 is a blocker unless explicitly waived by the release owner. If `ch09b_root_archive_preview_runner.gd` is waived because f58 is text-only and visual preview validation is too broad/expensive for the bark slice, record the release-owner waiver and still run `ch09b_revision_runner.gd` plus `ch09_shell_runner.gd`.

## Acceptance criteria for f58

Block release until all of these are true:

1. Actual CH09B_04~CH09B_05 stage coverage
   - `data/stages/ch09b_04_stage.tres` and `data/stages/ch09b_05_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch09b_04...`, `ch09b_05...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH09B_04~CH09B_05 are Noah/CH09B end-route stages: rewritten battlefield and abyss-of-record/Melkion archive route. Bark lines may reinforce aftermath, battlefield rewrite pressure, revision-core collapse, red annotation cleanup, archive abyss pressure, Melkion truth, Noah survival, archive stabilization, no-casualty discipline, and final-tower route momentum, but must not replace clear cutscenes, objective text, campaign handoff, Noah roster/presentation ownership, Melkion/boss mechanics, or next-destination summaries.

2. Optional objective ids are exact
   - CH09B_04 bark conditions may only reference:
     - `ch09b_04_west_revision_core`
     - `ch09b_04_east_revision_core`
   - CH09B_04 also has interactive object `ch09b_04_center_red_annotation_pillar`, but it is not currently an optional objective id. Do not use it in `optional_completed` or `optional_failed` bark conditions unless the stage optional-objective data and all validators are intentionally migrated together.
   - CH09B_05 bark conditions may only reference:
     - `melkion_truth_revealed`
     - `noah_survives`
   - CH09B_05 has interactive object `ch09b_05_archive_lectern` and rule-template relief flags (`melkion_archive_stabilized`, `melkion_archive_destabilized`), but those are not optional objective ids. Do not use them in `optional_completed` or `optional_failed` bark conditions unless the stage optional-objective data and all validators are intentionally migrated together.
   - No condition may use translated descriptions, decorative prop ids, terrain/landmark labels, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, state ids, route labels, rule-template flags, or near-miss aliases.
   - CH09B_04~CH09B_05 optional objectives define backing `condition` fields with `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, chapter-flow ownership, Noah presentation/roster ownership, Melkion final-route ownership, or CH09B route handoff.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, support name-call, three-star, cutscene, CH09 shell, and CH09B focused runners still pass.
   - CH09B_04 keeps `start_cutscene_id = &"ch09b_04_intro"`, `clear_cutscene_id = &"ch09b_04_outro"`, `win_condition = &"resolve_all_interactions"`, three-object interaction ownership, optional objectives for west/east revision cores, `interaction_objective_state_ids` for revision-chain progression, and `next_destination_summary` for descending toward the deep archive intact.
   - CH09B_05 keeps `start_cutscene_id = &"ch09b_05_intro"`, `clear_cutscene_id = &"ch09b_05_outro"`, `win_condition = &"defeat_all_enemies"`, `turn_limit = 12`, optional objectives for Melkion truth and Noah survival, `rule_template_id = &"melkion_archive_relief"`, archive lectern relief modifiers, and `next_destination_summary` for moving from the abyss toward the final tower intact.
   - `ch09b_revision_runner.gd` still validates CH09B_04 revision-core interaction progression.
   - `ch09_shell_runner.gd` still reaches both CH09B_04 and CH09B_05 inside the CH09B campaign shell and preserves final CH09B camp handoff to the final tower with Noah roster/presentation ownership.
   - `ch09b_root_archive_preview_runner.gd` still loads the CH09B root-archive preview when included in the focused gate pack; bark text must not introduce new missing visual/resource dependencies.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH09B_04~CH09B_05 in both the authored-stage load loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch09b_04_stage.tres` and `data/stages/ch09b_05_stage.tres` are delivered with the f58 payload.
   - `git diff --check` passes against the f58-owned files.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f58 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f58-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.
- Cutscene runner ObjectDB/resource leak warning at process exit
  - Non-blocking only when the cutscene runner exits 0 and no assertion failed.
  - Treat as a blocker if paired with nonzero exit, missing cutscene linkage, missing handoff state, or a new leak/error pattern tied to the f58 bark payload.

## Blocker checks and review risks

Treat any of these as blockers for f58 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - CH09B_04 or CH09B_05 lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH09B_03 and never loads `res://data/stages/ch09b_04_stage.tres` and `res://data/stages/ch09b_05_stage.tres`.

2. Optional id mismatch
   - CH09B_04 uses `flag:ch09b_04_west_revision_core`, `flag:ch09b_04_east_revision_core`, `ch09b_04_center_red_annotation_pillar`, translated descriptions, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch09b_04_west_revision_core` and `ch09b_04_east_revision_core`.
   - CH09B_05 uses `flag:melkion_truth_revealed`, `flag:noah_survives`, `ch09b_05_archive_lectern`, `melkion_archive_stabilized`, `melkion_archive_destabilized`, translated descriptions, terrain labels, landmark labels, rule-template flag names, object resource paths, unit ids, or runtime condition syntax instead of `melkion_truth_revealed` and `noah_survives`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of optional objective ids.
   - Runner expected optional-id map is not updated to include exactly these f58 ids.

3. Queue cap/regression risk
   - Any f58 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff, boss/interaction, and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH09B_04~CH09B_05 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids, decorative prop ids, object resource paths, rule-template relief flags, or backing `flag:` conditions, causing stage-resolution, CH09 shell, or three-star regressions.
   - CH09B_04 bark authoring breaks three-object revision-core interaction ownership, center red annotation pillar requirement, or revision-chain state progression.
   - CH09B_05 bark authoring breaks Melkion boss/relief template ownership, archive lectern relief behavior, truth-revealed optional handling, Noah survival optional handling, turn-limit expectations, or final-tower transition.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f58 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - CH09B object/resources referenced by the f58-owned stage payload remain workspace-only or missing when Gate0/package validation runs.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f58 payload, not the whole dirty index.

6. QA-doc freshness risk
   - This document must remain aligned with the implemented working-tree payload. If f58 files change again, update `Current QA findings` with the new runner results, observed warnings, and payload list before claiming release-readiness.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch09b_04_stage.tres` and `data/stages/ch09b_05_stage.tres` now each define 4 compact `post_battle_bark_rules`.
- Each f58 stage covers the required result sections: `story`, `bonds`, and `telemetry`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now extends both the expected optional-id map and the authored-stage load loop through CH09B_04~CH09B_05.
- f58 bark conditions use only exact optional objective ids:
  - CH09B_04: `ch09b_04_west_revision_core`, `ch09b_04_east_revision_core`.
  - CH09B_05: `melkion_truth_revealed`, `noah_survives`.
- CH09B_04 `ch09b_04_center_red_annotation_pillar` remains a required interaction object only; f58 did not use it in `optional_completed` / `optional_failed` bark conditions.
- CH09B_05 `ch09b_05_archive_lectern`, `melkion_archive_stabilized`, and `melkion_archive_destabilized` remain runtime/rule-template concepts only; f58 did not use them in `optional_completed` / `optional_failed` bark conditions.
- f58 did not create or modify image assets, portraits, UI art, or visual resources. `ch09b_root_archive_preview_runner.gd` was run only as an existing CH09B regression/surface-loading gate.
- f58 preserves existing stronger systems: optional objective stars, bonus EXP/progression, memory fragment command unlock, support/name-call, treasure ledger, telemetry, cutscene IDs, `next_destination_summary`, Melkion archive relief template ownership, Noah survival optional handling, and `StageResolutionService` behavior.

Executed f58 gates from `/Volumes/AI/tactics` with `/opt/homebrew/bin/godot4`:

- PASS: `scripts/dev/post_battle_bark_queue_runner.gd`.
- PASS: `scripts/dev/post_battle_readability_runner.gd`.
- PASS: `scripts/dev/post_battle_handoff_runner.gd`.
- PASS: `scripts/dev/result_entry_tempo_runner.gd`.
- PASS: `scripts/dev/result_screen_readability_runner.gd`.
- PASS: `scripts/dev/treasure_ledger_runner.gd`.
- PASS: `scripts/dev/stage_resolution_runner.gd`.
- PASS: `scripts/dev/support_namecall_pipeline_runner.gd`.
- PASS: `scripts/dev/ch09b_revision_runner.gd`.
- PASS: `scripts/dev/ch09b_root_archive_preview_runner.gd`.
- PASS: `scripts/dev/ch09_shell_runner.gd`.
- PASS: `scripts/dev/ch06_ch10_cutscene_runner.gd`.
- PASS: `scripts/dev/three_star_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch09b_04_stage.tres data/stages/ch09b_05_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f58-ch09b-04-ch09b-05-post-battle-bark-release-qa.md` exited 0 for tracked diffs. Because `scripts/dev/post_battle_bark_queue_runner.gd` and this QA note are currently untracked, that Git command does not inspect their content until they are staged/tracked; run a separate local whitespace scan or stage them before package validation.

Observed known warnings, all non-blocking in this f58 run because the relevant commands exited 0:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` in isolated headless result/handoff/support runners.
- `ch06_ch10_cutscene_runner.gd` emitted ObjectDB/resource leak cleanup warnings after PASS.
- Gate0 reported existing workspace-only `res://` targets and Android `[SIGNING-DEFERRED][INTERNAL-QA] package/signed=false`; Gate0 still exited PASS and public release remains blocked by separate signing custody.

Remaining delivery caution:

- Working-tree implementation/QA is complete for f58 after the listed gates. Package/index readiness is still BLOCKED until the f58 payload is staged/included or explicitly waived by the release owner: CH09B_04~CH09B_05 stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, this QA note, and `scripts/dev/post_battle_bark_queue_runner.gd.uid` if repository convention requires it.
- The repository still has broader pre-existing dirty/untracked work. Treat only the listed f58 bark/runner/QA files as this slice's owned payload unless the release owner explicitly expands scope.

## Recommended f58 packaging check

Before packaging or committing f58, include the complete f58 payload:

- `data/stages/ch09b_04_stage.tres`
- `data/stages/ch09b_05_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f58 payload, with only the known warnings above allowed as non-blocking.
