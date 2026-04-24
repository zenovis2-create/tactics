# Truth Dais Runtime Family Candidate V01

## Purpose

This document defines the next-step design for promoting `truth_dais_01` from:

- promoted icon

to:

- actual runtime object family candidate

It does not wire the family yet.
It explains the safest route to do so.

## Why This Candidate Exists

`truth_dais_01` is currently one of the strongest chapter-local landmark icons in the project:

- it already has a promoted production icon
- it has a clear chapter identity
- it reads distinctly from both `altar_01` and `gate_control_01`

However, it does not yet have a dedicated typed gameplay contract in runtime.

That is the next question to solve.

## Current Runtime Reality

Today, CH05 still reuses existing families:

- the upper stack seal and similar archive truth points still route through `altar`
- local pressure valves still route through `lever`

That is acceptable for the current slice,
but it hides the difference between:

- sacred or witness object
- evidence-bearing truth anchor
- seal or pressure device

## Candidate Runtime Meaning

If `truth_dais_01` becomes a true runtime family, it should mean:

- evidence anchor
- truth-bearing station
- archive witness surface

It should **not** mean:

- generic sacred objective
- route-state machine
- local trigger

## Best Initial Family Role

Recommended first runtime role:

- `evidence`

Why:

- short and stable
- more precise than `truth`
- separates from `altar`
- can be reused for later archive, record, or witness landmarks without swallowing all sacred objects

## Best First Wiring Targets

If this family is wired, the safest first target should be:

1. `ch05_03_upper_stack_seal`

Reason:

- it already behaves like a chapter-defining archive truth control
- it is currently typed as `altar`
- its role is closer to evidence-bearing authority than to a generic sacred anchor

## Second-Wave Targets

Only after the first target works:

- selected CH09B witness-like archive objects

Why later:

- CH09B is already a deeper archive variation and should not be used to define the first contract
- prove the family in CH05 first

## What Must Change When Wiring

When this moves from candidate to real runtime family:

1. add `evidence` to [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add an `evidence` visual contract to [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. point the contract at `truth_dais.png`
4. update one real CH05 object to `object_type = "evidence"`
5. extend a runner to verify:
   - icon resolves
   - objective flow still works
   - `evidence` does not collapse into `altar`

## Risks

### Risk 1. Family Overlap

`evidence` could collapse into `altar` if:

- the icon stays too much like a sacred shrine
- the visual contract uses the same emphasis cues as altar

### Risk 2. Over-Generalization

If `evidence` becomes “all important archive props,” the family will get muddy quickly.

Keep the role narrow:

- truth-bearing or witness-bearing archive focal objects

### Risk 3. Premature Breadth

Do not immediately retype every archive item or shelf to `evidence`.

Prove the family first on one clearly legible anchor.

## Recommended Validation

The safest validation path is:

- extend [ch05_archive_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch05_archive_pressure_runner.gd)

Expected checks:

- object count unchanged
- objective texts unchanged
- resolved interactions still win the stage
- the chosen evidence object resolves a distinct icon from `altar`

## Working Conclusion

`truth_dais_01` is the strongest next runtime family candidate after `well`, `battery`, `shrine`, and `floodgate`.

But it should move in two steps:

1. approve the `evidence` family role in writing
2. wire only one real CH05 truth-bearing object first

That is the safest way to add the family without widening sacred or archive semantics too early.
