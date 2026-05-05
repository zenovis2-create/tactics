# f61 accumulated post-battle bark payload packaging QA scout

Scope: packaging/index readiness for the accumulated post-battle bark payload authored across f34 through f60. This is not a new bark-authoring slice; it is a release QA packaging scout for the combined payload.

Working directory: `/Volumes/AI/tactics`.

## Status split

Working-tree validation: PASS for the focused runtime/package-surface checks run in this scout.

Package/index readiness: BLOCKED until the accumulated payload is deliberately staged/included and package manifest ownership is resolved. The f45/f46 review-doc final-newline defects found by the scout were fixed in f61. No `git add` or commit was performed.

## Accumulated payload under f61 packaging review

Primary stage payload:

- `data/stages/ch01_02_stage.tres` through `data/stages/ch01_05_stage.tres`
- `data/stages/ch02_01_stage.tres` through `data/stages/ch02_05_stage.tres`
- `data/stages/ch03_01_stage.tres` through `data/stages/ch03_05_stage.tres`
- `data/stages/ch04_01_stage.tres` through `data/stages/ch04_05_stage.tres`
- `data/stages/ch05_01_stage.tres` through `data/stages/ch05_05_stage.tres`
- `data/stages/ch06_01_stage.tres` through `data/stages/ch06_05_stage.tres`
- `data/stages/ch07_01_stage.tres` through `data/stages/ch07_05_stage.tres`
- `data/stages/ch08_01_stage.tres` through `data/stages/ch08_05_stage.tres`
- `data/stages/ch09a_01_stage.tres` through `data/stages/ch09a_05_stage.tres`
- `data/stages/ch09b_01_stage.tres` through `data/stages/ch09b_05_stage.tres`
- `data/stages/ch10_01_stage.tres` through `data/stages/ch10_05_stage.tres`

Required runner/index payload:

- `scripts/dev/post_battle_bark_queue_runner.gd`
- `scripts/dev/post_battle_bark_queue_runner.gd.uid` if this repository's Godot UID convention requires committing generated UID files
- `scripts/dev/post_battle_handoff_runner.gd`
- `scripts/dev/post_battle_handoff_runner.gd.uid` if UID files are packaged
- `scripts/dev/post_battle_readability_runner.gd`
- `scripts/dev/post_battle_readability_runner.gd.uid` if UID files are packaged
- `scripts/dev/check_post_battle_bark_payload_package.py`

Review evidence payload, if evidence docs are packaged:

- `docs/reviews/2026-05-05-f44-ch03-04-ch03-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f45-ch04-01-ch04-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f46-ch04-04-ch04-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f47-ch05-01-ch05-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f48-ch05-04-ch05-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f49-ch06-01-ch06-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f50-ch06-04-ch06-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f51-ch07-01-ch07-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f52-ch07-04-ch07-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f53-ch08-01-ch08-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f54-ch08-04-ch08-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f55-ch09a-01-ch09a-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f56-ch09a-04-ch09a-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f57-ch09b-01-ch09b-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f58-ch09b-04-ch09b-05-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f59-ch10-01-ch10-03-post-battle-bark-release-qa.md`
- `docs/reviews/2026-05-05-f60-ch10-04-ch10-05-post-battle-bark-release-qa.md`
- this f61 QA scout, if review evidence docs are packaged

## f61 validation gates

Run these from `/Volumes/AI/tactics` before claiming package/index readiness.

```bash
export GODOT_BIN=/opt/homebrew/bin/godot4
export GODOT_QA_HOME="$PWD/tmp/home_f61_packaging_qa"
export HOME="$GODOT_QA_HOME"
mkdir -p "$GODOT_QA_HOME"

/opt/homebrew/bin/godot4 --headless --path . --script res://scripts/dev/post_battle_bark_queue_runner.gd
bash scripts/dev/check_runnable_gate0.sh
```

Package manifest/index gate:

1. Build a manifest for the intended f61 payload before staging or packaging.
2. The manifest must include all f34-f60 stage files that own post-battle bark changes, the queue/handoff/readability runners, and their UID files if required.
3. The manifest must explicitly include or explicitly exclude the f44-f61 review docs; do not leave them accidentally workspace-only if release evidence docs are expected.
4. The manifest must identify any non-bark stage/resource changes carried inside the same dirty stage files and either include their dependencies or record a release-owner scope waiver.
5. The index must match the manifest exactly before package validation; partially staged stage files are not package-ready.
6. Run whitespace/final-newline checks against untracked docs and runner files before relying on `git diff --check`, because `git diff --check -- <untracked-file>` does not inspect untracked content until it is staged/tracked.
7. Run `python3 scripts/dev/check_post_battle_bark_payload_package.py`; it must PASS before claiming package/index readiness.
8. Run `git diff --check` against the staged/manifest payload after staging, then rerun Gate0 against the staged package payload.

Recommended manifest check commands:

