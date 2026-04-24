# Floodgate Wheel Runtime Family Candidate V01

## Purpose

This document defines the next-step design for promoting `floodgate_wheel_01` from:

- promoted icon

to:

- actual runtime object family candidate

It does not wire the family yet.
It explains the safest route to do so.

## Why This Candidate Exists

`floodgate_wheel_01` is currently one of the strongest chapter-local landmark icons in the project:

- it already has a promoted production icon
- it has a clear chapter identity
- it reads distinctly from both `altar_01` and `gate_control_01`

However, it does not yet have a dedicated typed gameplay contract in runtime.

That is the next question to solve.

## Current Runtime Reality

Today, CH04 still reuses existing families:

- the west and east sluice wheels are currently typed as `lever`
- reliquary seals still route through `altar`

That is acceptable for the current slice,
but it hides the difference between:

- local hand-operated trigger
- sacred object
- chapter-local water-control machine

## Candidate Runtime Meaning

If `floodgate_wheel_01` becomes a true runtime family, it should mean:

- water-control device
- flood-state or route-state controller
- sacred-machinery control point

It should **not** mean:

- generic local trigger
- broad route-control infrastructure
- sacred witness object

## Best Initial Family Role

Recommended first runtime role:

- `floodgate`

Why:

- short and explicit
- matches current chapter wording
- separates from `lever` and `gate_control`
- reusable for CH04 now and potentially later flood-control or water-state spaces if they appear

## Best First Wiring Targets

If this family is wired, the safest first target should be:

1. `ch04_03_west_sluice_wheel`
2. `ch04_03_east_sluice_wheel`

Reason:

- they already form a paired objective
- they are currently typed as `lever`
- their role is clearly flood-state control, not local trigger simplicity

## What Must Change When Wiring

When this moves from candidate to real runtime family:

1. add `floodgate` to [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a `floodgate` visual contract to [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. point the contract at `floodgate_wheel.png`
4. update the CH04 paired sluice wheels to `object_type = "floodgate"`
5. extend a runner to verify:
   - icon resolves
   - objective flow still works
   - `floodgate` does not collapse into `lever` or `gate_control`

## Risks

### Risk 1. Family Overlap

`floodgate` could collapse into `gate_control` if:

- the icon silhouette reads like a generic machine face instead of a wheel
- the marker colors become too close to route-control golds

### Risk 2. Over-Generalization

If `floodgate` becomes “all large water or machine controls,” it will get muddy quickly.

Keep the role narrow:

- water-control wheel / sluice / flood-state control

### Risk 3. Premature Breadth

Do not immediately retype unrelated sacred-machinery objects like purification basins.

Prove the water-control family first.

## Recommended Validation

The safest validation path is:

- extend [ch04_flood_route_runner.gd](/Volumes/AI/tactics/scripts/dev/ch04_flood_route_runner.gd)

Expected checks:

- object count unchanged
- objective texts unchanged
- resolved interactions still win the stage
- both sluice wheels resolve the `floodgate` family icon distinctly from `lever` and `gate_control`

## Working Conclusion

`floodgate_wheel_01` is the strongest next runtime family candidate after `well`, `battery`, and `shrine`.

But it should move in two steps:

1. approve the `floodgate` family role in writing
2. wire only the paired CH04 sluice wheels first

That is the safest way to add the family without widening sacred-machinery semantics too early.
