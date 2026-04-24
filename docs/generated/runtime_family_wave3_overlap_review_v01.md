# Runtime Family Wave 3 Overlap Review V01

## Purpose

This document compares the current wave-3 runtime family candidates by overlap
risk rather than by raw chapter flavor.

It exists to answer three questions:

1. which candidate adds the cleanest new contract
2. which candidate overlaps most with existing live families
3. which candidate should open next if only one slot is available

## Current Live Runtime Families

- `well`
- `battery`
- `shrine`
- `floodgate`
- `evidence`
- `bell`
- `chain_control`
- `keeper_lectern`

## Wave 3 Candidates Under Review

1. `split_marker_post_01` -> `route_marker`
2. `transfer_gate_latch_01` -> `latch`
3. `city_seal_dais_01` -> `civic_seal`
4. `bell_dais_01` -> `final_toll_anchor`

## Review Axes

Each candidate is evaluated on four axes:

1. runtime proof
2. UI separation
3. non-battle surface survivability
4. overlap risk with live families

## Candidate Matrix

| Candidate | Runtime proof | UI separation | Non-battle survivability | Main overlap risk | Working result |
| --- | --- | --- | --- | --- | --- |
| `route_marker` | Medium | High | Medium | `gate_control`, `latch` | Strong but still needs clearer proof |
| `latch` | High | Medium | Low-Medium | `lever`, `gate_control` | Strong contract, weaker surface separation |
| `civic_seal` | Medium | Medium | High | `bell`, `evidence` | Valuable later, but overlap still muddy |
| `final_toll_anchor` | Medium | Low | Low-Medium | `bell`, `chain_control` | Too close to current CH10 live families |

## Candidate Notes

### `route_marker`

Strength:

- adds a route-reading grammar that no live family fully owns

Weakness:

- still lacks one dominant stage-side proof object as strong as current control
  objects

Main overlap:

- can drift toward `gate_control` if it starts behaving like route machinery
- can drift toward `latch` if it starts standing for route release rather than
  route guidance

### `latch`

Strength:

- has the strongest proven runtime contract among the remaining candidates
- CH08 already demonstrates objective-state, choke-release, and boss-behavior
  change through the latch

Weakness:

- weaker dossier or codex value than other candidates

Main overlap:

- can collapse into `lever` if treated as any small local mechanism
- can collapse into `gate_control` if treated as any route-opening object

### `civic_seal`

Strength:

- stronger records-facing and authority-facing value than many remaining props

Weakness:

- does not yet have as strong a runtime proof chain as `latch`

Main overlap:

- can collapse into `bell` if treated as civic-pressure ritual
- can collapse into `evidence` if treated as authority-bearing record object

### `final_toll_anchor`

Strength:

- strong endgame identity

Weakness:

- current endgame family set already covers most of its value

Main overlap:

- can collapse into `bell` if treated as final ritual pressure
- can collapse into `chain_control` if treated as terminal control anchor

## Ranked Overlap Outcome

From cleanest to muddiest:

1. `route_marker`
2. `latch`
3. `civic_seal`
4. `final_toll_anchor`

This is not the same as runtime-proof strength.

From strongest runtime-proof to weakest:

1. `latch`
2. `route_marker`
3. `civic_seal`
4. `final_toll_anchor`

## Working Interpretation

If the next step values cleaner category separation:

- prefer `route_marker`

If the next step values stronger existing stage proof:

- prefer `latch`

If the next step values records-facing chapter identity:

- consider `civic_seal`, but only after the first two

`final_toll_anchor` should stay art-first for now.

## Recommended Next Move

After `keeper_lectern`, the next opening depends on goal:

1. choose `route_marker` for cleaner grammar expansion
2. choose `latch` for stronger existing gameplay proof

Default recommendation:

- choose `latch` only if the project wants a mechanics-first wave
- otherwise choose `route_marker`

## Working Conclusion

Wave 3 no longer needs more candidates.

It needs a clear choice between:

- cleaner new grammar: `route_marker`
- stronger existing proof: `latch`

Everything else should wait.
