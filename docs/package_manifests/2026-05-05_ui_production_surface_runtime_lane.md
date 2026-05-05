# UI Production Surface Runtime Lane — 2026-05-05 20:27 KST

## Decision

The Agency specialists classified the current dirty UI production surface set as a coherent package lane, with unrelated files split out.

This lane normalizes and promotes production UI surfaces:

- tile cards: 25 PNG, 48x48 RGBA
- tile icons: 25 PNG, 24x24 RGBA
- object icons: 17 PNG, RGBA, 40x40 or 256x256
- generated object icon promotion: `command_obelisk`

## Included boundary

- `assets/ui/production/tile_cards/*.png` dirty production surface updates
- `assets/ui/production/tile_icons/*.png` and `.png.import` dirty/new production tile icons
- `assets/ui/production/object_icons/*.png` and `.png.import` dirty/new object icon updates
- `assets/ui/production/ui_production_surfaces_v02_1_manifest.json`
- `scripts/dev/build_ui_production_surface_runtime_package.py`
- `scripts/dev/check_ui_production_surface_contract.py`
- `scripts/dev/ui_production_surface_runtime_runner.gd`
- `scripts/dev/ui_production_surface_runtime_runner.gd.uid`
- `docs/package_manifests/2026-05-05_ui_production_surface_runtime_lane.md`

## Excluded from this lane

- `scripts/dev/character_facing_sprite_runtime_runner.gd.uid` — separate UID follow-up
- `docs/reviews/2026-05-05-f99-ending-criteria-ui-runner-only-qa-scout.md` — separate f99 QA doc lane
- broad recovery worktree imports
- battle_board/story terrain code mapping
- signing/codesign/notarization custody

## Validation

Executed before staging:

```bash
tmp/asset_forge_venv/bin/python scripts/dev/check_ui_production_surface_contract.py
python3 -m py_compile scripts/dev/build_ui_production_surface_runtime_package.py scripts/dev/check_ui_production_surface_contract.py
godot --headless --path . --script scripts/dev/ui_production_surface_runtime_runner.gd
python3 PNG header dimension check
git diff --check -- assets/ui/production scripts/dev/build_ui_production_surface_runtime_package.py scripts/dev/check_ui_production_surface_contract.py scripts/dev/ui_production_surface_runtime_runner.gd
```

Results:

```text
[PASS] ui production surface contract validated.
[PASS] ui_production_surface_runtime_runner validated production UI surface runtime loading.
tile_cards 25 all 48x48
tile_icons 25 all 24x24
object_icons 17 valid
git diff --check=PASS
```

## Risk note

This is internal runtime/package readiness, not final visual art certification. The Python contract checker requires Pillow; use `tmp/asset_forge_venv/bin/python` for reproducible validation in the current environment.
