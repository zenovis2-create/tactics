# Support Trio Runtime Sprite Lane — 2026-05-05 16:47 KST

## Decision

The Agency specialists recommended closing the current main dirty Enoch/Kyle/Noah runtime sprite lane before importing UI/recovery worktree assets.

This lane packages the v02.1 runtime sprite assets and runtime wiring for the support trio: Enoch, Kyle, and Noah.

## Included boundary

- `assets/characters/sprite_anchor_enoch/**`
- `assets/characters/sprite_anchor_kyle/**`
- `assets/characters/sprite_anchor_noah/**`
- `scripts/battle/battle_art_catalog.gd`
- `scripts/dev/support_trio_sprite_runtime_runner.gd`
- `scripts/dev/support_trio_sprite_runtime_runner.gd.uid`
- `scripts/dev/battle_sprite_roster_gallery.gd`
- `scripts/dev/battle_sprite_roster_gallery_runner.gd`
- `docs/package_manifests/2026-05-05_support_trio_runtime_lane.md`

## Excluded from this lane

- UI production/tile card recovery
- environment surface assets
- broad recovery worktree contents
- signing/codesign/notarization custody
- stash cleanup

## Static evidence

After Godot import sidecar generation, each support-trio anchor has the same coherent shape:

- Enoch: total 1013, PNG 505, `.png.import` 505, other 3
- Kyle: total 1013, PNG 505, `.png.import` 505, other 3
- Noah: total 1013, PNG 505, `.png.import` 505, other 3

Runtime contract pattern:

- `direction_set`: `diagonal_4`
- states: `idle`, `move`, `attack`, `cast`, `hit`, `guard`, `defeat`
- flat state frames: 8 PNG per state
- facing frames: 4 facings x 16 frames per state

## Runtime wiring

`battle_art_catalog.gd` adds support-trio aliases:

- `Enoch`, `ally_enoch` -> `sprite_anchor_enoch`
- `Kyle`, `ally_kyle`, `ally_karl`, `enemy_kyle_1`, `enemy_karl_1` -> `sprite_anchor_kyle`
- `Noah`, `ally_noah` -> `sprite_anchor_noah`

`battle_sprite_roster_gallery.gd` adds Enoch/Kyle/Noah preview entries and updates gallery layout/count.

## Validation

Executed before staging with current worktree content:

```bash
godot --headless --path . --script scripts/dev/support_trio_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/battle_sprite_roster_gallery_runner.gd
godot --headless --path . --script scripts/dev/ally_battle_sprite_runner.gd
git diff --check
```

Results:

```text
support_exit=0
[PASS] support_trio_sprite_runtime_runner validated Enoch/Kyle/Noah v02.1 sprite runtimes.

gallery_exit=0
[PASS] battle_sprite_roster_gallery_runner validated ally/enemy roster gallery loading.

ally_exit=0
[PASS] ally_battle_sprite_runner validated ally sprite-first frame resolution.
```

## Risk note

The package contains many PNG and `.png.import` files. Staging must remain explicit and allowlisted. Do not use broad `git add .`, `git add -A`, or `git add assets/`.
