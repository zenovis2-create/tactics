# Export Platform Checklist v1

## Purpose

This checklist defines the smallest reproducible path from the current runnable Godot project to a real platform validation pass.

It is scoped for the current demo candidate lane:

- preserve the existing save-free runtime slice
- validate export assumptions
- record hard blockers early

## Target Order

1. Android first
2. Desktop packaging sanity check second
3. iOS only after Android is stable

## Gate Before Export Work

These must stay green before every export attempt:

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --quit`
- `godot4 --headless --path . --script res://scripts/dev/m1_core_loop_contract_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`

## Pre-Export Repo Checklist

- `export_presets.cfg` exists at repo root and is committed
- preset names and output paths are stable and documented
- no referenced `res://` assets fail import during editor reimport
- version/name/app id fields are filled in for the chosen target
- export artifacts are ignored or routed outside the repo working tree

## Known Current Blockers

- matching Godot `4.6.2.stable` export templates are not installed on the current macOS host
- no first successful packaged desktop artifact has been recorded yet
- Android export remains intentionally deferred until the desktop preset path and host template install are confirmed

## Android First-Pass Checklist

- create a committed Android export preset
- choose APK or AAB intentionally and document the reason
- confirm package identifier, version name, and version code
- confirm export succeeds from CLI
- install on one Android test device
- verify app boots to `Main.tscn`
- verify one full Chapter 1 flow is still playable on device
- verify touch targets remain usable in battle and camp
- verify text remains readable on the target device density
- record any performance or input regressions in `docs/reviews/`

Suggested validation commands after preset exists:

- `godot4 --headless --path . --export-debug "Android" <output.apk-or-aab>`
- `godot4 --headless --path . --export-release "Android" <output.apk-or-aab>`

## Desktop Packaging Sanity Check

Desktop packaging is not the primary shipping target, but it is useful as a packaging sanity pass once presets exist.

- create one desktop preset intentionally
- export once from CLI
- boot exported build locally
- confirm battle -> camp handoff still works outside editor

Suggested validation commands after preset exists:

- `godot4 --headless --path . --export-release "Linux/X11" <output>`
- or the equivalent preset name chosen for the committed desktop target

## iOS Deferred Checklist

Do not open this until Android is green.

- confirm macOS + Xcode signing environment
- commit iOS preset intentionally
- define bundle id and signing expectations
- export successfully
- run on one real iOS device
- verify touch/readability/session-completion smoke

## Evidence To Record After Each Attempt

- exact command used
- preset name used
- output artifact path
- success or failure
- import/export errors verbatim
- target device or host used
- gameplay smoke result

## Exit Criteria For Export Validation v1

Export/platform validation can be called green only when all of the following are true:

- committed `export_presets.cfg` exists
- artifact import mismatches are fixed
- one Android export command succeeds
- one package boots on a target device
- one touch/readability smoke pass is recorded
- the result is written to `docs/reviews/`
