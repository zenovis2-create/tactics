# Runner Shutdown Warning Follow-up V01

## Purpose

This document narrows the next follow-up actions for runner shutdown warnings.

It does not fix the issue.

It records:

1. which runners are affected
2. what the most plausible cleanup candidates are
3. what to try first before deeper investigation

## Reviewed Runners

Current known cases:

- [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)
- [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd)

Observed warning class:

- `ObjectDB instances leaked at exit`
- `resources still in use at exit`

## Reproduction Status

Current working assumption:

- the warnings are reproducible enough to track
- they appear after a `PASS` result, not during failed validation
- they are tied to shutdown cleanup, not to objective logic correctness

This is enough for engineering follow-up even without a deeper root-cause claim.

## First Cleanup Candidates

### 1. `battle.queue_free()` lifecycle drain

Both reviewed runners currently do:

- `battle.queue_free()`
- `await process_frame`

That is the first cleanup candidate.

Reason:

- one frame may not be enough for the entire spawned battle scene tree to finish
  releasing before the SceneTree exits

Low-risk follow-up:

- test whether an additional `await process_frame` or a short cleanup loop
  reduces the warning

### 2. Repeated scene instantiation without explicit tree drain

Both runners create multiple battle scenes in sequence.

Reason:

- even if each case individually passes, the cumulative release timing may lag
  behind the runner exit

Low-risk follow-up:

- add a consistent post-case cleanup step before the next stage case begins

### 3. Cached resources surviving past runner exit

Possible source:

- runtime icon or scene-level caches that stay valid through the process exit

Reason:

- the warnings mention resources still in use at exit, which can happen even
  when gameplay objects are already functionally gone

Low-risk follow-up:

- check whether the warnings remain after more aggressive scene-tree drain
- inspect caches only if the warning still remains after that

## What Not To Assume Yet

Do not assume yet that:

- the warnings are battle-logic regressions
- the warnings invalidate current runtime-family evidence
- the warnings require a large refactor

The current evidence supports a smaller first pass.

## Recommended Follow-up Order

1. try stronger scene-tree drain after `queue_free()`
2. rerun the affected runners
3. only then inspect cache ownership or deeper object lifetime issues

## Result Of First Cleanup Attempt

The first low-risk cleanup attempt has now been tried.

Applied change:

- both reviewed runners were updated to perform one extra `await process_frame`
  after `battle.queue_free()`

Observed result:

- functional validation still passed
- shutdown warnings still remained

Observed warnings after the extra drain pass:

- [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)
  - `ObjectDB instances leaked at exit`
  - `21 resources still in use at exit`
- [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd)
  - `ObjectDB instances leaked at exit`
  - `22 resources still in use at exit`

Interpretation:

- simple extra frame drain is not sufficient by itself
- the next investigation step should move beyond the shallow cleanup hypothesis

## Updated Next Step

The next reasonable follow-up is:

1. inspect repeated battle-scene lifetime more directly
2. inspect cache or resource ownership if the lifetime path looks clean
3. continue treating the warnings as non-blocking unless they spread into
   non-test flows

## Additional Clues From Code Search

Two useful clues now exist.

### 1. Repeated battle-scene churn is common in the affected test style

The reviewed runners instantiate and free battle scenes repeatedly in one
SceneTree session.

That pattern also appears in other larger runners such as:

- [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd)
- [ch09b_revision_runner.gd](/Volumes/AI/tactics/scripts/dev/ch09b_revision_runner.gd)
- [ch08_production_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_production_runner.gd)

Interpretation:

- the issue may be cumulative scene lifetime churn rather than a single bad
  stage case

### 2. Battle-side caches exist in several runtime systems

Relevant cache owners include:

