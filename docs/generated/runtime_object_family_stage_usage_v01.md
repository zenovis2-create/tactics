# Runtime Object Family Stage Usage V01

## Purpose

This document records where the currently live chapter-local runtime object families are actually used.

It exists to answer three questions quickly:

1. which families are live
2. which concrete stage objects use them
3. which stages provide current validation evidence

It is a usage matrix, not a design document.

## Live Runtime Families

Current live chapter-local runtime families:

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

These sit on top of the older base runtime families:

- `chest`
- `lever`
- `gate`
- `altar`
- `gate_control`

## Stage Usage Matrix

| Family | Current object ids | Stage coverage | Validation evidence |
| --- | --- | --- | --- |
| `well` | `ch01_03_ruined_well` | `CH01_03` | [ch01_ruined_well_runner.gd](/Volumes/AI/tactics/scripts/dev/ch01_ruined_well_runner.gd) |
| `battery` | `ch06_02_west_battery_winch`, `ch06_02_east_battery_winch` | `CH06_02` | [ch06_line_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch06_line_control_runner.gd) |
| `shrine` | `ch03_01_west_trail_marker`, `ch03_01_east_trail_marker` | `CH03_01` | [ch03_shrine_route_runner.gd](/Volumes/AI/tactics/scripts/dev/ch03_shrine_route_runner.gd) |
| `floodgate` | `ch04_03_west_sluice_wheel`, `ch04_03_east_sluice_wheel` | `CH04_03` | [ch04_flood_route_runner.gd](/Volumes/AI/tactics/scripts/dev/ch04_flood_route_runner.gd) |
| `evidence` | `ch05_03_upper_stack_seal` | `CH05_03` | [ch05_archive_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch05_archive_pressure_runner.gd) |
| `bell` | `ch07_01_queue_bell` | `CH07_01` | [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd) |
| `chain_control` | `ch10_05_anchor_chain` | `CH10_05` | [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd) |
| `keeper_lectern` | `ch09b_05_archive_lectern` | `CH09B_05` | [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd) |
| `route_marker` | `ch08_01_east_signal_post` | `CH08_01` | [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd) |
| `latch` | `ch08_05_transfer_gate_latch` | `CH08_05` | [lategame_boss_pattern_runner.gd](/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd) |

## Family Notes

### `well`

- Chapter meaning: investigation and memory disturbance
- Why it matters: separates chapter-local survey logic from `altar`

### `battery`

- Chapter meaning: siege pressure and battery-line control
- Why it matters: separates artillery-line machinery from `lever`

### `shrine`

- Chapter meaning: hidden ritual and route-reading witness marker
- Why it matters: separates local sacred pressure from `altar`

### `floodgate`

- Chapter meaning: water-state control and route stabilization
- Why it matters: separates CH04 sluice-wheel control from `lever` and `gate_control`

### `evidence`

- Chapter meaning: truth-bearing archive control and witness logic
- Why it matters: separates archive evidence priority from `altar`

### `bell`

- Chapter meaning: civic ritual pressure and public warning
- Why it matters: separates CH07 queue-bell logic from `lever` and `altar`

### `chain_control`

- Chapter meaning: terminal release and bell-line suppression
- Why it matters: separates CH10 endgame control from generic `gate_control`

### `keeper_lectern`

- Chapter meaning: keeper-mediated archive guidance and controlled access
- Why it matters: separates CH09B keeper-side archive handling from `evidence` truth-bearing authority

### `route_marker`

- Chapter meaning: divided-route guidance and split-path commitment
- Why it matters: separates CH08 route-reading pressure from `gate_control` machinery and `latch` release-state control

### `latch`

- Chapter meaning: release-state gating and blocked-path relief
- Why it matters: separates CH08 choke-release control from `lever` local mechanism and `gate_control` system-state control

## What Is Still Not Live

Promoted icons that are still not runtime families:

- `memory_well_01` sibling chapter props beyond the first CH01 well slot
- `battery_emplacement_01` as a separate battery-emplacement object family
- `truth_dais_01` itself as a named object family distinct from `evidence`
- all remaining chapter-local landmark icons outside the five families above

This is acceptable.

The matrix is meant to show current real usage, not theoretical readiness.

## Working Conclusion

The project now has a real runtime-family bridge between chapter-local art and authored stage logic.

Current live coverage is enough to support:

- investigation-style interaction
- siege-line control
- hidden ritual route reading
- flood-state control
- archive evidence control
- civic warning / ritual-city pressure
- terminal bell-line release and endgame control
- keeper-mediated archive handling and stabilization
- route-reading guidance and split-path narrowing
- release-state gating and blocked-path relief

The next family should be opened only if it adds a clearly different gameplay contract, not just more art variety.
