# Headless Development Guide

## Purpose

This project is now set up to support a headless-first Godot development workflow.

Use this guide when the main development loop is:

- edit code or assets
- run Godot in `--headless`
- validate structural and gameplay surfaces through scripted runners
- only open the full editor or desktop window when a visual/manual check is strictly needed

## Why Headless First

Headless mode is the fastest way to keep the project stable while the codebase and runtime art surfaces are still evolving.

It is best suited for:

- boot validation
- scene/script/resource integrity checks
- gameplay contract checks
- campaign shell validation
- UI state validation
- runtime asset loading validation

It is not a replacement for:

- final visual sign-off
- touch-feel judgment
- high-fidelity manual combat tuning

## Core Commands

From the repo root:

```bash
godot4 --headless --path /Volumes/AI/tactics --quit
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m2_campaign_flow_runner.gd
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/battle_integration_preview_runner.gd
/Volumes/AI/tactics/scripts/dev/run_visual_qa_suite.sh
/Volumes/AI/tactics/scripts/dev/run_perf_benchmarks.sh
```

## Fast Entry Points

### 1. Structural Check

```bash
/Volumes/AI/tactics/scripts/dev/check_runnable_gate0.sh
```

Use this when you only need:

- file presence
- `res://` reference integrity

### 2. Core Headless Smoke

```bash
/Volumes/AI/tactics/scripts/dev/headless_dev_smoke.sh
```

Use this for the default development loop.

It currently runs:

- headless boot
- M1 playtest
- M2 campaign flow
- M3 UI
- battle integration asset-loading validation
- broader visual QA remains in the art promotion suite

### 3. Art/Integration Check

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/battle_integration_preview_runner.gd
```

Use this after:

- runtime sprite updates
- production tile/icon swaps
- cleaned environment asset insertion

### 4. Visual QA Report

```bash
/Volumes/AI/tactics/scripts/dev/run_visual_qa_suite.sh
```

This produces project-tracked visual QA artifacts:

- `docs/generated/visual_qa_suite_report_v01.json`
- `docs/generated/visual_qa_suite_report_v01.md`

Use the Markdown report for human review and the JSON report for tooling or batch summaries.

Current snapshot:

- `8/8` runners passing
- preview families locked for `city / archive / final_bell`
- representative battle proximity locked at:
  - `CH07`: `1 / 1`
  - `CH09B`: `1`
  - `CH10`: `1 / 1`

### 5. Performance Benchmarks

```bash
/Volumes/AI/tactics/scripts/dev/run_perf_benchmarks.sh
```

This runs lightweight, machine-parsable headless benchmarks for:

- core loop bootstrap and enemy-phase roundtrip timing
- AI decision timing

Each runner emits a `PERF_RESULT=` JSON line for easy parsing in CI or local scripts.

## Current Headless-Critical Runners

- `m1_playtest_runner.gd`
- `m2_campaign_flow_runner.gd`
- `m3_ui_runner.gd`
- `battle_integration_preview_runner.gd`
- `run_visual_qa_suite.py`
- `core_loop_perf_runner.gd`
- `ai_decision_perf_runner.gd`

## Recommended Development Loop

1. make code or asset changes
2. run `check_runnable_gate0.sh`
3. run `headless_dev_smoke.sh`
4. if all pass, continue
5. only open the full project interactively when a manual visual call is needed

## Notes

### Runtime PNG Loading

The dev preview scripts now load runtime PNG assets directly from disk using `Image.load(...)`.

This matters because:

- freshly created PNGs may not have imported `.ctex` resources yet
- headless validation should not depend on editor reimport timing for dev-preview-only surfaces

### Audio

Headless mode uses the dummy audio driver.
Do not treat audio playback behavior in headless mode as equal to desktop runtime behavior.

### Visual Preview Limits

The current battle integration runner validates asset loading, not final visual capture.
That is enough for headless development stability, but not enough for final art sign-off.

## Current Working Conclusion

This project can now support a headless-first workflow for:

- core gameplay stability
- UI stability
- campaign shell stability
- runtime sprite loading
- runtime environment asset loading

That should be the default workflow until a task specifically requires full interactive visual review.
