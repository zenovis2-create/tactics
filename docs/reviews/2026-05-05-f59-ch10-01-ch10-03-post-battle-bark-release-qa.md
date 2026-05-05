# f59 CH10_01~CH10_03 post-battle bark authoring release QA scout

Scope: Farland-style post-battle bark authoring for `data/stages/ch10_01_stage.tres`, `data/stages/ch10_02_stage.tres`, and `data/stages/ch10_03_stage.tres`, with validation gates and release risks separated into blockers versus known non-blocking warnings.

This is a release-QA scout note. It defines the gates f59 must satisfy before release-readiness is claimed. Current working-tree observations are listed separately from the acceptance gates so known warnings are not confused with blockers.

## Focused validation gates

Run from `/Volumes/AI/tactics` with Godot `/opt/homebrew/bin/godot4`.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f59_focused_gates"
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
  scripts/dev/ch10_tower_chain_runner.gd \
  scripts/dev/ch10_shell_runner.gd \
  scripts/dev/ch06_ch10_cutscene_runner.gd \
  scripts/dev/three_star_runner.gd
 do
  /opt/homebrew/bin/godot4 --headless --path . --script "res://$script" || exit $?
done

git diff --check -- \
  data/stages/ch10_01_stage.tres \
  data/stages/ch10_02_stage.tres \
  data/stages/ch10_03_stage.tres \
  scripts/dev/post_battle_bark_queue_runner.gd \
  docs/reviews/2026-05-05-f59-ch10-01-ch10-03-post-battle-bark-release-qa.md

