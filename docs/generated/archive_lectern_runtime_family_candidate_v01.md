# Archive Lectern Runtime Family Candidate V01

## Purpose

This document evaluates whether
[archive_lectern_01](/Volumes/AI/tactics/assets/props/archive_lectern_01/spec.md)
should become the next live runtime family after:

- `well`
- `battery`
- `shrine`
- `floodgate`
- `evidence`
- `bell`
- `chain_control`

## Working Recommendation

Recommended family name:

- `keeper_lectern`

This should not be treated as a second `evidence` surface.

It should be treated as a keeper-side archive control surface.

## Why It Is Still Distinct From `evidence`

`evidence` already covers:

- archive witness authority
- truth-bearing control
- seal-bound proof or exposure

`keeper_lectern` should cover:

- archive mediation
- guided revision access
- keeper-side stabilization or handling

In short:

- `evidence` = truth-bearing archive authority
- `keeper_lectern` = keeper-operated archive guidance and control

If that distinction cannot be maintained, this family should not open.

## Best First Wiring Target

The safest first authored object is:

- [ch09b_05_archive_lectern.tres](/Volumes/AI/tactics/data/objects/ch09b_05_archive_lectern.tres)

Why:

- it already reads as a single clear control object
- it has explicit interaction and reward text
- it sits in late-game archive logic where keeper mediation is already legible

## Secondary Candidates

Possible later extensions:

- [ch09b_03_east_keeper_record.tres](/Volumes/AI/tactics/data/objects/ch09b_03_east_keeper_record.tres)
- [hunt_saria_choir_lectern.tres](/Volumes/AI/tactics/data/objects/hunt_saria_choir_lectern.tres)

These should remain second-wave only.

Reason:

- `ch09b_03_east_keeper_record` is close to record/evidence semantics
- `hunt_saria_choir_lectern` may drift toward ritual or choir-specific flavor

## Why It Ranks First In Wave 3

1. it still opens a new readable contract
2. it has a plausible non-battle UI surface in codex / records views
3. it is already tied to late-game authored stage logic
4. it expands CH09B without collapsing into generic sacred or machine grammar

## Main Risk

The main risk is overlap with `evidence`.

That overlap happens if the lectern is framed as:

- proof
- seal
- witness authority
- truth exposure

It must instead be framed as:

- keeper mediation
- archive handling
- controlled access
- revision guidance

## UI Surface Survivability

This candidate is strong because it can plausibly survive all three layers:

1. battle marker
2. stage-authored data
3. codex / dossier or records surface

It is weaker on briefing UI, which is acceptable.

The family does not need to be a first-wave briefing surface to be worthwhile.

## Suggested Validation Path

If opened, validate in this order:

1. add `keeper_lectern` to
   [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a dedicated visual contract to
   [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. convert
   [ch09b_05_archive_lectern.tres](/Volumes/AI/tactics/data/objects/ch09b_05_archive_lectern.tres)
   first
4. extend
   [interaction_object_routing_runner.gd](/Volumes/AI/tactics/scripts/dev/interaction_object_routing_runner.gd)
5. validate against a CH09B stage runner, most likely
   [ch09b_revision_runner.gd](/Volumes/AI/tactics/scripts/dev/ch09b_revision_runner.gd)
   or a dedicated CH09B lectern runner

## Recommended Decision

If only one wave-3 family is opened next:

- open `keeper_lectern`

If the role cannot stay narrower than `evidence`:

- do not open it
- keep `archive_lectern_01` as art and dossier material only

## Working Conclusion

`archive_lectern_01` is the strongest remaining candidate because it can still
add a new runtime read without breaking the current UI surface separation rules.

That is true only if it remains a keeper-mediated archive-control family, not a
second evidence family.
