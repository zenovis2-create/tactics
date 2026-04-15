# Technical Director Architecture Review (2026-04-13)

## Scope

- active implementation lane for the Memory Tactics RPG project
- current repo state under `scenes/`, `scripts/`, `data/`, and `docs/`
- current project gates for runnable integrity, battle loop, campaign flow, and UI shell

## Verdict

The current build is technically stable for the active runtime lane, but the campaign shell is accumulating maintainability debt and the project is not export-ready.

- Build stability is green across the current `P0`, `P1`, and active `P2` runners.
- The main architecture drift is concentrated in `scripts/campaign/campaign_controller.gd`.
- Export readiness remains red because platform export configuration and validation are still absent.

## Evidence

Validated locally on 2026-04-13:

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --quit`
- `godot4 --headless --path . --script res://scripts/dev/m1_core_loop_contract_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`

All of the above passed in the current workspace.

## Findings

### 1. Build stability is currently protected

The repo still boots headlessly and the battle loop, campaign shell, and UI shell runners all pass. There is no immediate build-break or promotion blocker inside the current runtime lane.

### 2. `campaign_controller.gd` is now the main maintainability risk

`scripts/campaign/campaign_controller.gd` is 2,795 lines and mixes too many responsibilities:

- chapter flow orchestration
- stage registry data
- authored cutscene/interlude copy
- reward, memory, evidence, and letter tables
- equipment unlock tables
- party/loadout session defaults

This is stable today, but it is the wrong scaling surface. Continuing to add chapter content or unlock logic there will turn future fixes into regression-heavy controller edits.

### 3. Documentation is lagging the implemented shape

`docs/scene_script_structure.md` still describes a smaller M2-era extension centered on `scripts/ui/camp/` and a minimal chapter shell. The actual repo has already advanced into a broader multi-chapter `CampaignController` plus `CampaignPanel` implementation. That mismatch increases drift because the written boundary no longer matches the live one.

### 4. Export readiness is still not established

There is no committed `export_presets.cfg` in the workspace, and there is no recorded target-platform validation artifact for Android or any other shipping surface. Current runner success is useful build evidence, but it is not export evidence.

## Required Guardrails

Apply these rules to the next implementation tranche:

1. Do not add more authored chapter copy, reward tables, or unlock tables to `campaign_controller.gd`.
2. Keep `campaign_controller.gd` limited to orchestration and volatile session progression.
3. Extract chapter order and authored campaign content into `data/` resources or dedicated registry/session modules before further chapter expansion.
4. Keep panel and camp UI scripts presentation-only.
5. Do not claim demo-ready or release-ready until export presets and target-platform validation exist.

## Technical Position

Short term:

- safe to continue the active runtime lane
- not safe to keep scaling the campaign shell by extending the monolithic controller

Medium term:

- prioritize controller decomposition and content externalization before broadening chapter/camp scope again
- add explicit export configuration before any release-readiness discussion
