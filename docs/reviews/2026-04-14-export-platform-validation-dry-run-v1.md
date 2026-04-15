# Export And Platform Validation Dry Run v1 (2026-04-14)

## Scope

Dry-run export readiness review for the current demo candidate.

In scope:

- structural and headless runtime validation
- export-path probing from the current macOS workstation
- immediate blockers for a demo-ready candidate
- platform checklist handoff for the next export tranche

Out of scope:

- save/load
- release automation
- store submission setup
- monetization / IAP

## Commands Run

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --quit`
- `godot4 --headless --path . --script res://scripts/dev/m1_core_loop_contract_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`
- `godot4 --headless --path . --export-release "Linux/X11" /tmp/tactics-dry-run.x86_64`
- `godot4 --headless --path . --export-debug "Android" /tmp/tactics-dry-run.apk`
- `file artifacts/ash15/*.png artifacts/ash16/*.png artifacts/ash29/*.png artifacts/ash30/*.png artifacts/ash36/*.png artifacts/ash37/*.png`

## Result

The build is **runtime-stable but not export-ready**.

What passed:

- Gate 0 structural integrity
- headless boot
- core loop contract runner
- Chapter 1 campaign flow runner
- UI shell runner

What failed:

- both export probes stopped immediately because the project has no committed `export_presets.cfg`
- export-time asset reimport also surfaced mislabeled image files in `artifacts/`

## Findings

### 1. Runtime baseline is strong enough for export work

The current repo still satisfies the build-stability side of the release policy:

- the project boots under `godot4 --headless`
- the core battle contract is green
- the active Chapter 1 shell is green
- the camp/UI snapshot runner is green

This means the export lane is blocked by export setup and content packaging issues, not by a broken game loop.

### 2. The primary blocker is missing export configuration

The export command fails with:

`This project doesn't have an export_presets.cfg file at its root.`

That is a hard blocker for any demo-ready or release-ready claim under:

- `docs/engineering_rules.md`
- `docs/release_confidence_policy.md`

Without committed presets, there is no source-controlled target surface, no versioned export options, and no reproducible export command path.

### 3. The secondary blocker is invalidly named art files

During export probing, Godot reimport reported several `.png` files as corrupt.

File inspection confirms the root cause:

- `artifacts/ash15/ash15_portrait_sheet.png` is actually JPEG data
- `artifacts/ash15/ash15_portrait_sheet_v2.png` is actually JPEG data
- `artifacts/ash15/ash15_portrait_sheet_v3.png` is actually JPEG data
- `artifacts/ash16/ash16_equipment_icon_sheet_v1.png` is actually JPEG data

These files currently work around the problem only as loose workspace artifacts. Export-time reimport treats the extension mismatch as a real import failure.

This is an immediate packaging blocker even after export presets are added.

### 4. Target-platform validation is still absent

There is still no evidence for:

- Android preset validation
- Android install/run smoke
- touch input confirmation on a real device
- desktop export packaging validation

The current machine has `godot4` available, but this heartbeat produced no deployable package because the preset layer is missing.

### 5. Android should remain the first real target

Project docs already point to Android-first validation before iOS:

- `docs/game_spec.md`
- `docs/codex_workflow.md`

That remains the correct order.

iOS should stay deferred until:

- an Android export path exists
- the touch/readability pass is complete
- a macOS + Xcode signing workflow is intentionally opened

## Dry-Run Verdict

Current candidate status:

- build-ready evidence: partial green
- export-ready evidence: red
- demo-ready evidence: red

The repo is ready for an export-setup tranche.
It is not ready for a demo candidate export or platform claim yet.

## Immediate Unblock Order

1. Commit `export_presets.cfg` for the first target surface, starting with Android.
2. Fix artifact filename/encoding mismatches by converting or renaming the JPEG-backed `.png` files in `artifacts/ash15/` and `artifacts/ash16/`.
3. Re-run export dry run on the committed preset.
4. Record install/run results on the first target surface.
5. Run touch/readability smoke on device before any demo-ready claim.

## Evidence Summary

- `godot4` version available locally: `4.6.2.stable.official.71f334935`
- `export_presets.cfg`: missing
- export template directory under macOS user data: not present in this workspace check
- invalid image-extension set: `ash15` portrait sheets and `ash16` icon sheet

## Recommendation

Open a narrow follow-up tranche for export setup only:

- add Android-first export presets
- clean the four mislabeled art files
- capture the first successful package command in-repo

Do not mix this with save/load, release automation, or broader architecture refactors.