bash scripts/dev/check_runnable_gate0.sh
```

A missing or failing focused post-battle runner, CH10 runner, `ch10_shell_runner.gd`, `ch06_ch10_cutscene_runner.gd`, `three_star_runner.gd`, `git diff --check`, or Gate0 is a blocker unless explicitly waived by the release owner. `ch10_tower_chain_runner.gd` is the focused CH10_01~CH10_03 stage-chain runner and should not be waived for this slice unless the release owner provides a written waiver and an equivalent stage-chain validation record.

## Acceptance criteria for f59

Block release until all of these are true:

1. Actual CH10_01~CH10_03 stage coverage
   - `data/stages/ch10_01_stage.tres`, `data/stages/ch10_02_stage.tres`, and `data/stages/ch10_03_stage.tres` each define `post_battle_bark_rules`.
   - Each stage has at least one bark in each supported result section: `story`, `bonds`, and `telemetry`.
   - Bark `id` values start with the lowercase stage prefix (`ch10_01...`, `ch10_02...`, `ch10_03...`) and are unique within the stage.
   - Every bark has non-empty `speaker` and `text`.
   - Bark text keeps a compact Farland-like aftermath / route-hook rhythm without copying Farland names, dialogue, UI, art, map names, character names, or scenario-specific nouns from Farland.
   - CH10_01~CH10_03 are final-tower ascent stages: eclipse eve / first lift, resonance tower crest / outer ring collapse, and nameless corridor / king's hall route. Bark lines may reinforce aftermath, ascent pressure, tower controls, corridor stabilization, no-casualty discipline, optional-objective discipline, and route momentum toward CH10_04/CH10_05, but must not replace clear cutscenes, objective text, campaign handoff, CH10 ending ownership, final-boss mechanics, or next-destination summaries.

2. Optional objective ids are exact
   - CH10_01 bark conditions may only reference:
     - `ch10_01_west_eclipse_tablet`
     - `ch10_01_east_lift_latch`
   - CH10_02 bark conditions may only reference:
     - `ch10_02_west_crest_control`
     - `ch10_02_east_crest_control`
   - CH10_03 bark conditions may only reference:
     - `ch10_03_west_corridor_anchor`
     - `ch10_03_east_corridor_anchor`
   - No condition may use translated descriptions, decorative prop ids, terrain/landmark labels, interactive object resource paths, backing `flag:` strings, Korean text, unit ids, state ids, route labels, or near-miss aliases.
   - CH10_01~CH10_03 optional objectives define backing `condition` fields with `flag:...` strings. Bark rules must reference the optional objective `id` values above, not the `flag:` condition strings.

3. Queue behavior remains bounded and deterministic
   - Result metadata includes `post_battle_bark_queue` and `post_battle_bark_count`.
   - Matching barks cap at max 4 entries.
   - Empty/unmatched barks are excluded.
   - Re-running terminal result handling does not mutate the already-built bark queue.

4. Result, handoff, and adjacent post-battle surfaces stay compatible
   - Result screen renders bark lines inside existing `story`, `bonds`, and `telemetry` sections.
   - Campaign handoff includes compact bark lines without bypassing clear cutscenes, next destination text, chapter-flow ownership, CH10 tower-chain ownership, CH10 ending ownership, or final route handoff.
   - Readability, handoff, result tempo, treasure ledger, stage resolution, support name-call, three-star, cutscene, CH10 shell, and CH10 focused runners still pass.
   - CH10_01 keeps `start_cutscene_id = &"ch10_01_intro"`, `clear_cutscene_id = &"ch10_01_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership for the west eclipse tablet and east lift latch, `interaction_objective_state_ids` for `tower_ascent_locked` / `tower_ascent_partial` / `tower_ascent_open`, and `next_destination_summary` for the outer lift / first resonance tower intact.
   - CH10_02 keeps `start_cutscene_id = &"ch10_02_intro"`, `clear_cutscene_id = &"ch10_02_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership for the west and east crest controls, `weather_type = "night"`, `interaction_objective_state_ids` for `tower_crest_locked` / `tower_crest_partial` / `tower_crest_broken`, and `next_destination_summary` for entering the nameless corridor intact.
   - CH10_03 keeps `start_cutscene_id = &"ch10_03_intro"`, `clear_cutscene_id = &"ch10_03_outro"`, `win_condition = &"resolve_all_interactions"`, two-object interaction ownership for the west and east corridor anchors, `interaction_objective_state_ids` for `corridor_locked` / `corridor_partial` / `corridor_open`, and `next_destination_summary` for entering the king's hall intact.
   - `ch10_tower_chain_runner.gd` still validates CH10_01 ascent, CH10_02 crest, and CH10_03 corridor objective chains.
   - `ch10_shell_runner.gd` still reaches CH10 intro, CH10_01~CH10_05 flow, final resolution, postgame title return, and NG+ unlock. Bark text must not introduce new missing visual/resource dependencies or alter final ending ownership.

5. Delivery/index integrity
   - `scripts/dev/post_battle_bark_queue_runner.gd` covers CH10_01~CH10_03 in both the authored-stage load loop and expected optional-id map.
   - `scripts/dev/post_battle_bark_queue_runner.gd` and `scripts/dev/post_battle_bark_queue_runner.gd.uid` are delivered in the changelist/index when changed or newly required by repository convention, not left workspace-only.
   - `data/stages/ch10_01_stage.tres`, `data/stages/ch10_02_stage.tres`, and `data/stages/ch10_03_stage.tres` are delivered with the f59 payload.
   - `git diff --check` passes against the f59-owned files.
   - Gate0 passes after any new stage/resource references are staged or otherwise made part of the release payload.

## Known non-blocking warnings

These are warnings only when the relevant runner exits 0 and the context matches the note below:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.`
  - Seen in isolated headless campaign/controller runners that intentionally construct `CampaignController` without a Main-owned SaveService.
  - Do not classify this as an f59 bark blocker unless it accompanies a failing exit code, missing handoff state, missing save-owned runtime path, or save/handoff regression in an owned runtime path.
- `[SIGNING-DEFERRED][INTERNAL-QA] Android package/signed=false...`
  - Gate0 may pass for internal QA.
  - Public release remains blocked by separate operator-owned signing custody/preflight, but this is not a bark-authoring blocker.
- Gate0 workspace-only `res://` warning list
  - Current Gate0 can still exit PASS with known workspace-only warnings.
  - Any f59-critical runner/stage/resource left untracked is not covered by this warning carve-out and should be treated as a delivery blocker.
- Cutscene runner ObjectDB/resource leak warning at process exit
  - Non-blocking only when the cutscene runner exits 0 and no assertion failed.
  - Treat as a blocker if paired with nonzero exit, missing cutscene linkage, missing handoff state, or a new leak/error pattern tied to the f59 bark payload.

## Blocker checks and review risks

Treat any of these as blockers for f59 until fixed or explicitly waived by the release owner:

