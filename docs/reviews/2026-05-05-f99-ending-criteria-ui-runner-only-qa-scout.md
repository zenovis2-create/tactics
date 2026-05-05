# f99 Ending Criteria UI Runner-Only QA Scout

## Scope

Selected f99 payload:

- `scripts/dev/ending_criteria_ui_runner.gd`
- `scripts/dev/ending_criteria_ui_runner.gd.uid`
- `docs/reviews/2026-05-05-f99-ending-criteria-ui-runner-only-qa-scout.md`
- `tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/`

This is a runner/doc/evidence-only internal QA slice for the existing non-image CH10 ending-criteria UX surface: criteria checklist text, current ending verdict, dedicated ending criteria presentation card, progress rows, icon metadata, and hint metadata.

No production Main, CampaignController, CampaignPanel, EndingResolver, scene, battle logic, combat math, AI, reward/EXP formula, support mechanic, memory/save/progression schema, telemetry implementation, stage data, image asset, `.import` file, Android signing, bark payload, package manifest, or public release change is owned by selected f99.

The repository currently has broader non-f readiness blockers. f99 validates only this selected working-tree runner/doc/evidence UX slice and must not be used to certify the broader worktree, package state, signing state, or public release readiness.

## Focused f99 gate

Run the focused Godot runner:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ending_criteria_ui_runner.gd
```

Required PASS line:

```text
[PASS] ending_criteria_ui_runner: all assertions passed.
```

Focused gate intent:

- Main scene can instantiate far enough for the CH10 resolution UI check.
- CH10 resolution body exposes resonance completion count.
- CH10 resolution body exposes name-anchor requirement status.
- CH10 resolution body exposes name-call requirement status when criteria remain incomplete.
- CH10 resolution body exposes the current ending verdict alongside the checklist.
- CampaignPanel snapshot exposes a dedicated `최종 진엔딩 기준` presentation card.
- Ending criteria card exposes progress rows for resonance, anchors, and name calls.
- First progress row includes non-empty icon and hint metadata for text/UI polish.

A focused-runner failure is a selected f99 blocker unless the evidence proves it is caused only by unrelated broad workspace damage and explicitly separates it.

Known focused-runner side effects:

- The runner instantiates `scenes/Main.tscn` and drives CH10 resolution state through existing runtime services.
- Any user/cache writes are not repository file changes and are not package/public readiness evidence.
- Any repository file delta after the focused run must be investigated before classifying f99.

## Adjacent runner-only gates

Run these adjacent gates after the focused runner:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/true_ending_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ending_cinematic_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/postgame_surface_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ch06_ch10_cutscene_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/title_load_panel_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ng_plus_title_load_panel_runner.gd
```

Adjacent gate rationale:

- `true_ending_runner.gd` protects the CH10 true-ending resolution surface and presentation-card expansion adjacent to criteria UI.
- `ending_cinematic_runner.gd` protects normal/true ending overlay UI, ending labels, phase labels, outcome labels, and cinematic metadata adjacent to the criteria verdict path.
- `postgame_surface_runner.gd` protects postgame criteria/title/credits surfaces that consume ending completion state.
- `ch06_ch10_cutscene_runner.gd` protects late-game and CH10 ending cutscene catalog/stage contracts adjacent to the resolution entry point.
- `title_load_panel_runner.gd` protects title/load UX reached after ending/defeat flows and guards basic load-panel continuity near public-facing UI.
- `ng_plus_title_load_panel_runner.gd` protects title/load UX while NG+ metadata is visible after ending completion.

Focused and adjacent runner failures are f99 internal QA blockers unless the evidence identifies them as unrelated to selected f99 runner/doc/evidence paths or to CH10 ending criteria/resolution/title-load UX adjacency.

Do not include image-backed presentation-card, field-sword, party-support, sprite, or art-generation runners as f99 gates. If a non-selected adjacent runner cannot parse because of unrelated merge conflict markers or non-f99 worktree damage, record the failure verbatim and classify it outside selected f99 unless it prevents the focused runner or selected adjacent UX from executing.

## Evidence directory

Use this evidence directory:

```text
tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/
```

Recommended evidence files:

