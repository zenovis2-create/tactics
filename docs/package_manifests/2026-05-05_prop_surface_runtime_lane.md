# Prop Surface Runtime Lane — 2026-05-05 20:06 KST

## Decision

The Agency specialists recommended closing the current dirty prop surface lane before returning to the noisy recovery worktree. This lane packages v02.1 prop surface assets for:

- `altar_01`
- `paladin_shield`

## Included boundary

- `assets/props/altar_01/runtime/altar_01_clean_v01.png`
- `assets/props/altar_01/runtime/altar_01_integration_v01.png`
- `assets/props/altar_01/runtime/altar_01_object_icon_v01.png`
- `assets/props/altar_01/source/altar_01_battlefield_candidate_v02.png`
- `assets/props/altar_01/source/altar_01_battlefield_candidate_v02.png.import`
- `assets/props/paladin_shield/runtime/paladin_shield_clean_v01.png`
- `assets/props/paladin_shield/runtime/paladin_shield_equipment_v01.png`
- `assets/props/paladin_shield/runtime/paladin_shield_icon_v01.png`
- `assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png`
- `assets/props/paladin_shield/source/paladin_shield_candidate_v02.png`
- `assets/props/paladin_shield/source/paladin_shield_candidate_v02.png.import`
- `assets/props/prop_surfaces_runtime_v02_1_manifest.json`
- `assets/ui/production/object_icons/altar.png`
- `assets/ui/production/object_icons/paladin_shield.png`
- `assets/ui/production/object_icons/paladin_shield.png.import`
- `scripts/dev/build_prop_surface_runtime_package.py`
- `scripts/dev/imagegen_prop_surface_runtime_runner.gd`
- `scripts/dev/imagegen_prop_surface_runtime_runner.gd.uid`
- `docs/package_manifests/2026-05-05_prop_surface_runtime_lane.md`

## Excluded from this lane

- broad `assets/props/**`
- existing unrelated prop clean/source/spec files
- recovery worktree broad imports
- signing/codesign/notarization custody

## Static evidence

```text
altar source: 1536x1024
altar runtime clean/integration: 1536x1024
altar runtime icon: 256x256
paladin_shield source: 1536x1024
paladin_shield runtime clean/equipment/integration: 1536x1024
paladin_shield runtime icon: 256x256
production object icons: 256x256
manifest_assets: 2
```

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/imagegen_prop_surface_runtime_runner.gd
python3 -m py_compile scripts/dev/build_prop_surface_runtime_package.py
tmp/asset_forge_venv/bin/python -c 'import PIL; print(PIL.__version__)'
git diff --check -- assets/props assets/ui/production/object_icons scripts/dev/build_prop_surface_runtime_package.py scripts/dev/imagegen_prop_surface_runtime_runner.gd
```

Result:

```text
[PASS] imagegen_prop_surface_runtime_runner validated prop surfaces and production object icons.
venv_pillow=PASS 12.2.0
py_compile=PASS
git diff --check=PASS
```

## Risk note

This is internal runtime/package readiness, not final visual art certification. The builder requires Pillow; the project-local `tmp/asset_forge_venv/bin/python` currently has Pillow 12.2.0, while the system Python may not.