1. Missing actual stage coverage
   - CH10_01, CH10_02, or CH10_03 lacks `post_battle_bark_rules`.
   - A stage has fewer than the required `story`, `bonds`, and `telemetry` coverage.
   - The runner still stops at CH09B_05 and never loads `res://data/stages/ch10_01_stage.tres`, `res://data/stages/ch10_02_stage.tres`, and `res://data/stages/ch10_03_stage.tres`.

2. Optional id mismatch
   - CH10_01 uses `flag:ch10_01_west_eclipse_tablet`, `flag:ch10_01_east_lift_latch`, translated descriptions, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch10_01_west_eclipse_tablet` and `ch10_01_east_lift_latch`.
   - CH10_02 uses `flag:ch10_02_west_crest_control`, `flag:ch10_02_east_crest_control`, translated descriptions, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch10_02_west_crest_control` and `ch10_02_east_crest_control`.
   - CH10_03 uses `flag:ch10_03_west_corridor_anchor`, `flag:ch10_03_east_corridor_anchor`, translated descriptions, terrain labels, landmark labels, objective state ids, object resource paths, or runtime condition syntax instead of `ch10_03_west_corridor_anchor` and `ch10_03_east_corridor_anchor`.
   - Any bark condition includes `flag:` prefixes or Korean objective descriptions instead of optional objective ids.
   - Runner expected optional-id map is not updated to include exactly these f59 ids.

3. Queue cap/regression risk
   - Any f59 change weakens the existing max-4 queue cap.
   - Empty text/speaker barks leak into `post_battle_bark_queue`.
   - Repeated battle-end/result processing mutates the queue or count.

4. Handoff, interaction-objective, and stage-resolution risk
   - Bark authoring overrides, suppresses, or rewrites CH10_01~CH10_03 `clear_cutscene_id` values or `next_destination_summary` text.
   - Bark authoring confuses optional objective ids with interaction-object runtime state ids, decorative prop ids, object resource paths, terrain labels, landmark labels, or backing `flag:` conditions, causing stage-resolution, CH10 tower-chain, CH10 shell, or three-star regressions.
   - CH10_01 bark authoring breaks eclipse tablet / lift latch two-object interaction ownership or the transition into the first resonance tower.
   - CH10_02 bark authoring breaks crest-control two-object interaction ownership, night presentation, outer-ring collapse state progression, or the handoff into the nameless corridor.
   - CH10_03 bark authoring breaks corridor-anchor two-object interaction ownership, central corridor route pressure, corridor-open state progression, or the king's hall transition.
   - Bark lines are authored as long story paragraphs instead of compact aftermath/route-hook barks, causing result/handoff readability regressions.
   - Bark lines imply final ending, final bell, NG+, Karon/Karuon boss resolution, or CH10_04/CH10_05 ownership before those later stages own it.

5. Delivery risk
   - `scripts/dev/post_battle_bark_queue_runner.gd` or its `.uid` remains untracked/workspace-only when required and is omitted from the f59 payload.
   - Stage `.tres` changes are present locally but not included in the intended changelist.
   - CH10 object/resources referenced by the f59-owned stage payload remain workspace-only or missing when Gate0/package validation runs.
   - The repo has unrelated staged/dirty files; judge reproducibility from the intended f59 payload, not the whole dirty index.

6. QA-doc freshness risk
   - This document must remain aligned with the implemented working-tree payload. If f59 files change again, update `Current QA findings` with the new runner results, observed warnings, and payload list before claiming release-readiness.

## Current QA findings

Implemented working-tree snapshot:

- `data/stages/ch10_01_stage.tres`, `data/stages/ch10_02_stage.tres`, and `data/stages/ch10_03_stage.tres` now each define 4 compact `post_battle_bark_rules`.
- Each f59 stage covers the required result sections: `story`, `bonds`, and `telemetry`.
- `scripts/dev/post_battle_bark_queue_runner.gd` now extends both the expected optional-id map and the authored-stage load loop through CH10_01~CH10_03.
- f59 bark conditions use only exact optional objective ids:
  - CH10_01: `ch10_01_west_eclipse_tablet`, `ch10_01_east_lift_latch`.
  - CH10_02: `ch10_02_west_crest_control`, `ch10_02_east_crest_control`.
  - CH10_03: `ch10_03_west_corridor_anchor`, `ch10_03_east_corridor_anchor`.
