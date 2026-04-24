# Character Derivative QA Review V01

## Scope

Review board:

- `/Volumes/AI/tactics/docs/generated/character_derivative_qa_board_v02_single_view.png`

Targets:

- `Rian`
- `Serin`
- `Tia`
- `Bran`
- `Enemy Raider`
- `Enemy Skirmisher`

## Verdict

The derivative slice is now structurally acceptable.

The previous failure mode was removed:

- portraits and tokens are no longer whole-sheet miniatures
- both now derive from single-view crops

## Findings

### 1. Portrait derivation is now valid

Current portrait outputs read as single-character derivatives rather than
shrunk 8-direction sheets.

This is good enough to treat `v02_single_view` as the current portrait baseline.

### 2. Token derivation is now valid

Current token outputs are now actual single-character `48x48` derivatives.

They are not yet heavily polished, but they pass the minimum read test.

### 3. Remaining minor issues

- `Bran` token is shield-dominant, but still acceptable for the heavy lane
- `Serin` token is softer and lower-contrast than the others, but still
  readable
- some portrait crops retain a small amount of side-edge dead space; this is
  cosmetic, not blocking

## Current Promotion Guidance

Use these as the current derivative baseline:

- `*_portrait_v02_single_view.png`
- `*_token_v02_single_view.png`

Do not promote the earlier `v01` derivative outputs as the preferred baseline.

## Working Conclusion

The portrait/token derivative slice is complete enough to close.

Next correct move:

1. keep `v02_single_view` as the active derivative baseline
2. reflect this in handoff/summary
3. choose the next production slice deliberately
