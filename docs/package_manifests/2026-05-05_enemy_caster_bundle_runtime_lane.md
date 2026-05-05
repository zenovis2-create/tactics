# Enemy Caster Bundle Runtime Lane — 2026-05-05 17:09 KST

## Decision

The Agency specialists recommended closing the current main dirty enemy caster runtime asset lane before importing UI/recovery worktree assets.

This lane packages prototype v02.1 runtime sprite bundles for:

- Hes
- Resin Warden
- Ash Archivist

## Included boundary

- `assets/characters/sprite_anchor_enemy_hes/**`
- `assets/characters/sprite_anchor_enemy_resin_warden/**`
- `assets/characters/sprite_anchor_enemy_ash_archivist/**`
- `docs/package_manifests/2026-05-05_enemy_caster_bundle_runtime_lane.md`

The catalog aliases and focused runner already exist in tracked project files:

- `scripts/battle/battle_art_catalog.gd`
- `scripts/dev/enemy_caster_bundle_sprite_runtime_runner.gd`

## Excluded from this lane

- UI production/tile card recovery
- environment surface assets
- broad recovery worktree contents
- signing/codesign/notarization custody
- stash cleanup

## Static evidence

After Godot import sidecar generation, each anchor has a coherent runtime/source/contract shape:

- enemy_hes: total 1014, PNG 506, `.png.import` 506, JSON 2
- enemy_resin_warden: total 1014, PNG 506, `.png.import` 506, JSON 2
- enemy_ash_archivist: total 1014, PNG 506, `.png.import` 506, JSON 2

Runtime contract pattern:

- `direction_set`: `diagonal_4`
- states: `idle`, `move`, `attack`, `cast`, `hit`, `guard`, `defeat`
- flat state frames: 8 PNG per state
- facing frames: 4 facings x 16 frames per state

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/enemy_caster_bundle_sprite_runtime_runner.gd
git diff --check
```

Result:

```text
caster_exit=0
[PASS] enemy_caster_bundle_sprite_runtime_runner validated Hes/Resin Warden/Ash Archivist prototype v02.1 sprite runtimes.
```

## Risk note

This is a prototype runtime package. Contract generation metadata marks back views as temporary derived placeholders pending live back-view image generation. Treat as internal runtime readiness, not final public art certification.

Staging must remain explicit and allowlisted. Do not use broad `git add .`, `git add -A`, or `git add assets/`.
