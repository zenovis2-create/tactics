# Fortress Edge Repetition Review V01

## Purpose

This review decides whether `fortress_edge_01` is already repeating too obviously across the current fortress-family surfaces.

It does not ask whether a second structural support surface would be nice.
It asks whether one is required now.

## Reviewed Surfaces

- [CH02FortressArtPreview.tscn](/Volumes/AI/tactics/scenes/dev/CH02FortressArtPreview.tscn)
- [CH06IronKeepPreview.tscn](/Volumes/AI/tactics/scenes/dev/CH06IronKeepPreview.tscn)
- [fortress_edge_support_decision_v01.md](/Volumes/AI/tactics/docs/fortress_edge_support_decision_v01.md)

## Review Result

`fortress_edge_01` is **not** repeating too obviously for the current implementation phase.

## Why

### 1. Usage Count Is Still Controlled

The edge surface appears in a small number of chapter-specific fortress contexts.
It is not yet a globally repeated board-edge treatment.

### 2. It Sits In Support Position

The edge surface is not the main read.
It acts as:

- parapet suggestion
- boundary reinforcement
- structural context cue

That means repetition pressure is much lower than it would be for a floor tile or central landmark.

### 3. Current Family Breadth Is Proportionate

The fortress family already contains:

- `fortress_tile_01`
- `fortress_tile_02`
- `fortress_edge_01`

That is enough for the current runtime slice.
Adding another structural support surface now would likely widen the family faster than actual chapter usage demands.

## Working Conclusion

Do **not** add a second fortress structural support surface yet.

The correct next step remains:

- use the current fortress family in real chapter contexts
- revisit repetition only if a new preview reveals obvious structural sameness

## Trigger For Reopening

Reopen this decision only if:

- a new fortified chapter surface makes the edge treatment feel copy-pasted
- a composition needs a taller vertical fortification language
- a mechanic requires a structurally distinct edge/read from the current parapet support
