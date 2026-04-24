# Runtime Family Wave 3 Execution Order V01

## Purpose

This document fixes the practical execution order for remaining wave-3 runtime
family candidates after `keeper_lectern` became live.

It exists because candidate priority and overlap review are no longer enough.

The project now needs an explicit order of operations.

## Current Live Runtime Families

- `well`
- `battery`
- `shrine`
- `floodgate`
- `evidence`
- `bell`
- `chain_control`
- `keeper_lectern`

## Remaining Wave 3 Candidates

- `latch`
- `civic_seal`
- `final_toll_anchor`

## Fixed Execution Order

### 1. `latch`

Why first now:

- it has the strongest remaining stage proof
- `route_marker` is already live
- it is now the next most actionable mechanics-backed family

Working target:

- `transfer_gate_latch_01`

### 2. `civic_seal`

Why third:

- it has meaningful records-facing value
- but still overlaps with both `bell` and `evidence`
- it should wait until the guidance-vs-control branch is settled first

Working target:

- `city_seal_dais_01`

### Hold: `final_toll_anchor`

Why hold:

- current CH10 live families already cover most of its useful runtime meaning
- it is still too close to `bell` and `chain_control`
- it is better treated as a stage-specific landmark unless a second endgame
  control grammar becomes necessary

Working target:

- `bell_dais_01`

## Decision Logic

Use this order unless one of these becomes true:

1. a stage demands stronger release-state formalization immediately
2. a route-marker implementation fails to prove reusable gameplay value
3. a civic-seal surface becomes necessary for records UI ahead of runtime use

If none of those conditions happen, do not reorder the wave.

## Working Summary

Wave 3 should now proceed as:

1. `latch`
2. `civic_seal`

And it should leave:

- `final_toll_anchor`

as art-first and stage-specific for now.

## Immediate Follow-up

The next useful step is:

1. convert `latch` from candidate spec into actual runtime family wiring
2. only revisit `final_toll_anchor` if `civic_seal` proves too muddy
