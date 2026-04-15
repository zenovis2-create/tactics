# Export And Platform Validation Dry Run v3 (2026-04-14)

## Scope

Final follow-up export validation after:

- committing export presets
- normalizing runtime audio placeholder paths
- converting mislabeled image assets to valid PNG files
- installing local Godot export templates

## Commands Run

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --script res://scripts/dev/sfx_trigger_integration_runner.gd`
- `python3 scripts/dev/install_godot_export_templates.py`
- `godot4 --headless --path . --export-release "Linux/X11" build/demo/memory-tactics-demo.x86_64`
- `ls -l build/demo`

## Result

The first desktop demo export succeeded on the current macOS host.

Produced artifacts:

- `/Volumes/AI/tactics/build/demo/memory-tactics-demo.x86_64`
- `/Volumes/AI/tactics/build/demo/memory-tactics-demo.pck`

## Verification Summary

- Gate 0 integrity: pass
- runtime SFX cue routing: pass
- export preset presence: pass
- local export template install: pass
- desktop package generation: pass

## Remaining Notes

- This confirms desktop packaging, not Android install/run validation.
- Save/load remains intentionally frozen and out of scope for the demo candidate.
- Placeholder audio and concept-derived art are still accepted known issues for the current candidate lane.

## Recommendation

- Close the demo-build umbrella as complete.
- Treat the current workspace as an exportable internal desktop demo candidate.
- Open a future Android-first validation tranche only if device packaging is required next.
