# Device Smoke And Touch-Readability Checklist v1

## Purpose

This checklist defines the minimum demo-surface QA pass for the current build candidate.

Use it with:

- `docs/release_confidence_policy.md` for promotion logic
- `docs/production/export_platform_checklist_v1.md` for export/device setup

This document answers three questions:

1. what gets tested first
2. what blocks promotion immediately
3. what must be true before a patch, build, or demo candidate moves forward

## Test Priority Order

Always execute in this order. Do not spend device time while a higher tier is red.

### `P0` Structural integrity

Must pass first:

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --quit`

Blockers:

- any missing `res://` reference
- any parse error or boot failure
- any scene/resource load failure

### `P1` Core loop baseline

Must pass before any manual touch smoke:

- `godot4 --headless --path . --script res://scripts/dev/m1_core_loop_contract_runner.gd`

Blockers:

- illegal move/action flow
- broken victory/defeat resolution
- enemy-phase legality failure
- interaction/cancel regression in the battle loop

### `P2` Active shell and UI lane

Must pass before any demo-surface claim:

- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`

Blockers:

- wrong Chapter 1 routing or camp handoff
- missing camp payload or empty critical surface
- HUD/UI readability cue regression that hides player state

### `P3` Target-device manual smoke

Run on the actual intended play surface after `P0` through `P2` are green.

Required path:

1. boot the exported build on the target device
2. complete one battle with touch input only
3. progress through the active Chapter 1 lane into camp
4. inspect `party`, `inventory`, and `records`
5. confirm the next-step recommendation and session-complete understanding

## Manual Device Checklist

### 1. Boot and session start

- app launches without crash on the target device
- first screen is legible without zooming or guessing
- no essential UI is clipped by aspect ratio, safe area, or device scaling

### 2. Battle touch usability

- ally selection works reliably on first or second tap, not after repeated tapping
- reachable tiles and target previews remain visually clear under touch interaction
- move, attack, wait, and cancel can be completed without accidental adjacent taps
- inventory/modal surfaces block world input while open
- phase/objective/selected-unit labels remain readable during play

### 3. Battle completion smoke

- one full battle can be completed on device
- victory handoff proceeds without softlock or invisible confirmation step
- no battle interaction requires mouse hover, keyboard-only input, or editor-only affordance

### 4. Camp and shell readability

- `summary`, `party`, `inventory`, and `records` are all reachable on device
- tab labels, badges, and counts are readable at normal handheld distance
- roster selection updates the detail surface correctly
- recommendation text clearly tells the player what to inspect next
- `records` content is understandable without tiny-text scanning

### 5. Session-complete understanding

By the end of the smoke path, a first-pass player should be able to answer all of the following without external explanation:

- what just happened in the battle
- what reward, memory, evidence, or roster change was gained
- what screen matters next
- where the next progression step points

If any of these answers are unclear because of layout, copy, cue visibility, or touch friction, the candidate is not demo-ready.

## Quality Gates

### Patch-ready

A patch can move forward only when:

- required automated gates for the changed surface are green
- the reported bug is fixed in a manual smoke path that directly exercises the changed behavior
- no new `critical` or `high` defect was introduced in the same player-facing surface

### Build-ready

A build can move forward only when:

- `P0`, `P1`, and `P2` are green
- every touched regression family from `docs/release_confidence_policy.md` is green
- the active-lane manual smoke path is complete
- no open `critical` or `high` defect remains in scoped content

### Demo-ready

A demo candidate can move forward only when:

- the build-ready gate is green
- export/preset validation is complete for the target surface
- one real device smoke pass confirms touch usability and readability
- one session-complete path is verified on the same target surface
- remaining issues are documented and none create progression-loss or player-misleading risk

## Severity Rules

Promotion is blocked by any reproducible issue in scoped content that is:

- `Critical`: crash, hard lock, impossible progression, corrupted session state, or missing required payload
- `High`: broken chapter order, failed battle completion, unusable touch interaction on the target surface, or unreadable state cues that hide required player decisions

`Medium` can move only by explicit acceptance and only if progression remains understandable.
`Low` never overrides a failed automated gate.

## What Must Be True Before Promotion

Before a patch, build, or demo candidate moves forward, all of the following must be true:

1. The exact required gate set was selected from the changed surface, not guessed from perceived risk.
2. The candidate passed all required automated commands in the same workspace under review.
3. Manual smoke covered the player path most likely to expose the changed behavior.
4. For demo claims, the smoke happened on the actual target play surface, not only in-editor.
5. QA can name the device/host used, the commands run, the manual path covered, and the unresolved issues left behind.
6. No blocker was waived because the issue seemed cosmetic when it actually hid progression state, battle state, or next-step understanding.

## Evidence Template

Every gate decision should record:

- candidate identifier or commit
- commands run
- pass/fail result per gate tier
- target device or host
- manual path covered
- unresolved issues and accepted risk

Without this evidence, the candidate is not promoted.

## Current Baseline Evidence (2026-04-14)

Fresh automated pre-gates passed in the current workspace:

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --quit`
- `godot4 --headless --path . --script res://scripts/dev/m1_core_loop_contract_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`

Interpretation:

- runtime baseline is green enough to justify device smoke
- demo-ready is still blocked until export/device validation is recorded on a real target surface
