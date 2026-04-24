# City Seal Dais Runtime Family Candidate V01

## Purpose

This document evaluates whether
[city_seal_dais_01](/Volumes/AI/tactics/assets/props/city_seal_dais_01/spec.md)
should become the next live runtime family after:

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

## Working Recommendation

Recommended family name:

- `civic_seal`

This should not be treated as:

- a second `bell` surface
- a second `evidence` surface

It should be treated as a civic-legitimacy and oath-state surface.

## Why It Is Potentially Distinct

Current nearby live families already cover:

- `bell` = civic warning and public ritual pressure
- `evidence` = archive truth and witness authority
- `keeper_lectern` = keeper-mediated archive handling

`civic_seal` would cover something else:

- civic legitimacy
- oath-state confirmation
- city authority made tangible through a seal object

In short:

- `bell` = public warning
- `evidence` = truth-bearing archive authority
- `civic_seal` = civic oath and legitimacy authority

If that distinction cannot survive, this family should not open.

## Best First Wiring Target

The safest first authored object is:

- [ch07_05_city_seal.tres](/Volumes/AI/tactics/data/objects/ch07_05_city_seal.tres)

Why:

- it already sits in a chapter-final civic context
- it has clearer authority and oath meaning than the noisier procession props
- it is the cleanest place to prove that seal-state is different from bell-state

## Secondary Candidates

Possible later extensions:

- [ch09a_02_oath_pike_post.tres](/Volumes/AI/tactics/data/objects/ch09a_02_oath_pike_post.tres)
- [ch09a_03_west_oath_roll.tres](/Volumes/AI/tactics/data/objects/ch09a_03_west_oath_roll.tres)
- [ch06_04_ceremonial_seal.tres](/Volumes/AI/tactics/data/objects/ch06_04_ceremonial_seal.tres)

These should remain second-wave only.

Reason:

- they drift toward oath proof, records, or ceremony before the civic-seal core
  meaning is proven

## Main Risk

The main risk is semantic collapse.

That happens if the family is framed as:

- a public warning object
- a truth-bearing record object
- a generic ritual prop

It must instead be framed as:

- a city authority token
- a legitimacy anchor
- a seal-state or oath-state control point

## UI Surface Survivability

This candidate is stronger in records and codex surfaces than in briefing UI.

It can plausibly survive:

1. battle marker use
2. stage-authored data
3. codex / dossier or records surfaces

It is weaker than `latch` on mechanics proof, but stronger than `latch` on
authority-facing non-battle UI value.

## Existing Proof Signals

The strongest current signals are:

- [ch07_05_stage.tres](/Volumes/AI/tactics/data/stages/ch07_05_stage.tres)
- [ch04_ch07_gimmick_runner.gd](/Volumes/AI/tactics/scripts/dev/ch04_ch07_gimmick_runner.gd)

These already show that CH07 city-seal interactions have real scenario meaning.

What is still missing is a dedicated runtime-family separation from `bell` and
`evidence`.

## Suggested Validation Path

If opened, validate in this order:

1. add `civic_seal` to
   [interactive_object_data.gd](/Volumes/AI/tactics/scripts/data/interactive_object_data.gd)
2. add a dedicated visual contract to
   [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)
3. convert
   [ch07_05_city_seal.tres](/Volumes/AI/tactics/data/objects/ch07_05_city_seal.tres)
   first
4. extend
   [interaction_object_routing_runner.gd](/Volumes/AI/tactics/scripts/dev/interaction_object_routing_runner.gd)
5. validate through
   [ch04_ch07_gimmick_runner.gd](/Volumes/AI/tactics/scripts/dev/ch04_ch07_gimmick_runner.gd)
   or a dedicated CH07 civic-seal runner

## Recommended Decision

Do not open `civic_seal` before `latch`.

After `latch`, it becomes the most valuable remaining candidate if the project
wants stronger records-facing and legitimacy-facing runtime grammar.

If the role cannot stay separate from `bell` and `evidence`:

- do not open it
- keep `city_seal_dais_01` as art, codex, and chapter-support material only

## Working Conclusion

`city_seal_dais_01` remains a valid next-step candidate because it may still add
a civic-legitimacy grammar not owned by any live family.

It should open only if that legitimacy read can stay cleaner than both public
warning and archive authority.
