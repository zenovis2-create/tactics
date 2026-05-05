# Enemy Infantry Runtime Sprite Lane — 2026-05-05 16:22 KST

## Decision

The Agency specialists recommended handling the current main dirty runtime sprite lanes before pulling more material from the noisy stash recovery worktree.

This lane packages Raider/Skirmisher runtime sprite refresh and the focused enemy infantry validation runner as an atomic internal package slice.

## Included boundary

- `assets/characters/sprite_anchor_enemy_raider/**`
- `assets/characters/sprite_anchor_enemy_skirmisher/**`
- `scripts/battle/battle_art_catalog.gd` alias lines only:
  - `enemy_raider -> sprite_anchor_enemy_raider`
  - `enemy_skirmisher -> sprite_anchor_enemy_skirmisher`
- `scripts/dev/enemy_infantry_sprite_runtime_runner.gd`
- `scripts/dev/enemy_infantry_sprite_runtime_runner.gd.uid`
- `docs/package_manifests/2026-05-05_enemy_infantry_runtime_lane.md`

## Excluded from this lane

- `assets/characters/sprite_anchor_enemy_basil/**`
- `scripts/dev/basil_sprite_runtime_runner.gd`
- Basil catalog aliases
- Basil roster gallery changes
- UI production recovery
- broad stash recovery worktree contents
- signing/codesign/notarization custody

## Counts before staging

- Raider: total 1137, PNG 556, `.png.import` 556, other 25
- Skirmisher: total 1132, PNG 556, `.png.import` 556, other 20
- Missing PNG imports: 0
- Orphan PNG imports: 0

## Validation

Executed before staging with current worktree content:

```bash
godot --headless --path . --script scripts/dev/enemy_infantry_sprite_runtime_runner.gd
```

Result:

```text
enemy_exit=0
[PASS] enemy_infantry_sprite_runtime_runner validated Raider/Skirmisher sprite aliases and Unit visual layers.
```

Also executed:

```bash
git diff --check
```

Result: PASS.

## Risk note

`battle_art_catalog.gd` also contains Basil aliases in the working tree. The index must stage only the Raider/Skirmisher alias lines for this commit. Basil remains a separate follow-up lane.
