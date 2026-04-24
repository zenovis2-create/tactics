# Runtime UI Polish Slice Kickoff V01

## Purpose

This document starts the `runtime/UI polish` slice.

It exists to keep the next work focused on:

- presentation cleanup
- surface consistency
- family readability

and not on opening new runtime families by default.

## Starting State

The project currently has:

- cleared image-stage backlog
- ten live chapter-local runtime families
- first-pass usage expansion closed
- non-blocking shutdown warnings separated into an engineering-hygiene lane

That means the main job now is polish, not expansion.

## Primary Polish Targets

### 1. Briefing-first family presentation

Target families:

- `battery`
- `floodgate`
- `chain_control`

Why first:

- these are the clearest player-facing planning surfaces
- they already have authored usage
- improvements here have immediate readability value

### 2. Records evidence presentation

Target families:

- `evidence`
- `bell`

Why second:

- the records path now exists
- wording and surface consistency can be judged against a real destination

### 3. Selective live-family restraint

Target families:

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

Why third:

- these families should be kept clean by avoiding overuse
- polish here is mainly about restraint and consistency

## What This Slice Should Not Do

Do not use this slice to:

- open new runtime families by default
- restart pass 1 usage expansion
- fold shutdown warning work back into the main production lane

## Working Order

Use this order:

1. briefing-first surfaces
2. records evidence surfaces
3. selective-restraint review

## Companion References

- [live_runtime_family_summary_v01.md](/Volumes/AI/tactics/docs/generated/live_runtime_family_summary_v01.md)
- [live_runtime_family_review_checklist_v01.md](/Volumes/AI/tactics/docs/generated/live_runtime_family_review_checklist_v01.md)
- [art_runtime_handoff_executive_summary_v01.md](/Volumes/AI/tactics/docs/generated/art_runtime_handoff_executive_summary_v01.md)
- [post_pass1_next_slice_recommendation_v01.md](/Volumes/AI/tactics/docs/generated/post_pass1_next_slice_recommendation_v01.md)

## Working Conclusion

The current slice is now:

- `runtime/UI polish`

Its job is to make the existing live system read better, not to make the system larger.