- `f99_ending_criteria_ui_runner.log`
- `true_ending.log`
- `ending_cinematic.log`
- `postgame_surface.log`
- `ch06_ch10_cutscene.log`
- `title_load_panel.log`
- `ng_plus_title_load_panel.log`
- `git_diff_check_f99.log`
- `no_index_f99_whitespace.log`
- `check_runnable_gate0.log`
- `check_runnable_gate0_exit.txt`
- `package_guard.log`
- `package_guard_exit.txt`
- `git_status_after_f99.log`

Each runner log should retain full Godot output and the observed PASS line. Each exit file should contain the numeric exit code in a simple parseable form, e.g. `CHECK_RUNNABLE_GATE0_EXIT 1` or `PACKAGE_GUARD_EXIT 1`.

## Exact evidence commands

Create evidence directory:

```bash
mkdir -p /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only
```

Focused runner evidence:

```bash
set +e
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ending_criteria_ui_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/f99_ending_criteria_ui_runner.log 2>&1
printf 'F99_ENDING_CRITERIA_UI_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/f99_ending_criteria_ui_runner_exit.txt
```

Adjacent runner evidence:

```bash
set +e
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/true_ending_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/true_ending.log 2>&1
printf 'TRUE_ENDING_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/true_ending_exit.txt
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ending_cinematic_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/ending_cinematic.log 2>&1
printf 'ENDING_CINEMATIC_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/ending_cinematic_exit.txt
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/postgame_surface_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/postgame_surface.log 2>&1
printf 'POSTGAME_SURFACE_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/postgame_surface_exit.txt
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ch06_ch10_cutscene_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/ch06_ch10_cutscene.log 2>&1
printf 'CH06_CH10_CUTSCENE_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/ch06_ch10_cutscene_exit.txt
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/title_load_panel_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/title_load_panel.log 2>&1
printf 'TITLE_LOAD_PANEL_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/title_load_panel_exit.txt
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ng_plus_title_load_panel_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/ng_plus_title_load_panel.log 2>&1
printf 'NG_PLUS_TITLE_LOAD_PANEL_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/ng_plus_title_load_panel_exit.txt
```

## Hygiene gates

Scoped git whitespace gate:

```bash
git -C /Volumes/AI/tactics diff --check -- scripts/dev/ending_criteria_ui_runner.gd scripts/dev/ending_criteria_ui_runner.gd.uid docs/reviews/2026-05-05-f99-ending-criteria-ui-runner-only-qa-scout.md > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/git_diff_check_f99.log 2>&1
```

Selected no-index whitespace/final-newline scan:

```bash
python3 - <<'PY' > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/no_index_f99_whitespace.log
from pathlib import Path
root = Path('/Volumes/AI/tactics')
paths = [
    root / 'scripts/dev/ending_criteria_ui_runner.gd',
    root / 'scripts/dev/ending_criteria_ui_runner.gd.uid',
    root / 'docs/reviews/2026-05-05-f99-ending-criteria-ui-runner-only-qa-scout.md',
    root / 'tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only',
]
failures = []
for path in paths:
    if path.is_dir():
        candidates = [p for p in path.rglob('*') if p.is_file()]
    else:
        candidates = [path]
    for item in candidates:
        if item.suffix.lower() in {'.png', '.jpg', '.jpeg', '.webp', '.import'}:
            continue
        data = item.read_bytes()
        try:
            text = data.decode('utf-8')
        except UnicodeDecodeError:
            continue
        if data and not data.endswith(b'\n'):
            failures.append(f'{item}: missing final newline')
        for idx, line in enumerate(text.splitlines(), 1):
            if line.rstrip(' \t') != line:
                failures.append(f'{item}:{idx}: trailing whitespace')
if failures:
    print('\n'.join(failures))
    raise SystemExit(1)
print('PASS no selected f99 trailing whitespace or missing final newline')
PY
```

Post-run repository hygiene check:

```bash
git -C /Volumes/AI/tactics status --short > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/git_status_after_f99.log
```

## Gate0 separation

Run Gate0 separately after focused/adjacent runner and hygiene gates:

```bash
set +e
bash /Volumes/AI/tactics/scripts/dev/check_runnable_gate0.sh > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/check_runnable_gate0.log 2>&1
printf 'CHECK_RUNNABLE_GATE0_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/check_runnable_gate0_exit.txt
```

