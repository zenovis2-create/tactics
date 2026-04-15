# Battle Art Production Override Guide

## Purpose

This folder is the production override target for battle UI and battle-scene art.

The runtime now prefers files in these `production/` subfolders first.
If a production asset is missing, the game falls back to the generated placeholder asset in the legacy generated folders.

That means:
- you do not need to replace generated files directly
- you can drop final art into the production folders with the same filename
- the game will pick the production version automatically

## Folders

### `button_icons/`

Used by:
- `scripts/battle/battle_hud.gd`
- `scenes/battle/BattleHUD.tscn`

Expected files:
- `bag.png`
- `back.png`
- `wait.png`
- `enemy.png`

Suggested size:
- `32x32`

### `object_icons/`

Used by:
- `scripts/battle/interactive_object_actor.gd`
- `scenes/battle/InteractiveObject.tscn`

Expected files:
- `chest.png`
- `lever.png`
- `altar.png`
- `gate.png`

Suggested size:
- `40x40`

### `unit_role_icons/`

Used by:
- `scripts/battle/unit_actor.gd`
- `scenes/battle/Unit.tscn`

Expected files:
- `knight.png`
- `ranger.png`
- `mystic.png`
- `vanguard.png`
- `medic.png`
- `boss.png`

Suggested size:
- `28x28`

### `unit_token_art/`

Used by:
- `scripts/battle/unit_actor.gd`
- `scenes/battle/Unit.tscn`

Expected files:
- `knight.png`
- `ranger.png`
- `mystic.png`
- `vanguard.png`
- `medic.png`
- `boss.png`

Suggested size:
- `48x48`

### `tile_icons/`

Used by:
- `scripts/battle/battle_board.gd`

Current expected files:
- `forest.png`
- `wall.png`
- `bridge.png`
- `highground.png`
- `battery.png`
- `cathedral.png`
- `bell.png`

Suggested size:
- `24x24`

### `tile_cards/`

Used by:
- `scripts/battle/battle_board.gd`

Current expected files:
- `plain.png`
- `forest.png`
- `wall.png`
- `bridge.png`
- `highground.png`
- `battery.png`
- `bell.png`

Suggested size:
- `48x48`

### `fx/`

Used by:
- `scripts/battle/battle_controller.gd`
- `scenes/battle/BattleScene.tscn`

Expected files:
- `hit_spark.png`
- `mark_ring.png`
- `objective_burst.png`

Suggested size:
- `64x64`

## Rules

### Naming

- Keep the exact filenames above.
- The loader matches by filename, not by metadata.

### Format

- PNG
- Transparent background where applicable

### Readability

- These assets are used at small gameplay scale.
- Favor bold silhouette and strong contrast over fine detail.

### Scope

- Do not add new runtime asset names unless the code is updated with intention.
- Replace existing slots first.

## Verification

After adding any production asset batch, run:

- `/Volumes/AI/tactics/scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd`
- `/Volumes/AI/tactics/scripts/dev/render_representative_snapshots.sh /Volumes/AI/tactics/.codex-representative-snaps`

## Related Docs

- `/Volumes/AI/tactics/docs/plans/2026-04-14-art-replacement-priority.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-14-art-production-briefs.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-14-artist-handoff-onepager.md`
- `/Volumes/AI/tactics/docs/production/battle_art_manifest_v1.json`
- `/Volumes/AI/tactics/docs/production/battle_art_replacement_checklist_v1.md`
