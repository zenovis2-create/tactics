# Anchor Chain Runtime Family Candidate V01

## Purpose

This document defines the next-step design for promoting `anchor_chain_01` from:

- promoted icon

to:

- actual runtime object family candidate

It does not wire the family yet.
It explains the safest route to do so.

## Why This Candidate Exists

`anchor_chain_01` is currently one of the strongest unwired chapter-local landmark icons in the project:

- it already has a promoted production icon
- it has a clear chapter identity
- it reads distinctly from `gate_control_01` and `altar_01`

However, it does not yet have a dedicated typed gameplay contract in runtime.

That is the next question to solve.

## Current Runtime Reality

Today, CH10 still reuses existing families:

- `ch10_05_anchor_chain` still routes through `gate_control`
- the end-state landmark split exists in art, but not yet in typed runtime logic

That is acceptable for the current slice,
but it hides the difference between:

- generic route-state machinery
- terminal bell-line suppression
- last-route reopening under endgame pressure

## Candidate Runtime Meaning

If `anchor_chain_01` becomes a true runtime family, it should mean:

- bell-line suppression device
- terminal route-reopening control
- final restraint-release landmark

It should **not** mean:

- generic route-state machine
- ordinary gate control
- sacred witness object

## Best Initial Family Role

Recommended first runtime role:

- `chain_control`

Why:

- explicit and stage-appropriate
- separates from `gate_control`
- matches the current late-game rule-object intent closely
- can stay narrow enough to avoid swallowing every chain-related prop later

## Best First Wiring Targets

If this family is wired, the safest first target should be:

1. `ch10_05_anchor_chain`

Reason:

- it already has a direct gameplay contract
- it already exists as a named late-game control object
- its role is not ambiguous

## What Must Change When Wiring

When this moves from candidate to real runtime family:

1. add `chain_control` to [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a `chain_control` visual contract to [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. point the contract at `anchor_chain.png`
4. update `ch10_05_anchor_chain` to `object_type = "chain_control"`
5. extend or add a runner to verify:
   - icon resolves
   - objective flow still works
   - `chain_control` does not collapse into `gate_control`

## Risks

### Risk 1. Family Overlap

`chain_control` could collapse into `gate_control` if:

- the icon and silhouette still read mainly like a generic machine box
- the chain is not the first clear read at small scale

### Risk 2. Over-Generalization

If `chain_control` becomes “all chain-like mechanics,” the family will get muddy quickly.

Keep the role narrow:

- endgame bell-line suppression and terminal restraint-release

### Risk 3. Premature Breadth

Do not immediately retag every chain-lift or siege chain object to this family.

Prove it first in CH10.

## Recommended Validation

The safest validation path is:

- extend [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd)

Expected checks:

- the object still resolves and can be used at the intended boss phase
- the resulting objective-state flag remains correct
- the icon resolves separately from `gate_control`

## Working Conclusion

`anchor_chain_01` is the strongest next runtime family candidate after the current six live families.

But it should move in two steps:

1. approve the `chain_control` family role in writing
2. wire only `ch10_05_anchor_chain` first

That is the safest way to add the family without widening late-game machinery semantics too early.
