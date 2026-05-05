# f100 Campaign Panel Dialogue History Runner-Only QA Scout

## Scope

Selected f100 payload:

- `scripts/dev/campaign_panel_dialogue_history_runner.gd`
- `scripts/dev/campaign_panel_dialogue_history_runner.gd.uid`
- `docs/reviews/2026-05-05-f100-campaign-panel-dialogue-history-runner-only-qa-scout.md`
- `tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/`

This is a runner/doc/evidence-only internal QA slice for the existing non-image CampaignPanel dialogue-history UX surface: dedicated dialogue-history tab, dialogue-history section visibility, normalized recent/support/handoff text, badge text, fallback empty-state copy, snapshot fields, and summary mirroring.

No production CampaignPanel/CampaignController/Main logic, scenes, battle logic, combat math, AI, reward/EXP formula, support mechanic implementation, memory/save/progression schema, telemetry implementation, stage data, image asset, `.import` file, Android signing, bark payload, package manifest, or public release change is owned by selected f100.

The repository currently has broader non-f readiness blockers. f100 validates only this selected working-tree runner/doc/evidence UX slice and must not be used to certify the broader worktree, package state, signing state, or public release readiness.

## Focused f100 gate

Run the focused Godot runner:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_dialogue_history_runner.gd
```

Required PASS line:

```text
[PASS] campaign_panel_dialogue_history_runner validated the dedicated camp dialogue history section.
```

Focused gate intent:

- CampaignPanel instantiates directly without Main/CampaignController ownership.
- `active_section=dialogue_history` selects the dedicated dialogue-history surface.
- `DialogueHistoryButton` and `DialogueHistorySection` exist.
- The summary section is hidden while dialogue history is active.
- Dialogue-history tab state disables only its own tab and keeps adjacent records navigation available.
- Section hint explains recent/support/handoff review.
- Dialogue entries normalize the Korean empire handoff line with the `Empire link:` prefix.
- Badge text auto-populates as `신규 3` for populated dialogue history.
- Recent/support/handoff headings and list text expose the expected counts and copy.
- Summary dialogue list mirrors normalized dialogue-history entries.
- Empty dialogue history keeps the section active, does not invent a badge, and renders empty-state fallback copy for recent/support/handoff buckets.

A focused-runner failure is a selected f100 blocker unless the evidence proves it is caused only by unrelated broad workspace damage and explicitly separates it.

Known focused-runner side effects:

- The runner instantiates only `scenes/campaign/CampaignPanel.tscn` and drives synthetic non-image payload data.
- Any user/cache writes are not repository file changes and are not package/public readiness evidence.
- Any repository file delta after the focused run must be investigated before classifying f100.

## Adjacent runner-only gates

Run these adjacent gates after the focused runner:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_skill_section_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_presentation_card_runner.gd
```

Adjacent gate rationale:

- `campaign_panel_skill_section_runner.gd` protects the adjacent direct CampaignPanel camp tab/section path, selected unit label, skill list, resource cost text, and EXP copy.
- `campaign_panel_presentation_card_runner.gd` protects the adjacent direct CampaignPanel presentation-card path, including meta-only cards that do not require new image assets.

Focused and adjacent runner failures are f100 internal QA blockers unless the evidence identifies them as unrelated to selected f100 runner/doc/evidence paths or to direct CampaignPanel dialogue-history/skills/presentation-card UX adjacency.

Do not include Main-heavy, save-heavy, battle-heavy, image-generation, sprite, art/package, field-sword, party-support, title-load, or CH10 ending runners as f100 gates. If a non-selected adjacent runner cannot parse because of unrelated merge conflict markers or non-f100 worktree damage, record the failure verbatim and classify it outside selected f100 unless it prevents the focused runner or selected adjacent direct CampaignPanel UX gates from parsing or executing.

## Evidence directory

Use this evidence directory:

```text
tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/
```

Recommended evidence files:

- `f100_campaign_panel_dialogue_history.log`
- `f100_campaign_panel_dialogue_history_exit.txt`
- `campaign_panel_skill_section.log`
- `campaign_panel_skill_section_exit.txt`
- `campaign_panel_presentation_card.log`
- `campaign_panel_presentation_card_exit.txt`
- `git_diff_check_f100.log`
- `git_diff_check_f100_exit.txt`
- `no_index_f100_whitespace.log`
- `no_index_f100_whitespace_exit.txt`
- `check_runnable_gate0.log`
- `check_runnable_gate0_exit.txt`
- `package_guard.log`
- `package_guard_exit.txt`
- `git_status_after_f100.log`

Each runner log should retain full Godot output and the observed PASS line. Each exit file should contain the numeric exit code in a simple parseable form, e.g. `F100_CAMPAIGN_PANEL_DIALOGUE_HISTORY_RUNNER_EXIT 0`, `CHECK_RUNNABLE_GATE0_EXIT 1`, or `PACKAGE_GUARD_EXIT 1`.

## Exact evidence commands

Create evidence directory:

```bash
mkdir -p /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only
```

Focused runner evidence:

```bash
set +e
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_dialogue_history_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/f100_campaign_panel_dialogue_history.log 2>&1
printf 'F100_CAMPAIGN_PANEL_DIALOGUE_HISTORY_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/f100_campaign_panel_dialogue_history_exit.txt
```

Adjacent runner evidence:

```bash
set +e
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_skill_section_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/campaign_panel_skill_section.log 2>&1
printf 'CAMPAIGN_PANEL_SKILL_SECTION_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/campaign_panel_skill_section_exit.txt
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_presentation_card_runner.gd > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/campaign_panel_presentation_card.log 2>&1
printf 'CAMPAIGN_PANEL_PRESENTATION_CARD_RUNNER_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/campaign_panel_presentation_card_exit.txt
```