- [battle_art_catalog.gd](/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd)
- [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
- [battle_board.gd](/Volumes/AI/tactics/scripts/battle/battle_board.gd)
- [battle_controller.gd](/Volumes/AI/tactics/scripts/battle/battle_controller.gd)
- [telegraph_texture_library.gd](/Volumes/AI/tactics/scripts/battle/telegraph_texture_library.gd)

Interpretation:

- if scene-tree drain is not the only cause, resource lifetime may be prolonged
  by these caches until process exit

## Result Of Battle Lifetime Debug Pass

A dedicated lifetime debug runner has now been executed:

- [battle_scene_lifetime_debug_runner.gd](/Volumes/AI/tactics/scripts/dev/battle_scene_lifetime_debug_runner.gd)

What it checked:

- repeated `BattleScene` instantiation
- repeated `queue_free()` cleanup
- whether battle-like nodes remained attached to the root after cleanup

Observed result:

- root child count returned to `0` after each test case
- no lingering battle-like root nodes remained after cleanup
- the runner ended with:
  - `[PASS] battle_scene_lifetime_debug_runner found no lingering battle-like root nodes after cleanup.`

Interpretation:

- the simplest root-level battle lifetime leak hypothesis is now weaker
- the next suspect should shift toward deeper child/resource lifetime or cache
  ownership rather than root-level scene persistence

## Result Of Cache Debug Pass

A dedicated cache debug runner has now been executed:

- [battle_cache_debug_runner.gd](/Volumes/AI/tactics/scripts/dev/battle_cache_debug_runner.gd)

What it checked:

- static cache size in
  [battle_art_catalog.gd](/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd)
- static cache size in
  [telegraph_texture_library.gd](/Volumes/AI/tactics/scripts/battle/telegraph_texture_library.gd)
- per-battle cache size in
  [battle_board.gd](/Volumes/AI/tactics/scripts/battle/battle_board.gd)
- per-battle FX cache size in
  [battle_controller.gd](/Volumes/AI/tactics/scripts/battle/battle_controller.gd)

Observed result:

- initial static caches:
  - `battle_art = 0`
  - `telegraph = 0`
- after `CH07_01`:
  - `battle_art = 68`
  - `telegraph = 0`
  - `board_icons = 1`
  - `board_cards = 2`
  - `controller_fx = 0`
- after cleanup:
  - `battle_art` remained populated
- after `CH08_01`:
  - `battle_art = 69`
  - `telegraph = 0`
  - `board_icons = 1`
  - `board_cards = 2`
  - `controller_fx = 0`

Interpretation:

- `battle_art_catalog.gd` static cache is confirmed to persist across repeated
  battle-scene churn
- `telegraph_texture_library.gd` did not contribute in this narrow pass
- board-local caches exist during each battle instance, but this pass does not
  show them persisting after cleanup
- `battle_art_catalog.gd` is now the strongest concrete suspect among the
  currently observed cache owners

## Result Of BattleArtCatalog Cache Reset Experiment

A runner-only cache reset experiment has now been tried.

Applied change:

- [battle_art_catalog.gd](/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd)
  gained `clear_cache()`
- the reset was called only from:
  - [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)
  - [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd)

Observed result:

- functional validation still passed
- shutdown warnings still remained
- observed warning counts did not materially improve:
  - `ch07_procession_control_runner.gd` -> `21 resources still in use at exit`
  - `ch08_route_pressure_runner.gd` -> `22 resources still in use at exit`

Interpretation:

- `BattleArtCatalog` cache persistence is real
- but clearing that cache alone is not sufficient to remove the shutdown
  warnings
- `BattleArtCatalog` is therefore not proven as the sole cause

Practical takeaway:

- keep the reset experiment scoped to runners only
- shift the main investigation target toward deeper child/resource lifetime
  and/or additional cache owners

## Result Of Child Lifetime Debug Pass

A dedicated child-lifetime debug runner has now been executed:

- [battle_child_lifetime_debug_runner.gd](/Volumes/AI/tactics/scripts/dev/battle_child_lifetime_debug_runner.gd)

What it checked:

- a single battle scene instance
- root battle node validity after `queue_free()`
- representative child/service references after `queue_free()`
  - `BattleBoard`
  - `BattleHUD`
  - `status_service`
  - `telemetry_service`
  - `reward_service`
  - `cutscene_player`
  - `bond_service`

Observed result:

- before cleanup, all tracked references were valid
- after one frame:
  - battle root invalid
  - tracked child/service references invalid
  - root child count returned to `0`
- after two frames:
  - state remained clean

Interpretation:

- the simple deeper child/service lifetime hypothesis is now weaker
- the cleanup path appears to invalidate the direct battle-owned references
  correctly in this narrow pass
- that leaves non-battle-root resource ownership and broader cache behavior as
  stronger remaining suspects

## Result Of BattleBoard Cache Lifetime Debug Pass

A dedicated board-cache lifetime runner has now been executed:

- [battle_board_cache_lifetime_debug_runner.gd](/Volumes/AI/tactics/scripts/dev/battle_board_cache_lifetime_debug_runner.gd)

What it checked:

- `BattleBoard` validity before cleanup
- `BattleBoard` tile cache sizes before cleanup
- `BattleBoard` validity after `queue_free()`

Observed result:

- before cleanup:
  - `board_valid = true`
  - `tile_icons = 1`
  - `tile_cards = 2`
- after one frame:
  - `board_valid = false`
  - `root_children = 0`
- after two frames:
  - state remained clean

Interpretation:

- the `BattleBoard` node itself is not persisting across cleanup in this narrow
  pass
- its local cache ownership does not currently look like the strongest suspect
- the investigation should now move further outward toward HUD-owned or broader
  resource ownership patterns

## Result Of BattleHUD Lifetime Debug Pass

A dedicated HUD lifetime runner has now been executed:

- [battle_hud_lifetime_debug_runner.gd](/Volumes/AI/tactics/scripts/dev/battle_hud_lifetime_debug_runner.gd)

What it checked:

- `BattleHUD` validity before cleanup
- `BattleHUD` validity after `queue_free()`
- result-surface snapshot presence before cleanup

Observed result:

- before cleanup:
  - `hud_valid = true`
  - result surface snapshot existed in default state
- after one frame:
  - `hud_valid = false`
  - `root_children = 0`
- after two frames:
  - state remained clean

Interpretation:

- the `BattleHUD` node itself is not persisting across cleanup in this narrow
  pass
- direct HUD ownership is therefore weaker as a primary suspect
- the warning source is now more likely to involve broader resource ownership
  outside the immediately freed scene nodes

## Additional Narrowing: Audio Routers Are Lower Priority

The two reviewed warning cases:

- [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)
- [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd)

instantiate only:

- [BattleScene.tscn](/Volumes/AI/tactics/scenes/battle/BattleScene.tscn)

They do not instantiate:

- [Main.tscn](/Volumes/AI/tactics/scenes/Main.tscn)

This matters because the audio routers are attached to:

- [Main.tscn](/Volumes/AI/tactics/scenes/Main.tscn)
  - `AudioEventRouter`
  - `BgmRouter`

Interpretation:

- audio-router stream caches are currently weaker suspects for these specific
  shutdown warnings
- they should stay below battle-side static/resource ownership in the next
  investigation order

## Narrowed Investigation Order

The next pass should now be:

1. inspect broader non-battle-root resource ownership patterns
2. inspect remaining static or singleton-style cache owners beyond the current
   narrow suspects
3. postpone broader cleanup work unless one of those two paths produces a
   concrete lead

## Working Conclusion

The next reasonable cleanup pass is small and targeted:

- root-level battle lifetime is not the strongest suspect anymore
- direct battle child/service lifetime is not the strongest suspect anymore
- direct HUD ownership is not the strongest suspect anymore
- treat broader non-battle-root resource ownership as the first suspect
- treat remaining static or singleton-style caches as the second suspect
- keep `AudioEventRouter` and `BgmRouter` below the current top suspects for
  the reviewed runner pair
- do not escalate into broader runtime cleanup work until those two paths are checked
