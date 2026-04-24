# Runtime Object Family Expansion Policy V01

## Purpose

This document defines when a promoted landmark should become a real runtime object family.

It exists because the project now has two different kinds of progress:

- art promotion
- runtime family wiring

Those are not the same decision.

## Current Runtime Family Set

The current runtime object families are:

- `chest`
- `lever`
- `gate`
- `altar`
- `gate_control`
- `well`
- `battery`
- `shrine`
- `floodgate`
- `evidence`
- `bell`
- `chain_control`
- `keeper_lectern`
- `route_marker`
- `latch`

The first five were the original slice set.

The last ten are the chapter-local landmark families that have now crossed from art-only promotion into actual runtime typing.

## Current Evidence Standard

A new object family should be added only when all of these are true:

1. The icon already exists in the production path.
2. The gameplay meaning is stable across at least one real stage.
3. The silhouette is distinct enough that it should not be represented by an existing family.
4. There is an immediate validation path through a runner or stage shell.

If one of these is missing, do not add a new runtime family yet.

## Promotion Ladder

Use this order.

### 1. Art Candidate

The lane has:

- `source/`
- `clean/`
- `runtime/`

But it is still only a support artifact.

### 2. Production Icon

The landmark has:

- a promoted file under `/Volumes/AI/tactics/assets/ui/production/object_icons/`

At this stage it is visually accepted, but not yet a runtime family.

### 3. Runtime Family Candidate

The landmark has:

- a strong gameplay contract
- a specific stage or preview surface that clearly benefits

At this stage it should be reviewed for runtime typing.

### 4. Runtime Family

The landmark has:

- `InteractiveObjectData` enum support
- `InteractiveObjectActor` visual contract support
- at least one real stage object wired to the new family
- a passing runner or stage validation

Only this stage counts as true runtime family expansion.

## Approved Runtime Family Candidates

### Ready Now

- `memory_well_01`
- `battery_emplacement_01`
- `resin_shrine_01`
- `floodgate_wheel_01`
- `truth_dais_01`
- `bell_frame_01`
- `anchor_chain_01`
- `archive_lectern_01`
- `split_marker_post_01`
- `transfer_gate_latch_01`

Status:

- production icon promoted
- runtime family added
- stage or routing validation passed

### Hold

- all other chapter-local landmarks stay art-only until a concrete runtime need appears

## When To Reuse Existing Families

Prefer existing families when:

- the gameplay meaning is already covered
- the new landmark differs mainly by chapter flavor, not by interaction class
- the runtime benefit is low

Examples:

- a local trigger can remain `lever`
- a broad route-state machine can remain `gate_control`
- a sacred witness object can remain `altar`

Do not create a new family just because the art is different.

## When Not To Reuse Existing Families

Create a new family when reuse would hide a real gameplay distinction.

Examples:

- `well` is not just `altar`
  because CH01 investigation and memory-disturbance reading is materially different from sacred-objective reading

- `battery` is not just `lever`
  because CH06 battery-line control is a siege-pressure silhouette and not a local hand-operated device

- `shrine` is not just `altar`
  because CH03 trail-marker ritual reading is a hidden local witness grammar rather than a formal sacred-objective grammar

- `floodgate` is not just `gate_control`
  because CH04 sluice-wheel control is a water-state machine rather than a broad route-system controller

- `evidence` is not just `altar`
  because CH05 truth-bearing control is archive evidence authority rather than a generic sacred-objective anchor

- `bell` is not just `lever`
  because CH07 queue-bell control is a civic ritual pressure signal rather than a generic local release device

- `chain_control` is not just `gate_control`
  because CH10 anchor-chain control is terminal bell-line suppression rather than a broad route-state machine

- `keeper_lectern` is not just `evidence`
  because CH09B archive-lectern control is keeper-mediated archive handling rather than truth-bearing witness authority

- `route_marker` is not just `gate_control`
  because CH08 signal-post guidance narrows route reading rather than governing a machinery-driven route-state system

- `latch` is not just `gate_control`
  because CH08 transfer-gate relief opens a held path rather than governing a broad route-state system

- `latch` is not just `lever`
  because CH08 transfer-gate relief is blocked-path release rather than a generic local mechanism action

- `bell` is not just `lever`
  because CH07 queue-bell control is a civic ritual pressure signal rather than a generic local release device

## Validation Requirement

Never claim a new runtime family is live unless one of these has passed:

- a focused routing runner
- a stage-specific shell or objective runner

Current evidence:

- [interaction_object_routing_runner.gd](/Volumes/AI/tactics/scripts/dev/interaction_object_routing_runner.gd)
- [ch01_ruined_well_runner.gd](/Volumes/AI/tactics/scripts/dev/ch01_ruined_well_runner.gd)
- [ch06_line_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch06_line_control_runner.gd)
- [ch03_shrine_route_runner.gd](/Volumes/AI/tactics/scripts/dev/ch03_shrine_route_runner.gd)
- [ch04_flood_route_runner.gd](/Volumes/AI/tactics/scripts/dev/ch04_flood_route_runner.gd)
- [ch05_archive_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch05_archive_pressure_runner.gd)
- [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)
- [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd)
- [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd)

## Current Policy

Default policy from now on:

1. promote art first
2. promote icon second
3. add runtime family only when a stage contract clearly justifies it

That means chapter-local landmark growth is no longer blocked by runtime typing,
but runtime typing is also no longer granted automatically.

## Working Conclusion

The project now has enough evidence to stop treating runtime family expansion as experimental.

It should now be governed by a simple rule:

- `new family only when gameplay meaning and validation both exist`
