# Basil Runtime Sprite Lane — 2026-05-05 16:22 KST

## Decision

After the Raider/Skirmisher enemy infantry slice, Basil is the next current-main runtime sprite lane. The Agency specialists recommended this before `enemy_raider`/UI recovery worktree imports because the boundary is already present in main and has focused validation.

## Included boundary

- `assets/characters/sprite_anchor_enemy_basil/**`
- `scripts/battle/battle_art_catalog.gd` alias lines only:
  - `Basil -> sprite_anchor_enemy_basil`
  - `enemy_basil -> sprite_anchor_enemy_basil`
- `scripts/dev/basil_sprite_runtime_runner.gd`
- `scripts/dev/basil_sprite_runtime_runner.gd.uid`
- `scripts/dev/battle_sprite_roster_gallery.gd`
- `scripts/dev/battle_sprite_roster_gallery_runner.gd`
- `docs/package_manifests/2026-05-05_basil_runtime_lane.md`

## Excluded from this lane

- Raider/Skirmisher asset refresh and enemy infantry runner after they are committed separately
- UI production recovery
- broad stash recovery worktree contents
- signing/codesign/notarization custody

## Counts before staging

- Basil: total 1013, PNG 505, `.png.import` 505, other 3
- Missing PNG imports: 0
- Orphan PNG imports: 0

## Validation

Executed before staging with current worktree content:

```bash
godot --headless --path . --script scripts/dev/basil_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/battle_sprite_roster_gallery_runner.gd
```

Results:

```text
basil_exit=0
[PASS] basil_sprite_runtime_runner validated Basil sprite catalog aliases and Unit visual layer.

gallery_exit=0
[PASS] battle_sprite_roster_gallery_runner validated ally/enemy roster gallery loading.
```

Also executed:

```bash
git diff --check
```

Result: PASS.

## Risk note

`battle_art_catalog.gd` shares one hunk with Raider/Skirmisher aliases. This lane must stage only the Basil alias lines after the enemy infantry lane is committed.
