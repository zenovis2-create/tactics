# Resin Shrine Runtime Family Candidate V01

## Purpose

This document defines the next-step design for promoting `resin_shrine_01` from:

- promoted icon

to:

- actual runtime object family candidate

It does not wire the family yet.
It explains the safest route to do so.

## Why This Candidate Exists

`resin_shrine_01` is currently one of the strongest chapter-local landmark icons in the project:

- it already has a promoted production icon
- it has a clear chapter identity
- it reads distinctly from `altar_01`

However, it does not yet have a stable typed gameplay contract in runtime.

That is the next question to solve.

## Current Runtime Reality

Today, CH03 still reuses existing families:

- trail markers and residue often still route through `altar`
- snare points route through `lever`

That is acceptable for the current slice,
but it hides the difference between:

- sacred / memory object
- hidden ritual landmark
- suspicious trap device

## Candidate Runtime Meaning

If `resin_shrine_01` becomes a true runtime family, it should mean:

- a hidden ritual landmark
- a forest witness or memory anchor
- a non-altar sacred pressure point

It should **not** mean:

- generic sacred objective
- local machine trigger
- route-state engineering

## Best Initial Family Role

Recommended first runtime role:

- `shrine`

Why:

- short, stable name
- matches current chapter language
- separates from `altar`
- reusable for CH03 now and potentially CH07 / CH09B variants later if needed

## Best First Wiring Targets

If this family is wired, the safest first target should be:

1. `ch03_01_west_trail_marker`
2. `ch03_01_east_trail_marker`

Reason:

- they already form a paired investigation objective
- they are currently typed as `altar`
- their chapter role is closer to route-reading shrine markers than to full altar logic

## Second-Wave Targets

Only after the first pair works:

- `ch03_03_wildfire_residue`

Why later:

- it may still read more like clue residue than shrine
- its final family fit should depend on whether CH03 uses a second residue-like landmark later

## What Must Change When Wiring

When this moves from candidate to real runtime family:

1. add `shrine` to [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a `shrine` visual contract to [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. point the contract at `resin_shrine.png`
4. update one real CH03 object pair to `object_type = "shrine"`
5. add or extend a runner to verify:
   - icon resolves
   - objective flow still works
   - `shrine` does not collapse into `altar`

## Risks

### Risk 1. Family Overlap

`shrine` could collapse into `altar` if:

- the icon and marker colors are too similar
- the object staging still reads as a tabletop altar

### Risk 2. Over-Generalization

If `shrine` becomes “all sacred things that are not altars,” the family will get muddy quickly.

Keep the role narrow:

- hidden ritual / local witness / chapter-specific sacred marker

### Risk 3. Premature Breadth

Do not immediately retag CH07 or CH09B objects to `shrine`.

Prove it first in CH03.

## Recommended Validation

Add a focused CH03 runner or extend an existing one to validate:

- object count unchanged
- objective texts unchanged
- resolved interactions still win the stage
- the shrine icon resolves separately from altar

## Working Conclusion

`resin_shrine_01` is the strongest next runtime family candidate after `well` and `battery`.

But it should move in two steps:

1. approve the `shrine` family role in writing
2. wire only the paired CH03 trail-marker stage objects first

That is the safest way to add the family without widening sacred-object semantics too early.
