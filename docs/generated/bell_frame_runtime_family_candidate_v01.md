# Bell Frame Runtime Family Candidate V01

## Purpose

This document defines the next-step design for promoting `bell_frame_01` from:

- promoted icon

to:

- actual runtime object family candidate

It does not wire the family yet.
It explains the safest route to do so.

## Why This Candidate Exists

`bell_frame_01` is currently one of the strongest unwired chapter-local landmark icons in the project:

- it already has a promoted production icon
- it has a clear chapter identity
- it reads distinctly from `altar_01`, `lever_01`, and `gate_control_01`

However, it does not yet have a dedicated typed gameplay contract in runtime.

That is the next question to solve.

## Current Runtime Reality

Today, CH07 still reuses existing families:

- the queue bell still routes through `lever`
- the city seal anchor remains art-only

That is acceptable for the current slice,
but it hides the difference between:

- local hand-operated release
- civic ritual pressure
- public warning and procession control

## Candidate Runtime Meaning

If `bell_frame_01` becomes a true runtime family, it should mean:

- civic bell landmark
- public warning or pressure signal
- ritual-city processional control anchor

It should **not** mean:

- generic sacred objective
- local lever action
- broad route-state machine

## Best Initial Family Role

Recommended first runtime role:

- `bell`

Why:

- short and stable
- matches chapter language directly
- separates from altar and machine families
- likely reusable in CH07 now and later bell-pressure spaces if needed

## Best First Wiring Targets

If this family is wired, the safest first target should be:

1. `ch07_01_queue_bell`

Reason:

- it already has a concrete stage contract
- it is currently typed as `lever`
- its role is clearly a public bell pressure device, not a hand-operated machine in the usual sense

## Second-Wave Targets

Only after the first target works:

- other CH07 bell or sermon-pressure devices

Why later:

- they should only move once the initial civic-bell semantics are proven
- avoid widening the family until the first interaction slot is stable

## What Must Change When Wiring

When this moves from candidate to real runtime family:

1. add `bell` to [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a `bell` visual contract to [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. point the contract at `bell_frame.png`
4. update one real CH07 object to `object_type = "bell"`
5. extend or add a runner to verify:
   - icon resolves
   - objective flow still works
   - `bell` does not collapse into `altar` or `lever`

## Risks

### Risk 1. Family Overlap

`bell` could collapse into `altar` if:

- the frame still reads primarily as shrine architecture
- the marker/halo treatment is too sacred instead of civic

### Risk 2. Over-Generalization

If `bell` becomes “all ritual pressure objects,” the family will become muddy fast.

Keep the role narrow:

- public bell / sermon-pressure / civic warning object

### Risk 3. Premature Breadth

Do not immediately retag all city-seal or procession objects to `bell`.

Prove the family first on the queue-bell slot.

## Recommended Validation

The safest validation path is:

- extend [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)

Expected checks:

- object count unchanged
- objective texts unchanged
- resolved interactions still win the stage
- the queue-bell object resolves a distinct icon from `altar`, `lever`, and `gate_control`

## Working Conclusion

`bell_frame_01` is the strongest next runtime family candidate after the five live chapter-local families.

But it should move in two steps:

1. approve the `bell` family role in writing
2. wire only the queue-bell stage object first

That is the safest way to add the family without widening ritual-city semantics too early.
