# Game Image Production Next Wave Plan

**Date:** 2026-04-23

## Objective

Execute the next image-production wave in this order:

1. player 8-direction bases
2. enemy 8-direction bases
3. battle-state expansion
4. object-family support tranche

## Phase A: Folder Setup Rules

For each character lane, standardize:

- `source/8dir/`
- `clean/8dir/`
- `runtime/8dir/`
- `runtime/portraits/`
- `runtime/tokens/`

Do not create a global shared directional folder.

Keep direction outputs inside the per-character lane.

## Phase B: Player 8-Direction Bases

### B1. `Rian`

- define direction sheet or per-view source set
- clean all four views
- export runtime four-view set
- update lane runtime note

### B2. `Serin`

- repeat the same structure

### B3. `Tia`

- repeat the same structure

### B4. `Bran`

- repeat the same structure

Current status:

- lane structure and 8dir runtime docs are prepared for:
  - `Rian`
  - `Serin`
  - `Tia`
  - `Bran`

## Phase C: Enemy 8-Direction Bases

### C1. `Enemy Raider`

- same output shape as ally lanes

### C2. `Enemy Skirmisher`

- same output shape as ally lanes

Current status:

- lane structure and 8dir runtime docs are prepared for:
  - `Enemy Raider`
  - `Enemy Skirmisher`

## Phase D: Battle-State Variant Expansion

Apply only after the eight-direction base is stable.

Per selected lane:

- `idle`
- `move`
- `attack`
- `hit`

Do not start with all states for all characters at once.

Recommended first state rollout:

1. `Rian`
2. `Enemy Raider`

## Phase E: Object-Family Support Images

Primary pass:

- `battery`
- `floodgate`
- `chain_control`
- `evidence`
- `bell`

Secondary pass:

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

## File Naming Rules

Per view:

- `<character>_front_source_v01.png`
- `<character>_back_source_v01.png`
- `<character>_left_source_v01.png`
- `<character>_right_source_v01.png`

- `<character>_front_clean_v01.png`
- `<character>_back_clean_v01.png`
- `<character>_left_clean_v01.png`
- `<character>_right_clean_v01.png`

- `<character>_front_runtime_v01.png`
- `<character>_back_runtime_v01.png`
- `<character>_left_runtime_v01.png`
- `<character>_right_runtime_v01.png`

Optional sheet:

- `<character>_8dir_sheet_source_v01.png`
- `<character>_8dir_sheet_clean_v01.png`

## Exit Criteria

### Exit A

Player 8-direction tranche complete.

Current checkpoint:

- folder and document structure complete
- image generation itself not started yet

### Exit B

Enemy 8-direction tranche complete.

Current checkpoint:

- folder and document structure complete
- image generation itself not started yet

### Exit C

At least two lanes have battle-state expansion on top of direction baseline.

## Notes

- treat this as a production plan, not a runtime-family plan
- use the existing style bible and character specs as the visual constraint set
- prefer consistency and readability over output volume