- f59 did not create or modify image assets, portraits, UI art, or visual resources.
- f59 preserves existing stronger systems: optional objective stars, bonus EXP/progression, memory fragment command unlock, support/name-call, treasure ledger, telemetry, cutscene IDs, `next_destination_summary`, CH10 tower-chain interaction ownership, CH10 shell flow, and `StageResolutionService` behavior.

Executed f59 gates from `/Volumes/AI/tactics` with `/opt/homebrew/bin/godot4`:

- PASS: `scripts/dev/post_battle_bark_queue_runner.gd`.
- PASS: `scripts/dev/post_battle_readability_runner.gd`.
- PASS: `scripts/dev/post_battle_handoff_runner.gd`.
- PASS: `scripts/dev/result_entry_tempo_runner.gd`.
- PASS: `scripts/dev/result_screen_readability_runner.gd`.
- PASS: `scripts/dev/treasure_ledger_runner.gd`.
- PASS: `scripts/dev/stage_resolution_runner.gd`.
- PASS: `scripts/dev/support_namecall_pipeline_runner.gd`.
- PASS: `scripts/dev/ch10_tower_chain_runner.gd`.
- PASS: `scripts/dev/ch10_shell_runner.gd`.
- PASS: `scripts/dev/ch06_ch10_cutscene_runner.gd`.
- PASS: `scripts/dev/three_star_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh`.
- PASS: `git diff --check -- data/stages/ch10_01_stage.tres data/stages/ch10_02_stage.tres data/stages/ch10_03_stage.tres scripts/dev/post_battle_bark_queue_runner.gd docs/reviews/2026-05-05-f59-ch10-01-ch10-03-post-battle-bark-release-qa.md` exited 0 for tracked diffs. Because `scripts/dev/post_battle_bark_queue_runner.gd` and this QA note are currently untracked, that Git command does not inspect their content until they are staged/tracked; run a separate local whitespace scan or stage them before package validation.

Observed known warnings, all non-blocking in this f59 run because the relevant commands exited 0:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` in isolated headless result/handoff/support runners.
- `ch06_ch10_cutscene_runner.gd` emitted ObjectDB/resource leak cleanup warnings after PASS.
- Gate0 reported existing workspace-only `res://` targets and Android `[SIGNING-DEFERRED][INTERNAL-QA] package/signed=false`; Gate0 still exited PASS and public release remains blocked by separate signing custody.

Remaining delivery caution:

- Working-tree implementation/QA is complete for f59 after the listed gates. Package/index readiness is still BLOCKED until the f59 payload is staged/included or explicitly waived by the release owner: CH10_01~CH10_03 stage changes, `scripts/dev/post_battle_bark_queue_runner.gd`, this QA note, `scripts/dev/post_battle_bark_queue_runner.gd.uid` if repository convention requires it, and the CH10_02~CH10_03 object resources currently referenced by the modified stage payload.
- Required f59-adjacent object resources to include before package/index readiness, because the modified CH10_02~CH10_03 stage files reference them and they are currently workspace-only: `data/objects/ch10_02_west_crest_control.tres`, `data/objects/ch10_02_east_crest_control.tres`, `data/objects/ch10_03_west_corridor_anchor.tres`, and `data/objects/ch10_03_east_corridor_anchor.tres`.
- The repository still has broader pre-existing dirty/untracked work. Treat only the listed f59 bark/runner/QA files plus the directly referenced CH10_02~CH10_03 object resources as this slice's delivery payload unless the release owner explicitly expands scope.

## Recommended f59 packaging check

Before packaging or committing f59, include the complete f59 payload:

- `data/stages/ch10_01_stage.tres`
- `data/stages/ch10_02_stage.tres`
- `data/stages/ch10_03_stage.tres`
- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if Godot requires the generated UID file in this repository convention
- `data/objects/ch10_02_west_crest_control.tres`
- `data/objects/ch10_02_east_crest_control.tres`
- `data/objects/ch10_03_west_corridor_anchor.tres`
- `data/objects/ch10_03_east_corridor_anchor.tres`
- this review note, if release evidence docs are being committed

The focused gate pack and Gate0 must pass against the implemented f59 payload, with only the known warnings above allowed as non-blocking.
