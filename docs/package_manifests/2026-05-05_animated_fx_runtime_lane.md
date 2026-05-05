# Animated FX Runtime Lane — 2026-05-05 KST

## Decision

The Agency specialists recommended processing remaining current-main dirty lanes before recovery worktree imports. This lane packages animated battle FX runtime assets and battle playback wiring.

## Included boundary

- `assets/fx/**`
- `scripts/dev/build_fx_bundle_runtime_package.py`
- `scripts/dev/animated_fx_runtime_runner.gd`
- `scripts/dev/animated_fx_runtime_runner.gd.uid`
- `scripts/battle/battle_controller.gd`
- FX-only loader hunk in `scripts/battle/battle_art_catalog.gd`
- shared `_load_texture_from_resource_path()` helper in `scripts/battle/battle_art_catalog.gd`
- `docs/package_manifests/2026-05-05_animated_fx_runtime_lane.md`

## Excluded from this lane

- `assets/objects/**`
- `assets/equipment_overlays/**`
- object interaction actor changes
- equipment overlay unit actor changes
- object/equipment loader hunks in `scripts/battle/battle_art_catalog.gd`
- unrelated `docs/api_tooling/**` and `scripts/dev/public_api_visual_tools.py`
- signing/codesign/notarization custody

## Static evidence

FX package totals:

```text
fx_total 176 png 85 import 85 json 6
finale_burst 35 17 17 1
hit_spark 35 17 17 1
mark_ring 35 17 17 1
objective_burst 35 17 17 1
trap_burst 35 17 17 1
```

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/animated_fx_runtime_runner.gd
python3 -m py_compile scripts/dev/build_fx_bundle_runtime_package.py
git diff --check -- assets/fx scripts/dev/build_fx_bundle_runtime_package.py scripts/dev/animated_fx_runtime_runner.gd scripts/battle/battle_controller.gd scripts/battle/battle_art_catalog.gd
```

Result:

```text
[PASS] animated_fx_runtime_runner validated imagegen FX frames and battle world FX playback.
py_compile=PASS
git diff --check=PASS
```

## Risk note

This is internal runtime/package readiness. It changes battle FX playback to prefer animated frames when available, so battle readability should still receive later visual QA.