Current observed classification from workspace probe:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
[FAIL] Found 14 broken res:// references
```

Observed broken references from the probe were non-f99 artifact/object paths under `res://artifacts/ash29`, `res://artifacts/ash30`, `res://artifacts/ash36`, `res://artifacts/ash37`, and these object resources:

- `res://data/objects/ch03_04_east_ember_echo_device.tres`
- `res://data/objects/ch03_04_west_resin_shrine.tres`
- `res://data/objects/ch04_01_supply_chest.tres`
- `res://data/objects/ch04_02_belfry_cache.tres`

Gate0 reporting rule:

- Do not claim `Gate0: PASS` unless `check_runnable_gate0.sh` exits 0.
- If Gate0 exits 1 only on non-f99 index/readiness/artifact/object files, classify it as a separated non-f99 blocker and record the blocker text verbatim.
- Any f99-owned missing runner/resource, changed-file reference failure, parse error, runtime load failure, invalid readiness file, or failure naming selected f99 dependencies is a selected f99 blocker.
- Known broader workspace-only `res://` failures, conflicted non-f99 files, and Android signing-deferred warnings are not selected f99 blockers by themselves, but they still prevent package/public release readiness claims.

## Package guard separation

Run the bark package guard separately from f99 UX validation:

```bash
set +e
python3 /Volumes/AI/tactics/scripts/dev/check_post_battle_bark_payload_package.py > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/package_guard.log 2>&1
printf 'PACKAGE_GUARD_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f99_ending_criteria_ui_runner_only/package_guard_exit.txt
```

Current observed classification from workspace probe:

```text
PACKAGE_GUARD_EXIT 1
cached_bark_stage_coverage=0/54
```

Package guard reporting rule:

- Record the guard exit code and key counts, but do not use it as f99 UX evidence.
- `PACKAGE_GUARD_EXIT 0` means the package guard passed at that moment; it does not create an f99 package/index readiness claim.
- `PACKAGE_GUARD_EXIT 1` is a bark package/index custody blocker only if it identifies package/index state, not a selected f99 blocker unless it names selected f99 paths or worsens because of selected f99 files.
- f99 must not claim package readiness or public release readiness from package guard output.

## Internal QA classification rule

The selected f99 runner-only non-image UX slice can be classified only as internal working-tree QA evidence when all of the following are true:

- Focused `ending_criteria_ui_runner.gd`: PASS with the required PASS line.
- Adjacent runner-only gates: PASS or explicitly separated as unrelated in evidence.
- Scoped git whitespace and no-index selected-path hygiene: PASS.
- Gate0 result recorded and separated; known exit 1 is not hidden or converted into PASS.
- Package guard result recorded and separated; possible `cached_bark_stage_coverage=0/54` exit 1 is not hidden or converted into PASS.
- No production-code, asset-production, image, `.import`, package-manifest, signing, package readiness, or public release readiness claim is made.

## Blockers

Selected f99 blockers:

- Focused ending criteria UI runner missing or failing.
- Required focused PASS line missing from focused runner log.
- Any adjacent runner failure that shares CH10 resolution, ending criteria checklist, ending verdict, ending presentation cards, ending cinematic overlays, postgame criteria/title state, or title/load UX and is not explicitly proven unrelated.
- Any hygiene failure in selected f99 runner/doc/evidence paths.
- Any repository file delta caused by f99 execution outside the selected evidence/doc paths.
- Any Gate0 blocker that names selected f99 paths or selected f99 dependencies.
- Any package guard failure that names selected f99 paths or demonstrably worsens because of selected f99 files.

Separated non-f99 blockers:

- Gate0 exit 1 caused only by the known 14 non-f99 artifact/object broken references.
- Broader dirty-worktree changes outside the selected f99 payload.
- Bark package/index custody output, including `cached_bark_stage_coverage=0/54`, unless it names selected f99 paths or worsens because of selected f99 files.
- Existing merge-conflict state in non-selected runners, unless it prevents the selected focused runner or selected adjacent UX gates from parsing or executing.
- Android signing-deferred/internal-QA warnings.

No package readiness, public readiness, or release readiness claim is made by this scout proposal.
