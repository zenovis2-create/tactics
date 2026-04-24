# Split Marker Post Runtime Family Candidate V01

## Purpose

This document evaluates whether
[split_marker_post_01](/Volumes/AI/tactics/assets/props/split_marker_post_01/spec.md)
should become the next live runtime family after:

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

- `route_marker`

This should not be treated as a generic signpost family.

It should be treated as a divided-route guidance family.

## Why It Is Potentially Distinct

Current live families already cover:

- sacred witness or ritual pressure
- machinery or route-state control
- archive truth and keeper mediation
- civic warning
- terminal release

`route_marker` would cover something different:

- route commitment
- split-line guidance
- pursuit-lane reading before or during engagement

In short:

- `gate_control` = system control
- `latch` = release-state control
- `route_marker` = route-reading guidance

If that distinction cannot survive in UI and stage logic, this family should not
open.

## Main Constraint

This family must stay narrower than a general navigation prop system.

Allowed meaning:

- divided route guidance
- pursuit-line direction
- split-path commitment

Disallowed drift:

- generic trail sign
- generic village signpost
- broad chapter decoration

## Why It Is Not Yet Stronger Than `keeper_lectern`

`route_marker` still has weaker current proof than `keeper_lectern`.

Reasons:

1. the strongest live CH08 control object is still
   [ch08_05_transfer_gate_latch.tres](/Volumes/AI/tactics/data/objects/ch08_05_transfer_gate_latch.tres)
   rather than a route-marker object
2. many post-like props in the lane are still context-heavy support surfaces
3. route markers risk repetition faster than control objects

That means `route_marker` is still a good candidate, but not the first one.

## Best First Wiring Target

The safest first authored object is likely:

- [ch08_01_east_signal_post.tres](/Volumes/AI/tactics/data/objects/ch08_01_east_signal_post.tres)

Why:

- it most naturally reads as route guidance
- it is less likely to collapse into `lever` or `gate_control`
- it gives CH08 a visible split-line guidance point without borrowing latch
  semantics

## Secondary Candidates

Possible later extensions:

- [ch08_01_west_hound_sign.tres](/Volumes/AI/tactics/data/objects/ch08_01_west_hound_sign.tres)
- [ch08_02_ambush_marker.tres](/Volumes/AI/tactics/data/objects/ch08_02_ambush_marker.tres)
- [ch07_01_market_route_board.tres](/Volumes/AI/tactics/data/objects/ch07_01_market_route_board.tres)

These should remain second-wave only.

Reason:

- some drift toward ambush warning rather than route guidance
- some drift toward chapter flavor or city signage rather than split-line logic

## Main Risk

The main risk is that the family becomes decorative rather than systemic.

That happens if:

- the object does not change route reading
- the object survives only as flavor signage
- the object overlaps with latch or gate-control interactions

## UI Surface Survivability

This candidate is interesting because it could survive:

1. battle marker use
2. stage-authored data
3. selective briefing or codex support

But it is weaker than current live families on dossier-grade meaning.

That is acceptable if the route-reading contract is real enough.

## Suggested Validation Path

If opened, validate in this order:

1. add `route_marker` to
   [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a dedicated visual contract to
   [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. convert one CH08 route-guidance object first
4. extend
   [interaction_object_routing_runner.gd](/Volumes/AI/tactics/scripts/dev/interaction_object_routing_runner.gd)
5. validate through a CH08-specific runner, most likely:
   - [ch08_production_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_production_runner.gd)
   - or a dedicated split-line route runner

## Recommended Decision

Do not open `route_marker` before `keeper_lectern`.

After `keeper_lectern`, it remains the strongest remaining candidate because it
still offers a distinct route-reading contract.

If the family cannot stay tied to divided-route guidance:

- do not open it
- keep `split_marker_post_01` as art, briefing, or chapter support material only

## Working Conclusion

`split_marker_post_01` remains a valid wave-3 candidate, but its value depends
entirely on proving that route guidance is a real reusable interaction grammar
rather than just a recurring landmark shape.
