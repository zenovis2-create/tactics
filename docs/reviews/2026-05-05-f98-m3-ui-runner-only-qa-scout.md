# f98 M3 UI Runner-Only QA Scout

## Scope

Proposed selected f98 payload:

- `scripts/dev/m3_ui_runner.gd`
- `scripts/dev/m3_ui_runner.gd.uid`
- `docs/reviews/2026-05-05-f98-m3-ui-runner-only-qa-scout.md`
- `tmp/validation/qa_evidence_20260505_f98_m3_ui_runner_only/`

This is a runner/doc/evidence-only internal QA slice for existing M3 UI behavior: compact BattleHUD layout, inventory/menu input blocking, battle result surface, CampaignPanel camp shell snapshots, save-entry visibility, records handoff, and CampaignPanel selection persistence.

No production BattleHUD, BattleController, CampaignPanel, CampaignController, Main scene logic, scenes, battle logic, combat math, AI, reward/EXP formulas, support mechanics, passive modifier data, memory/save/progression schema, telemetry implementation, stage data, new image assets, `.import` files, Android signing, bark payloads, package manifests, or public release changes are owned by the selected f98 payload.

The repository has a broad dirty baseline with unrelated tracked/untracked changes and conflict state outside this selected proposal. f98 validates only the selected working-tree runner/doc/evidence UX slice and must not be used to certify the broader worktree.

## Focused f98 gate

Run the focused Godot runner:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd
```

Required PASS line:

```text
[PASS] M3 UI runner verified battle HUD inventory and camp shell snapshots.
```

Focused gate intent:

- Main scene can instantiate and start direct battle flow for runner verification.
- BattleHUD compact layout enters narrow viewport mode at 430x900.
- Compact BattleHUD preserves readable Phase/Objective prefixes, 2-column actions, 72px action minimum height, vertical inventory body, and 16px safe inset.
- CampaignPanel compact layout enters narrow viewport mode at 430x900.
- Compact CampaignPanel preserves 2-column tabs, 56px tab minimum height, vertical party content, and 16px safe inset.
- BattleHUD inventory/menu state blocks inappropriate battle input while a menu is open.
- Battle result surface exposes structured result/readability/feedback fields expected by the M3 UX contract.
- Campaign camp shell snapshot, save entry, result-to-record handoff, and CampaignPanel selection persistence remain intact.

A focused-runner failure is a selected f98 blocker unless proven to be caused by unrelated broad workspace damage and explicitly separated in the evidence log.

Known focused-runner side effects:

- The runner instantiates `scenes/Main.tscn`, starts a direct battle/campaign flow, and may write current user-save/cache state through existing debug/runtime paths.
- User/cache writes are not repository file changes and are not package/public readiness evidence.
- Any repository file delta after the focused run must be investigated before classifying f98.

## Adjacent runner-only gates

Run these adjacent gates after the focused runner:

```bash
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/battle_result_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ui_screens_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/title_load_panel_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/s3_camp_save_tab_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_save_panel_roundtrip_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_skill_section_runner.gd
/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/campaign_panel_dialogue_history_runner.gd
```

Adjacent gate rationale:

- `battle_result_runner.gd` protects battle result/readability behavior covered by the focused M3 runner.
- `ui_screens_runner.gd` protects shared UI screen and shell behavior near Main/UI boot flows.
- `title_load_panel_runner.gd` protects title/load UX adjacent to the focused save-entry and title handoff checks.
- `s3_camp_save_tab_runner.gd` protects the camp save-tab and CampaignPanel save-entry surface.
- `campaign_save_panel_roundtrip_runner.gd` protects CampaignPanel save/load roundtrip state adjacent to save-entry visibility.
- `campaign_panel_skill_section_runner.gd` protects selected-party context and section rendering after CampaignPanel refresh.
- `campaign_panel_dialogue_history_runner.gd` protects shared CampaignPanel section ordering and snapshot integrity after camp state changes.

Focused and adjacent runner failures are f98 internal QA blockers unless the evidence identifies them as unrelated to the selected f98 runner/doc/evidence payload.

Do not include conflicted broad-worktree runners as f98 gates unless their conflict state is resolved first. If an adjacent runner cannot parse because of unrelated merge conflict markers or non-f98 worktree damage, record the failure verbatim and classify it outside selected f98 unless the failing file is selected above.

## Evidence directory

Use this evidence directory:

```text
tmp/validation/qa_evidence_20260505_f98_m3_ui_runner_only/
```

Recommended evidence files:

- `f98_m3_ui_runner.log`
- `battle_result.log`
- `ui_screens.log`
- `title_load_panel.log`
- `s3_camp_save_tab.log`
- `campaign_save_panel_roundtrip.log`
- `campaign_panel_skill_section.log`
- `campaign_panel_dialogue_history.log`
- `git_diff_check_f98.log`
- `no_index_f98_whitespace.log`
- `check_runnable_gate0.log`
- `check_runnable_gate0_exit.txt`
- `package_guard.log`
- `package_guard_exit.txt`

Each runner log should retain the full Godot output and the observed PASS line. Each exit file should contain the numeric exit code in a simple parseable form, e.g. `CHECK_RUNNABLE_GATE0_EXIT 1` or `PACKAGE_GUARD_EXIT 1`.

## Hygiene gates

Scoped git whitespace gate:

```bash
git diff --check -- scripts/dev/m3_ui_runner.gd scripts/dev/m3_ui_runner.gd.uid docs/reviews/2026-05-05-f98-m3-ui-runner-only-qa-scout.md
```

Because selected f98 files/evidence may be untracked in this dirty workspace, also run a selected no-index whitespace/final-newline scan over:

- `scripts/dev/m3_ui_runner.gd`
- `scripts/dev/m3_ui_runner.gd.uid`
- `docs/reviews/2026-05-05-f98-m3-ui-runner-only-qa-scout.md`
- `tmp/validation/qa_evidence_20260505_f98_m3_ui_runner_only/`

No-index scan requirements:

- No trailing whitespace in selected text/log/evidence files.
- Selected text/log/evidence files end with a final newline.
- Binary/image dependencies are excluded from whitespace scanning.
- Broader dirty-worktree whitespace is not classified as f98 unless it is in the selected payload/evidence paths above.

## Gate0 separation

Run Gate0 separately after focused/adjacent runner and hygiene gates:

```bash
bash scripts/dev/check_runnable_gate0.sh
```

Current expected classification from known workspace state:

```text
CHECK_RUNNABLE_GATE0_EXIT 1
```

Gate0 reporting rule:

- Do not claim `Gate0: PASS` unless `check_runnable_gate0.sh` exits 0.
- If Gate0 exits 1 only on non-f98 index/readiness files, classify it as a non-f98 blocker and record the blocker text verbatim.
- Any f98-owned missing runner/resource, changed-file reference failure, parse error, runtime load failure, or invalid readiness file is a selected f98 blocker.
- Known broader workspace-only `res://` warnings, conflicted non-f98 files, and Android signing-deferred warnings are not selected f98 blockers by themselves, but they still prevent public release readiness claims.

