# Object Interaction Animation Runtime Lane — 2026-05-05 KST

## Decision

This lane packages object interaction animation runtime assets and actor playback after the animated FX lane established the shared texture-loading helper.

## Included boundary

- `assets/objects/**`
- `scripts/dev/build_object_interaction_runtime_package.py`
- `scripts/dev/object_interaction_animation_runner.gd`
- `scripts/dev/object_interaction_animation_runner.gd.uid`
- `scripts/battle/interactive_object_actor.gd`
- object-only loader hunk in `scripts/battle/battle_art_catalog.gd`
- `docs/package_manifests/2026-05-05_object_interaction_animation_lane.md`

## Excluded from this lane

- `assets/equipment_overlays/**`
- equipment overlay unit actor changes
- equipment loader hunk in `scripts/battle/battle_art_catalog.gd`
- unrelated `docs/api_tooling/**` and `scripts/dev/public_api_visual_tools.py`
- signing/codesign/notarization custody

## Static evidence

```text
objects_total 561 png 272 import 272 json 17
```

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/object_interaction_animation_runner.gd
python3 -m py_compile scripts/dev/build_object_interaction_runtime_package.py
git diff --check -- assets/objects scripts/dev/build_object_interaction_runtime_package.py scripts/dev/object_interaction_animation_runner.gd scripts/battle/interactive_object_actor.gd scripts/battle/battle_art_catalog.gd
```

Result:

```text
[PASS] object_interaction_animation_runner validated imagegen object frames and actor playback.
py_compile=PASS
git diff --check=PASS
```
