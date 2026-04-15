# Export And Platform Validation Dry Run v2 (2026-04-14)

## Scope

Follow-up export validation after the desktop export setup pass.

In scope:

- committed export preset presence
- packaging blocker cleanup for artifact imports
- one desktop export probe from the current macOS workstation
- explicit identification of the next environment-side blocker

Out of scope:

- Android packaging
- signing or notarization
- save/load
- release automation

## Commands Run

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --script res://scripts/dev/sfx_trigger_integration_runner.gd`
- `godot4 --headless --path . --export-release "Linux/X11" build/demo/memory-tactics-demo.x86_64`
- `file artifacts/ash15/* artifacts/ash16/*`

## Result

The export lane is **configuration-ready but host-template blocked**.

What passed:

- `export_presets.cfg` now exists at repo root
- Gate 0 is green after audio-manifest cleanup
- runtime SFX cue routing remains green after manifest path normalization
- the previously mislabeled `ash15` and `ash16` `.png` assets are now real PNG files
- the export preset parses and reaches the export-template lookup phase

What failed:

- the desktop export still stops before package creation because the local machine does not have the Godot 4.6.2 Linux export templates installed

## Findings

### 1. The primary repository blockers are cleared

The current repo now includes source-controlled export configuration:

- `/Volumes/AI/tactics/export_presets.cfg`

The previous packaging-time art blocker is also removed:

- `artifacts/ash15/ash15_portrait_sheet.png`
- `artifacts/ash15/ash15_portrait_sheet_v2.png`
- `artifacts/ash15/ash15_portrait_sheet_v3.png`
- `artifacts/ash16/ash16_equipment_icon_sheet_v1.png`

These files are now valid PNG data rather than JPEG-backed files with a `.png` suffix.

### 2. Audio manifest drift was also a latent export blocker

Gate 0 initially failed because the placeholder SFX manifest still referenced:

- `res://assets/audio/sfx/placeholders/...`

The runtime now consistently points at:

- `res://audio/sfx/*.wav`

That change restored:

- Gate 0 integrity
- runtime cue-routing validation

### 3. The remaining export blocker is environmental, not repository-side

The export probe now fails at template lookup, not at preset parsing:

- expected template path:
  `/Users/daehan/Library/Application Support/Godot/export_templates/4.6.2.stable/`

This is the correct next blocker for the current host:

- install matching Godot export templates
- rerun the desktop export probe
- only then decide whether Android export setup is next or still deferred

## Dry-Run Verdict

Current candidate status:

- runtime-ready evidence: green
- export-configuration evidence: green
- local package creation evidence: red

This repo is now ready for a host-template install and a second export attempt.
It is not yet an actually packaged demo build from the current workstation.

## Immediate Next Step

1. Install Godot `4.6.2.stable` export templates on the macOS host.
2. Re-run:
   - `godot4 --headless --path . --export-release "Linux/X11" build/demo/memory-tactics-demo.x86_64`
3. Record the first successful packaged artifact path in-repo.

## Recommendation

Close the repository-side export setup task.

Keep the demo-build umbrella open until the host template dependency is satisfied and one real export artifact is produced.
