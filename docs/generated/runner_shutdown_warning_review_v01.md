# Runner Shutdown Warning Review V01

## Purpose

This document records runner cases that currently pass their validation goals
but still emit shutdown warnings.

These warnings are not treated as current feature regressions.

They are treated as engineering-hygiene follow-up items.

## Current Status

Known pattern:

- runner exits with `PASS`
- Godot still prints shutdown warnings such as:
  - `ObjectDB instances leaked at exit`
  - `resources still in use at exit`

## Reviewed Runners

### 1. `ch07_procession_control_runner.gd`

Reference:

- [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)

Observed behavior:

- stage-objective validation passes
- interaction-driven victory flow passes
- shutdown warning has been observed after the pass condition

Current judgment:

- not a blocker for runtime-family validation
- keep as a follow-up hygiene issue

### 2. `ch08_route_pressure_runner.gd`

Reference:

- [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd)

Observed behavior:

- route-pressure validation passes
- `CH08_01` route-marker check passes
- Godot emits:
  - `ObjectDB instances leaked at exit`
  - `resources still in use at exit`

Current judgment:

- not a blocker for runtime-family validation
- keep as a follow-up hygiene issue

## What This Means

For current art/runtime promotion work:

- a `PASS` result still counts as functional evidence
- shutdown warnings should be tracked separately
- do not reclassify a validated family as failing only because of these current
  exit warnings

## Likely Cause Class

These warnings usually indicate one of these patterns:

1. scene instances or child nodes not fully freed before process exit
2. asynchronous cleanup not fully drained after `queue_free()`
3. cached resources still alive when the SceneTree exits

This document does not claim a root cause yet.

It only records that the issue exists.

## Recommended Follow-up Order

1. verify whether the warnings reproduce consistently
2. check whether additional `await process_frame` cleanup is enough
3. inspect scene-tree lifetime and cache ownership only if the warning becomes
   broader or starts affecting non-test flows

## Working Conclusion

Current shutdown warnings are:

- real
- worth tracking
- not current blockers for family promotion or validation evidence