## Hygiene gates

Scoped git whitespace gate:

```bash
set +e
git -C /Volumes/AI/tactics diff --check -- scripts/dev/campaign_panel_dialogue_history_runner.gd scripts/dev/campaign_panel_dialogue_history_runner.gd.uid docs/reviews/2026-05-05-f100-campaign-panel-dialogue-history-runner-only-qa-scout.md > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/git_diff_check_f100.log 2>&1
printf 'GIT_DIFF_CHECK_F100_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/git_diff_check_f100_exit.txt
```

Selected no-index whitespace/final-newline scan:

```bash
set +e
python3 - <<'PY' > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/no_index_f100_whitespace.log
from pathlib import Path
root = Path('/Volumes/AI/tactics')
paths = [
    root / 'scripts/dev/campaign_panel_dialogue_history_runner.gd',
    root / 'scripts/dev/campaign_panel_dialogue_history_runner.gd.uid',
    root / 'docs/reviews/2026-05-05-f100-campaign-panel-dialogue-history-runner-only-qa-scout.md',
    root / 'tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only',
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
print('PASS no selected f100 trailing whitespace or missing final newline')
PY
printf 'NO_INDEX_F100_WHITESPACE_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/no_index_f100_whitespace_exit.txt
```

Post-run repository hygiene check:

```bash
git -C /Volumes/AI/tactics status --short > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/git_status_after_f100.log
```

## Gate0 separation

Run Gate0 separately after focused/adjacent runner and hygiene gates:

```bash
set +e
bash /Volumes/AI/tactics/scripts/dev/check_runnable_gate0.sh > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/check_runnable_gate0.log 2>&1
printf 'CHECK_RUNNABLE_GATE0_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/check_runnable_gate0_exit.txt
```

Expected current-risk classification from handoff context:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
[FAIL] Found 14 broken res:// references
```

Gate0 reporting rule:

- Do not claim `Gate0: PASS` unless `check_runnable_gate0.sh` exits 0.
- If Gate0 exits 1 only on the known 14 non-f artifact/object broken `res://` references, classify it as a separated non-f100 blocker and record the blocker text verbatim.
- Any f100-owned missing runner/resource, changed-file reference failure, parse error, runtime load failure, invalid readiness file, or failure naming selected f100 dependencies is a selected f100 blocker.
- Known broader workspace-only `res://` failures, conflicted non-f100 files, and Android signing-deferred warnings are not selected f100 blockers by themselves, but they still prevent package/public release readiness claims.

## Package guard separation

Run the bark package guard separately from f100 UX validation:

```bash
set +e
python3 /Volumes/AI/tactics/scripts/dev/check_post_battle_bark_payload_package.py > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/package_guard.log 2>&1
printf 'PACKAGE_GUARD_EXIT %s\n' "$?" > /Volumes/AI/tactics/tmp/validation/qa_evidence_20260505_f100_campaign_panel_dialogue_history_runner_only/package_guard_exit.txt
```

Expected current-risk classification from handoff context:

```text
PACKAGE_GUARD_EXIT 1
cached_bark_stage_coverage=0/54
```

Package guard reporting rule:

- Record the guard exit code and key counts, but do not use it as f100 UX evidence.
- `PACKAGE_GUARD_EXIT 0` means the package guard passed at that moment; it does not create an f100 package/index readiness claim.
- `PACKAGE_GUARD_EXIT 1` is a bark package/index custody blocker only if it identifies package/index state, not a selected f100 blocker unless it names selected f100 paths or worsens because of selected f100 files.
- f100 must not claim package readiness or public release readiness from package guard output.

## Internal QA classification rule

The selected f100 runner-only non-image UX slice can be classified only as internal working-tree QA evidence when all of the following are true:

- Focused `campaign_panel_dialogue_history_runner.gd`: PASS with the required PASS line.
- Adjacent direct CampaignPanel runner-only gates: PASS or explicitly separated as unrelated in evidence.
- Scoped git whitespace and no-index selected-path hygiene: PASS.
- Gate0 result recorded and separated; possible 14 broken non-f refs exit 1 is not hidden or converted into PASS.
- Package guard result recorded and separated; possible `cached_bark_stage_coverage=0/54` exit 1 is not hidden or converted into PASS.
- No production-code, asset-production, image, `.import`, package-manifest, signing, package readiness, or public release readiness claim is made.

## Blockers

Selected f100 blockers:

- Focused CampaignPanel dialogue-history runner missing or failing.
- Required focused PASS line missing from focused runner log.
- Any adjacent direct CampaignPanel runner failure that shares dialogue-history, skills, presentation-card, section-tab, section visibility, section badge, non-image text rendering, or snapshot behavior and is not explicitly proven unrelated.
- Any hygiene failure in selected f100 runner/doc/evidence paths.
- Any repository file delta caused by f100 execution outside the selected evidence/doc paths.
- Any Gate0 blocker that names selected f100 paths or selected f100 dependencies.
- Any package guard failure that names selected f100 paths or demonstrably worsens because of selected f100 files.

Separated non-f100 blockers:

- Gate0 exit 1 caused only by the known 14 non-f broken `res://` references.
- Broader dirty-worktree changes outside the selected f100 payload.
- Bark package/index custody output, including `cached_bark_stage_coverage=0/54`, unless it names selected f100 paths or worsens because of selected f100 files.
- Existing merge-conflict state in non-selected runners, unless it prevents the selected focused runner or selected adjacent direct CampaignPanel UX gates from parsing or executing.
- Android signing-deferred/internal-QA warnings.

No package readiness, public readiness, or release readiness claim is made by this scout proposal.
