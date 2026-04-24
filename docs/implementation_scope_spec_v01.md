# Implementation Scope Spec V01

## Purpose

This document defines the remaining implementation scope for the current Farland Tactics headless-first development lane.

It is not a design brainstorm.
It is an execution-facing specification that answers:

1. what is already complete
2. what is still required
3. what counts as done
4. what order should be followed

## Current Baseline

The project already has the following implementation layers in place:

### Headless Development

- headless boot validation
- runnable gate validation
- battle integration validation
- campaign/camp UI validation
- one-command art promotion validation through:
  - `/Volumes/AI/tactics/scripts/dev/headless_art_promotion_suite.sh`

### Character Runtime

- ally battle-art preference:
  - `Rian`
  - `Serin`
  - `Bran`
  - `Tia`
- hostile battle-art preference:
  - `Enemy Raider`
  - `Enemy Skirmisher`

### Environment Runtime

- global terrain baseline:
  - `forest`
- map-specific terrain family:
  - `fortress_tile_01`
  - `fortress_tile_02`
  - `fortress_edge_01`

### Interaction Object Runtime

- sacred family:
  - `altar_01`
- mechanical family:
  - `lever_01`
- route/system-control family:
  - `gate_control_01`

### Equipment Runtime

- `paladin_shield`
  - camp/interlude presentation
  - party/detail support
- `field_sword_01`
  - sword-class weapon preview
  - Rian camp/detail support

## Remaining Implementation Scope

The remaining work is now in maintenance mode.

The base implementation lane is already broad enough to support ongoing game development.
Remaining work should be driven by concrete gaps, not by default expansion pressure.

## Workstream A: Chapter-Specific Surface Expansion

### Goal

Expand validated art/runtime families into more chapter-context surfaces without breaking the headless suite.

### Still Needed

- review and use the current `CH03 / CH05 / CH07 / CH08` chapter surface set
- add another chapter surface only if this set still leaves a family underexercised

### Done Criteria

For each new chapter surface:

- one preview scene exists
- one preview runner exists
- the surface uses existing promoted families rather than inventing a new art language
- the full headless art promotion suite remains green

## Workstream B: Equipment Family Maturity

### Goal

Decide which equipment families stay as support surfaces and which need broader UI/runtime destinations.

### Still Needed

- keep `field_sword_01` at the current support level unless new evidence appears
- decide later whether `field_sword_01` needs more than:
  - weapon preview
  - camp/detail support
- decide whether `paladin_shield` needs a stronger battlefield/loadout destination
- decide the next equipment family after:
  - `shield`
  - `sword`

### Done Criteria

An equipment family is considered mature when:

- it has `source / clean / runtime`
- it has at least one real in-game destination
- it has at least one dedicated validation runner
- it does not rely on generic placeholder artifacts for its primary read

## Workstream C: Terrain Family Breadth

### Goal

Use the now-complete first-pass fortress family in real chapter contexts before adding more structural assets.

### Still Needed

- use the current fortress family in more chapter-specific surfaces
- defer any second fortress structural support asset until repeated chapter usage proves the need
- decide whether a third terrain family should be introduced after:
  - `forest`
  - `fortress`

### Done Criteria

A terrain family is considered broad enough when:

- it appears in more than one validated chapter surface
- it has internal variation
- it does not flatten character readability
- its next expansion is driven by chapter need, not asset hunger

## Workstream D: Interaction Object Family Coverage

### Goal

Exercise the now runtime-routed `altar / lever / gate_control` family across more than fortress and archive contexts.

### Still Needed

- review whether the current `CH05 / CH07 / CH08` set is enough for interaction-family coverage
- decide whether a fourth interaction family is actually needed

### Done Criteria

Interaction family coverage is sufficient when:

- family placement rules match actual runtime usage
- each family has at least one clear chapter-context proof point
- no family is still only “preview semantics” without runtime behavior support

## Workstream E: Runtime Slot Promotion Discipline

### Goal

Avoid uncontrolled promotion of assets into production slots.

### Rule

Do not promote a new runtime slot unless all are true:

- the family is already validated in preview
- the asset has a clear gameplay read
- a runner exists or is added
- the headless suite remains green after promotion

### Still Needed

- keep production `object_icons`, `tile_cards`, `tile_icons`, and equipment-facing surfaces consistent with the actual family rules

## Workstream F: Headless Safety

### Goal

Keep the project runnable from headless-first workflows as asset breadth increases.

### Still Needed

- keep `m3_ui_runner.gd` green
- keep `headless_art_promotion_suite.sh` green
- keep `headless_dev_smoke.sh` green
- prefer new narrow runners when adding new promoted surfaces

## Out of Scope For This Spec

These are not the next implementation priority:

- editor-only polish passes
- cinematic key art
- new Rhino beauty renders for their own sake
- massive environment overhauls without runtime destination
- adding new art families before existing ones are exercised

## Execution Priority

Follow this order unless a blocker forces a change:

1. keep the current runtime slice green
2. expand only if a concrete family or destination gap appears
3. review interaction, equipment, or terrain breadth only when evidence demands it
4. only then consider a new family

## Final Definition Of Done

The current implementation lane is complete when:

- the project has at least seven robust chapter-context preview surfaces across forest, archive, fortress, ritual-city, split-line, and late archive-depth contexts
- the interaction family is no longer fortress/archive-biased
- the equipment family has at least two stable in-game support destinations
- all headless validation entry points remain green
- new work can be scheduled from the checklist without re-deciding the whole pipeline

## Current Status

The current lane now satisfies the above definition.

That means the project should remain in maintenance mode until a concrete gap appears.