```bash
git status --short -- \
  data/stages \
  scripts/dev/post_battle_bark_queue_runner.gd scripts/dev/post_battle_bark_queue_runner.gd.uid \
  scripts/dev/post_battle_handoff_runner.gd scripts/dev/post_battle_handoff_runner.gd.uid \
  scripts/dev/post_battle_readability_runner.gd scripts/dev/post_battle_readability_runner.gd.uid \
  scripts/dev/check_post_battle_bark_payload_package.py \
  scripts/data/stage_data.gd scripts/dev/ch06_ch10_boss_surface_runner.gd \
  data/objects/ch05_04_truth_shelf_index.tres data/objects/ch05_04_zero_transfer_ledger.tres \
  data/objects/ch09a_04_east_censor_pike.tres data/objects/ch09a_04_west_cell_witness.tres \
  data/objects/ch10_02_east_crest_control.tres data/objects/ch10_02_west_crest_control.tres \
  data/objects/ch10_03_east_corridor_anchor.tres data/objects/ch10_03_west_corridor_anchor.tres \
  docs/reviews

git diff --cached --name-only -- \
  data/stages scripts/dev/post_battle_bark_queue_runner.gd scripts/dev/post_battle_bark_queue_runner.gd.uid \
  scripts/dev/post_battle_handoff_runner.gd scripts/dev/post_battle_handoff_runner.gd.uid \
  scripts/dev/post_battle_readability_runner.gd scripts/dev/post_battle_readability_runner.gd.uid \
  scripts/dev/check_post_battle_bark_payload_package.py scripts/data/stage_data.gd \
  scripts/dev/ch06_ch10_boss_surface_runner.gd data/objects docs/reviews

python3 scripts/dev/check_post_battle_bark_payload_package.py
```

## Working-tree findings from this scout

Executed checks:

- PASS: `/opt/homebrew/bin/godot4 --headless --path . --script res://scripts/dev/post_battle_bark_queue_runner.gd`.
- PASS: `bash scripts/dev/check_runnable_gate0.sh` exited 0.
- PASS: `python3 scripts/dev/check_post_battle_bark_payload_package.py` executed and correctly returned BLOCKED/nonzero for current index state, with this summary: `cached_bark_stage_coverage=0/54`, `unstaged_bark_stage_deltas=54`, `untracked_manifest_paths=33`, `unstaged_manifest_paths=56`. This is a successful guardrail result, not package readiness.

Observed known non-blocking warnings:

- `CampaignController.setup requires a Main-owned SaveService; autosave is disabled.` appeared during the focused queue runner. This remains non-blocking because the runner exited 0 and the warning is the known isolated-headless SaveService warning.
- Gate0 reported workspace-only `res://` warning targets and exited PASS. Treat this as non-blocking for working-tree QA only; any f61-critical payload file left workspace-only is still a packaging blocker.
- Gate0 reported Android signing deferred. Internal QA may pass, but public package readiness remains blocked until operator-owned Android signing custody/preflight passes.

Local package hygiene finding:

- A local whitespace/final-newline scan over f44-f60 stage payload candidates, queue runner files, and f44-f60 review docs originally found missing final newlines in:
  - `docs/reviews/2026-05-05-f45-ch04-01-ch04-03-post-battle-bark-release-qa.md`
  - `docs/reviews/2026-05-05-f46-ch04-04-ch04-05-post-battle-bark-release-qa.md`
- f61 fixed those two final-newline defects. Current newline/whitespace scan over the f61 docs/runner manifest has no doc final-newline blocker.

## Package/index blockers

Package/index readiness is BLOCKED by all of the following until resolved:

1. The accumulated payload is not staged as a coherent package. Current scoped status shows most f34-f60 stage files as unstaged modified files, while `data/stages/ch03_04_stage.tres`, `data/stages/ch04_01_stage.tres`, and `data/stages/ch04_02_stage.tres` have both staged and unstaged changes (`MM`).
2. `scripts/dev/post_battle_bark_queue_runner.gd`, `scripts/dev/post_battle_handoff_runner.gd`, `scripts/dev/post_battle_readability_runner.gd`, and `scripts/dev/check_post_battle_bark_payload_package.py` are untracked. If they are required for the accumulated bark validation payload, leaving them workspace-only blocks package/index readiness.
3. The corresponding Godot UID files for the bark/handoff/readability runners are untracked. Include them if repository convention requires Godot UID files, or document a release-owner waiver.
4. f44-f61 review docs are untracked. If release evidence docs are part of the package, they must be included intentionally and pass newline/whitespace checks.
5. Gate0 still reports workspace-only `res://` targets. Gate0 exits PASS for internal QA, but package readiness requires all f61-critical refs to be staged/included or explicitly waived.
6. Android signing remains deferred. This is not a bark payload implementation blocker, but it is a public package readiness blocker.
7. The repository contains broader dirty/untracked work outside the f34-f60 bark payload. Packaging from the whole working tree without an explicit manifest risks accidentally including unrelated assets/scripts or omitting bark-critical files.

## Release risk calls

- Do not claim package/index readiness from a working-tree PASS alone.
- Do not rely on `git diff --check` to validate untracked docs/runner content before staging.
- Do not classify known headless SaveService warnings or cutscene ObjectDB leak-at-exit warnings as blockers when the relevant runner exits 0; do classify them as blockers if paired with nonzero exit, failed assertions, missing handoff state, or new payload-specific errors.
- Do not treat Gate0's workspace-only warning carve-out as permission to omit f61-critical bark files from the package.
- Do not package the accumulated dirty stage files without reviewing non-bark dependencies embedded in the same files.

## Current conclusion

Working-tree QA for the accumulated post-battle bark payload is PASS for the focused queue runner and Gate0 checks run by this scout, with only known non-blocking warnings.

Package/index readiness is BLOCKED. The new `scripts/dev/check_post_battle_bark_payload_package.py` manifest guard is in place and correctly reports the current index/package blockers. Resolve the manifest/index mismatch, untracked queue/handoff/readability runners and UID files, untracked f44-f61 review docs, workspace-only critical refs, and public signing custody before claiming f61 package readiness.
