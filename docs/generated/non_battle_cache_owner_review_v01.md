# Non-Battle Cache Owner Review V01

## Purpose

This memo narrows which cache owners remain plausible suspects after:

- root-level battle lifetime looked clean
- direct battle child/service lifetime looked clean
- `BattleArtCatalog.clear_cache()` did not remove the shutdown warnings

The goal is not to prove a root cause.

It is to reduce the next debugging surface.

## Remaining Cache Owners Worth Attention

### 1. `battle_board.gd`

Reference:

- [battle_board.gd](/Volumes/AI/tactics/scripts/battle/battle_board.gd)

Relevant caches:

- `_tile_icon_cache`
- `_tile_card_cache`

Why it still matters:

- these caches are battle-instance-local
- they wrap textures loaded from `BattleArtCatalog`
- if cleanup ordering is unusual, board-held references may survive longer than
  expected during shutdown

Current evidence:

- cache debug showed these caches are populated during battle
- current debug passes do not yet prove their release timing relative to engine
  shutdown

### 2. `battle_controller.gd`

Reference:

- [battle_controller.gd](/Volumes/AI/tactics/scripts/battle/battle_controller.gd)

Relevant cache:

- `_fx_cache`

Why it still matters:

- it is battle-instance-local but owned by the controller
- the controller also owns many runtime service nodes
- even if `_fx_cache` was `0` in the narrow pass, this file still sits at a
  convergence point for resource lifetime

Current evidence:

- narrow cache debug did not show `_fx_cache` growth
- so it is not the strongest suspect, but still belongs to the ownership layer

### 3. `battle_hud.gd`

Reference:

- [battle_hud.gd](/Volumes/AI/tactics/scripts/battle/battle_hud.gd)

Why it still matters:

- HUD surfaces may retain text, dialog, or preview resources through popup or
  UI state
- this is not a classic texture cache, but it is still part of the non-battle
  resource-ownership layer once a battle ends

Current evidence:

- no direct cache growth evidence yet
- remains a secondary suspect only because it is one of the last layers still
  alive during result and telegraph flow

### 4. `telegraph_texture_library.gd`

Reference:

- [telegraph_texture_library.gd](/Volumes/AI/tactics/scripts/battle/telegraph_texture_library.gd)

Why it still matters:

- it is a static cache owner

Why it is weaker now:

- the narrow cache debug did not show any growth here
- this lowers its priority for the next pass

## Relative Suspicion Ranking

From strongest to weakest current non-`BattleArtCatalog` suspect:

1. `battle_board.gd`
2. `battle_hud.gd`
3. `battle_controller.gd`
4. `telegraph_texture_library.gd`

## Why `battle_board.gd` Is First

`battle_board.gd` is the best next target because:

- it definitely holds per-battle texture references
- it sits between battle teardown and cached texture consumption
- it is simple enough to inspect without pulling the whole battle stack apart

## Recommended Next Debug Pass

The next smallest useful experiment is:

1. inspect `battle_board.gd` cache state immediately before and after cleanup
2. verify whether its local caches empty naturally when the board goes invalid
3. only then inspect HUD-owned or controller-owned late references

## Working Conclusion

The current shutdown-warning investigation should now move to:

- `battle_board.gd` first

Everything else should remain secondary until the board-local ownership path is
either confirmed or ruled out.
