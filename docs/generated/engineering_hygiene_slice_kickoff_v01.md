# Engineering Hygiene Slice Kickoff V01

## Purpose

This document starts the `engineering hygiene` slice.

It exists to keep the next work focused on:

- shutdown warning investigation
- runner cleanup
- ownership and lifetime debugging

without mixing those tasks back into the main art/runtime production lane.

## Why This Slice Starts Now

The current production-oriented slices are already in a stable checkpoint:

- `usage expansion` pass 1 is closed
- `runtime/UI polish` is closed
- handoff and summary documents are current

That makes this the right time to move maintenance work into its own lane.

## Current Known Problem

Some validation runners still end with:

- `ObjectDB instances leaked at exit`
- `resources still in use at exit`

Current judgment:

- real
- tracked
- non-blocking

## Current Investigation State

Weaker suspects:

- root-level battle lifetime
- direct battle child/service lifetime
- `BattleArtCatalog` as a sole cause
- `BattleBoard` local cache ownership
- `BattleHUD` direct ownership

Stronger remaining suspects:

- broader non-battle-root resource ownership
- remaining static or singleton-style cache owners

## Current References

- [runner_shutdown_warning_review_v01.md](/Volumes/AI/tactics/docs/generated/runner_shutdown_warning_review_v01.md)
- [runner_shutdown_warning_followup_v01.md](/Volumes/AI/tactics/docs/generated/runner_shutdown_warning_followup_v01.md)
- [battle_art_catalog_cache_reset_review_v01.md](/Volumes/AI/tactics/docs/generated/battle_art_catalog_cache_reset_review_v01.md)
- [non_battle_cache_owner_review_v01.md](/Volumes/AI/tactics/docs/generated/non_battle_cache_owner_review_v01.md)

## Working Order

Use this order:

1. investigate remaining cache and ownership suspects
2. test the smallest viable cleanup experiments
3. keep any fix scoped to runners unless production evidence appears

## What This Slice Should Not Do

Do not use this slice to:

- open new runtime families
- expand art usage surfaces
- revise handoff documents unless the engineering findings materially change them

## Working Conclusion

The current slice is now:

- `engineering hygiene`

Its job is to make the validation lane cleaner without disturbing the current
production checkpoint.
