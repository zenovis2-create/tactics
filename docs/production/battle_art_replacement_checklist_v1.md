# Battle Art Replacement Checklist

Use this to track which generated battle assets have been replaced by production overrides.

## Status

### `button_icons`

- Generated count: `4`
- Production replaced: `0`
- Production dir: `/Volumes/AI/tactics/assets/ui/production/button_icons`

- [ ] `back.png`
- [ ] `bag.png`
- [ ] `enemy.png`
- [ ] `wait.png`

### `object_icons`

- Generated count: `4`
- Production replaced: `0`
- Production dir: `/Volumes/AI/tactics/assets/ui/production/object_icons`

- [ ] `altar.png`
- [ ] `chest.png`
- [ ] `gate.png`
- [ ] `lever.png`

### `unit_role_icons`

- Generated count: `6`
- Production replaced: `0`
- Production dir: `/Volumes/AI/tactics/assets/ui/production/unit_role_icons`

- [ ] `boss.png`
- [ ] `knight.png`
- [ ] `medic.png`
- [ ] `mystic.png`
- [ ] `ranger.png`
- [ ] `vanguard.png`

### `unit_token_art`

- Generated count: `6`
- Production replaced: `0`
- Production dir: `/Volumes/AI/tactics/assets/ui/production/unit_token_art`

- [ ] `boss.png`
- [ ] `knight.png`
- [ ] `medic.png`
- [ ] `mystic.png`
- [ ] `ranger.png`
- [ ] `vanguard.png`

### `tile_icons`

- Generated count: `7`
- Production replaced: `0`
- Production dir: `/Volumes/AI/tactics/assets/ui/production/tile_icons`

- [ ] `battery.png`
- [ ] `bell.png`
- [ ] `bridge.png`
- [ ] `cathedral.png`
- [ ] `forest.png`
- [ ] `highground.png`
- [ ] `wall.png`

### `tile_cards`

- Generated count: `7`
- Production replaced: `0`
- Production dir: `/Volumes/AI/tactics/assets/ui/production/tile_cards`

- [ ] `battery.png`
- [ ] `bell.png`
- [ ] `bridge.png`
- [ ] `forest.png`
- [ ] `highground.png`
- [ ] `plain.png`
- [ ] `wall.png`

### `fx`

- Generated count: `3`
- Production replaced: `0`
- Production dir: `/Volumes/AI/tactics/assets/ui/production/fx`

- [ ] `hit_spark.png`
- [ ] `mark_ring.png`
- [ ] `objective_burst.png`

## Verification After Any Replacement Batch

- `scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd`
- `scripts/dev/render_representative_snapshots.sh /Volumes/AI/tactics/.codex-representative-snaps`

