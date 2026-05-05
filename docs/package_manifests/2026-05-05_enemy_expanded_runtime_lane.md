# Enemy Expanded Runtime Sprite Lane — 2026-05-05 19:23 KST

## Decision

The Agency specialists recommended closing the current main dirty enemy runtime lane before importing UI/recovery worktree assets.

This lane packages v02.1 runtime sprite bundles and enemy-only catalog/gallery/runner wiring for:

- Barten / Varten
- Hardren Captain
- Roderic
- Valgar / Valgar II
- Enemy Melkion
- Enemy Kyle
- Enemy Lete
- Final Karuon
- Saria II alias fallback
- Karuon variant fallback

## Included boundary

- `assets/characters/sprite_anchor_enemy_barten/**`
- `assets/characters/sprite_anchor_enemy_hardren_captain/**`
- `assets/characters/sprite_anchor_enemy_karuon_final/**`
- `assets/characters/sprite_anchor_enemy_kyle/**`
- `assets/characters/sprite_anchor_enemy_lete/**`
- `assets/characters/sprite_anchor_enemy_melkion/**`
- `assets/characters/sprite_anchor_enemy_roderic/**`
- `assets/characters/sprite_anchor_enemy_valgar/**`
- enemy-only hunk of `scripts/battle/battle_art_catalog.gd`
- `scripts/dev/build_sprite_bundle_runtime_package.py`
- `scripts/dev/battle_sprite_roster_gallery.gd`
- `scripts/dev/battle_sprite_roster_gallery_runner.gd`
- `scripts/dev/karuon_melkion_sprite_runtime_runner.gd`
- `scripts/dev/lete_sprite_runtime_runner.gd`
- `scripts/dev/support_trio_sprite_runtime_runner.gd`
- `scripts/dev/enemy_core_bundle_sprite_runtime_runner.gd`
- `scripts/dev/enemy_core_bundle_sprite_runtime_runner.gd.uid`
- `scripts/dev/enemy_late_bundle_sprite_runtime_runner.gd`
- `scripts/dev/enemy_late_bundle_sprite_runtime_runner.gd.uid`
- `scripts/dev/enemy_variant_alias_runner.gd`
- `scripts/dev/enemy_variant_alias_runner.gd.uid`
- `scripts/dev/enemy_variant_bundle_sprite_runtime_runner.gd`
- `scripts/dev/enemy_variant_bundle_sprite_runtime_runner.gd.uid`
- `docs/package_manifests/2026-05-05_enemy_expanded_runtime_lane.md`

## Excluded from this lane

- `assets/fx/**`
- `assets/objects/**`
- `scripts/battle/battle_controller.gd`
- `scripts/battle/interactive_object_actor.gd`
- FX/object loader hunks from `scripts/battle/battle_art_catalog.gd`
- UI production/tile card recovery
- broad recovery worktree contents
- signing/codesign/notarization custody
- stash cleanup

## Static evidence

Each new enemy anchor has the same coherent runtime/source/contract shape:

- total files: 1014
- PNG: 506
- `.png.import`: 506
- JSON: 2

Runtime contract pattern:

- `direction_set`: `diagonal_4`
- states: `idle`, `move`, `attack`, `cast`, `hit`, `guard`, `defeat`
- flat state frames: 8 PNG per state
- facing frames: 4 facings x 16 frames per state

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/enemy_core_bundle_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/enemy_late_bundle_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/enemy_variant_bundle_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/enemy_variant_alias_runner.gd
godot --headless --path . --script scripts/dev/karuon_melkion_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/lete_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/support_trio_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/battle_sprite_roster_gallery_runner.gd
git diff --check
```

Results:

```text
enemy_core_bundle_sprite_runtime_runner=PASS
enemy_late_bundle_sprite_runtime_runner=PASS
enemy_variant_bundle_sprite_runtime_runner=PASS
enemy_variant_alias_runner=PASS
karuon_melkion_sprite_runtime_runner=PASS
lete_sprite_runtime_runner=PASS
support_trio_sprite_runtime_runner=PASS
battle_sprite_roster_gallery_runner=PASS
```

## Risk note

This lane is internal runtime/package readiness only. Some generated bundle contracts describe derived or placeholder back-facing frames. Do not treat this as final public art certification.

`battle_art_catalog.gd` is mixed with FX/object loader hunks in the working tree, so this lane stages only enemy alias/map changes from that file.
