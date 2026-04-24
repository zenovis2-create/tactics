# Selective Expansion Pass 2 Kickoff V01

## Purpose

This document starts `selective expansion pass 2`.

Pass 1 closed the highest-value authored usage gaps.

Pass 2 exists only to evaluate narrowly justified surface expansion for the
remaining live families.

## Families In Scope

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

## What Pass 2 Is Allowed To Do

Pass 2 may:

- expand one family into one additional justified surface
- refine one existing live usage if the family read is weak
- stop without changes if the expansion would blur family boundaries

## What Pass 2 Must Not Do

Pass 2 must not:

- open new runtime families by default
- force all five families into briefing or codex surfaces
- reopen already closed pass-1 gaps
- mix shutdown-warning work back into the production lane

## Preferred Order

1. `keeper_lectern`
2. `route_marker`
3. `latch`
4. `well`
5. `shrine`

## Why This Order

- `keeper_lectern` has the strongest records-facing expansion value
- `route_marker` has the cleanest conditional briefing value
- `latch` has real gameplay proof but higher overlap risk
- `well` and `shrine` are already stable and do not need automatic expansion

## Entry Criterion

Only continue with a family if all three hold:

1. the destination surface is concrete
2. the family read stays distinct from nearby families
3. the expansion improves comprehension more than it increases clutter

## Initial Recommendation

If one family is reviewed first in pass 2, start with:

- `keeper_lectern`

Specifically:

- review whether a records-facing surface beyond current stage routing is
  justified without collapsing into `evidence`

## Working Conclusion

`selective expansion pass 2` is now open.

Its default posture is restraint.
