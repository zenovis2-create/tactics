# Runtime Object Icon Wiring Targets V01

## Purpose

This document decides which promoted landmark icons are ready for actual runtime object-icon wiring,
and which should remain promotion-only art surfaces for now.

It does not change runtime code by itself.
It defines the safest next candidates for expanding beyond the current object families:

- `altar`
- `lever`
- `gate_control`
- `chest`
- `gate`

## Current Runtime Constraint

The current runtime object system is still typed through:

- [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
- [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)

That means new production icons can exist without yet having:

- a new `object_type`
- a new runtime visual contract
- a new routed gameplay meaning

Promotion and wiring are different decisions.

## Decision Framework

Only wire a new landmark into runtime now if all of these are true:

1. it has a strong small-size icon read
2. its gameplay meaning is already known, not speculative
3. it does not ambiguously overlap with an existing object family
4. a real stage or preview surface would benefit immediately from direct routing

## Best Wiring Candidates Now

### 1. `memory_well_01`

Status:

- promoted art icon exists
- gameplay meaning is already stable

Why it is the safest next candidate:

- CH01 already uses the ruined well as a specific investigation trigger
- its meaning is unique enough that it does not collapse into altar or chest
- the icon silhouette is already readable

Recommended runtime role:

- new chapter-local investigation family or `well` family

Recommended use:

- CH01 investigation surfaces first

### 2. `battery_emplacement_01`

Status:

- promoted art icon exists
- chapter meaning is strong

Why it is a good second candidate:

- CH02 siege pressure depends on the battery being legible
- it is visually distinct from lever and gate-control
- it could later support artillery or danger-preview routing

Recommended runtime role:

- new `battery` or `artillery` family

Recommended use:

- CH02 / CH06 pressure surfaces

### 3. `resin_shrine_01`

Status:

- promoted art icon exists
- chapter meaning is stable

Why it is now approved:

- CH03 trail markers now have a dedicated shrine grammar
- the icon resolves separately from altar
- the chapter role is now narrow and proven enough to justify real typing

Recommended runtime role:

- `shrine`

Recommended use:

- CH03 route-reading shrine markers first

### 4. `floodgate_wheel_01`

Status:

- promoted art icon exists
- chapter meaning is stable

Why it is now approved:

- CH04 paired sluice wheels now have a dedicated flood-control grammar
- the icon resolves separately from lever and gate-control
- the chapter role is clearly water-state and route-state control

Recommended runtime role:

- `floodgate`

Recommended use:

- CH04 sluice wheel controls first

### 5. `truth_dais_01`

Status:

- promoted art icon exists
- chapter meaning is stable

Why it is now approved:

- CH05 archive pressure now routes a truth-bearing control through a dedicated family
- the icon resolves separately from altar
- the chapter role is clearly evidence and archive authority, not generic sacred-object use

Recommended runtime role:

- `evidence`

Recommended use:

- CH05 truth-bearing control points first

### 6. `bell_frame_01`

Status:

- promoted art icon exists
- chapter meaning is stable

Why it is now approved:

- CH07 queue bell now routes through a dedicated bell grammar
- the icon resolves separately from altar, lever, and gate-control
- the chapter role is clearly civic ritual pressure and public warning

Recommended runtime role:

- `bell`

Recommended use:

- CH07 queue-bell control points first

## Promote But Do Not Wire Yet

These are promoted object icons, but should remain art-only for now:

## Hold For Later

These should not be wired yet:

- `scavenged_cache_01`
- `evac_handcart_01`
- `banner_mast_01`
- `hunter_rig_01`
- `purification_basin_01`
- `seal_frame_01`
- `shield_wreck_01`
- `chain_lift_winch_01`
- `city_seal_dais_01`
- `transfer_gate_latch_01`
- `archive_lectern_01`
- `revision_core_01`
- `bell_dais_01`

Why:

- some need stronger gameplay contracts
- some are more context-heavy than a first-wave runtime family should be
- some are better treated as chapter landmarks than reusable object types

## Recommended Next Move

1. review the now-live `well`, `battery`, `shrine`, `floodgate`, `evidence`, `bell`, and `chain_control` families for broader stage use
2. decide which promoted icon should become the eighth typed landmark family
3. only then reopen lower-priority candidates

## Working Conclusion

The project is now beyond the question of whether chapter-local landmarks can be promoted.

The real question is:

- which promoted icons deserve full runtime family status

Current answer:

- `memory_well_01` is live
- `battery_emplacement_01` is live
- `resin_shrine_01` is live
- `floodgate_wheel_01` is live
- `truth_dais_01` is live
- `bell_frame_01` is live
- `anchor_chain_01` is live
- `archive_lectern_01` is live
- `split_marker_post_01` is live
- `transfer_gate_latch_01` is live
- the rest should remain promoted art surfaces until a stronger gameplay contract appears
