# Layered Enemy Preview Review V02

## Scope

Review targets:

- `Enemy Raider`
- `Enemy Skirmisher`

Reference board:

- `/Volumes/AI/tactics/docs/generated/roster_layered_preview_board_v02_enemy_corrected.png`

## Verdict

The correction pass improved `Enemy Skirmisher`, but `Enemy Raider` is still not
ready to promote as the hostile melee baseline.

## Findings

### 1. `Enemy Raider` still fails the melee-baseline read

The lane still reads too close to:

- `crossbow-wall`
- `defender-machine`
- `mobile barricade`

instead of:

- `hostile melee pressure`
- `rigid authority infantry`

Main problem:

- the current composite still carries too much front-dominant weapon mass
- armor and weapon together remain too wide and too heavy
- the silhouette is still solving itself with machinery-like gear instead of
  compact infantry threat

Required next correction:

- redo `weapon_overlay` again
- likely demote current `weapon_overlay v02` to reference-only if the next pass
  succeeds
- keep `upper_armor_overlay v02` only if the new weapon read stops fighting it

### 2. `Enemy Skirmisher` improved materially

The lane is now much closer to the intended read:

- hostile agile pursuit hunter
- disciplined hostile cloth coverage
- less rogue/brawler-coded than the previous pass

Remaining risk:

- upper silhouette is still close to becoming too armored if future passes add
  more mass

Current judgment:

- usable as the current best enemy-skirmisher baseline candidate

## Immediate Rule Changes

### `Enemy Raider`

Keep for now:

- `anchor`
- `base_body`
- `base_outfit`
- `upper_armor_overlay v02`

Redo next:

- `weapon_overlay`

Target:

- compact sword-led hostile infantry
- no ranged-machine read
- no barricade-front silhouette

### `Enemy Skirmisher`

Keep as current best set:

- `base_outfit v02_disciplined`
- `weapon_overlay v02_clean`
- `upper_armor_overlay v02_light`

No immediate redo is required unless a later roster-wide pass shows drift.

## Working Conclusion

The enemy correction pass is only half-closed.

Next correct move:

1. redo only `Enemy Raider weapon_overlay`
2. regenerate `Enemy Raider` composite preview
3. rebuild the roster board
4. verify whether `Raider` now reads as hostile melee infantry rather than
   defender-machine mass
