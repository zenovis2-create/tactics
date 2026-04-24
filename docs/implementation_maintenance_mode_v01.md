# Implementation Maintenance Mode V01

## Decision

The current implementation lane is now in `maintenance mode`.

This means:

- the current runtime slice is broad enough to continue game development
- new art/runtime surfaces should not be added by default
- expansion now requires a concrete gap, not generic momentum

## Why This Decision Is Correct

The project already has:

- a green headless validation suite
- a green `m3_ui_runner`
- multiple chapter-context surfaces:
  - `CH02`
  - `CH03`
  - `CH04`
  - `CH05`
  - `CH06`
  - `CH07`
  - `CH08`
- a runtime-routed interaction family:
  - `altar`
  - `lever`
  - `gate_control`
- a live equipment family:
  - `paladin_shield`
  - `field_sword_01`

At this point, the main risk is no longer under-building.
It is uncontrolled widening of the art/runtime lane without a specific gameplay need.

## What Maintenance Mode Means

### Allowed

- keep the validation suite green
- repair regressions
- promote an existing asset if a real in-game destination is required
- add a new surface only if a specific family gap is identified

### Not Allowed By Default

- adding another chapter surface just because it is easy
- adding another fortress support surface without repetition evidence
- widening `field_sword_01` or `paladin_shield` without a real UI/runtime need
- introducing a fourth interaction family without proof that the current three are insufficient

## Reopen Conditions

Leave maintenance mode only if one of these becomes true:

1. a real chapter requires a family that is not currently exercised
2. a runtime surface cannot communicate a mechanic with the existing families
3. a new UI/runtime destination appears that current equipment surfaces do not cover
4. a repeated preview shows obvious family repetition or coverage collapse

## Working Rule

Until one of the reopen conditions appears:

- maintain
- verify
- only expand on evidence
