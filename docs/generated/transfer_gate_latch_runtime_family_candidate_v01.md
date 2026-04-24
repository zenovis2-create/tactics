# Transfer Gate Latch Runtime Family Candidate V01

## Purpose

This document evaluates whether
[transfer_gate_latch_01](/Volumes/AI/tactics/assets/props/transfer_gate_latch_01/spec.md)
should become a live runtime family after:

- `well`
- `battery`
- `shrine`
- `floodgate`
- `evidence`
- `bell`
- `chain_control`
- `keeper_lectern`

## Working Recommendation

Recommended family name:

- `latch`

This should not be treated as a generic switch family.

It should be treated as a release-state control family.

## Why It Is Potentially Distinct

Current nearby families already cover:

- `lever` = local hand-operated mechanism
- `gate_control` = broader route or system-state controller
- `route_marker` = route-reading guidance

`latch` would cover something narrower:

- blocked-lane release
- choke-point opening
- controlled passage relief

In short:

- `lever` = operate a mechanism
- `gate_control` = govern a route system
- `latch` = release a held path

If that distinction cannot survive, this family should not open.

## Why The Contract Is Strong

The strongest current evidence is already real stage logic:

- [ch08_05_transfer_gate_latch.tres](/Volumes/AI/tactics/data/objects/ch08_05_transfer_gate_latch.tres)
- [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd)

The object already proves:

1. it sets a dedicated control flag
2. it opens pursuit choke cells
3. it rewrites objective state and objective text
4. it changes boss pressure timing

That is stronger runtime evidence than most remaining candidates.

## Best First Wiring Target

The safest first authored object is:

- [ch08_05_transfer_gate_latch.tres](/Volumes/AI/tactics/data/objects/ch08_05_transfer_gate_latch.tres)

Why:

- it already anchors a complete relief contract
- it already has runner-backed validation
- it naturally reads as release-state control, not as broad machinery

## Secondary Candidates

Possible later extensions:

- [hunt_lete_gate_latch.tres](/Volumes/AI/tactics/data/objects/hunt_lete_gate_latch.tres)
- [ch10_01_east_lift_latch.tres](/Volumes/AI/tactics/data/objects/ch10_01_east_lift_latch.tres)
- [ch06_05_barricade_latch.tres](/Volumes/AI/tactics/data/objects/ch06_05_barricade_latch.tres)

These should remain second-wave only.

Reason:

- each one needs to prove the same release-state grammar rather than just
  sharing the word `latch`

## Main Risk

The main risk is overlap with `lever` and `gate_control`.

That overlap happens if the family is framed as:

- any local mechanism
- any route-state machine
- any interaction that opens movement

It must instead be framed as:

- release-state gating
- opened choke relief
- controlled unsealing of a blocked path

## UI Surface Survivability

This candidate can plausibly survive:

1. battle marker use
2. stage-authored data
3. selective briefing use

It is weaker on dossier or codex value, which is acceptable.

`latch` does not need strong archive-facing meaning to be useful.

## Suggested Validation Path

If opened, validate in this order:

1. add `latch` to
   [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a dedicated visual contract to
   [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. convert
   [ch08_05_transfer_gate_latch.tres](/Volumes/AI/tactics/data/objects/ch08_05_transfer_gate_latch.tres)
   first
4. extend
   [interaction_object_routing_runner.gd](/Volumes/AI/tactics/scripts/dev/interaction_object_routing_runner.gd)
5. validate through
   [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd)

## Recommended Decision

This is a stronger runtime-proof candidate than `route_marker`,
but a weaker UI-separation candidate than `keeper_lectern`.

That means:

- do not open it before `keeper_lectern`
- consider it immediately after `keeper_lectern` if the project wants a more
  interaction-heavy wave instead of a guidance-heavy wave

## Working Conclusion

`transfer_gate_latch_01` remains one of the strongest remaining candidates
because the release-state contract is already real.

It should only open if the team wants to formalize `blocked-path relief` as a
reusable interaction grammar rather than leaving it under `gate_control`.
