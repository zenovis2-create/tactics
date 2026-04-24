# Live Runtime Family Review Checklist V01

## Purpose

This checklist turns the current live runtime family set into a practical review
surface.

It is meant for:

- art/runtime review passes
- handoff reviews
- regression spot-checks after new family additions

It is not a design document.

It is a review checklist.

## Current Live Runtime Families

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

## Review Gates

For each live family, verify:

1. production icon exists
2. stage anchor still routes correctly
3. family meaning is still distinct from nearby families
4. allowed UI surface scope still makes sense
5. no new review finding forces the family back into candidate status

## Family Checklist

### `well`

- [ ] production icon remains present and readable
- [ ] `CH01_03` routing still points to `well`
- [ ] still reads as investigation/memory disturbance, not generic `altar`
- [ ] no accidental drift into codex-first overuse

### `battery`

- [ ] production icon remains present and readable
- [ ] `CH06_02` routing still points to `battery`
- [ ] still reads as siege pressure / line control, not generic `lever`
- [ ] still valid as briefing-first family

### `shrine`

- [ ] production icon remains present and readable
- [ ] `CH03_01` routing still points to `shrine`
- [ ] still reads as hidden ritual / route-reading witness
- [ ] no collapse into generic `altar`

### `floodgate`

- [ ] production icon remains present and readable
- [ ] `CH04_03` routing still points to `floodgate`
- [ ] still reads as water-state control, not generic `gate_control`
- [ ] still valid as briefing-first family

### `evidence`

- [ ] production icon remains present and readable
- [ ] `CH05_03` routing still points to `evidence`
- [ ] still reads as archive truth / witness authority
- [ ] no collapse into `altar`
- [ ] still valid as codex-dossier-first family

### `bell`

- [ ] production icon remains present and readable
- [ ] `CH07_01` routing still points to `bell`
- [ ] still reads as civic warning / ritual pressure
- [ ] no collapse into `lever`
- [ ] still valid as codex-dossier-first family

### `chain_control`

- [ ] production icon remains present and readable
- [ ] `CH10_05` routing still points to `chain_control`
- [ ] still reads as terminal release / bell-line suppression
- [ ] no collapse into `gate_control`

### `keeper_lectern`

- [ ] production icon remains present and readable
- [ ] `CH09B_05` routing still points to `keeper_lectern`
- [ ] still reads as keeper-mediated archive handling
- [ ] no collapse into `evidence`

### `route_marker`

- [ ] production icon remains present and readable
- [ ] `CH08_01` routing still points to `route_marker`
- [ ] still reads as divided-route guidance
- [ ] no collapse into `gate_control`
- [ ] no collapse into `latch`

### `latch`

- [ ] production icon remains present and readable
- [ ] `CH08_05` routing still points to `latch`
- [ ] still reads as release-state gating / blocked-path relief
- [ ] no collapse into `lever`
- [ ] no collapse into `gate_control`

## Cross-Family Review Questions

- [ ] Do any two adjacent families now read too similarly at icon scale?
- [ ] Did any new UI surface use a family outside its intended scope?
- [ ] Did any stage anchor drift away from the family’s intended meaning?
- [ ] Did any newly added landmark weaken the distinction of an existing live family?

## Warning Note

Current runner shutdown warnings remain non-blocking.

That means:

- do not fail a family review only because of the current shutdown warning class
- treat shutdown warnings as a parallel engineering-hygiene lane

Companion references:

- [live_runtime_family_summary_v01.md](/Volumes/AI/tactics/docs/generated/live_runtime_family_summary_v01.md)
- [runtime_object_family_stage_usage_v01.md](/Volumes/AI/tactics/docs/generated/runtime_object_family_stage_usage_v01.md)
- [runtime_object_family_ui_surface_scope_v01.md](/Volumes/AI/tactics/docs/generated/runtime_object_family_ui_surface_scope_v01.md)
- [runner_shutdown_warning_followup_v01.md](/Volumes/AI/tactics/docs/generated/runner_shutdown_warning_followup_v01.md)

## Working Conclusion

The project now has enough live runtime families that review should be run
against the family set as a system, not as isolated one-off assets.
