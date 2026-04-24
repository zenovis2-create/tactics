# Layered Character Derivative Slice Close V01

## Scope

This slice covered:

- portrait derivatives
- token derivatives
- derivative QA and correction

Applies to:

- `Rian`
- `Serin`
- `Tia`
- `Bran`
- `Enemy Raider`
- `Enemy Skirmisher`

## Completed Outputs

For each lane, the current derivative baseline now exists as:

- `runtime/portraits/*_portrait_v02_single_view.png`
- `runtime/tokens/*_token_v02_single_view.png`

## Decision

This slice is now closed.

Reason:

- derivative outputs are no longer whole-sheet miniatures
- portrait and token outputs now derive from a single selected direction cell
- token outputs satisfy the current minimum `48x48` readability threshold
- remaining issues are cosmetic, not structural

## Current Preferred Baseline

Use:

- `*_portrait_v02_single_view.png`
- `*_token_v02_single_view.png`

Do not use:

- earlier `v01` derivative outputs as the preferred baseline

## Explicitly Not Included

This slice did not attempt:

- battle-state sheet generation
- runtime portrait wiring
- token-style over-polish
- class expansion beyond the current six lanes

## Next Recommended Slice

The next correct move is:

- `battle-state sheets from locked layered baselines`

Reason:

- the project now has stable enough layered baselines
- battle-ready production value will come from state coverage, not more static crops
- continuing to polish portraits/tokens now would produce diminishing returns
