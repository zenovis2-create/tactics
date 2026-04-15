# Battle Art Audit

## Scope

- Root: `/Volumes/AI/tactics`
- Purpose: enumerate current battle art replacement groups and their runtime integration points.

## Groups

### `button_icons`

- Path: `/Volumes/AI/tactics/assets/ui/icons_generated`
- Exists: `True`
- File count: `4`
- Production override path: `/Volumes/AI/tactics/assets/ui/production/button_icons`
- Production override count: `0`
- Files:
  - `back.png`
  - `bag.png`
  - `enemy.png`
  - `wait.png`
- Effective source:
  - `back.png` -> `generated`
  - `bag.png` -> `generated`
  - `enemy.png` -> `generated`
  - `wait.png` -> `generated`
- Runtime integration:
  - `/Volumes/AI/tactics/scripts/battle/battle_hud.gd`
  - `/Volumes/AI/tactics/scenes/battle/BattleHUD.tscn`
  - `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

### `object_icons`

- Path: `/Volumes/AI/tactics/assets/ui/object_icons_generated`
- Exists: `True`
- File count: `4`
- Production override path: `/Volumes/AI/tactics/assets/ui/production/object_icons`
- Production override count: `0`
- Files:
  - `altar.png`
  - `chest.png`
  - `gate.png`
  - `lever.png`
- Effective source:
  - `altar.png` -> `generated`
  - `chest.png` -> `generated`
  - `gate.png` -> `generated`
  - `lever.png` -> `generated`
- Runtime integration:
  - `/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd`
  - `/Volumes/AI/tactics/scenes/battle/InteractiveObject.tscn`
  - `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

### `unit_role_icons`

- Path: `/Volumes/AI/tactics/assets/ui/unit_role_icons_generated`
- Exists: `True`
- File count: `6`
- Production override path: `/Volumes/AI/tactics/assets/ui/production/unit_role_icons`
- Production override count: `0`
- Files:
  - `boss.png`
  - `knight.png`
  - `medic.png`
  - `mystic.png`
  - `ranger.png`
  - `vanguard.png`
- Effective source:
  - `boss.png` -> `generated`
  - `knight.png` -> `generated`
  - `medic.png` -> `generated`
  - `mystic.png` -> `generated`
  - `ranger.png` -> `generated`
  - `vanguard.png` -> `generated`
- Runtime integration:
  - `/Volumes/AI/tactics/scripts/battle/unit_actor.gd`
  - `/Volumes/AI/tactics/scenes/battle/Unit.tscn`
  - `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

### `unit_token_art`

- Path: `/Volumes/AI/tactics/assets/ui/unit_token_art_generated`
- Exists: `True`
- File count: `6`
- Production override path: `/Volumes/AI/tactics/assets/ui/production/unit_token_art`
- Production override count: `0`
- Files:
  - `boss.png`
  - `knight.png`
  - `medic.png`
  - `mystic.png`
  - `ranger.png`
  - `vanguard.png`
- Effective source:
  - `boss.png` -> `generated`
  - `knight.png` -> `generated`
  - `medic.png` -> `generated`
  - `mystic.png` -> `generated`
  - `ranger.png` -> `generated`
  - `vanguard.png` -> `generated`
- Runtime integration:
  - `/Volumes/AI/tactics/scripts/battle/unit_actor.gd`
  - `/Volumes/AI/tactics/scenes/battle/Unit.tscn`
  - `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

### `tile_icons`

- Path: `/Volumes/AI/tactics/assets/ui/tile_icons_generated`
- Exists: `True`
- File count: `7`
- Production override path: `/Volumes/AI/tactics/assets/ui/production/tile_icons`
- Production override count: `0`
- Files:
  - `battery.png`
  - `bell.png`
  - `bridge.png`
  - `cathedral.png`
  - `forest.png`
  - `highground.png`
  - `wall.png`
- Effective source:
  - `battery.png` -> `generated`
  - `bell.png` -> `generated`
  - `bridge.png` -> `generated`
  - `cathedral.png` -> `generated`
  - `forest.png` -> `generated`
  - `highground.png` -> `generated`
  - `wall.png` -> `generated`
- Runtime integration:
  - `/Volumes/AI/tactics/scripts/battle/battle_board.gd`
  - `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

### `tile_cards`

- Path: `/Volumes/AI/tactics/assets/ui/tile_cards_generated`
- Exists: `True`
- File count: `7`
- Production override path: `/Volumes/AI/tactics/assets/ui/production/tile_cards`
- Production override count: `0`
- Files:
  - `battery.png`
  - `bell.png`
  - `bridge.png`
  - `forest.png`
  - `highground.png`
  - `plain.png`
  - `wall.png`
- Effective source:
  - `battery.png` -> `generated`
  - `bell.png` -> `generated`
  - `bridge.png` -> `generated`
  - `forest.png` -> `generated`
  - `highground.png` -> `generated`
  - `plain.png` -> `generated`
  - `wall.png` -> `generated`
- Runtime integration:
  - `/Volumes/AI/tactics/scripts/battle/battle_board.gd`
  - `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

### `fx`

- Path: `/Volumes/AI/tactics/assets/ui/fx_generated`
- Exists: `True`
- File count: `3`
- Production override path: `/Volumes/AI/tactics/assets/ui/production/fx`
- Production override count: `0`
- Files:
  - `hit_spark.png`
  - `mark_ring.png`
  - `objective_burst.png`
- Effective source:
  - `hit_spark.png` -> `generated`
  - `mark_ring.png` -> `generated`
  - `objective_burst.png` -> `generated`
- Runtime integration:
  - `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`
  - `/Volumes/AI/tactics/scenes/battle/BattleScene.tscn`
  - `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

## Recommended First Replacement Sprint

1. `unit_token_art` and `unit_role_icons`
2. `object_icons`
3. `fx`

## Verification

- `scripts/dev/check_runnable_gate0.sh`
- `scripts/dev/m1_playtest_runner.gd`
- `scripts/dev/m3_ui_runner.gd`
- `scripts/dev/render_representative_snapshots.sh`

