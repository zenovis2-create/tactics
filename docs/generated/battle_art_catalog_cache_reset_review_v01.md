# Battle Art Catalog Cache Reset Review V01

## Purpose

This memo evaluates whether a runner-safe cache reset is appropriate for
[battle_art_catalog.gd](/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd).

It does not add the reset yet.

It records whether adding a test-only or runner-safe reset is technically
reasonable.

## Current Finding

The cache debug pass showed:

- [battle_cache_debug_runner.gd](/Volumes/AI/tactics/scripts/dev/battle_cache_debug_runner.gd)
- `BattleArtCatalog._cache` grows during repeated battle-scene churn
- the cache remains populated after battle cleanup

Current observed sizes in the narrow test:

- initial: `0`
- after `CH07_01`: `68`
- after `CH08_01`: `69`

That makes `BattleArtCatalog._cache` the strongest current cache suspect.

## What The Cache Stores

`BattleArtCatalog` caches file-backed runtime assets such as:

- object icons
- button icons
- tile icons
- tile cards
- FX textures
- character token art
- character sprite frames

These are loaded from disk and recreated on demand.

This matters because:

- the cache is a performance optimization
- it is not the authoritative source of truth

## Why A Runner-Safe Reset Looks Technically Reasonable

### 1. Cache entries are derived, not authored state

The cache contains loaded textures and frame arrays.

It does not appear to hold:

- battle-progress state
- unit state
- stage flags
- progression state

That makes reset lower-risk than clearing gameplay-owned data.

### 2. The catalog already behaves like a pure loader

The public API is effectively:

- request asset
- load if missing
- return cached texture or frames

This means that after a cache clear, callers should simply repopulate the cache
on next access.

### 3. The likely use case is runner hygiene, not runtime behavior change

The strongest current argument for reset is:

- test-process cleanup
- repeated runner churn
- narrower debugging

The strongest current argument against reset is not correctness.

It is only whether the reset is introduced in the wrong place.

## Constraints

If a reset is added, it should follow these rules:

1. do not call it implicitly during normal battle flow
2. do not call it from production game logic by default
3. prefer explicit runner-side use
4. keep the reset local to battle-art cache only unless evidence broadens

## Recommended Shape

If implemented, the smallest acceptable API would be something like:

- `BattleArtCatalog.clear_cache()`

And it should be used only from:

- debug runners
- cleanup experiments
- possibly dedicated QA harnesses

It should not be wired into:

- `_ready()`
- `bootstrap_battle()`
- normal phase transitions

without stronger evidence.

## Remaining Unknown

This memo does not prove that clearing `BattleArtCatalog._cache` will remove the
shutdown warnings.

It only shows that:

- adding a test-only reset appears technically safe enough to try

The remaining unknown is whether:

- static texture references in other systems still keep the resources alive

## Recommendation

Current recommendation:

- `safe to test in runners`

Not yet recommended:

- `safe to enable globally`

## Working Conclusion

The project does not yet have evidence for a production-wide cache-reset change.

But it does have enough evidence to justify a runner-safe `BattleArtCatalog`
cache clear experiment.