## Package guard separation

Run the bark package guard separately from f98 UX validation:

```bash
python3 scripts/dev/check_post_battle_bark_payload_package.py
```

Current expected classification from known workspace state:

```text
PACKAGE_GUARD_EXIT 1
```

Known package guard note:

- The package guard may exit 1 because cached bark stage coverage is incomplete or stale.
- That is package/index custody evidence, not selected f98 UX evidence, unless it names selected f98 paths or worsens because of selected f98 files.

Package guard reporting rule:

- Record the guard exit code and key counts, but do not use it as f98 UX evidence.
- `PACKAGE_GUARD_EXIT 0` means the package guard passed at that moment; it does not create an f98 package/index readiness claim.
- `PACKAGE_GUARD_EXIT 1` is a package/index custody blocker only if it identifies package/index state, not a selected f98 blocker unless it names selected f98 paths or worsens because of selected f98 files.
- f98 must not claim package readiness or public release readiness from package guard output.

## Internal QA classification rule

The selected f98 runner-only UX slice can be classified only as internal working-tree QA evidence when all of the following are true:

- Focused `m3_ui_runner.gd`: PASS.
- Adjacent runner-only gates: PASS or explicitly separated as unrelated.
- Scoped git whitespace and no-index selected-path hygiene: PASS.
- Gate0 result recorded and separated; known exit 1 is not hidden or converted into PASS.
- Package guard result recorded and separated; possible cached bark coverage exit 1 is not hidden or converted into PASS.
- No production-code, asset-production, package-manifest, signing, or public release readiness claim is made.

## Blockers

Selected f98 blockers:

- Focused M3 UI runner missing or failing.
- Any adjacent runner failure that shares BattleHUD compact layout, inventory/menu state, battle result, Main UI shell, CampaignPanel camp/save/detail, or title/load behavior and is not explicitly proven unrelated.
- Any hygiene failure in selected f98 runner/doc/evidence paths.
- Any Gate0 blocker that names selected f98 paths or selected f98 dependencies.

Separated non-f98 blockers:

- Gate0 exit 1 caused only by known non-f98 index/readiness files.
- Broader dirty-worktree changes outside the selected f98 payload.
- Package guard output for bark package/index custody, including cached bark coverage, unless it names selected f98 paths or worsens because of selected f98 files.
- Existing merge-conflict state in non-selected runners, unless it prevents the selected focused runner from parsing or executing.

No release readiness claim is made by this scout proposal.
