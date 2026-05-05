# Character Facing Sprite Runtime Lane — 2026-05-05 20:15 KST

## Decision

The Agency specialists classified the current dirty character-facing runtime lane as a coherent, code-only runtime selection boundary.

This lane adds 4-facing sprite frame lookup and UnitActor runtime selection while preserving flat 8-frame compatibility fallback.

## Included boundary

- `scripts/battle/battle_art_catalog.gd`
- `scripts/battle/unit_actor.gd`
- `scripts/dev/character_facing_sprite_runtime_runner.gd`
- `docs/package_manifests/2026-05-05_character_facing_sprite_runtime_lane.md`

## Behavior

- Adds `BattleArtCatalog.load_character_sprite_facing_frames(unit_name, state, facing)`.
- Loads facing frames from:
  - `assets/characters/<anchor>/runtime/facing_frames/<state>/<facing>/*.png`
- UnitActor keeps flat frame compatibility at setup.
- On movement/attack direction, UnitActor switches to 4-facing frame sets when available.
- If facing frames are unavailable, UnitActor falls back to existing flat runtime frames.

## Validation

Executed before staging:

```bash
godot --headless --path . --script scripts/dev/character_facing_sprite_runtime_runner.gd
python3 Rian facing asset count check
git diff --check -- scripts/battle/battle_art_catalog.gd scripts/battle/unit_actor.gd scripts/dev/character_facing_sprite_runtime_runner.gd
```

Results:

```text
[PASS] character_facing_sprite_runtime_runner validated in-game 4-facing 16-frame sprite selection.
rian_facing_assets=PASS
git diff --check=PASS
```

## Risk note

The runner validates Rian flat compatibility, 4-facing idle loading, movement toward back_right, and attack toward front_left. Broader visual QA should still review curved/multi-segment paths and enemy default facing behavior.
