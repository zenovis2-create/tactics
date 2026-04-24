# Maintenance Validation Snapshot 2026-04-21

## Purpose

This snapshot records the current maintenance-mode validation state after the headless-first visual/runtime lane reached phase-complete status.

Use this file as the comparison point for future regressions.

## Validation Status

### Core Maintenance Gates

- `headless_art_promotion_suite.sh`: PASS
- `headless_dev_smoke.sh`: PASS
- `m3_ui_runner.gd`: PASS

This means both:

- the narrow art/runtime promotion lane
- the broader core development smoke lane

are green at the same time.

## What This Confirms

The current repo baseline supports:

- headless boot and runnable-gate safety
- campaign shell flow
- camp/interlude UI shell
- battle integration asset loading
- promoted character, terrain, interaction-object, and equipment surfaces

## Active Runtime Slice

### Character

- `Rian`
- `Serin`
- `Bran`
- `Tia`
- `Enemy Raider`
- `Enemy Skirmisher`

### Terrain

- `forest`
- `fortress_tile_01`
- `fortress_tile_02`
- `fortress_edge_01`

### Interaction Objects

- `altar_01`
- `lever_01`
- `gate_control_01`

### Equipment

- `paladin_shield`
- `field_sword_01`

## Working Rule

If a future change breaks either:

- `headless_art_promotion_suite.sh`
- `headless_dev_smoke.sh`

then the repo should be treated as out of maintenance baseline until the regression is fixed.
