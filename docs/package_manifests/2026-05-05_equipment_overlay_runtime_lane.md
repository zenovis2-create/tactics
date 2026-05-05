# Equipment Overlay Runtime Lane — 2026-05-05 KST

## Decision

This lane packages equipment overlay runtime assets and UnitActor overlay layering after FX/object lanes committed the shared catalog helper and object/FX loaders.

## Included boundary

- `assets/equipment_overlays/**`
- `scripts/dev/build_equipment_overlay_runtime_package.py`
- `scripts/dev/equipment_overlay_runtime_runner.gd`
- `scripts/dev/equipment_overlay_runtime_runner.gd.uid`
- `scripts/battle/unit_actor.gd`
- equipment-only loader hunk in `scripts/battle/battle_art_catalog.gd`
- `docs/package_manifests/2026-05-05_equipment_overlay_runtime_lane.md`

## Excluded from this lane

- unrelated `docs/api_tooling/**`
- unrelated `scripts/dev/public_api_visual_tools.py`
- recovery worktree broad imports
- signing/codesign/notarization custody

## Static evidence

```text
equipment_total 281 png 136 import 136 json 9
```

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/equipment_overlay_runtime_runner.gd
python3 -m py_compile scripts/dev/build_equipment_overlay_runtime_package.py
git diff --check -- assets/equipment_overlays scripts/dev/build_equipment_overlay_runtime_package.py scripts/dev/equipment_overlay_runtime_runner.gd scripts/battle/unit_actor.gd scripts/battle/battle_art_catalog.gd
```

Result:

```text
[PASS] equipment_overlay_runtime_runner validated imagegen equipment overlays and UnitActor layering.
py_compile=PASS
git diff --check=PASS
```

## Risk note

This is internal runtime/package readiness. It changes UnitActor layering by adding weapon/armor/accessory overlay AnimatedSprite2D nodes, so broader combat visual QA remains recommended before public release.
