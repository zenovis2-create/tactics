# Tile Surface Runtime Lane — 2026-05-05 19:33 KST

## Decision

The Agency specialists recommended closing the current dirty tile surface UI lane before FX/object/equipment lanes and before recovery worktree imports.

This lane promotes imagegen terrain candidates into the production BattleBoard tile card/icon contracts for:

- `forest`
- `wall`

## Included boundary

- `assets/ui/production/tile_cards/forest.png`
- `assets/ui/production/tile_cards/wall.png`
- `assets/ui/production/tile_icons/forest.png`
- `assets/ui/production/tile_icons/wall.png`
- `assets/environment/tile_surface_sources/forest/forest_tile_01_battlefield_candidate_v02.png`
- `assets/environment/tile_surface_sources/forest/forest_tile_01_battlefield_candidate_v02.png.import`
- `assets/environment/tile_surface_sources/wall/fortress_tile_01_candidate_v01.png`
- `assets/environment/tile_surface_sources/wall/fortress_tile_01_candidate_v01.png.import`
- `assets/ui/production/tile_surface_runtime_v02_1_manifest.json`
- `scripts/dev/build_tile_surface_runtime_package.py`
- `scripts/dev/imagegen_tile_surface_runtime_runner.gd`
- `scripts/dev/imagegen_tile_surface_runtime_runner.gd.uid`
- `docs/package_manifests/2026-05-05_tile_surface_runtime_lane.md`

## Excluded from this lane

- `assets/fx/**`
- `assets/objects/**`
- `assets/equipment_overlays/**`
- `scripts/battle/battle_art_catalog.gd`
- `scripts/battle/battle_controller.gd`
- `scripts/battle/interactive_object_actor.gd`
- `scripts/battle/unit_actor.gd`
- UI recovery worktree broad imports
- signing/codesign/notarization custody

## Static evidence

Production output dimensions:

```text
assets/ui/production/tile_cards/forest.png: 48 x 48
assets/ui/production/tile_cards/wall.png: 48 x 48
assets/ui/production/tile_icons/forest.png: 24 x 24
assets/ui/production/tile_icons/wall.png: 24 x 24
```

Source dimensions:

```text
forest_tile_01_battlefield_candidate_v02.png: 1536 x 1024
fortress_tile_01_candidate_v01.png: 1536 x 1024
```

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/imagegen_tile_surface_runtime_runner.gd
python3 -m py_compile scripts/dev/build_tile_surface_runtime_package.py
file assets/ui/production/tile_cards/forest.png assets/ui/production/tile_cards/wall.png assets/ui/production/tile_icons/forest.png assets/ui/production/tile_icons/wall.png
git diff --check -- assets/ui/production/tile_cards assets/ui/production/tile_icons assets/environment/tile_surface_sources assets/ui/production/tile_surface_runtime_v02_1_manifest.json scripts/dev/build_tile_surface_runtime_package.py scripts/dev/imagegen_tile_surface_runtime_runner.gd
```

Results:

```text
[PASS] imagegen_tile_surface_runtime_runner validated production tile surface texture sizes.
py_compile=PASS
git diff --check=PASS
```

## Risk note

`forest.png` and `wall.png` replace existing production UI assets. This is package/runtime readiness, not final visual art sign-off. Visual review can still be run as a later QA lane.
